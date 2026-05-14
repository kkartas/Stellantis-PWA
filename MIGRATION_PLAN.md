# Stellantis Mobile — Migration Plan

> **Target architecture:** A single Flutter mobile app (iOS + Android) that talks directly to the Stellantis cloud. No backend, no server, no proxy. All Stellantis logic, secrets, and persistence live in the app.
>
> **Replaces:** The legacy Flask/Dash PWA *and* the abandoned FastAPI-backend migration. Both are removed.
>
> **Non-negotiables:** modern, native, fast, brand-adaptive, complete feature parity with the existing Python project, full git commit history at every milestone, full documentation.

---

## 0. Guiding principles

1. **Speed of perception trumps speed of network.** Every screen paints from local cache instantly; the Stellantis network call refreshes in the background.
2. **Native everywhere.** Flutter 3.x with Impeller, AOT Dart, no JS bridge.
3. **One commit per atomic deliverable.** Each step in this plan ends with a commit. PR-quality messages, conventional commits style.
4. **Document as we go.** README, ARCHITECTURE, BRANDS, RELEASE all updated in the same commit that introduces the change.
5. **Lose nothing.** Every feature the Python project ships gets a Dart equivalent, mapped explicitly below.
6. **No backend.** The mobile app holds the Stellantis client secrets (same as the official MyPeugeot/MyCitroën apps do), stores tokens in Keychain/Keystore, and speaks OAuth + MQTT directly.

---

## 1. Feature inventory — what must survive

Anything below this line must work in the Flutter app at v1.0 unless explicitly deferred to v1.1.

### 1.1 Authentication & setup
| Existing (Python) | Migrates to |
|---|---|
| OAuth2 + PKCE login for Peugeot, Citroën, DS, Opel, Vauxhall | `lib/features/auth/data/oauth_service.dart` |
| APK-derived client_id / client_secret per brand ([psa_car_controller/psa/setup/app_decoder.py](psa_car_controller/psa/setup/app_decoder.py)) | Secrets pre-extracted, baked into app per-brand build flavor |
| Brand-specific redirect schemes (`mymap://`, `mymacsdk://`, `mymopar://`, …) | Per-flavor `AndroidManifest` intent-filters + iOS `CFBundleURLSchemes` |
| SMS OTP + PIN setup for remote-command MQTT ([psa_car_controller/psa/otp/otp.py](psa_car_controller/psa/otp/otp.py)) | `lib/features/auth/data/otp_service.dart` |
| Token refresh ([psa_car_controller/psa/oauth.py](psa_car_controller/psa/oauth.py)) | Dio interceptor with refresh-on-401 |
| Account info / brand detection ([psa_car_controller/psa/AccountInformation.py](psa_car_controller/psa/AccountInformation.py)) | `lib/features/auth/data/account_info.dart` |

### 1.2 Vehicle data
| Existing | Migrates to |
|---|---|
| Vehicle list with VIN, brand, label ([psa_car_controller/psacc/application/psa_client.py](psa_car_controller/psacc/application/psa_client.py)) | `vehicles_repository.dart` |
| Live status: battery %, fuel level, range, mileage, doors, lights, position, charging state | `vehicle_status_repository.dart` |
| Tire pressure, oil level, engine state, alerts | parsed into typed `VehicleStatus` model |
| Force-refresh (wake the car) | explicit pull-to-refresh; default reads use the cached fast path |
| VIN → model spec lookup ([car_models.yml](psa_car_controller/psacc/data/car_models.yml)) | shipped as a Dart asset, parsed on first launch into Isar |

### 1.3 Remote commands (MQTT)
All current commands ported 1:1, executed over the same MQTT broker as the official apps:

- lock / unlock
- start / stop preconditioning (climate)
- start / stop charge
- charge limit / charge hours
- horn
- lights
- wake-up

Source: [psa_car_controller/psa/RemoteClient.py](psa_car_controller/psa/RemoteClient.py), [psa_car_controller/psa/mqtt_request.py](psa_car_controller/psa/mqtt_request.py). Dart equivalent will use `mqtt_client` package over MQTTS.

