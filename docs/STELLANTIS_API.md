# Stellantis Connected Car API — Dart Reference

Reference for the Stellantis (PSA Group) Connected Car API as consumed
by the Flutter mobile app. All HTTP calls use Dio; all MQTT calls use
`mqtt_client`. This document records the contracts discovered by
reverse-engineering the official Peugeot / Citroën apps and the
`psa_car_controller` Python project.

---

## 1. Authentication

### 1.1 Brand OAuth endpoints

Each brand has a distinct realm and token endpoint.

| Brand | Realm | Customer-ID prefix |
|---|---|---|
| Peugeot | `clientsB2CPeugeot` | `AP` |
| Citroën | `clientsB2CCitroen` | `AC` |
| DS | `clientsB2CDS` | `DS` |
| Opel / Vauxhall | `clientsB2COpel` | `OV` |

Token endpoint pattern:
```
POST https://idpcvs.{realm-domain}/am/oauth2/access_token
```

Grant: `authorization_code` with PKCE (`S256`).

Scopes: `openid profile email`.

Client credentials (per brand, extracted from APK):
- `client_id`
- `client_secret`
- `redirect_uri` (custom scheme, e.g. `mymap://oauth2redirect`)

### 1.2 Token refresh

```
POST {token_endpoint}
Content-Type: application/x-www-form-urlencoded

grant_type=refresh_token
&client_id={client_id}
&client_secret={client_secret}
&refresh_token={refresh_token}
```

### 1.3 Remote-access token (MQTT)

A second token pair is required for MQTT remote commands. It is
refreshed independently from the main OAuth token.

```
POST https://api.groupe-psa.com/applications/cvs/v4
     /virtualkey/remoteaccess/token
Authorization: Bearer {main_access_token}
```

Response:
```json
{
  "accessToken": "...",
  "refreshToken": "..."
}
```

TTL: **890 seconds**. Dart constant: `BrandConstants.mqttTokenTtlSeconds`.

---

## 2. MQTT Remote Commands

### 2.1 Broker

| Field | Value |
|---|---|
| Host | `mwa.mpsa.com` |
| Port | `8885` (MQTTS / TLS) |
| Protocol | MQTT 3.1.1 |
| Username | `IMA_OAUTH_ACCESS_TOKEN` |
| Password | remote access token (see §1.3) |
| Client ID | `{brand}{customerId}@MQTTBroker` |

### 2.2 Topic scheme

| Direction | Topic |
|---|---|
| Publish (commands) | `psa/RemoteServices/from/cid/{customerId}{commandPath}` |
| Subscribe (responses) | `psa/RemoteServices/to/cid/{customerId}/#` |
| Subscribe (events) | `psa/RemoteServices/events/MPHRTServices/{vin}` |

Customer-ID prefix mapping (broker partition):

| Brand API realm | Prefix |
|---|---|
| DS | `AC` |
| VX (Vauxhall) | `OV` |
| OP (Opel) | `OV` |
| others | unchanged |

### 2.3 Command payload

```json
{
  "vin": "VR3UHZKXZL123456",
  "correlationId": "<uuid-no-dashes>_<yyyyMMddHHmmssSSS>",
  "action": "...",
  "execution": {
    "date": "<yyyy-MM-ddTHH:mm:ssZ>",
    "token": "<main_access_token>"
  },
  "request": { ... }
}
```

Correlation IDs expire after **30 seconds** (`MqttRequest._expirationSeconds`).

### 2.4 Supported commands

| Dart class | `commandPath` | `action` | Notes |
|---|---|---|---|
| `HornCommand` | `/Horn/execute` | `activate` | |
| `LightsCommand` | `/Lights/execute` | `activate` | |
| `WakeupCommand` | `/VehicleState/refresh` | `state` | |
| `LockCommand` | `/Doors/execute` | `lock` | |
| `UnlockCommand` | `/Doors/execute` | `unlock` | |
| `ClimateOnCommand` | `/ThermalPrecond/execute` | `activate` | |
| `ClimateOffCommand` | `/ThermalPrecond/execute` | `deactivate` | |
| `ChargeOnCommand` | `/Charge/execute` | `immediate` | |
| `ChargeOffCommand` | `/Charge/execute` | `delayed` | |
| `SetChargeScheduleCommand` | `/Charge/scheduleConfig` | `setSchedule` | hour + minute |

---

## 3. Vehicle Status API

### 3.1 Vehicle list

```
GET https://api.groupe-psa.com/applications/cvs/v4/vehicles
    ?client_id={client_id}
Authorization: Bearer {access_token}
```

### 3.2 Vehicle status

```
GET https://api.groupe-psa.com/applications/cvs/v4
    /vehicles/{vin}/status
    ?client_id={client_id}
Authorization: Bearer {access_token}
```

Key response fields used by the app:

