# Legacy Feature Audit

> Generated during Phase 0. This document is the authoritative snapshot of everything the Python
> `psa_car_controller` project shipped. After Phase 10 deletes the Python code, this file remains
> as the specification for what was ported and where.
>
> Cross-reference: `MIGRATION_PLAN.md §1` for the Flutter landing zone per feature.

---

## 1. Authentication & Setup

### 1.1 OAuth2 flow

**Module:** `psa_car_controller/psa/oauth.py`  
**Class:** `OpenIdCredentialManager` (wraps `oauthlib` / `requests-oauthlib`)

- PKCE-based OAuth2 Authorization Code flow.
- Separate IdP endpoints per brand (see §1.3 for URLs).
- Token refresh is performed automatically before API calls.
- `refresh_token` is written to `config.json` and loaded on restart.
- `remote_refresh_token` is a second token specifically for MQTT remote-access; stored separately in `config.json`.

### 1.2 APK secret extraction

**Module:** `psa_car_controller/psa/setup/app_decoder.py`  
**Helpers:** `psa_car_controller/psa/setup/apk_parser.py`, `psa_car_controller/psa/setup/github.py`

- Downloads the official `MyPeugeot` (or other brand) APK from a known source.
- Parses the APK using `androguard` (static analysis) to extract the embedded OAuth2 `client_id` and `client_secret`.
- Results are cached for 24 hours in `.psacc_cache/apk_setup_cache.json`.
- `InitialSetup` class wires together: APK download → secret extraction → PSAClient construction → first OAuth login.
- **Working-tree change noted:** `InitialSetup.__init__` was parameterised with `scopes`, `cars_file`, `otp_file`, `config_file` arguments during the abandoned backend migration, so that multiple isolated sessions could share the same codebase.
- **Working-tree change noted:** `app` global in `app_decoder.py` was made lazily initialised (`_controller()` factory) to prevent import-time side effects.

### 1.3 Brand-specific constants

**Module:** `psa_car_controller/psa/constants.py`

| Brand | realm (OAuth realm key) | OAuth token URL | redirect scheme | brand_code | MQTT brand |
|---|---|---|---|---|---|
| Peugeot | `clientsB2CPeugeot` | `https://idpcvs.peugeot.com/am/oauth2/access_token` | `mymap://` | `AP` | `AP` |
| Citroën | `clientsB2CCitroen` | `https://idpcvs.citroen.com/am/oauth2/access_token` | `mymacsdk://` | `AC` | `AC` |
| DS | `clientsB2CDS` | `https://idpcvs.driveds.com/am/oauth2/access_token` | `mymdssdk://` | `DS` | `AC` |
| Opel | `clientsB2COpel` | `https://idpcvs.opel.com/am/oauth2/access_token` | `mymopsdk://` | `OP` | `OV` |
| Vauxhall | `clientsB2CVauxhall` | `https://idpcvs.vauxhall.co.uk/am/oauth2/access_token` | `mymvxsdk://` | `VX` | `OV` |

Authorize endpoints (`AUTHORIZE_SERVICE`):
- Peugeot: `https://idpcvs.peugeot.com/am/oauth2/authorize`
- Citroën: `https://idpcvs.citroen.com/am/oauth2/authorize`
- DS: `https://idpcvs.driveds.com/am/oauth2/authorize`
- Opel: `https://idpcvs.opel.com/am/oauth2/authorize`
- Vauxhall: `https://idpcvs.vauxhall.co.uk/am/oauth2/authorize`

Package-name → brand mapping (`BRAND` dict):
- `com.psa.mym.mypeugeot` → Peugeot / AP
- `com.psa.mym.mycitroen` → Citroën / AC
- `com.psa.mym.myds` → DS / DS
- `com.psa.mym.myopel` → Opel / OP
- `com.psa.mym.myvauxhall` → Vauxhall / VX

**Flutter landing zone:** `lib/stellantis/brands/` — per-brand constants Dart file; secrets extracted via `tools/extract_secrets/`.

### 1.4 SMS OTP / remote-command credentials

**Module:** `psa_car_controller/psa/otp/otp.py`  
**Sub-modules:** `otp/load.py`, `otp/oaep.py`, `otp/tokenizer.py`