### 1.4 Trip & charging history
| Existing | Migrates to |
|---|---|
| Trip detection from telemetry deltas ([psa_car_controller/psacc/application/trip_parser.py](psa_car_controller/psacc/application/trip_parser.py)) | `lib/features/trips/data/trip_parser.dart` |
| Trip history with start/end position, distance, duration, consumption | Isar `Trip` collection, map preview per row |
| Charging session detection ([psa_car_controller/psacc/application/charging.py](psa_car_controller/psacc/application/charging.py)) | `lib/features/charging/data/charging_parser.dart` |
| Charging cost calculation w/ peak/off-peak hours | `ChargingPriceService` |
| Battery charge curve modelling ([psa_car_controller/psacc/application/battery_charge_curve.py](psa_car_controller/psacc/application/battery_charge_curve.py)) | `ChargeCurveAnalyzer` |
| Existing SQLite history (`info.db`) | One-time import on first launch (optional dev tool) |

### 1.5 Stats & analytics
- Battery SOH over time ([psa_car_controller/psacc/model/battery_soh.py](psa_car_controller/psacc/model/battery_soh.py))
- Consumption per trip and rolling averages
- Mileage tracking & projection
- Cost of electricity / fuel
- Emissions estimate ([psa_car_controller/psacc/application/ecomix.py](psa_car_controller/psacc/application/ecomix.py))
- Maintenance reminders

All rendered with `fl_chart`.

### 1.6 Settings & integrations
- Per-brand auth config
- Charge target SOC + scheduled charge windows ([psa_car_controller/psacc/application/charge_control.py](psa_car_controller/psacc/application/charge_control.py))
- Charge price (per kWh, peak/off-peak)
- OpenWeather ambient temperature fallback
- ABRP push integration ([psa_car_controller/psacc/application/abrp.py](psa_car_controller/psacc/application/abrp.py))
- Units (km/mi, °C/°F, currency)
- Theme override (auto-brand vs forced brand)

### 1.7 Branding
Stellantis brands covered: **Peugeot, Citroën, DS, Opel, Vauxhall, Fiat, Lancia, Alfa Romeo, Jeep, Maserati, Chrysler, Dodge, Ram**. Each gets a full theme token set + logo + hero illustration. Brand is read from the Stellantis account response and applied at runtime.

### 1.8 Explicitly **dropped** in v1.0 (with reason)
- Flask/Dash web UI — replaced by native app.
- Docker / docker-compose — no server.
- Domoticz integration — niche, can return in v1.1 as a plugin.
- Windows `mymap://` protocol scripts — irrelevant on mobile.
- Multi-user serving — app is single-user-per-install.

---

## 2. Technology stack (locked)

| Layer | Choice | Reason |
|---|---|---|
| Framework | **Flutter 3.x** | AOT, Impeller, single codebase |
| Language | Dart 3.x with sound null safety | |
| State | **Riverpod 2** | compile-safe, testable, no rebuild surprises |
| Routing | **go_router** | declarative, deep-link friendly |
| HTTP | **dio** with HTTP/2 + persistent client | one TLS handshake per session |
| MQTT | **mqtt_client** | maintained, TLS support |
| Local DB | **Isar 4** | µs reads, zero-copy, async isolate |
| Secure storage | **flutter_secure_storage** | Keychain / EncryptedSharedPrefs |
| JSON | **dart_mappable** (codegen) | type-safe, fast, no reflection |
| Charts | **fl_chart** | GPU-rendered, smooth |
| Maps | **flutter_map** + OSM tiles | free, native perf |
| Animations | **rive** + **lottie** | hero animations, charging flows |
| Background | **workmanager** | periodic refresh on both OSes |
| Notifications | **flutter_local_notifications** | local-only, no FCM/APNs server needed |
| Haptics | **gestures** + native channel for fine control | premium feel |
| Testing | `flutter_test`, `mocktail`, `patrol` (E2E), `golden_toolkit` (theme snapshots) | |
| Lint | `very_good_analysis` | strict, modern |
| CI | **Codemagic** | iOS builds without owning a Mac |
| Code-push | **Shorebird** | ship Dart fixes without store review |

---

