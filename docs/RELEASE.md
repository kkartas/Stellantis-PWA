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

1. Generate a keystore (keep this file out of version control):
   ```sh
   keytool -genkey -v \
     -keystore stellantis.keystore \
     -alias stellantis \
     -keyalg RSA -keysize 2048 \
     -validity 10000
   ```
2. In Codemagic → App Settings → Code Signing → Android, upload `stellantis.keystore`
   and name it `stellantis_keystore` (matches the reference in `codemagic.yaml`).
3. Set the following environment variables in Codemagic App Settings → Environment variables:

   | Variable | Value |
   |---|---|
   | `KEY_ALIAS` | the alias used in keytool (e.g. `stellantis`) |
   | `KEY_PASSWORD` | key password |
   | `STORE_PASSWORD` | keystore password |

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

Bundle identifier: `com.stellantis.app` (matches `codemagic.yaml` and `mobile/ios/Runner/Info.plist`).

---

## First-Time Setup Checklist

- [ ] Register bundle ID `com.stellantis.app` in Apple Developer portal
- [ ] Create App Store listing skeleton in App Store Connect (name, category, description)
- [ ] Create Play Console listing skeleton (app name, default language, APK uploaded)
- [ ] Configure Firebase project and App Distribution group `internal-testers`
- [ ] Set `FIREBASE_TOKEN` and `FIREBASE_ANDROID_APP_ID` env vars in Codemagic
- [ ] Connect Codemagic to the GitHub repo and enable both workflows on `main`
- [ ] Run `shorebird init` inside `mobile/` and commit `shorebird.yaml` (Phase 9)

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

## Environment Variables Reference

| Variable | Workflow | Purpose |
|---|---|---|
| `PACKAGE_NAME` | android-release | APK package name (`com.stellantis.app`) |
| `FIREBASE_TOKEN` | android-release | Firebase CLI token for App Distribution |
| `FIREBASE_ANDROID_APP_ID` | android-release | Firebase Android app ID |
| `BUNDLE_ID` | ios-release | iOS bundle identifier |
| `APP_STORE_CONNECT_PRIVATE_KEY` | ios-release | App Store Connect API key (`.p8` contents) |
| `APP_STORE_CONNECT_KEY_IDENTIFIER` | ios-release | App Store Connect API key ID |
| `APP_STORE_CONNECT_ISSUER_ID` | ios-release | App Store Connect issuer ID |