- Implements a TOTP-like OTP scheme using RSA/OAEP encryption (not standard TOTP).
- `Otp` class manages the activation handshake:
  1. `activation_start()` — sends OTP request to Stellantis.
  2. `activation_finalyze()` — completes the handshake with the SMS code + PIN.
- `new_otp_session(smscode, codepin)` — full lifecycle; on success calls `save_otp()`.
- `save_otp(obj, filename="otp.bin")` — pickles the `Otp` object to disk. In working-tree changes, `Path.parent.mkdir(parents=True, exist_ok=True)` was added to support session-isolated file paths.
- `load_otp(filename)` — unpickles; returns `None` if file absent.
- `CONFIG_NAME = "otp.bin"` (default file).
- OTP code generation is rate-limited: **6 codes per day** (enforced in `RemoteClient.get_otp_code()`).
- SMS request endpoint: `POST https://api.groupe-psa.com/applications/cvs/v4/mobile/smsCode?client_id={client_id}`

**Flutter landing zone:** `lib/features/auth/data/otp_service.dart`

### 1.5 Account information

**Module:** `psa_car_controller/psa/AccountInformation.py`  
**Class:** `AccountInformation(client_id, customer_id, realm, country_code)`

- `get_mqtt_customer_id()` translates the raw `customer_id` prefix to the MQTT brand prefix:
  - `AP…` → `AP…`, `AC…` → `AC…`, `DS…` → `AC…`, `VX…` → `OV…`, `OP…` → `OV…`
- The `customer_id` is opaque per account; retrieved from the Stellantis API `/user` endpoint.

---

## 2. REST API Surface

**Generated client:** `psa_car_controller/psa/connected_car_api/` (130 model files, 3 API files)  
**Base URL pattern:** `https://api.groupe-psa.com/connectedcar/v4/` (configured in `connected_car_api/configuration.py`)  
**Auth header:** Bearer token from OAuth2 flow; `x-introspect-realm: {realm}`, `User-Agent: okhttp/4.8.0`

### 2.1 User API (`user_api.py`)

| Method | HTTP | Path | Description |
|---|---|---|---|
| `get_user` | GET | `/user` | Returns account info: customer_id, email, brand, locale |

Key response model: `User`, `UserEmbedded`, `UserLinks`

### 2.2 Vehicles API (`vehicles_api.py`)

| Method | HTTP | Path | Description |
|---|---|---|---|
| `get_vehicles_by_device` | GET | `/user/vehicles` | List all vehicles linked to account |
| `get_vehicle_byid` | GET | `/user/vehicles/{id}` | Single vehicle metadata |
| `get_vehicle_status` | GET | `/user/vehicles/{id}/status` | Full live status snapshot |
| `get_car_last_position` | GET | `/user/vehicles/{id}/lastPosition` | Last GPS position |
| `get_telemetry` | GET | `/user/vehicles/{id}/telemetry` | Telemetry history (paginated) |
| `get_vehicle_alerts` | GET | `/user/vehicles/{id}/alerts` | Active alerts |
| `get_vehicle_alerts_by_id` | GET | `/user/vehicles/{id}/alerts/{aid}` | Single alert |
| `get_vehicle_maintenance` | GET | `/user/vehicles/{id}/maintenance` | Maintenance schedule |
| `get_vehicle_monitors` | GET | `/user/vehicles/{id}/monitors` | Geo-fence / event monitors |
| `get_vehicle_monitors_by_id` | GET | `/user/vehicles/{id}/monitors/{mid}` | Single monitor |
| `set_vehicle_monitor` | POST | `/user/vehicles/{id}/monitors` | Create geo-fence monitor |
| `set_fleet_vehicle_monitor_status` | PUT | `/user/vehicles/{id}/monitors/{mid}` | Update monitor status |
| `delete_monitordd` | DELETE | `/user/vehicles/{id}/monitors/{mid}` | Delete monitor |
| `get_vehicle_collision` | GET | `/user/vehicles/{id}/collisions` | Collision events |
| `get_vehicle_collision_by_id` | GET | `/user/vehicles/{id}/collisions/{cid}` | Single collision |

