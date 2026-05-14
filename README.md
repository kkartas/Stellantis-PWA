# Stellantis Mobile

A single Flutter mobile app (iOS + Android) that talks **directly** to the Stellantis
connected-car cloud — no backend, no server, no proxy.

The app replicates and extends everything the original Python `psa_car_controller` project
provided, as a native, offline-first, brand-adaptive mobile experience.

> **Status:** Pre-alpha. Phase 0 (audit & repo reset) is complete. Flutter scaffold begins in Phase 1.

---

## What it is

| | |
|---|---|
| **Target platforms** | Android, iOS |
| **Architecture** | Flutter app → Stellantis API directly (OAuth2 + MQTTS) |
| **No backend** | The app holds client secrets (same as the official My* apps), stores tokens in Keychain/EncryptedSharedPreferences, and speaks OAuth + MQTT directly |
| **Brand-adaptive** | Auto-detects brand from account response; applies full theme (colors, type, motion, logo) at runtime |
| **Offline-first** | Every screen paints from local Isar cache instantly; network refreshes in background |

---

## Brands supported

| Brand | OAuth realm | Redirect scheme |
|---|---|---|
| Peugeot | clientsB2CPeugeot | `mymap://` |
| Citroën | clientsB2CCitroen | `mymacsdk://` |
| DS Automobiles | clientsB2CDS | `mymdssdk://` |
| Opel | clientsB2COpel | `mymopsdk://` |
| Vauxhall | clientsB2CVauxhall | `mymvxsdk://` |
| Fiat | — | — |
| Alfa Romeo | — | — |
| Jeep | — | — |
| Lancia | — | — |
| Maserati | — | — |

Entries marked `—` are visually supported (theme + logo) but require APK secret extraction
in Phase 2. The first five brands are fully documented in the legacy Python project.

---

## Repository layout

```
/
├── mobile/                     # Flutter app (the product) — Phase 1+
│   └── .gitkeep                # Placeholder; replaced by flutter create in Phase 1
├── tools/
│   ├── extract_secrets/        # Dart CLI: extract OAuth secrets from brand APK
│   └── import_legacy_db/       # Dart CLI: import legacy info.db → Isar
├── docs/
│   ├── LEGACY_AUDIT.md         # Full feature snapshot of the Python project
│   ├── ARCHITECTURE.md         # (Phase 1) Layers, data flow, threading
│   ├── BRANDS.md               # (Phase 4) Per-brand design tokens
│   ├── STELLANTIS_API.md       # (Phase 2) Reverse-engineered API reference
│   ├── SECURITY.md             # (Phase 2+9) Secret handling, threat model
│   ├── RELEASE.md              # (Phase 1+9) Build, sign, distribute, hotpatch
│   ├── adr/                    # Architecture Decision Records
│   ├── legacy/
│   │   ├── brands/             # SVG brand logos from the legacy PWA
│   │   └── sample_data/        # Gitignored. Local copy of info.db, config.json, etc.
│   └── stellantis/
│       ├── api-b2c.yaml        # Stellantis API OpenAPI spec (reference)
│       └── api_spec.md         # Human-readable API notes
├── psa_car_controller/         # Legacy Python project (port reference — removed in Phase 10)
├── codemagic.yaml              # CI/CD (Phase 9)
├── shorebird.yaml              # Code-push (Phase 9)
├── MIGRATION_PLAN.md           # Full phased execution plan
└── README.md                   # This file
```

---

## How to run

> Phase 1 will add real instructions. This is a placeholder.

**Prerequisites:** Flutter 3.x, Dart 3.x, Android Studio / Xcode

```sh
# Phase 1 will scaffold the project — placeholder command:
flutter create mobile --org com.stellantis.app --platforms=android,ios
cd mobile
flutter pub get
flutter run
```

Full build, sign, and distribution instructions will live in `docs/RELEASE.md` (Phase 1).

---

## Key documents

| Document | Purpose |
|---|---|
| [`MIGRATION_PLAN.md`](MIGRATION_PLAN.md) | Full phased plan with commit-by-commit task list |
| [`docs/LEGACY_AUDIT.md`](docs/LEGACY_AUDIT.md) | Every feature the Python project shipped, where it lived, and where it lands in Flutter |
| [`docs/stellantis/api-b2c.yaml`](docs/stellantis/api-b2c.yaml) | Stellantis API OpenAPI spec (used in Phase 2 to generate Dart models) |
| `docs/STELLANTIS_API.md` | Human-readable API reference (Phase 2) |
| `docs/BRANDS.md` | Per-brand palette, typography, motion language (Phase 4) |
| `docs/SECURITY.md` | Secret extraction, token storage, threat model (Phase 2+9) |

---

## License

This project is a community reimplementation of the Stellantis connected-car app.
See [`LICENSE`](LICENSE) for the original project's license terms. The Flutter rewrite
inherits the same license.