## 3. Repository layout (target)

```
/
├── mobile/                     # Flutter app (the product)
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/                # bootstrap, router, theme injection
│   │   ├── core/
│   │   │   ├── network/        # dio client, interceptors, retry
│   │   │   ├── storage/        # Isar, secure storage
│   │   │   ├── error/          # typed errors, recovery
│   │   │   ├── time/           # clock abstractions
│   │   │   └── logging/        # structured logging
│   │   ├── stellantis/         # ← the Python port lives here
│   │   │   ├── auth/           # OAuth + OTP
│   │   │   ├── api/            # REST endpoints
│   │   │   ├── mqtt/           # command client
│   │   │   ├── models/         # generated from api-b2c.yaml
│   │   │   └── brands/         # client_id/secret + scheme per brand
│   │   ├── domain/             # pure Dart domain (Car, Trip, Charge…)
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── dashboard/
│   │   │   ├── vehicle_detail/
│   │   │   ├── trips/
│   │   │   ├── charging/
│   │   │   ├── stats/
│   │   │   ├── maintenance/
│   │   │   ├── commands/
│   │   │   └── settings/
│   │   ├── theme/              # BrandTheme + per-brand themes
│   │   └── shared/             # widgets, formatters, hooks
│   ├── assets/
│   │   ├── brands/             # SVG logos + hero illustrations
│   │   ├── animations/         # Rive + Lottie
│   │   └── data/               # car_models.yml copy
│   ├── android/
│   ├── ios/
│   ├── test/
│   ├── integration_test/
│   └── pubspec.yaml
├── tools/
│   ├── extract_secrets/        # one-shot Dart CLI: rerun against new APK
│   └── import_legacy_db/       # one-shot: info.db → Isar
├── docs/
│   ├── ARCHITECTURE.md
│   ├── BRANDS.md
│   ├── STELLANTIS_API.md       # reverse-engineered API reference
│   ├── SECURITY.md
│   ├── RELEASE.md
│   └── adr/                    # architecture decision records
├── codemagic.yaml              # CI/CD
├── shorebird.yaml              # code push
├── README.md
└── MIGRATION_PLAN.md           # this file
```

`backend/` and `psa_car_controller/web/` are deleted. `psa_car_controller/` stays in-repo *only* as a reference during the port — removed at the end of Phase 2 once parity is reached.

---

## 4. Phased execution

Each step ends with a git commit using **Conventional Commits**:
- `feat:` new capability
- `chore:` infra, scaffolding
- `refactor:` no behavior change
- `fix:` bug fix
- `docs:` documentation
- `test:` tests
- `style:` formatting

Each commit message ends with `Co-Authored-By: Claude Opus 4.7 <noreply@anthropic.com>`.

### Phase 0 — Audit & reset *(~½ day)*

| # | Task | Commit message |
|---|---|---|
| 0.1 | Land this plan | `docs: add migration plan` |
| 0.2 | Snapshot legacy state in `docs/LEGACY_AUDIT.md` (every feature, where it lived) | `docs: capture legacy feature audit` |
| 0.3 | Delete `backend/` | `chore: remove abandoned backend scaffold` |
| 0.4 | Delete prior `mobile/` scaffold contents (keep folder) | `chore: reset mobile scaffold` |
| 0.5 | Restore brand SVGs from git history into `docs/legacy/brands/` for reference | `chore: preserve brand SVGs from legacy PWA` |
| 0.6 | Move `info.db`, `cars.json`, `config.json`, `otp.bin` out of root → `docs/legacy/sample_data/` (gitignored if private) | `chore: relocate legacy state files` |
| 0.7 | Rewrite root README with new architecture intro | `docs: rewrite README for direct-to-Stellantis app` |
| 0.8 | Delete `Dockerfile`, `docker-compose.yml`, `.eslintrc.yml`, Windows mymap scripts | `chore: remove obsolete server tooling` |

### Phase 1 — Flutter foundation *(~1 day)*