Key status sub-models used in `get_vehicle_status`:
- `Energy` — level (%), type (Electric/Fuel), range, consumption
- `EnergyBattery` — voltage, current
- `EnergyBatteryHealth` — capacity, resistance, SOH-related fields
- `EnergyCharging` — status (enum), mode (Quick/Slow), next_delayed_time, charging_rate
- `ChargingStatusEnum` — Disconnected, InProgress, Failure, Stopped, Finished
- `DoorsState` / `DoorsStateOpening` — door open/locked state per door
- `Kinetic` — speed, acceleration
- `Environment` / `EnvironmentLuminosity` — ambient temperature, luminosity
- `Ignition` — state (StartUp/Stop/Accessory/Free)
- `Lighting` — front/rear lighting state
- `Safety` — seat-belt, e-call
- `Preconditioning` / `PreconditioningAirConditioning` — AC state, programs
- `PreconditioningProgram` — scheduled AC programs
- `Privacy` — state
- `Engine` / `EngineOil` — oil level, temperature
- `Maintenance` — oil change due, brake fluid, service items
- `Position` — GeoJSON Feature with geometry.coordinates [lon, lat]
- `Geometry` / `Point` — GeoJSON geometry
- `VehicleOdometer` — mileage
- `ADAS` / `ADASparkAssist` — driver-assist state
- `Overall autonomy` — calculated total range
- `Status` / `StatusEmbedded` / `StatusLinks` — root envelope
- `Alerts` / `Alert` — warning messages

### 2.3 Trips API (`trips_api.py`)

| Method | HTTP | Path | Description |
|---|---|---|---|
| `get_user_trips` | GET | `/user/trips` | All trips for the account |
| `get_trips_by_vehicle_1` | GET | `/user/vehicles/{id}/trips` | Trips for a specific vehicle |
| `get_trip_by_vehicle` | GET | `/user/vehicles/{id}/trips/{tid}` | Single trip detail |
| `get_telemetry_for_trip_0` | GET | `/user/vehicles/{id}/trips/{tid}/telemetry` | Trip telemetry |
| `get_path_for_trip_0` | GET | `/user/vehicles/{id}/trips/{tid}/path` | Trip GPS path (waypoints) |
| `get_vehicle_trip_alerts` | GET | `/user/vehicles/{id}/trips/{tid}/alerts` | Alerts during trip |
| `get_vehicle_collisions_by_trip_id` | GET | `/user/vehicles/{id}/trips/{tid}/collisions` | Collisions during trip |

Key trip models: `Trip`, `TripAvgConsumption`, `TripLinks`, `Trips`, `TripsEmbedded`, `WayPoints`, `WayPointsEmbedded`, `Telemetry`, `TelemetryEmbedded`, `TelemetryMessage`

---

## 3. MQTT Commands

**Module:** `psa_car_controller/psa/RemoteClient.py`  
**Request builder:** `psa_car_controller/psa/mqtt_request.py`

### 3.1 Broker configuration

| Parameter | Value |
|---|---|
| Broker host | `mwa.mpsa.com` |
| Transport | MQTTS (TLS) |
| MQTT username | `IMA_OAUTH_ACCESS_TOKEN` |
| MQTT password | Remote access token (refreshed via `_refresh_remote_token`) |
| Remote token TTL | 890 seconds |
| Remote token URL | `https://api.groupe-psa.com/connectedcar/v4/virtualkey/remoteaccess/token?client_id={client_id}` |
| Remote token grant types | `password` (initial, using OTP code) / `refresh_token` (subsequent) |

### 3.2 Topic structure

```
Publish:   psa/RemoteServices/from/cid/{mqtt_customer_id}/{command_suffix}
Subscribe: psa/RemoteServices/to/cid/{mqtt_customer_id}/#
Events:    psa/RemoteServices/events/MPHRTServices/{vin}
```

`mqtt_customer_id` is derived from `AccountInformation.get_mqtt_customer_id()` which applies the brand-code prefix mapping (see §1.5).

### 3.3 Message envelope

Every publish carries:
```json
{
  "access_token": "<remote_access_token>",
  "customer_id": "<customer_id>",
  "correlation_id": "<uuid_without_dashes><timestamp_microseconds>",
  "req_date": "<UTC ISO8601>",
  "vin": "<VIN>",
  "req_parameters": { ... }
}
```

### 3.4 Commands

