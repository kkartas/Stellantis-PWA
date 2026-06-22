# Release Runbook

## Overview

Codemagic builds both Android (APK/AAB) and iOS (IPA) from the `mobile/` Flutter project.
Shorebird handles Dart-only code patches that deploy without a full store review cycle.

Two Codemagic workflows are defined in `codemagic.yaml` at the repo root:

| Workflow | Trigger | Output | Distribution |
|---|---|---|---|
| `android-release` | push to `main` | APK | Firebase App Distribution → internal-testers |
| `ios-release` | push to `main` | IPA | TestFlight via App Store Connect API |

---

## Prerequisites

| Tool | Version |
|---|---|
| Flutter | stable (3.x) |
| Dart | 3.x |
| Android Studio | Hedgehog or later |
| Xcode | 15+ (macOS only) |
| Codemagic account | codemagic.io |
| Apple Developer account | developer.apple.com |
| Google Play Console account | play.google.com/console |
| Shorebird account | shorebird.dev |

---

## Android Signing

The release build reads its signing config from `mobile/android/key.properties`
(gitignored) and falls back to debug keys when that file is absent — so local
`flutter run --release` works without a keystore. See
`mobile/android/key.properties.example` for the format.

1. Generate a keystore (keep this file out of version control):
   ```sh
   keytool -genkey -v \
     -keystore stellantis.keystore \
     -alias stellantis \
     -keyalg RSA -keysize 2048 \
     -validity 10000
   ```
2. **Local release builds:** copy `key.properties.example` to
   `mobile/android/key.properties` and fill in `storeFile`, `storePassword`,
   `keyAlias`, `keyPassword`.
3. **CI:** in Codemagic → App Settings → Code Signing → Android, upload the
   keystore and name it `stellantis_keystore` (matches the reference in
   `codemagic.yaml`). Codemagic injects it and generates `key.properties` for
   the build automatically — do not commit a real `key.properties`.

---

## iOS Signing

1. Create an App Store Connect API key at
   App Store Connect → Users and Access → Integrations → App Store Connect API.
   Download the `.p8` file.
2. In Codemagic → App Settings → Code Signing → iOS, choose **Automatic** and paste
   the `.p8` contents.
3. Set the following environment variables in Codemagic:

   | Variable | Value |
   |---|---|
   | `APP_STORE_CONNECT_PRIVATE_KEY` | contents of the `.p8` file |
   | `APP_STORE_CONNECT_KEY_IDENTIFIER` | Key ID from App Store Connect |
   | `APP_STORE_CONNECT_ISSUER_ID` | Issuer ID from App Store Connect |

Bundle identifier: `com.stellantis.app.stellantisMobile` (matches `codemagic.yaml`
`ios-release` and `mobile/ios/Runner.xcodeproj`). The Android applicationId is
`com.stellantis.app.stellantis_mobile` (underscores are invalid in iOS bundle ids,
hence the per-platform spelling).

---

## First-Time Setup Checklist

- [ ] Register bundle ID `com.stellantis.app.stellantisMobile` in Apple Developer portal
- [ ] Create App Store listing skeleton in App Store Connect (name, category, description)
- [ ] Set up the **TestFlight internal testing** group and add internal testers (plan 9.4)
- [ ] Create Play Console listing skeleton (app name, default language, AAB uploaded)
- [ ] Set up the Play **Internal Testing** track and add testers (plan 9.3)
- [ ] Configure Firebase project and App Distribution group `internal-testers` (plan 9.5)
- [ ] Set `FIREBASE_TOKEN` and `FIREBASE_ANDROID_APP_ID` env vars in Codemagic
- [ ] Connect Codemagic to the GitHub repo and enable both workflows on `main`
- [ ] Run `shorebird init` inside `mobile/` to replace the placeholder `app_id`
      in `mobile/shorebird.yaml`, then commit it (plan 9.6)

---

## Releasing a Build

1. Merge your branch into `main`.
2. Codemagic detects the push and starts both workflows automatically.
3. Android: APK is published to Firebase App Distribution → `internal-testers` group.
   Testers receive an email with a download link.
4. iOS: IPA is uploaded to TestFlight. TestFlight sends a notification to internal testers.
5. Promote to production:
   - Android: promote the APK to AAB and submit through Play Console.
   - iOS: promote the TestFlight build to App Store review in App Store Connect.

---

## Shorebird Code Push

Shorebird lets you ship Dart-only patches (no native changes) without store review.

### Before a new store release

```sh
# Inside mobile/
shorebird release android  # creates the baseline patch for Android
shorebird release ios      # creates the baseline patch for iOS
```

### Dart-only hotfix

```sh
shorebird patch android    # pushes a patch to Android devices
shorebird patch ios        # pushes a patch to iOS devices
```

Patches are delivered OTA to users within minutes. Native code changes still require a
full store release. See Phase 9 for the complete Shorebird setup (keys, channels, CI
integration).

---

## Cutting the v1.0.0-beta.1 Beta

Do this only once the Phase 1–9 quality gates pass (`flutter analyze` clean,
`flutter test` green, release builds succeed on both platforms):

1. Bump `version:` in `mobile/pubspec.yaml` to `1.0.0-beta.1+1`.
2. Update `CHANGELOG.md` — move items from *Unreleased* into a dated
   `1.0.0-beta.1` section.
3. Commit `chore(release): v1.0.0-beta.1` and tag:
   ```sh
   git tag v1.0.0-beta.1
   git push --tags
   ```
4. Codemagic builds and distributes to the TestFlight internal group and
   Firebase App Distribution `internal-testers`.
5. Monitor crash-free sessions (target > 99% over the 1-week beta window).

---

## Environment Variables Reference

| Variable | Workflow | Purpose |
|---|---|---|
| `PACKAGE_NAME` | android-release | APK package name (`com.stellantis.app.stellantis_mobile`) |
| `FIREBASE_TOKEN` | android-release | Firebase CLI token for App Distribution |
| `FIREBASE_ANDROID_APP_ID` | android-release | Firebase Android app ID |
| `BUNDLE_ID` | ios-release | iOS bundle identifier (`com.stellantis.app.stellantisMobile`) |
| `APP_STORE_CONNECT_PRIVATE_KEY` | ios-release | App Store Connect API key (`.p8` contents) |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | ios-release | App Store Connect API key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | ios-release | App Store Connect issuer ID |