| # | Task | Commit |
|---|---|---|
| 1.1 | `flutter create mobile --org com.stellantis.app --platforms=android,ios` | `chore: scaffold flutter project` |
| 1.2 | Add dependencies in `pubspec.yaml` (the locked stack) | `chore: pin dependencies` |
| 1.3 | Set up `analysis_options.yaml` (very_good_analysis) | `chore: enable strict linting` |
| 1.4 | Create folder skeleton from §3 | `chore: lay out lib/ structure` |
| 1.5 | Add Riverpod ProviderScope, go_router shell, MaterialApp.router | `feat: app shell with riverpod + go_router` |
| 1.6 | Splash screen with neutral Stellantis logo | `feat: splash screen` |
| 1.7 | Theme infrastructure scaffold (`BrandTheme`, `BrandThemeProvider`) | `feat: brand theme infrastructure` |
| 1.8 | Logging + error boundary | `feat: structured logging and error boundary` |
| 1.9 | `codemagic.yaml` with Android + iOS workflows targeting TestFlight + Firebase App Distribution | `chore: ci/cd via codemagic` |
| 1.10 | `docs/RELEASE.md` documenting build, sign, distribute | `docs: release runbook` |

### Phase 2 — Stellantis integration port *(~5 days)*

> Goal: replicate everything `psa_car_controller/psa/` and `psa_car_controller/psacc/` do, in Dart, with tests, screen-free.

| # | Task | Commit |
|---|---|---|
| 2.1 | Dart CLI tool `tools/extract_secrets/` mirroring `app_decoder.py` — outputs `lib/stellantis/brands/secrets.dart` (gitignored) and a public `secrets_template.dart` | `feat(tools): apk secret extractor` |
| 2.2 | Per-brand constants (redirect URI, base URLs, MQTT broker) | `feat(stellantis): brand constants` |
| 2.3 | OAuth2 PKCE flow with `flutter_web_auth_2` for the system browser | `feat(stellantis): oauth2 pkce login` |
| 2.4 | Token refresh interceptor on dio | `feat(stellantis): token refresh interceptor` |
| 2.5 | Persistent HTTP/2 dio client w/ keep-alive, connection pooling | `feat(network): persistent http2 client` |
| 2.6 | dart_mappable models generated for vehicles, status, trips, energy, position, alerts, maintenance (from `api-b2c.yaml`) | `feat(stellantis): typed api models` |
| 2.7 | REST client: GET /vehicles, GET /status, POST /refresh | `feat(stellantis): vehicles api` |
| 2.8 | OTP service: SMS request + complete, derive remote credentials | `feat(stellantis): otp setup` |
| 2.9 | MQTT client: connect, subscribe, publish, command building | `feat(stellantis): mqtt command client` |
| 2.10 | Each command: lock, unlock, climate-on/off, charge-on/off, horn, lights, wake-up — one commit each | 8× `feat(commands): <name>` |
| 2.11 | VIN → model resolver loading `car_models.yml` asset | `feat(stellantis): vin model lookup` |
| 2.12 | Trip parser ported from `trip_parser.py` | `feat(stellantis): trip parser` |
| 2.13 | Charging parser + price calculator | `feat(stellantis): charging parser` |
| 2.14 | Battery SOH + charge curve port | `feat(stellantis): battery analytics` |
| 2.15 | Ecomix emissions port | `feat(stellantis): emissions estimator` |
| 2.16 | ABRP push integration | `feat(stellantis): abrp integration` |
| 2.17 | Full unit test pack: every parser tested against fixtures captured from current Python repo | `test(stellantis): port parser fixtures` |
| 2.18 | `docs/STELLANTIS_API.md` — every endpoint, every quirk | `docs: stellantis api reference` |

### Phase 3 — Data & cache layer *(~2 days)*

| # | Task | Commit |
|---|---|---|
| 3.1 | Isar schemas: Vehicle, VehicleStatusSnapshot, Trip, ChargeSession, SohSample, Alert, Maintenance | `feat(storage): isar schemas` |
| 3.2 | Repositories with stale-while-revalidate pattern: returns cached `Stream<T>`, kicks off network refresh | `feat(storage): swr repositories` |
| 3.3 | Background polling worker (workmanager): every 30 min when app backgrounded | `feat(background): periodic refresh` |
| 3.4 | Local notifications on state change (charging complete, low battery, door left open) | `feat(notifications): local state-change alerts` |
| 3.5 | One-shot legacy importer: read existing `info.db` SQLite → Isar (tool, not in-app) | `feat(tools): legacy db importer` |
| 3.6 | Cache invalidation policies + TTL tuning | `feat(storage): cache policies` |