| Command | Suffix | `req_parameters` payload | Notes |
|---|---|---|---|
| Horn | `/Horn` | `{"nb_horn": 1, "action": "activate"}` | Hardcoded to 1 horn (was parametric before backend migration) |
| Lights | `/Lights` | `{"action": "activate", "duration": 10}` | Hardcoded 10s (was parametric before backend migration) |
| Wake-up | `/VehCharge/state` | `{"action": "state"}` | Rate-limited: 6 per 20 min |
| Lock | `/Doors` | `{"action": "lock"}` | |
| Unlock | `/Doors` | `{"action": "unlock"}` | |
| Precondition ON | `/ThermalPrecond` | `{"asap": "activate", "programs": <programs_dict>}` | Falls back to `DEFAULT_PRECONDITIONING_PROGRAM` |
| Precondition OFF | `/ThermalPrecond` | `{"asap": "deactivate", "programs": <programs_dict>}` | |
| Charge now | `/VehCharge` | `{"program": {"hour": h, "minute": m}, "type": "immediate"}` | Hour/minute from `next_delayed_time` |
| Charge delayed | `/VehCharge` | `{"program": {"hour": h, "minute": m}, "type": "delayed"}` | |

Default preconditioning programs structure:
```python
DEFAULT_PRECONDITIONING_PROGRAM = {
    "program1": {"day": [0,0,0,0,0,0,0], "hour": 34, "minute": 7, "on": 0},
    "program2": {"day": [0,0,0,0,0,0,0], "hour": 34, "minute": 7, "on": 0},
    "program3": {"day": [0,0,0,0,0,0,0], "hour": 34, "minute": 7, "on": 0},
    "program4": {"day": [0,0,0,0,0,0,0], "hour": 34, "minute": 7, "on": 0}
}
```

### 3.5 MQTT session lifecycle

1. `RemoteClient.start()` — connects MQTT client, subscribes to response + event topics, starts a keep-alive thread.
2. `__keep_mqtt()` — background thread that refreshes the remote token before it expires (every 890s).
3. `_on_mqtt_disconnect()` — on disconnect code 1: force-refreshes token. On code 5: sets `otp_expired` error.
4. `_on_mqtt_message()` — parses incoming JSON responses; matches `correlation_id` to `last_request`; calls `_fix_not_updated_api()` for charging status workaround.
5. `RemoteClient.stop()` — disconnects MQTT.

**Flutter landing zone:** `lib/stellantis/mqtt/` — MQTT command client using `mqtt_client` package.

---

## 4. Trip & Charging Detection

### 4.1 Trip parser

**Module:** `psa_car_controller/psacc/application/trip_parser.py`  
**Class:** `TripParser(car: Car)`

Detection logic (applied to pairs of consecutive `position` DB rows):

- `get_thermal_consumption(start, end)` — fuel L/100km from mileage delta and level_fuel delta.
- `get_elec_consumption(start, end)` — kWh/100km from mileage delta and electric level delta.
- `get_hybrid_consumption(start, end)` — combines both energy methods for PHEV.
- `__get_energy_method()` — selects the right consumption method based on `Car.is_electric()` / `is_thermal()` / `is_hybrid()`.
- `__is_refuel_or_recharging(start, end, distance)` — gates trip detection: returns `True` if the delta looks like a refuel or recharge (not a genuine trip).
- `__is_refuel(start, end, distance)` — fuel level increase > small threshold and low distance → refuel.
- `__is_recharging(start, end, distance)` — delegates to `is_recharging()`.
- `is_recharging(decharge, distance) ` — classifies as recharge if energy lost per km is implausibly high.
- `is_low_speed(speed_average, duration)` — flags trips where average speed is too low relative to duration (parking / slow traffic filter).

Trips are stored in the `position` table; trip boundaries are inferred from data, not explicitly recorded. A separate `trips` repository (`psacc/repository/trips.py`) aggregates position rows.

**Flutter landing zone:** `lib/features/trips/data/trip_parser.dart`

### 4.2 Charging detection

**Module:** `psa_car_controller/psacc/application/charging.py`

Key functions:
- `get_chargings()` — reads all charge sessions from `info.db`.
- `record_charging(car, charging_status, charge_date, level, latitude, longitude, mileage)` — writes a new row or updates current charge session in `battery` table. Creates a new session when `start_level` is set; marks `stop_at` when `is_charge_ended()` returns true.
- `is_charge_ended(charge)` — returns True when status is not `InProgress`.
- `update_chargings(conn, charge, car)` — updates charge record and fetches battery curve data.
- `get_battery_curve(conn, charge, car)` — reads `battery_curve` rows for the charge window, calls `BatteryChargeCurve.dto_to_battery_curve()`.
- `set_charge_price(charge, conn, car)` — calculates cost using `charge.kw * price_per_kwh`, respecting peak/off-peak windows.
- `set_default_price(cars)` — iterates all charges without prices and fills them.
- `_calculated_fields(charge_list)` — derives `co2` (via Ecomix) and `price` for each session.

