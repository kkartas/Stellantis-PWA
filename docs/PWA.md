# PWA Architecture

## Runtime Model

The app now runs as:

- Python service layer (existing PSA logic, remote control, persistence)
- Flask HTTP server
- Static Progressive Web App frontend served by Flask

Dash-driven pages are no longer used as the primary UI runtime.

## Main Components

- Server bootstrap: `psa_car_controller/web/app.py`
- API + static PWA routes: `psa_car_controller/web/view/api.py`
- PWA frontend files: `psa_car_controller/web/pwa/`
  - `index.html`
  - `styles.css`
  - `app.js`
  - `manifest.webmanifest`
  - `service-worker.js`
  - `offline.html`

## PWA Capabilities

- Installable app via browser prompt
- App shell caching for offline startup
- Cached API responses (best-effort) through service worker
- Responsive mobile + desktop layout

## Setup Flow in PWA

Use the `Setup` tab:

1. Login setup (`/api/setup/login`) with brand app, email, password, country code
2. Complete OAuth (`/api/setup/oauth`) with redirect code
3. Request SMS (`/api/setup/otp/sms`)
4. Finish OTP (`/api/setup/otp`)

## Backward Compatibility

Legacy endpoints remain available for existing automations and scripts.

## Desktop OAuth Bridge (Windows)

Peugeot login redirects to the mobile deep-link scheme `mymap://...`, which a browser cannot handle by default on desktop.

Use the protocol bridge scripts in `tools/`:

1. Register protocol handler (current user):

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\register-mymap-protocol.ps1
```

2. Start PSACC and run setup normally from the PWA.
3. After Peugeot consent, `mymap://...` is opened by Windows and forwarded to:
   - `POST /api/setup/oauth` with extracted `code`
4. To remove integration later:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\unregister-mymap-protocol.ps1
```

Optional environment overrides:

- `PSACC_OAUTH_API_URL` (default: `http://127.0.0.1:5000/api/setup/oauth`)
- `PSACC_UI_URL` (default: `http://127.0.0.1:5000/`)
- `PSACC_HANDLER_SHOW_UI=1` (show popup messages)

Protocol test helper:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\test-mymap-protocol.ps1 -Code DEMO123
```

Handler log file (best effort):

- `%LOCALAPPDATA%\psacc-mymap-handler.log`

## Notes

- Base path deployments are preserved through existing dispatcher middleware behavior.
- CORS wildcard remains enabled for API responses (`Access-Control-Allow-Origin: *`).
