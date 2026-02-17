# PSACC API

These links work when PSACC runs locally. If hosted elsewhere, replace `localhost` with your PSACC server address.

## 1. PWA API (recommended)

- `GET  /api/health`
- `GET  /api/vehicles`
- `GET  /api/vehicle/<VIN>`
- `GET  /api/dashboard/<VIN>`
- `GET  /api/trips?vin=<VIN>`
- `GET  /api/chargings?vin=<VIN>`
- `GET  /api/settings`
- `GET|POST /api/settings/<section>`
- `POST /api/vehicle/<VIN>/wakeup`
- `POST /api/vehicle/<VIN>/charge` with `{ "enabled": true|false }`
- `POST /api/vehicle/<VIN>/preconditioning` with `{ "enabled": true|false }`
- `POST /api/vehicle/<VIN>/horn` with `{ "count": 1 }`
- `POST /api/vehicle/<VIN>/lights` with `{ "duration": 10 }`
- `POST /api/vehicle/<VIN>/doors` with `{ "lock": true|false }`
- `POST /api/vehicle/<VIN>/charge-hour` with `{ "hour": 22, "minute": 30 }`
- `POST /api/vehicle/<VIN>/charge-control` with `{ "percentage": 80, "hour": 6, "minute": 0 }`
- `POST /api/vehicle/<VIN>/abrp` with `{ "enabled": true, "token": "..." }`
- Setup:
  - `POST /api/setup/login`
  - `POST /api/setup/oauth`
  - `POST /api/setup/otp/sms`
  - `POST /api/setup/otp`

## 2. Legacy API (kept for compatibility)

1. Get car state

   `http://localhost:5000/get_vehicleinfo/YOURVIN`

2. Get car state from cache

   `http://localhost:5000/get_vehicleinfo/YOURVIN?from_cache=1`

3. Stop charge

   `http://localhost:5000/charge_now/YOURVIN/0`

4. Set stop hour for charge (example: 06:00)

   `http://localhost:5000/charge_control?vin=YOURVIN&hour=6&minute=0`

5. Set charge threshold (example: 80%)

   `http://localhost:5000/charge_control?vin=YOURVIN&percentage=80`

6. Open PWA

   `http://localhost:5000`

7. Wakeup (request state push)

   `http://localhost:5000/wakeup/YOURVIN`

8. Start (1) / Stop (0) preconditioning

   `http://localhost:5000/preconditioning/YOURVIN/1`

9. Change delayed charge hour (example: 22:30)

   `http://localhost:5000/charge_hour?vin=YOURVIN&hour=22&minute=30`

10. Horn

    `http://localhost:5000/horn/YOURVIN/count`

11. Lights

    `http://localhost:5000/lights/YOURVIN/duration`

12. Lock (1) / Unlock (0) doors

    `http://localhost:5000/lock_door/YOURVIN/1`

13. Get config

    `http://localhost:5000/settings`

14. Update config parameter (restart recommended)

    `http://localhost:5000/settings/electricity_config?night_price=0.2`

15. Get battery SOH

    `http://localhost:5000/battery/soh/YOURVIN`

16. Get charging sessions

   `http://localhost:5000/vehicles/chargings`

17. Get trips

   `http://localhost:5000/vehicles/trips`
