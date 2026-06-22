# Security model

> How the app handles brand secrets, user tokens, transport security, and what
> an attacker can and cannot do. This is a client-only app: there is no
> backend to compromise, but that also means the client holds material the
> official MyPeugeot/MyCitroën apps hold, with the same trust assumptions.

---

## 1. Threat model

| Actor | Capability assumed | In scope |
|---|---|---|
| Network attacker | Can observe/modify traffic on the wire | ✅ mitigated by TLS + cert validation |
| Malicious app on the same device | Can read world-readable storage | ✅ mitigated by Keychain/Keystore |
| Device thief (locked device) | Physical access, no unlock | ✅ tokens at-rest encrypted by the OS |
| Device thief (unlocked device) | Full access as the user | ⚠️ out of scope — same as any banking app |
| APK/IPA reverse-engineer | Can extract baked-in brand secrets | ⚠️ accepted — see §2 |
| Stellantis cloud | Trusted endpoint | Trusted |

**Accepted risk:** the per-brand OAuth `client_id` / `client_secret` are shipped
in the app binary. This is unavoidable for a no-backend design and is exactly
what the official apps do — the secrets are *brand* credentials, not *user*
credentials, and grant nothing without a user's own OAuth login. Mitigation is
**rotation** (Shorebird hotpatch / nightly rebuild), not secrecy.

---

## 2. Brand secrets (client_id / client_secret / inWebo site codes)

- Extracted once from the official APK by
  [`tools/extract_secrets/`](../tools/extract_secrets) into
  `mobile/lib/stellantis/brands/secrets.dart`.
- That file is **gitignored** and must never be committed. The repo ships only
  [`secrets_template.dart`](../mobile/lib/stellantis/brands/secrets_template.dart)
  with empty values. CI injects the real file from an encrypted environment
  variable at build time.
- `secrets.dart` is imported **only** from within `stellantis/brands/`. No
  other layer references it (enforced in review — see
  [ARCHITECTURE.md §9](ARCHITECTURE.md)).
- **Rotation path:** if Stellantis rotates a secret, ship a new `secrets.dart`
  via a Shorebird code-push patch without a store review cycle, and the nightly
  CI rebuild detects the break.

> ⚠️ If a real secret is ever committed by accident, treat it as compromised:
> rotate via Shorebird **and** purge it from git history (`git filter-repo`),
> then force-push. A `.gitignore` entry does not undo an already-committed
> secret.

---

## 3. User tokens (OAuth access + refresh)

- Stored via **flutter_secure_storage**
  ([`auth_storage.dart`](../mobile/lib/stellantis/auth/auth_storage.dart)) —
  iOS **Keychain**, Android **EncryptedSharedPreferences** backed by the
  Keystore. Keys: `psa_access_token`, `psa_refresh_token`, `psa_expires_at`.
- Tokens are **never** written to logs, Isar, SharedPreferences, or crash
  reports. `AppLogger` must never receive a token argument.
- `AuthStorage.clear()` wipes all three keys on logout/session reset.
- The OAuth flow is **Authorization Code + PKCE** in the system browser
  (`flutter_web_auth_2`) — the app never sees the user's password, and the
  authorization code is bound to the PKCE `code_verifier` the app generated.

### Token refresh
`token_refresh_interceptor.dart` refreshes on a 401 exactly once per request
and replays it. A failed refresh forces a re-login rather than silently
retrying with stale credentials.

---

## 4. MQTT remote-command credentials

- Derived during **OTP setup** (SMS + PIN) in
  [`stellantis/otp/`](../mobile/lib/stellantis/otp); the resulting remote
  credentials are stored in secure storage alongside the OAuth tokens.
- Commands travel over **MQTTS** (TLS, port 8885) to the official broker.
- The PIN entered during setup is used to derive credentials and is not
  persisted in plaintext.

---

## 5. Transport security

- All REST traffic is HTTPS to `*.peugeot.com`, `*.citroen.com`,
  `*.driveds.com`, `*.opel.com`, `*.vauxhall.co.uk`, and
  `api.groupe-psa.com`. Default Dio TLS validation is **not** disabled.
- MQTT uses TLS to `mwa.mpsa.com:8885`.
- **Certificate pinning** is a known follow-up: if the broker or IdP rotates
  certs, pin updates ship via Shorebird and handshake failures are monitored
  in crash reporting (see the risk table in
  [MIGRATION_PLAN.md §7](../MIGRATION_PLAN.md)).

---

## 6. Local data at rest

- Vehicle status, trips, charges, and analytics live in **Isar**, which is not
  encrypted by default. This is non-sensitive telemetry (battery %, mileage,
  positions) — comparable to what a maps app caches. It contains **no
  credentials**.
- If position history is later deemed sensitive, enable Isar encryption with a
  key stored in secure storage. Tracked as a follow-up, not shipped in v1.0.

---

## 7. Platform privacy disclosures

- **iOS:** a `PrivacyInfo.xcprivacy` manifest declares the data categories
  collected (precise location, vehicle identifiers) and the required-reason
  APIs used (`UserDefaults`, file timestamps). Kept in sync with the app's
  actual behaviour.
- **Android:** the Play **Data Safety** form declares location + device
  identifiers, collected and stored on-device, transmitted only to the
  Stellantis cloud, never sold or shared with third parties.

---

## 8. Reporting a vulnerability

This is a personal/independent project. Open a private security advisory on the
repository host rather than a public issue. Do not include real tokens or
secrets in the report.
