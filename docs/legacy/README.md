# docs/legacy/

Reference material preserved from the legacy Python project.

| Sub-directory | Contents |
|---|---|
| `brands/` | SVG brand logos from the legacy PWA (`psa_car_controller/web/pwa/brands/`), restored in Phase 0 step 0.5 |
| `sample_data/` | Gitignored. Placeholder for local copies of `info.db`, `config.json`, `cars.json`, `otp.bin`, etc. See `sample_data/README.md`. |

## What was removed

### backend/ (abandoned FastAPI scaffold, March 2026)

An intermediate FastAPI + Flutter split was attempted (`backend/` + `mobile/`). The backend
wrapped the Stellantis API behind a bespoke REST layer with encrypted session storage. It was
abandoned in favour of the current architecture: a single Flutter app that speaks directly to
the Stellantis cloud. See `MIGRATION_PLAN.md` for rationale.

The backend scaffold comprised:
- `backend/app/main.py` — FastAPI bootstrap
- `backend/app/api/routes/` — auth, commands, health, vehicles endpoints
- `backend/app/clients/stellantis_client.py` — thin PSA API proxy
- `backend/app/repositories/session_repository.py` — encrypted SQLite session store
- `backend/app/services/` — auth, command, vehicle services
- `backend/requirements.txt` — FastAPI, uvicorn, pydantic, cryptography

`API_CONTRACT.md` and `MIGRATION_NOTES.md` documented this abandoned backend; both removed.