**Flutter landing zone:** `lib/features/charging/data/charging_parser.dart`

---

## 5. Battery / SOH / Charge-Curve Modelling

### 5.1 Charge curve

**Module:** `psa_car_controller/psacc/application/battery_charge_curve.py`  
**Class:** `BatteryChargeCurve(level, speed_kw)`

Algorithm (`dto_to_battery_curve`):
1. Reads `battery_curve` rows (stored during charge session: timestamp, level %, rate kW, autonomy km).
2. Computes `battery_capacity = last_level * car.battery_power / 100` kWh.
3. Derives efficiency `km_by_kw`:
   - If `final_autonomy >= MINIMUM_AUTONOMY_FOR_GOOD_RESULT (20 km)`: `km_by_kw = 0.8 * autonomy / capacity`
   - Else: fallback `DEFAULT_KM_BY_KW = 5.3`
4. For each consecutive pair of curve points where `Δlevel > 3` and `Δtime > 0`:
   - Computes `speed_kw` = average of rate-derived kW values in the window.
   - Emits a `BatteryChargeCurve(start_level, speed_kw)` point.
5. Appends a sentinel `BatteryChargeCurve(end_level, 0)` at the end.
6. Fallback when no curve data: single segment speed from `car.get_charge_speed(Δlevel, Δseconds)`.

`Car.get_charge_speed(diff_level, duration_sec)`: `(battery_power_kWh * diff_level/100) / (duration_sec/3600)` kW.

**Flutter landing zone:** `lib/stellantis/battery_analytics/charge_curve_analyzer.dart`

### 5.2 Battery SOH

**Module:** `psa_car_controller/psacc/model/battery_soh.py`  
**Class:** `BatterySoh(vin, dates, levels)`

Simple time-series container. SOH samples are written to `battery_soh` table by `Database.record_battery_soh()` whenever a new telemetry record arrives with a health value. The `energy_battery_health` field from the Stellantis API contains capacity/resistance data.

**Flutter landing zone:** `lib/stellantis/battery_analytics/` — `SohSample` Isar schema + trend chart.

---

## 6. Stats & Analytics

### 6.1 Emissions (ecomix)

**Module:** `psa_car_controller/psacc/application/ecomix.py`  
**Class:** `Ecomix` (static methods)

- `get_data_france(start, end)` — fetches gCO₂/kWh from **RTE eco2mix** (`https://eco2mix.rte-france.com`), parses XML response, averages over the time window. France-only.
- Global fallback: `Ecomix.co2_signal_key` → queries **Electricity Maps** API (`https://api.electricitymaps.com`). Requires a free API key (`co2_signal_api` in config.json).
- Results cached in `Ecomix._cache` (process-lifetime dict).

Used in `charging.py._calculated_fields()` to fill the `co2` column (gCO₂ per charge session).

**Flutter landing zone:** `lib/stellantis/emissions/ecomix_service.dart`

### 6.2 Consumption & cost

- Electric: `kWh / 100km` derived from battery level delta + car's `battery_power`.
- Thermal: `L / 100km` from fuel level delta + car's `fuel_capacity`.
- Charging cost: `kWh × price_per_kWh` with optional peak/off-peak window distinction (`charge_config.json`).
- Rolling averages: computed at query time over the `battery` / `position` tables.

---

## 7. Settings & Integrations

### 7.1 Charge control

**Module:** `psa_car_controller/psacc/application/charge_control.py`  
**Class:** `ChargeControl(psacc, vin, percentage_threshold, stop_hour)`

- `percentage_threshold`: SOC level at which the app stops charging (e.g., 80%).
- `stop_hour`: `[HH, MM]` — desired time to stop scheduled charging.
- `control_charge_with_ack(charge: bool)` — sends MQTT command, waits 60s (`MQTT_TIMEOUT`), re-reads status and retries once if the state doesn't match the intent.
- `force_update()` — forces a wake-up poll if the car's charging mode is `Quick`.
- Scheduling logic in `_schedule_stop()` advances `_next_stop_hour` by 1 day after each trigger.

