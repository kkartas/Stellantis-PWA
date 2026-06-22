# Remaining work — agent implementation spec

> **Audience:** an autonomous coding agent. **Goal:** finish the Stellantis
> mobile migration to v1.0-beta. This file is the single source of truth for
> what is *not* done. Every task below is written to be executed precisely,
> in order, with explicit acceptance criteria. Do not improvise scope.
>
> **Status reference:** [MIGRATION_PLAN.md](../MIGRATION_PLAN.md) holds the
> phase checklist; this file expands only the unchecked / partial items.
>
> Last verified against the repo: 2026-06-23.

---

## 0. Ground rules (read first — non-negotiable)

1. **Working tree.** The Flutter app is in [`mobile/`](../mobile). Run all
   `flutter`/`dart` commands from `mobile/` unless stated otherwise.
2. **Branch.** Do not commit to `master` directly. Create a feature branch per
   task group (`feat/ios-platform`, `test/widget-screens`, …).
3. **One commit per atomic deliverable**, Conventional Commits, and end every
   commit message with the same trailer the recent history uses:
   `Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>`. (The plan text
   says 4.7; the actual git history uses 4.8 — match the history.)
4. **Quality gate before every commit** (all must pass):
   ```bash
   cd mobile
   flutter analyze            # MUST print "No issues found!"
   flutter test               # MUST be all green
   ```
   `very_good_analysis` is strict and treats lints seriously. The only rules
   disabled project-wide are in [`analysis_options.yaml`](../mobile/analysis_options.yaml)
   (`public_member_api_docs`, `cascade_invocations`,
   `use_late_for_private_fields_and_variables`). Do not disable more without a
   one-line justification comment.
5. **Docs travel with code.** Update the relevant doc and the
   `MIGRATION_PLAN.md` status cell in the *same commit* that lands the change.
6. **Never commit real secrets.** `mobile/lib/stellantis/brands/secrets.dart`
   is gitignored. Only `secrets_template.dart` is tracked. See
   [SECURITY.md](SECURITY.md).

### Known environment gotchas (already hit — avoid re-discovering)
- **Windows build-dir lock:** `flutter test` sometimes fails with
  `Flutter failed to delete a directory at "build\unit_test_assets"`. Fix:
  `rm -rf mobile/build/unit_test_assets` (or PowerShell `Remove-Item -Recurse
  -Force`) then re-run. It is a stale handle, not a code error.
- **gen-l10n:** the synthetic `package:flutter_gen` path is removed in this
  Flutter (3.41). [`l10n.yaml`](../mobile/l10n.yaml) outputs generated Dart into
  `lib/l10n/app_localizations*.dart`; those files are committed and excluded
  from analysis. Re-run `flutter gen-l10n` after editing any `.arb`. Do **not**
  re-add a `synthetic-package:` key (it errors).
- **intl is pinned** to `^0.20.2` to match the Flutter SDK constraint. Do not
  bump it independently.
- **Golden images are host-sensitive.** Font hinting differs across OSes.
  Regenerate with `flutter test --update-goldens` on the same platform CI runs
  goldens on, and review the diff before committing PNGs.

---

## 1. iOS platform — ✅ ALREADY EXISTS (corrected)

> **Correction (2026-06-23):** an earlier audit wrongly concluded `mobile/ios/`
> was missing. It is in fact committed (`c051a41 chore: scaffold flutter
> project`, `448c80c feat(ios): brand redirect schemes`), already targets iOS
> 13.0, and carries the brand URL schemes. The only real defect was a bundle-id
> mismatch with CI, fixed below. The scaffolding sub-steps in this section are
> retained for reference but are **already satisfied** — do not re-run
> `flutter create --platforms=ios` (it strips the Android entry from
> `.metadata` and drops a stray default `test/widget_test.dart`).

**Applied fix:** [`codemagic.yaml`](../codemagic.yaml) referenced
`com.stellantis.app` for both platforms, which matches neither native project.
Corrected to the real identifiers — Android
`com.stellantis.app.stellantis_mobile`, iOS `com.stellantis.app.stellantisMobile`
— and set the iOS `CFBundleDisplayName` to `Stellantis`.