| JSON path | Dart field | Notes |
|---|---|---|
| `energy[type=Electric].level` | `BatterySoh.resistance` (SOH), charge `startLevel`/`endLevel` | 0–100 % |
| `energy[type=Electric].charging.status` | `ChargeMode` | `"InProgress"` / `"Stopped"` |
| `energy[type=Electric].charging.chargingMode` | `ChargeMode.fromApi()` | `"slow"` → AC, `"fast"` → DC |
| `energy[type=Electric].battery.health.resistance` | `BatterySohReading.resistance` | Ω; higher = degraded |
| `energy[type=Fuel].level` | `TripPoint.levelFuel` | 0–100 % |
| `kinematic.speed` | `TripPoint` / ABRP telemetry | km/h |
| `kinematic.totalMileage` | `TripPoint.mileage` | km |
| `lastPosition.geometry.coordinates` | `TripPoint.latitude/longitude` | [lon, lat] order |
| `lastPosition.properties.updatedAt` | `TripPoint.timestamp` | ISO-8601 UTC |

---

## 4. Analytics Models

### 4.1 Charge session (`Charge`)

| Field | Type | Source |
|---|---|---|
| `startAt` | `DateTime` | First `InProgress` tick |
| `stopAt` | `DateTime?` | First non-`InProgress` tick |
| `startLevel` / `endLevel` | `double?` | SoC % at start/stop |
| `kw` | `double?` | `computeEnergyKwh()` — battery × ΔSoC / 100 |
| `chargingMode` | `ChargeMode` | `fromApi(chargingMode string)` |
| `price` | `double?` | `ElectricityPriceConfig.getPrice()` |
| `co2` | `double?` | `EmissionsEstimator.getCo2PerKw()` |

### 4.2 Battery charge curve

Built by `BatteryChargeCurveBuilder.build()` from `BatteryCurvePoint`
samples (one per API poll during a charge):

- `level` — SoC % at the start of this charging segment
- `speed` — average charging power in kW, rounded to nearest 0.5 kW

Fallback (no samples or last autonomy ≤ 0): a straight-line curve
from `startLevel` to `endLevel` at a single average kW.

Key constant: `_defaultKmByKw = 5.3` (km of range per kWh, used when
reported autonomy is too low to be reliable).

### 4.3 Electricity pricing (`ElectricityPriceConfig`)

AC price formula (sampled every 30 min over the charge window):

```
price = round(kWh × avg_tariff / efficiency × 100) / 100
```

Default efficiency: **89.42 %** (`chargerEfficiency = 0.8942`).

DC price: `dcChargePrice × kWh`, or `highSpeedDcChargePrice × kWh` when
peak charging power exceeds `highSpeedDcChargeThreshold` kW.

### 4.4 Battery SOH (`BatterySoh`)

Stores `energy.battery.health.resistance` (Ω) over time per VIN.
Higher resistance → more degradation. `trendOverLast(n)` returns the
Ω delta over the last `n` readings (positive = degrading).

### 4.5 Trip (`Trip`, `TripParser`)

Detection logic (mirrors `psacc/application/trip_parser.py`):

- **Low-speed stop**: `speed < 0.2 km/h` for `duration > 0.05 h (~3 min)`
- **Recharging event**: SoC delta `< −2 %` with distance ≈ 0 km
- **Trip end**: refuel/recharge, low-speed stop, 2+ hour gap, or last
  data point
- **Max plausible speed**: 150 km/h (trips above this are discarded)

Consumption:
- Electric: `ΔSoC% × batteryPower / 100` kWh
- Thermal: `ΔfuelLevel% × fuelCapacity / 100` L
- Hybrid: both

### 4.6 Emissions (`EmissionsEstimator`)

Sources (in priority order):
1. **Electricity Maps API** (`api.electricitymaps.com`) — any country,
   requires API key, cached 10 minutes per country.
2. **RTE eco2mix XML** (`eco2mix.rte-france.com`) — France only, no key.

Country code is supplied by the caller (device locale or GPS
reverse-geocoding); the estimator does not perform geocoding.

---

## 5. ABRP Integration (`AbrpClient`)

Sends live telemetry to A Better Route Planner via:

```
POST https://api.iternio.com/1/tlm/send
     ?tlm={json}&token={user_token}&api_key={shared_key}
```

Shared API key: `1e28ad14-df16-49f0-97da-364c9154b44a` (public,
same as used by the Python project). Per-VIN opt-in via `enableAbrp()`.

Key telemetry fields:

| Field | Unit | Source |
|---|---|---|
| `utc` | Unix timestamp | `energy.updated_at` |
| `soc` | % | `energy.level` |
| `is_charging` | bool | `energy.charging.status == "InProgress"` |
| `lat` / `lon` | degrees | `lastPosition.geometry.coordinates` |
| `speed` | km/h | `kinematic.speed` |
| `power` | kW | `energy.consumption` |
| `car_model` | string | `CarModel.abrpName` |