### 7.2 ABRP integration

**Module:** `psa_car_controller/psacc/application/abrp.py`  
**Class:** `Abrp(token, abrp_enable_vin)`

- Pushes live telemetry to A Better Route Planner via `POST https://api.iternio.com/1/tlm/send`.
- Hardcoded API key: `1e28ad14-df16-49f0-97da-364c9154b44a` (ABRP public/community key for PSA vehicles).
- Per-VIN opt-in (`abrp_enable_vin` set).
- Payload fields: `utc`, `soc`, `speed`, `car_model` (ABRP model string from `Car.get_abrp_name()`), `current`, `is_charging`, `lat`, `lon`, `power`, optionally `ext_temp`.
- Called after every position/status record if a user ABRP token is configured.

### 7.3 OpenWeather integration

**Module:** `psa_car_controller/psacc/utils/utils.py` — `get_temp(latitude, longitude, api_key)`

- Calls `https://api.openweathermap.org/data/3.0/onecall` (One Call API 3.0 — paid tier).
- Returns current ambient temperature in °C.
- Used as fallback when the car's onboard temperature sensor is unavailable.
- API key stored in `config.json` as `co2_signal_api` (note: the field name is reused for the CO₂ signal key — separate keys for each).

### 7.4 Units & locale

- Distance: always stored in km; conversion happens at display layer (web UI, now dropped).
- Temperature: °C stored; display layer converts.
- Currency: stored as a floating-point price-per-kWh; no currency symbol in DB.
- `charge_config.json`: peak/off-peak hour windows and price-per-kWh values (parsed at app start).

---

## 8. Persistence

### 8.1 `info.db` — SQLite telemetry database

WAL-mode SQLite (`PRAGMA journal_mode=WAL`). Database class: `psa_car_controller/psacc/repository/db.py`.

#### Table: `position`

| Column | Type | Description |
|---|---|---|
| `Timestamp` | DATETIME | UTC timestamp of poll |
| `VIN` | TEXT | Vehicle VIN |
| `longitude` | REAL | GPS longitude |
| `latitude` | REAL | GPS latitude |
| `mileage` | REAL | Odometer reading (km) |
| `level` | INTEGER | Electric battery level (%) |
| `level_fuel` | INTEGER | Fuel level (%) |
| `moving` | BOOLEAN | Was the car moving? |
| `temperature` | REAL | Ambient temperature (°C) |
| `altitude` | INTEGER | Altitude (m) — added via migration `add_altitude_to_db()` |

#### Table: `battery` (charge sessions)

| Column | Type | Description |
|---|---|---|
| `start_at` | DATETIME | Charge session start |
| `stop_at` | DATETIME | Charge session end |
| `VIN` | TEXT | Vehicle VIN |
| `start_level` | INTEGER | SOC at start (%) |
| `end_level` | INTEGER | SOC at end (%) |
| `co2` | REAL | gCO₂ emitted (computed) |
| `kw` | REAL | Energy added (kWh) |
| `price` | REAL | Cost (user currency) — added via migration |
| `charging_mode` | TEXT | Quick / Slow / etc. — added via migration |
| `mileage` | REAL | Odometer at end — added via migration |

#### Table: `battery_curve`

| Column | Type | Description |
|---|---|---|
| `start_at` | DATETIME | Links to `battery.start_at` |
| `VIN` | TEXT | Vehicle VIN |
| `date` | DATETIME | Timestamp of curve sample |
| `level` | INTEGER | SOC at sample point (%) |
| `rate` | INTEGER | Charge rate at sample (kW approx) — added via migration |
| `autonomy` | INTEGER | Reported autonomy at sample (km) — added via migration |

#### Table: `battery_soh`

| Column | Type | Description |
|---|---|---|
| `date` | DATETIME | Timestamp of SOH reading |
| `VIN` | TEXT | Vehicle VIN |
| `level` | REAL | SOH level (0–100, where 100 = new battery) |

**Schema migration:** `Database.init_db()` performs `ALTER TABLE` migrations for the three `NEW_*_COLUMNS` lists; safe to run repeatedly.

**Flutter landing zone:** Isar 4 collections `VehicleStatusSnapshot`, `Trip`, `ChargeSession`, `BatteryChargeCurve`, `SohSample`. One-shot import tool at `tools/import_legacy_db/`.