### Phase 4 — Brand theme system *(~2 days)*

| # | Task | Commit |
|---|---|---|
| 4.1 | `BrandTheme` token class (colors, typography, motion curves, logo, hero asset) | `feat(theme): brand theme tokens` |
| 4.2 | Material 3 Expressive base + adaptive iOS Cupertino tweaks | `feat(theme): material 3 expressive base` |
| 4.3-4.15 | One commit per brand theme: peugeot, citroen, ds, opel, vauxhall, fiat, lancia, alfa-romeo, jeep, maserati, chrysler, dodge, ram | 13× `feat(theme): <brand>` |
| 4.16 | Auto-brand detection from API response, fallback to user override | `feat(theme): auto brand detection` |
| 4.17 | Brand SVG logo set (restored + sourced) in `assets/brands/` | `feat(theme): brand logo assets` |
| 4.18 | Golden tests: every screen × every brand snapshot | `test(theme): brand golden snapshots` |
| 4.19 | `docs/BRANDS.md` — palette table, type, motion language per brand | `docs: brand reference` |

### Phase 5 — Core UX shell *(~3 days)*

| # | Task | Commit |
|---|---|---|
| 5.1 | Pre-auth brand-picker (which brand do you drive?) | `feat(auth): brand picker` |
| 5.2 | Login screen → system browser OAuth → deep link handler | `feat(auth): oauth login flow` |
| 5.3 | Android deep-link intent-filters per brand | `feat(android): brand redirect schemes` |
| 5.4 | iOS URL schemes + universal links | `feat(ios): brand redirect schemes` |
| 5.5 | OTP setup wizard | `feat(auth): otp setup wizard` |
| 5.6 | Vehicle picker (if multiple cars) | `feat(vehicles): picker` |
| 5.7 | Adaptive shell: NavigationBar (Material) / TabBar (Cupertino) | `feat(shell): adaptive navigation` |
| 5.8 | Pull-to-refresh = wakeup endpoint, default reads = cached | `feat(shell): pull-to-refresh wake` |
| 5.9 | Global error states + retry surfaces | `feat(shell): error and offline states` |
| 5.10 | Logout + session reset | `feat(auth): logout` |

### Phase 6 — Feature screens *(~5 days)*

| # | Screen | Commit |
|---|---|---|
| 6.1 | **Dashboard**: brand-themed hero (car render + state), battery/fuel ring, range, mileage, quick actions row | `feat(dashboard): hero + quick actions` |
| 6.2 | **Quick actions**: lock, climate, charge — optimistic UI with revert-on-fail | `feat(commands): optimistic actions` |
| 6.3 | **Vehicle detail**: doors, windows, lights, tire pressure, oil, alerts | `feat(vehicle-detail): full state panel` |
| 6.4 | **Location & map**: last known position with flutter_map | `feat(vehicle-detail): location` |
| 6.5 | **Trips list** w/ filtering and search | `feat(trips): list and filters` |
| 6.6 | **Trip detail**: route polyline, stats, consumption profile | `feat(trips): trip detail` |
| 6.7 | **Charging list** w/ cost totals | `feat(charging): list and totals` |
| 6.8 | **Charging detail**: charge curve, energy added, cost | `feat(charging): detail with curve` |
| 6.9 | **Stats hub**: SOH trend, consumption trend, mileage projection, cost rollup, emissions | `feat(stats): hub` |
| 6.10 | **Maintenance**: oil, brake, service reminders | `feat(maintenance): reminders` |
| 6.11 | **Settings: units**: km/mi, °C/°F, currency | `feat(settings): units` |
| 6.12 | **Settings: charging**: target SOC, scheduled hours, kWh price, peak windows | `feat(settings): charging config` |
| 6.13 | **Settings: ABRP**: enable + token | `feat(settings): abrp` |
| 6.14 | **Settings: OpenWeather**: API key for ambient temp | `feat(settings): openweather` |
| 6.15 | **Settings: theme**: auto-brand vs forced brand | `feat(settings): theme override` |
| 6.16 | **Settings: account**: signed-in info, logout | `feat(settings): account` |
| 6.17 | **About + diagnostics**: version, last refresh, cache size, export logs | `feat(settings): about and diagnostics` |

