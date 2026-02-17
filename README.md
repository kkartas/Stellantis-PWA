# Stellantis PWA Car Controller

Python backend for Stellantis/PSA connected vehicles with an installable Progressive Web App frontend.

## What This Refactor Delivers

- Flask API + static PWA frontend (no Dash runtime dependency for the UI path)
- Installable app (`manifest.webmanifest` + service worker)
- Offline shell support with cached app assets
- Mobile-first interface with tabs for:
  - Overview (status + summary)
  - Vehicle controls
  - Trips
  - Charging sessions
  - Settings
  - Setup (login/oauth/otp)
- Legacy HTTP endpoints kept for backward compatibility

## Core Features Kept

- Vehicle status and refresh/wakeup
- Start/stop charging
- Charge threshold and stop-hour control
- Delayed charge hour update
- Preconditioning control
- Lights/horn control
- Door lock/unlock
- Trips and charging session retrieval
- Battery SOH and ABRP integration controls
- Config updates through API/UI

## Quick Start

1. Install requirements (Python 3.11+ recommended):

```bash
pip install -e .
```

2. Start the controller:

```bash
psa-car-controller --web-conf -c -r
```

3. Open the app:

```text
http://localhost:5000
```

4. Install the PWA from your browser (desktop or mobile) using the browser install prompt.

## New API Surface (`/api/*`)

- `GET /api/health`
- `GET /api/vehicles`
- `GET /api/vehicle/<vin>`
- `GET /api/dashboard/<vin>`
- `GET /api/trips?vin=<vin>`
- `GET /api/chargings?vin=<vin>`
- `GET /api/settings`
- `GET|POST /api/settings/<section>`
- `POST /api/vehicle/<vin>/wakeup`
- `POST /api/vehicle/<vin>/charge`
- `POST /api/vehicle/<vin>/preconditioning`
- `POST /api/vehicle/<vin>/horn`
- `POST /api/vehicle/<vin>/lights`
- `POST /api/vehicle/<vin>/doors`
- `POST /api/vehicle/<vin>/charge-hour`
- `POST /api/vehicle/<vin>/charge-control`
- `POST /api/vehicle/<vin>/abrp`
- `POST /api/setup/login`
- `POST /api/setup/oauth`
- `POST /api/setup/otp/sms`
- `POST /api/setup/otp`

## Legacy API Compatibility

Existing endpoints like `/get_vehicleinfo/<vin>`, `/charge_now/...`, `/settings`, `/vehicles/trips`, etc. are still available.

## Documentation

- Install: `docs/Install.md`
- Docker: `docs/Docker.md`
- API examples (legacy): `docs/psacc_api.md`
- PWA architecture: `docs/PWA.md`
- FAQ: `FAQ.md`

## Windows OAuth Note

If Peugeot OAuth opens `mymap://...` and desktop browser cannot continue, register the Windows protocol bridge:

```powershell
powershell -ExecutionPolicy Bypass -File .\tools\register-mymap-protocol.ps1
```