**Canonical identifiers (use exactly these):**
- Org: `com.stellantis.app`
- iOS bundle identifier: **`com.stellantis.app`** (this matches
  [`codemagic.yaml`](../codemagic.yaml) `ios-release.ios_signing.bundle_identifier`).
  > ⚠️ Note the inconsistency: Android `applicationId` is
  > `com.stellantis.app.stellantis_mobile`. Do **not** "fix" Android in this
  > task. Just make iOS match codemagic. Record the mismatch in the PR
  > description for a human to reconcile later.
- Display name: `Stellantis`
- Deployment target: **iOS 13.0** (required by `flutter_web_auth_2`,
  `flutter_secure_storage`, and Impeller).

### 1.1 Generate the iOS project
```bash
cd mobile
flutter create --org com.stellantis.app --platforms=ios .
```
This adds `mobile/ios/` without touching existing Dart/Android. Verify it did
not modify `lib/`, `pubspec.yaml`, or `android/` (git diff should show only
`ios/` additions).

Then set the bundle id to the canonical value in
`ios/Runner.xcodeproj/project.pbxproj`: replace every
`PRODUCT_BUNDLE_IDENTIFIER = com.stellantis.app.stellantisMobile;` (Debug,
Release, Profile) with `PRODUCT_BUNDLE_IDENTIFIER = com.stellantis.app;`.

**Commit:** `chore(ios): scaffold ios platform` — update plan rows 1.1, 5.4.

### 1.2 Info.plist baseline
In `ios/Runner/Info.plist`:
- Set `CFBundleDisplayName` to `Stellantis`.
- Add the brightness/edge-to-edge friendly status bar key
  `UIViewControllerBasedStatusBarAppearance` = `true` (mirrors the Android
  edge-to-edge setup in [`main.dart`](../mobile/lib/main.dart)).
- Set the iOS deployment target to `13.0` in
  `ios/Flutter/AppframeworkInfo.plist` and the Xcode project
  (`IPHONEOS_DEPLOYMENT_TARGET = 13.0;` in all three build configs) and in
  `ios/Podfile` (`platform :ios, '13.0'`).

**Commit:** `chore(ios): info.plist + deployment target` — part of 1.1.

### 1.3 Acceptance
- `flutter build ios --no-codesign` succeeds (run on macOS/CI; on Windows just
  ensure `flutter analyze` stays clean and the project files are well-formed).
- `git status` shows a complete `ios/` tree including `Runner.xcodeproj`,
  `Runner/`, `Flutter/`, `Podfile`.

---

## 2. iOS brand redirect schemes — ✅ ALREADY DONE

> The five schemes are already registered in
> [`Info.plist`](../mobile/ios/Runner/Info.plist) `CFBundleURLTypes` (committed
> in `448c80c`). They are grouped under one `CFBundleURLName`
> (`com.stellantis.app.oauth`) rather than one dict per brand — functionally
> identical for `ASWebAuthenticationSession`, which matches on the scheme
> string. No change required. The original instructions below are retained for
> reference only.

Mirror the Android intent-filters in
[`AndroidManifest.xml`](../mobile/android/app/src/main/AndroidManifest.xml)
lines 32–65. The Dart source of truth is
`BrandConstants.redirectScheme` in
[`brand_constants.dart`](../mobile/lib/stellantis/brands/brand_constants.dart):

| Brand | Scheme |
|---|---|
| Peugeot | `mymap` |
| Citroën | `mymacsdk` |
| DS | `mymdssdk` |
| Opel | `mymopsdk` |
| Vauxhall | `mymvxsdk` |

`flutter_web_auth_2` on iOS uses `ASWebAuthenticationSession`, which resolves
the callback by the URL scheme registered in `Info.plist`. Add **one
`CFBundleURLTypes` entry per scheme** to `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleURLName</key><string>peugeot</string>
    <key>CFBundleURLSchemes</key><array><string>mymap</string></array>
  </dict>
  <dict>
    <key>CFBundleURLName</key><string>citroen</string>
    <key>CFBundleURLSchemes</key><array><string>mymacsdk</string></array>
  </dict>
  <dict>
    <key>CFBundleURLName</key><string>ds</string>
    <key>CFBundleURLSchemes</key><array><string>mymdssdk</string></array>
  </dict>
  <dict>
    <key>CFBundleURLName</key><string>opel</string>
    <key>CFBundleURLSchemes</key><array><string>mymopsdk</string></array>
  </dict>
  <dict>
    <key>CFBundleURLName</key><string>vauxhall</string>
    <key>CFBundleURLSchemes</key><array><string>mymvxsdk</string></array>
  </dict>
</array>
```