### Phase 7 — Speed & polish *(~3 days)*

| # | Task | Commit |
|---|---|---|
| 7.1 | Skeleton loaders (shimmer) on every list and card | `feat(ui): skeleton loaders` |
| 7.2 | Haptic feedback on all primary actions (selection click, success notification) | `feat(ui): haptics` |
| 7.3 | Rive hero car: rotates, shows lock state, lights up doors | `feat(ui): rive hero car` |
| 7.4 | Lottie animations: charging flow, climate-on, lock cycle | `feat(ui): lottie state animations` |
| 7.5 | Predictive prefetch: idle on screen X → preload data for likely next screen | `feat(perf): predictive prefetch` |
| 7.6 | JSON parsing moved to `compute()` isolate for any payload > 8 KB | `feat(perf): isolate parsing` |
| 7.7 | Image precaching for brand assets at startup | `feat(perf): asset precache` |
| 7.8 | First-frame budget audit + fix (<800 ms cold start target) | `perf: cold start under 800ms` |
| 7.9 | List virtualization audit + sliver tuning | `perf: smooth scrolling under 16ms` |
| 7.10 | Glassmorphism cards w/ BackdropFilter, perf-checked on low-end Android | `feat(ui): glass cards` |
| 7.11 | Edge-to-edge layouts + safe area handling | `feat(ui): edge-to-edge` |
| 7.12 | Dark mode polish per brand | `feat(theme): dark mode polish` |

### Phase 8 — Testing & QA *(~2 days)*

| # | Task | Commit |
|---|---|---|
| 8.1 | Unit tests for every parser (port from `tests/test_psa.py` and `tests/test_unit.py`) | `test: port legacy parser tests` |
| 8.2 | Widget tests for every screen | `test(ui): widget tests` |
| 8.3 | Golden tests for every brand theme | `test(theme): golden suite` |
| 8.4 | Integration tests with patrol (E2E happy path: login → dashboard → command) | `test(e2e): happy path` |
| 8.5 | Replay-based tests using recorded Stellantis fixtures | `test(stellantis): replay fixtures` |
| 8.6 | Accessibility audit (semantic labels, contrast, touch targets ≥ 44pt) | `feat(a11y): full pass` |
| 8.7 | Localization scaffold (en, fr, de, it, es, nl) + extraction | `feat(i18n): scaffold + strings` |

### Phase 9 — Distribution & ops *(~2 days)*

| # | Task | Commit |
|---|---|---|
| 9.1 | Android signing config, keystore handled via Codemagic env | `chore(android): signing` |
| 9.2 | iOS certs + provisioning via App Store Connect API | `chore(ios): signing` |
| 9.3 | Play Console Internal Testing track setup | `chore(release): play internal track` |
| 9.4 | TestFlight internal group setup | `chore(release): testflight` |
| 9.5 | Firebase App Distribution for Android side-channel | `chore(release): firebase distribution` |
| 9.6 | Shorebird init + first patch dry-run | `chore(release): shorebird code-push` |
| 9.7 | Privacy manifest (iOS) + Data Safety form (Play) docs | `docs(release): privacy disclosures` |
| 9.8 | `docs/SECURITY.md`: secret handling, token storage, threat model | `docs: security model` |
| 9.9 | v1.0 beta cut | `chore(release): v1.0.0-beta.1` |

### Phase 10 — Retire legacy *(~½ day)*

