# Stellantis API replay fixtures

Captured JSON payloads for the four REST endpoints the app reads, shaped after
the `api-b2c.yaml` schemas and the legacy `psa_car_controller` recorded
responses. They back two kinds of test:

- **Model parsing** — feed each fixture to its `dart_mappable` mapper and assert
  the typed model is correct.
- **Client replay** — serve them through a fake Dio `HttpClientAdapter` and
  exercise `VehiclesApi` end-to-end (headers, query params, fallback logic).

| File | Endpoint | Mapper |
|---|---|---|
| `vehicles.json` | `GET /user/vehicles` | `VehiclesResponseMapper` |
| `status.json` | `GET /user/vehicles/{id}/status` | `VehicleStatusModelMapper` |
| `alerts.json` | `GET /user/vehicles/{id}/alerts` | `AlertsResponseMapper` |
| `maintenance.json` | `GET /user/vehicles/{id}/maintenance` | `MaintenanceModelMapper` |

VINs, ids, and picture URLs are synthetic. These fixtures are the durable
record of the API's shape — keep them even after `psa_car_controller/` is
removed (plan Phase 10).