**Acceptance:** the five schemes appear in `Info.plist`; they exactly equal the
Dart map values (no typos). **Commit:** `feat(ios): brand redirect schemes` —
this is the genuine 5.4; update its status note.

---

## 3. iOS privacy manifest (plan 9.7) — ✅ DONE

> Implemented: [`ios/Runner/PrivacyInfo.xcprivacy`](../mobile/ios/Runner/PrivacyInfo.xcprivacy)
> created and wired into the Runner target (PBXFileReference + PBXBuildFile +
> group + Resources phase, ids `F1F1F1F101000000000000A1/A2`). Declares precise
> location + diagnostic data (linked, non-tracking, AppFunctionality) and the
> UserDefaults (`CA92.1`) / FileTimestamp (`C617.1`) required-reason APIs.
> Original instructions retained below.


Create `ios/Runner/PrivacyInfo.xcprivacy` (a plist) and add it to the Runner
target's "Copy Bundle Resources" build phase (edit `project.pbxproj` or add via
Xcode). Declare:

- **Collected data types:**
  - `NSPrivacyCollectedDataTypePreciseLocation` — linked to user, not used for
    tracking, purpose `AppFunctionality`.
  - A device/vehicle identifier (use
    `NSPrivacyCollectedDataTypeOtherDiagnosticData` for VIN/telemetry) — linked
    to user, not tracking, purpose `AppFunctionality`.
- **Required-reason APIs** (`NSPrivacyAccessedAPITypes`):
  - `NSPrivacyAccessedAPICategoryUserDefaults`, reason `CA92.1`.
  - `NSPrivacyAccessedAPICategoryFileTimestamp`, reason `C617.1` (Isar/path_provider).
- `NSPrivacyTracking` = `false`; `NSPrivacyTrackingDomains` = empty array.

Keep it consistent with [SECURITY.md §7](SECURITY.md). **Commit:**
`docs(release): ios privacy manifest`. Update plan row 9.7.

---

## 4. Android release signing (plan 9.1)

Currently [`build.gradle.kts`](../mobile/android/app/build.gradle.kts) lines
34–40 sign the release build with the **debug** keystore. Replace with a real
config sourced from `key.properties` (gitignored), the standard Flutter pattern:

1. Add `android/key.properties` to `.gitignore` (verify it is ignored).
2. Read it in `build.gradle.kts`:
   ```kotlin
   import java.util.Properties
   import java.io.FileInputStream

   val keystoreProperties = Properties()
   val keystorePropertiesFile = rootProject.file("key.properties")
   if (keystorePropertiesFile.exists()) {
       keystoreProperties.load(FileInputStream(keystorePropertiesFile))
   }
   ```
3. Define `signingConfigs { create("release") { … storeFile/storePassword/
   keyAlias/keyPassword from keystoreProperties … } }` and use it in
   `buildTypes.release`. **Fall back to debug signing only when
   `keystorePropertiesFile` does not exist**, so `flutter run --release` still
   works locally without a keystore.

Codemagic injects the keystore via the `stellantis_keystore` reference already
declared in [`codemagic.yaml`](../codemagic.yaml) — do not hardcode secrets.

**Acceptance:** `flutter build apk --release` works both with and without
`key.properties` present. **Commit:** `chore(android): release signing config`.
Update plan row 9.1.

---

## 5. Per-screen widget tests (plan 8.2 — currently partial)

Core UI primitives are tested (`battery_ring`, `state_views`, `skeleton`,
`glass_card`, `brand_theme`). **Missing: the feature screens.** Add one widget
test file per screen below, under `test/features/<feature>/<screen>_test.dart`.

**Screens to cover** (file → widget):
- `features/auth/splash_page.dart`, `brand_picker_page.dart`, `login_page.dart`, `otp_setup_page.dart`
- `features/dashboard/dashboard_page.dart`
- `features/vehicle_detail/vehicle_detail_page.dart`, `location_page.dart`
- `features/vehicles/vehicle_picker_page.dart`
- `features/trips/trips_page.dart`, `trip_detail_page.dart`
- `features/charging/charging_page.dart`, `charging_detail_page.dart`
- `features/stats/stats_page.dart`
- `features/maintenance/maintenance_page.dart`
- `features/settings/units_settings_page.dart`, `charging_settings_page.dart`,
  `abrp_settings_page.dart`, `openweather_settings_page.dart`,
  `theme_settings_page.dart`, `account_settings_page.dart`,
  `about_settings_page.dart`