### 8.2 `config.json` — OAuth session

Created/updated by `PSAClient.save_config()`. Encrypted with `md5` change detection (hash stored in `_config_hash`).

| Key | Description |
|---|---|
| `abrp` | ABRP token dict (`token`, `abrp_enable_vin` list) |
| `client_id` | OAuth2 client ID (brand-specific, from APK) |
| `client_secret` | OAuth2 client secret (brand-specific, from APK) |
| `co2_signal_api` | API key for Electricity Maps / OpenWeather |
| `country_code` | Country code (e.g., `FR`) |
| `customer_id` | Stellantis account customer ID |
| `proxies` | Optional HTTP proxy dict |
| `realm` | OAuth realm (e.g., `clientsB2CPeugeot`) |
| `refresh_token` | Stellantis OAuth2 refresh token (**sensitive**) |
| `remote_refresh_token` | MQTT remote access refresh token (**sensitive**) |

**Sensitivity: HIGH.** Contains live refresh tokens. This file is already in `.gitignore`.

### 8.3 `cars.json` — Vehicle metadata cache

| Key | Description |
|---|---|
| `vin` | Vehicle VIN |
| `vehicle_id` | Opaque Stellantis vehicle UUID |
| `brand` | Brand string (e.g., `Peugeot`) |
| `label` | Model name (e.g., `2008 II`) |
| `battery_power` | Battery capacity in kWh |
| `fuel_capacity` | Fuel tank in L (0 for BEV) |
| `max_elec_consumption` | kWh/100km max |
| `max_fuel_consumption` | L/100km max |
| `abrp_name` | ABRP model string (nullable) |
| `picture_url` | Stellantis 3D render URL (brand-specific CDN) |
| `supports_electric` | nullable bool; `None` means derive from battery_power |

**Sensitivity: MEDIUM.** Contains real VIN and vehicle_id. Already in `.gitignore`.

### 8.4 `otp.bin` — MQTT OTP state

Pickled Python `Otp` object. Contains the derived TOTP secret/state used to generate remote-access OTP codes. Must never be committed.

**Sensitivity: HIGH.** Grants remote-command capability. Already in `.gitignore`.

### 8.5 `charge_config.json` — Charge control config

Simple JSON with per-VIN charge control settings: `percentage_threshold`, `stop_hour`. Empty `{}` is valid (no charge control).

### 8.6 `.psacc_cache/` — APK/setup cache

Directory containing `apk_setup_cache.json` (24-hour TTL). Caches the extracted `client_id` / `client_secret` to avoid re-downloading and re-parsing the APK on every run. Already in `.gitignore` (added in working-tree changes).

### 8.7 `car_models.yml` — VIN → model spec lookup

**Location:** `psa_car_controller/psacc/resources/car_models.yml`  
Loaded by `CarModelRepository` (singleton, ruamel.yaml). Each entry has:
- `name` — human label
- `battery_power` — kWh
- `fuel_capacity` — L
- `max_elec_consumption`, `max_fuel_consumption`
- `abrp_name` — ABRP model string
- `vins` — list of VIN prefix patterns that match this model

**Flutter landing zone:** Copied as `mobile/assets/data/car_models.yml`, parsed into Isar on first launch.

---

## 9. Branding Assets

**Source location:** `psa_car_controller/web/pwa/brands/` (deleted from working tree; preserved in `docs/legacy/brands/`)

| File | Brand |
|---|---|
| `alfaromeo.svg` | Alfa Romeo |
| `citroen.svg` | Citroën |
| `ds.svg` | DS Automobiles |
| `fiat.svg` | Fiat |
| `jeep.svg` | Jeep |
| `opel.svg` | Opel |
| `peugeot.svg` | Peugeot |
| `stellantis.svg` | Stellantis (group logo) |
| `vauxhall.svg` | Vauxhall |

Note: Fiat, Alfa Romeo, and Jeep SVGs were present in the PWA asset folder, but the Python `constants.py` and `BRAND` dict do **not** include matching OAuth configurations for them. These brands likely share the same Stellantis API backend but require separate APKs not covered by the Python project. Phase 2 will need to extract secrets for these brands.

**Flutter landing zone:** `mobile/assets/brands/` — SVG logos used in theme system. Phase 4.17.

