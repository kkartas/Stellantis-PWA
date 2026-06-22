# Changelog

All notable changes to the Stellantis mobile app are documented here. The format
is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and the
project aims to follow [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Native Flutter app (iOS + Android) talking directly to the Stellantis cloud —
  no backend (replaces the legacy Flask/Dash PWA and the abandoned FastAPI
  migration).
- OAuth2 + PKCE login for Peugeot, Citroën, DS, Opel, and Vauxhall via the system
  browser, with token refresh and secure (Keychain/Keystore) token storage.
- OTP setup (SMS + PIN) and MQTT remote commands: lock, unlock, climate,
  charge, horn, lights, wake-up.
- Vehicle data: live status, battery/fuel/range/mileage, doors, position, alerts,
  and maintenance, parsed into typed models.
- Trip and charging history with detection parsers, charge-curve and battery-SOH
  analytics, emissions estimation, and ABRP push integration.
- Stale-while-revalidate caching on Isar with background refresh (workmanager)
  and local notifications on state changes.
- Brand-adaptive theming for all 13 Stellantis brands (light + dark) with runtime
  auto-detection and a user override.
- Feature screens: dashboard, vehicle detail, location map, trips, charging,
  stats hub, maintenance, and settings (units, charging, ABRP, OpenWeather,
  theme, account, about/diagnostics).
- Performance polish: skeleton loaders, haptics, Rive/Lottie animations,
  predictive prefetch, isolate JSON parsing, asset precache, glass cards,
  edge-to-edge layouts.
- Localization scaffold for English, French, German, Italian, Spanish, and Dutch
  (shared navigation and error/offline strings localized).
- iOS privacy manifest and Android release signing via `key.properties`.
- Test suite: parser/model units, replay fixtures, brand golden snapshots,
  per-screen widget tests, accessibility guideline checks, and an end-to-end
  boot-flow integration test.

### Documentation
- `docs/ARCHITECTURE.md`, `docs/SECURITY.md`, `docs/STELLANTIS_API.md`,
  `docs/BRANDS.md`, `docs/RELEASE.md`, and `docs/REMAINING_WORK.md`.

[Unreleased]: https://example.invalid/compare/v1.0.0-beta.1...HEAD