**Method (mandatory pattern):**
1. Read the screen file first. Identify every Riverpod provider it
   `ref.watch`/`ref.read`s and every required route/constructor argument.
2. Wrap the screen in a `ProviderScope(overrides: [...])` that supplies fake
   data so the screen renders **without touching network, Isar, or secure
   storage**. Override the repository/controller providers with fakes — use
   `mocktail` (already a dev dependency) for behaviour, or
   `Override` with a fixed `AsyncValue.data(...)`.
3. Wrap in `MaterialApp` with `AppLocalizations.localizationsDelegates` and
   `supportedLocales` (import
   `package:stellantis_mobile/l10n/app_localizations.dart`) so any localized
   widget resolves.
4. Assert at least: (a) the happy-path renders expected text/widgets with no
   thrown exception (`expect(tester.takeException(), isNull)`); (b) the
   loading state shows `LoadingStateView`/`Skeleton`; (c) the error state shows
   `ErrorStateView`/`OfflineStateView` via `mapErrorToStateView`.
5. For screens with optimistic actions (dashboard quick actions), assert the
   optimistic flip and the revert-on-failure path
   (`features/dashboard/data/quick_action_controller.dart`).

**Do not** start a real Isar instance or MQTT connection in a widget test —
override the providers. If a screen cannot be rendered without a hard
dependency, extract the pure sub-widget and test that, and note the gap in the
test file header.

**Acceptance:** every screen above has a test file; `flutter test` green; no
test performs real I/O. **Commit:** `test(ui): widget tests for feature screens`
(may split per feature). Update plan row 8.2 to `[x]`.

---

## 6. Localize hard-coded UI strings (i18n follow-through)

The i18n **scaffold** exists ([`lib/l10n/*.arb`](../mobile/lib/l10n), 6 locales,
wired into [`app.dart`](../mobile/lib/app/app.dart)) but **screen strings are
still hard-coded** (e.g. `'Retry'`, `'You're offline'`, nav labels). Migrate
user-visible strings to `AppLocalizations`:

1. For each hard-coded user-facing `Text('…')`, add a key to
   `lib/l10n/app_en.arb` (and translate in the other five `.arb` files), then
   replace the literal with `AppLocalizations.of(context).<key>`.
2. Run `flutter gen-l10n` after every `.arb` edit.
3. Start with the shared widgets already keyed in `app_en.arb`
   (`actionRetry`, `errorOfflineTitle`, `errorOfflineMessage`, nav labels) —
   apply them in [`state_views.dart`](../mobile/lib/core/ui/state_views.dart)
   and the navigation shell
   ([`app_shell.dart`](../mobile/lib/features/shell/app_shell.dart)).
4. Keep `app_en.arb` as the template; every other locale must define the same
   key set (gen-l10n warns on missing translations — resolve all warnings).

**Acceptance:** no untranslated warnings from `flutter gen-l10n`; the strings
referenced in `app_en.arb` are actually used in code; `flutter analyze` clean.
**Commit:** `feat(i18n): localize shared widget strings` (extend per feature).

---

## 7. Patrol E2E happy path (plan 8.4)

1. Add `patrol` to `dev_dependencies` and create `integration_test/`.
2. Configure `patrol` per its docs (`patrol_cli`, native test runners for both
   platforms). Add the `integration_test/` folder and a
   `patrol.yaml`/`pubspec` `patrol:` block with `app_name: Stellantis`.
3. Author **one** happy-path flow: brand pick → login (stub the OAuth callback;
   do **not** hit live Stellantis — inject a fake token via a test-only
   provider override or a launch argument) → dashboard renders → issue a `lock`
   command and assert optimistic UI.
4. Network must be faked/replayed (see Task 8), never live, so the test is
   deterministic and offline.

**Acceptance:** `patrol test` runs the flow on an emulator/simulator. **Commit:**
`test(e2e): patrol happy path`. Update plan row 8.4.

---

## 8. Replay-based Stellantis fixtures (plan 8.5)

