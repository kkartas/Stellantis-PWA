# Architecture

> How the Stellantis mobile app is layered, how data flows, and how work is
> scheduled across isolates and the background. This document is the map; the
> code under [`mobile/lib/`](../mobile/lib) is the territory.

---

## 1. One-paragraph summary

A single Flutter app talks **directly** to the Stellantis cloud — OAuth2 over
the system browser, REST over a persistent HTTP/2 Dio client, and remote
commands over MQTTS. There is no backend. Every screen paints from a local
**Isar** cache instantly and refreshes from the network in the background
(stale-while-revalidate). Secrets live in the app binary per brand flavor;
tokens live in the platform keystore. State is **Riverpod**; routing is
**go_router**; theming is brand-adaptive and resolved at runtime from the
account response.

---

## 2. Layers

The code is organised in four concentric rings. Dependencies point **inward
only** — `features/` may import `stellantis/` and `core/`, but never the
reverse.

```
┌─────────────────────────────────────────────────────────────┐
│  features/            UI + per-feature controllers (Riverpod) │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │  stellantis/        The Python port: auth, api, mqtt,      │ │
│  │                     analytics, storage, brands             │ │
│  │  ┌───────────────────────────────────────────────────────┐ │ │
│  │  │  core/            network, storage primitives, ui kit,  │ │ │
│  │  │                   perf, logging, error boundary         │ │ │
│  │  │  ┌────────────────────────────────────────────────────┐ │ │ │
│  │  │  │  theme/         BrandTheme tokens + brand detector   │ │ │ │
│  │  │  └────────────────────────────────────────────────────┘ │ │ │
│  │  └───────────────────────────────────────────────────────┘ │ │
│  └──────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

| Directory | Responsibility | Key types |
|---|---|---|
| [`mobile/lib/app/`](../mobile/lib/app) | Bootstrap: `MaterialApp.router`, theme injection, router. | `StellantisApp`, `routerProvider` |
| [`mobile/lib/core/`](../mobile/lib/core) | Cross-cutting primitives with no Stellantis knowledge. | `AppLogger`, `GlassCard`, `Skeleton`, `mapErrorToStateView`, `jsonIsolate` |
| [`mobile/lib/stellantis/`](../mobile/lib/stellantis) | The Python port. Screen-free, unit-tested. | `OAuthService`, `OtpService`, `MqttClientService`, `TripParser`, `ChargingParser`, repositories |
| [`mobile/lib/theme/`](../mobile/lib/theme) | Brand design tokens + runtime detection. | `BrandTheme`, `brandThemeProvider`, `BrandDetector` |
| [`mobile/lib/features/`](../mobile/lib/features) | One folder per screen group; UI + its controllers. | `dashboard`, `trips`, `charging`, `stats`, `settings`, … |

`stellantis/` is the durable core — it is what survives if the UI is ever
rewritten. It carries no `BuildContext` and imports no Flutter widgets so it
stays unit-testable without a widget binding.

---

## 3. Data flow — stale-while-revalidate

Every read is served twice: once from cache (instant), once from the network
(authoritative). Screens subscribe to a repository `Stream<T>`; the repository
emits the cached value immediately, fires a network refresh, persists the
result to Isar, and emits again.

```
 Widget (ConsumerWidget)
   │  ref.watch(statusStreamProvider(vin))
   ▼
 Repository  ── emit cached snapshot ──────────────► Widget paints instantly
   │
   ├─ kick off network refresh (Dio, HTTP/2)
   │     │
   │     ▼
   │   Stellantis REST  ── JSON ──► compute() isolate parse (payloads > 8 KB)
   │     │                              │
   │     ▼                              ▼
   └─ write fresh snapshot to Isar ──► repository re-emits ──► Widget repaints