| # | Task | Commit |
|---|---|---|
| 10.1 | Delete `psa_car_controller/` (port is complete and verified) | `chore: remove python legacy after port` |
| 10.2 | Delete `tests/test_psa.py`, `tests/test_unit.py` (replaced by Dart equivalents) | `chore: remove python tests` |
| 10.3 | Delete `pyproject.toml`, `.pre-commit-config.yaml`, `.prospector.yaml` | `chore: remove python tooling` |
| 10.4 | Final README pass | `docs: final readme for v1.0` |
| 10.5 | Tag `v1.0.0-beta.1` | `git tag` |

---

## 5. Documentation deliverables

Every doc is created or updated *in the same commit* that introduces the relevant change.

| Doc | Purpose | First written in phase |
|---|---|---|
| `README.md` | What this is, how to run | 0 |
| `MIGRATION_PLAN.md` | This file | 0 |
| `docs/LEGACY_AUDIT.md` | Snapshot of legacy features before deletion | 0 |
| `docs/ARCHITECTURE.md` | Layers, data flow, threading model | 1 |
| `docs/STELLANTIS_API.md` | Reverse-engineered API surface | 2 |
| `docs/BRANDS.md` | Per-brand design tokens + assets | 4 |
| `docs/SECURITY.md` | Secret extraction, token storage, threat model | 2 + 9 |
| `docs/RELEASE.md` | Build, sign, distribute, hotpatch | 1 + 9 |
| `docs/adr/NNNN-*.md` | One ADR per consequential decision (Flutter over RN, no backend, etc.) | as decisions land |
| `mobile/README.md` | Local dev quickstart | 1 |
| `CHANGELOG.md` | User-facing changes | 9 |

---

## 6. Quality gates

Before any phase is declared complete:

1. **`flutter analyze`** → zero warnings
2. **`flutter test`** → all green
3. **`flutter test --update-goldens` review** → no unexpected visual drift
4. **`flutter build apk --release` + `flutter build ios --release`** → both succeed
5. **Manual smoke test** on a real Android device + iOS simulator (or device if available)
6. **Cold start profiling** with Flutter DevTools → first frame < 800 ms after Phase 7
7. **Memory profile** under continuous polling → no leaks over 30 min
8. **Docs touched** in the same commit

---

## 7. Risks & mitigations

| Risk | Mitigation |
|---|---|
| Stellantis rotates client secret → all installs broken | Shorebird hotpatch path to ship new secret; CI rebuilds APKs nightly to detect breaks |
| Stellantis API quirks not captured in old Python code | Phase 2.17 captures fixtures from live runs of legacy Python before deletion |
| iOS background refresh unreliable | Document the limitation; offer in-app refresh + persistent foreground service on Android |
| OAuth deep-link conflicts between brands installed side-by-side | Per-flavor schemes with unique suffix |
| MQTT broker certificate pinning changes | Build pin against current cert, monitor with Sentry/Crashlytics for handshake failures |
| Without a backend, no way to push "charge complete" while app is closed on iOS | Use BGAppRefreshTask + local notification; if reliability proves unacceptable, add a single Cloudflare Worker (not a server, just a webhook for APNs) as v1.1 |
| Reverse-engineered API is fragile and brand-by-brand | Per-brand integration tests; feature flags to disable broken brands without app update |

---

## 8. Definition of done — v1.0

- All Phase 1-9 commits landed and tagged `v1.0.0-beta.1`.
- All §1 features have a working Flutter equivalent.
- App passes §6 quality gates on Pixel 6 (Android 14+) and iPhone 13 (iOS 17+).
- TestFlight + Play Internal Test builds installable by external testers.
- Crash-free sessions > 99% over a 1-week beta window.
- Cold start < 800 ms; pull-to-refresh visible feedback < 100 ms.
- Brand auto-detection correctly themes the app on at least Peugeot, Citroën, DS, Opel, Fiat, Alfa Romeo, Jeep (test-account coverage).

---

## 9. After v1.0 (out of scope, parked here for memory)

- WatchOS / WearOS companion (lock/unlock, charge %)
- iOS Live Activities for active charging
- CarPlay / Android Auto surfaces
- Apple/Google Wallet keys (if Stellantis exposes them)
- Optional Cloudflare Worker for reliable push notifications
- Domoticz/Home Assistant bridge as an optional plugin
- AI assistant tab (Claude API) for natural-language scheduling