---

## 10. Web / PWA Layer — Explicitly Dropped

The following Python modules and assets existed in `psa_car_controller/web/` and are dropped with no Flutter equivalent. Their deletion is committed in Phase 0 step 0.7.

| What | Module / Path | Reason dropped |
|---|---|---|
| Flask/Dash web server | `web/app.py`, `web/__init__.py` | Replaced by native Flutter app; no server needed |
| Dash dashboard layout | `web/view/views.py` | All screens re-implemented natively in Flutter |
| REST API endpoints (internal) | `web/view/api.py` | Flutter calls Stellantis API directly |
| OAuth callback handler | `web/view/config_oauth.py` | Flutter uses system browser + deep link |
| Config editing views | `web/view/config_views.py` | Settings screen in Flutter |
| Vehicle control view | `web/view/control.py` | Commands screen in Flutter |
| Plotly figure builders | `web/figures.py` | Replaced by `fl_chart` in Flutter |
| Custom Dash components | `web/dash_custom.py` | N/A |
| UI utilities | `web/tools/Button.py`, `Switch.py`, `figurefilter.py`, `utils.py` | N/A |
| PWA service worker | `web/pwa/service-worker.js` | Native app; no PWA |
| PWA manifest | `web/pwa/manifest.webmanifest` | N/A |
| PWA HTML shell | `web/pwa/index.html`, `offline.html` | N/A |
| PWA styles | `web/pwa/styles.css` | N/A |
| PWA JS app | `web/pwa/app.js` | N/A |
| PWA icons | `web/pwa/icons/icon-192.svg`, `icon-512.svg` | N/A (Flutter generates its own) |
| Map sprites | `web/assets/sprites/osm-liberty.*` | flutter_map uses OSM tiles directly |
| Map style JSON | `web/assets/style.json` | N/A |
| UI images | `web/assets/images/*.svg` | N/A — Flutter uses its own icon set |
| Custom CSS overrides | `web/assets/99_custom_overides.css` | N/A |
| Clientside JS callbacks | `web/assets/clientside.js` | N/A |
| Docs: Develop, Docker, PWA, ABRP web | `docs/Develop.md`, `Docker.md`, `PWA.md`, `abrp.md` | Superseded by new docs structure |
| Domoticz integration docs + images | `docs/domoticz/` | Feature deferred to v1.1 |

**Domoticz integration** (referenced in `docs/domoticz/`) is deferred to v1.1 as an optional plugin (MIGRATION_PLAN.md §1.8).

---

## 11. Uncommitted In-Progress Changes (Notable)

The following working-tree modifications were found during Phase 0 audit. They represent backend-migration work that was **not committed** and is now superseded by the direct-to-Stellantis architecture:

| File | Change | Significance for Phase 2 |
|---|---|---|
| `psa_car_controller/__main__.py` | Replaced Flask startup with `SystemExit` stub pointing to `uvicorn backend.app.main:app` | Confirms the Flask runtime was intentionally disabled. Phase 2 Dart code should not attempt to re-enable it. |
| `psa_car_controller/psa/RemoteClient.py` | `horn()` hardcoded to `nb_horn=1`; `lights()` hardcoded to `duration=10`. Added `otp_file` constructor param. | In the Dart port, the Flutter UI can expose count/duration as user-facing settings. Keep the API flexible. |
| `psa_car_controller/psa/otp/otp.py` | `save_otp()` / `load_otp()` / `new_otp_session()` parameterised with `filename`. `Path.parent.mkdir()` added. | Dart port will use `flutter_secure_storage` for OTP state — no file-path parameterisation needed. |
| `psa_car_controller/psa/setup/app_decoder.py` | `InitialSetup` given `scopes`, `cars_file`, `otp_file`, `config_file` params. Global `app` made lazy. | Dart extraction tool (`tools/extract_secrets/`) mirrors this lazily; no session isolation concern since it's a CLI. |
| `psa_car_controller/psacc/application/psa_client.py` | `PSAClient.__init__` accepts `cars_file`, `otp_file`, `config_file`. `save_config()` adds `Path.mkdir()`. | Dart app uses Isar + Keychain — no path parameterisation needed. |
| `psa_car_controller/psacc/model/car.py` | `Cars.save_cars()` adds `Path.mkdir()`. | Dart equivalent is an Isar write — no filesystem concern. |