```

- **Cache** — [`stellantis/storage/`](../mobile/lib/stellantis/storage): Isar
  schemas (`Vehicle`, `StatusSnapshot`, `Trip`, `Charge`, `Soh`, `Alert`,
  `Maintenance`) + SWR repositories.
- **TTL / invalidation** —
  [`cache_policy.dart`](../mobile/lib/stellantis/storage/cache_policy.dart)
  decides when a cached row is too stale to skip the network call.
- **Force refresh** — pull-to-refresh maps to the MQTT **wake-up** command,
  not a plain GET; default reads always take the cached fast path.

---

## 4. Threading & isolates

Flutter is single-threaded per isolate. We keep the UI isolate free of two
things: large JSON parses and background polling.

| Work | Where it runs | Entry point |
|---|---|---|
| UI, animation, gesture | Root (UI) isolate | — |
| JSON parse > 8 KB | `compute()` worker isolate | [`core/perf/json_isolate.dart`](../mobile/lib/core/perf/json_isolate.dart) |
| Isar reads/writes | Isar's own async pool (off the UI thread) | `app_database.dart` |
| Periodic refresh (app backgrounded) | OS-scheduled worker | [`stellantis/background/refresh_worker.dart`](../mobile/lib/stellantis/background/refresh_worker.dart) |

The background worker (`workmanager`) wakes ~every 30 min, refreshes status,
runs the [`state_change_detector`](../mobile/lib/stellantis/notifications/state_change_detector.dart),
and posts a local notification on transitions (charge complete, low battery,
door left open). No FCM/APNs server is involved — notifications are local.

---

## 5. Networking

- **Dio**, one persistent client per session
  ([`stellantis/network/psa_http_client.dart`](../mobile/lib/stellantis/network/psa_http_client.dart)),
  HTTP/2 with keep-alive so there is a single TLS handshake per session.
- **Token refresh** is a Dio interceptor
  ([`token_refresh_interceptor.dart`](../mobile/lib/stellantis/auth/token_refresh_interceptor.dart)):
  on a 401 it refreshes the OAuth token once and replays the request.
- **MQTT** ([`stellantis/mqtt/`](../mobile/lib/stellantis/mqtt)) over MQTTS to
  the same broker the official apps use; commands are built and signed with
  credentials derived during OTP setup.

See [STELLANTIS_API.md](STELLANTIS_API.md) for the endpoint surface and quirks.

---

## 6. State management

- **Riverpod 2** with codegen. Providers live next to the feature that owns
  them (`features/<x>/data/`). Cross-feature shared state (`brandThemeProvider`,
  session, selected vehicle) lives in `theme/` or `stellantis/`.
- Controllers are `AsyncNotifier`/`Notifier`; screens `ref.watch` and render
  `AsyncValue` with the shared
  [`state_views.dart`](../mobile/lib/core/ui/state_views.dart) for
  loading/error/offline/empty.
- **Optimistic UI** for commands
  ([`dashboard/data/quick_action_controller.dart`](../mobile/lib/features/dashboard/data/quick_action_controller.dart)):
  the toggle flips immediately and reverts if the command fails.

---

## 7. Theming

`BrandTheme` ([`theme/brand_theme.dart`](../mobile/lib/theme/brand_theme.dart))
is an immutable token set (palette, typography, motion curves, logo, hero
asset) per brand. `brandThemeProvider` holds the active one;
[`brand_detector.dart`](../mobile/lib/theme/brand_detector.dart) picks it from
the account/vehicle response, and the user can override it in settings. All 13
Stellantis brands are registered in `BrandTheme.perBrand`. Both light and dark
`ThemeData` are derived from `ColorScheme.fromSeed` with explicit token
overrides. See [BRANDS.md](BRANDS.md).

---

## 8. Error handling

- A top-level `FlutterError.onError` + `PlatformDispatcher.onError` in
  [`main.dart`](../mobile/lib/main.dart) funnel uncaught errors to `AppLogger`.
- An [`error_boundary.dart`](../mobile/lib/core/error/error_boundary.dart)
  widget contains render-time exceptions to a recoverable surface.
- Network failures are classified by
  [`mapErrorToStateView`](../mobile/lib/core/ui/state_views.dart): transient
  connectivity errors land on the offline view (with the last cached state
  still visible), everything else on a retryable error view.

---

## 9. Module dependency rules (enforced by review)

1. `core/` and `theme/` import nothing from `stellantis/` or `features/`.
2. `stellantis/` imports `core/` + `theme/` but no `features/` and no widgets
   in its non-UI files (parsers, api, mqtt, analytics).
3. `features/` is the only layer allowed to wire UI to controllers.
4. Secrets are never imported outside `stellantis/brands/`; the real
   `secrets.dart` is gitignored (see [SECURITY.md](SECURITY.md)).