1. Create `test/fixtures/stellantis/` with recorded JSON for each endpoint the
   app calls (`/vehicles`, `/status`, `/alerts`, `/maintenance`, trips, energy).
   Capture them from the legacy Python repo's recorded responses or from a live
   run **before** Phase 10 deletes `psa_car_controller/`.
2. Add a Dio `MockAdapter` (mocktail or `http_mock_adapter`) that serves those
   fixtures, and write tests asserting the typed `dart_mappable` models parse
   them correctly and the repositories persist + emit them.
3. These fixtures are the shared input for Task 7's E2E network fakes.

**Acceptance:** every REST model has a replay test against a real captured
payload. **Commit:** `test(stellantis): replay fixtures`. Update plan row 8.5.

---

## 9. Accessibility pass (plan 8.6)

1. Add `meetsGuideline` checks in widget tests:
   `await expectLater(tester, meetsGuideline(textContrastGuideline));`
   `await expectLater(tester, meetsGuideline(androidTapTargetGuideline));`
   `await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));`
   for the primary screens (dashboard, settings, lists).
2. Fix violations: ensure all icon-only buttons have `Semantics`/`tooltip`
   labels (lock/unlock/climate/charge quick actions especially), tap targets
   ≥ 44×44 logical px, and brand color pairs meet WCAG AA. Where a brand
   palette fails contrast, adjust the `on*` token in
   [`brand_theme.dart`](../mobile/lib/theme/brand_theme.dart) — and regenerate
   goldens.

**Acceptance:** the guideline checks pass for the covered screens. **Commit:**
`feat(a11y): contrast, tap targets, semantic labels`. Update plan row 8.6.

---

## 10. Release ops (plan 9.x — partly external)

These need accounts/consoles a human controls. Do only the in-repo parts; for
the rest, write a checklist into [RELEASE.md](RELEASE.md) and stop.

- **9.6 Shorebird:** run `shorebird init` in `mobile/` to replace the
  `app_id: REPLACE_WITH_SHOREBIRD_INIT` placeholder in
  [`mobile/shorebird.yaml`](../mobile/shorebird.yaml) with the real UUID. Then
  `shorebird release android` dry-run. Requires a Shorebird account — if
  unavailable, leave the placeholder and document the exact command in
  RELEASE.md. **Do not invent a UUID.**
- **9.3 Play internal track / 9.4 TestFlight / 9.5 Firebase App Distribution:**
  console setup. Document the steps in RELEASE.md; codemagic publishing blocks
  already exist in [`codemagic.yaml`](../codemagic.yaml).
- **9.9 Beta cut:** only after Tasks 1–9 are done and the §6 quality gates in
  the plan pass. Commit `chore(release): v1.0.0-beta.1` and tag.

Also create **`CHANGELOG.md`** at repo root (plan §5 deliverable, currently
missing) summarising the v1.0 work, Keep a Changelog format.

---

## 11. Phase 10 — retire legacy (**guarded; do last**)

> ⚠️ Destructive. Execute **only** when ALL preconditions hold. If any fails,
> stop and report — do not delete.

**Preconditions:**
1. Tasks 5, 7, 8 complete and green (Dart tests fully replace the Python ones).
2. Replay fixtures (Task 8) are captured and committed — the Python repo is no
   longer the only place the recorded API behaviour lives.
3. A human has approved the deletion in the PR.

**Then:**
- 10.1 `git rm -r psa_car_controller/`
- 10.2 `git rm tests/test_psa.py tests/test_unit.py`
- 10.3 `git rm pyproject.toml .pre-commit-config.yaml .prospector.yaml`
- 10.4 final README pass; 10.5 tag `v1.0.0-beta.1`.

Commits per the plan's 10.1–10.5 messages.

---

## 12. Suggested execution order

1. **Task 1** (iOS platform) — unblocks all iOS rows.
2. **Task 2 + 3 + 4** (iOS schemes, privacy manifest, Android signing) — small,
   high-value, build-config.
3. **Task 8** (replay fixtures) — needed by 5, 7; capture *before* Phase 10.
4. **Task 5** (widget tests) → **Task 6** (localize strings) → **Task 9** (a11y).
5. **Task 7** (patrol E2E).
6. **Task 10** (release ops) + CHANGELOG.
7. **Task 11** (retire legacy) — last, guarded.

After each task: run the §0.4 quality gate, update the matching
`MIGRATION_PLAN.md` status cell, and commit.
