import json
import logging
from pathlib import Path
from typing import Any, Dict, List, Optional
from urllib.parse import parse_qs, urlparse, urlsplit, urljoin, urlencode, parse_qsl, urlunsplit

import requests
from flask import Response as FlaskResponse
from flask import jsonify, request, send_from_directory
from pydantic import BaseModel

from psa_car_controller.common.utils import RateLimitException, parse_hour
from psa_car_controller.psa.connected_car_api.rest import ApiException
from psa_car_controller.psacc.application.car_controller import PSACarController
from psa_car_controller.psacc.application.charging import Charging
from psa_car_controller.psacc.model.car import Cars
from psa_car_controller.psacc.repository.db import Database
from psa_car_controller.psacc.repository.trips import Trips as LocalTrips
from psa_car_controller.web.app import app
from psa_car_controller.web.tools.utils import convert_to_number_if_number_else_return_str

logger = logging.getLogger(__name__)

STYLE_CACHE = None
APP = PSACarController()
INITIAL_SETUP: Optional[Any] = None
PWA_DIR = Path(__file__).resolve().parents[1] / "pwa"
BRAND_LOGO_FILES = {
    "peugeot": "brands/peugeot.svg",
    "citroen": "brands/citroen.svg",
    "opel": "brands/opel.svg",
    "ds": "brands/ds.svg",
    "ds automobiles": "brands/ds.svg",
    "vauxhall": "brands/vauxhall.svg",
    "fiat": "brands/fiat.svg",
    "jeep": "brands/jeep.svg",
    "alfa romeo": "brands/alfaromeo.svg",
}


def _bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return value != 0
    if isinstance(value, str):
        return value.strip().lower() in {"1", "true", "yes", "on"}
    return bool(value)


def _json_response(payload: Any, status=200):
    return app.response_class(response=json.dumps(payload, default=str), status=status, mimetype="application/json")


def _error(message: str, status=400):
    return _json_response({"error": message}, status=status)


def _client_available() -> bool:
    return getattr(APP, "myp", None) is not None


def _authenticated() -> bool:
    if not _client_available():
        return False
    token = getattr(getattr(APP.myp, "manager", None), "access_token", None)
    return bool(APP.is_good and token)


def _remote_auth_error() -> Optional[str]:
    if not _client_available() or not APP.remote_control:
        return None
    remote_client = getattr(APP.myp, "remote_client", None)
    if remote_client is None:
        return None

    remote_credentials = getattr(remote_client, "remoteCredentials", None)
    remote_refresh_token = getattr(remote_credentials, "refresh_token", None)
    if not remote_refresh_token:
        return "Remote control is not configured. Please complete OTP setup (SMS and PIN)."

    last_error = getattr(remote_client, "last_error", None)
    if last_error:
        return str(last_error)
    return None


def _require_client():
    if not _client_available():
        return _error("PSA client is not configured yet. Complete setup first.", status=503)
    return None


def _get_vehicle(vin):
    if not _client_available():
        return None
    return APP.myp.vehicles_list.get_car_by_vin(vin)


def _normalize_brand(brand: Optional[str]) -> str:
    if not isinstance(brand, str):
        return ""
    return brand.strip().lower()


def _brand_logo_url(brand: Optional[str]) -> str:
    logo_file = BRAND_LOGO_FILES.get(_normalize_brand(brand), "brands/stellantis.svg")
    return f"/assets/pwa/{logo_file}"


def _supports_electric(car, status=None) -> bool:
    electric = _energy(status, "Electric") if status is not None else None
    if electric is not None:
        if getattr(electric, "level", None) is not None or getattr(electric, "autonomy", None) is not None:
            return True
    if hasattr(car, "supports_electric_features"):
        return bool(car.supports_electric_features())
    return bool(getattr(car, "has_battery", lambda: False)())


def _require_electric_vehicle(vin: str):
    car = _get_vehicle(vin)
    if car is None:
        return _error(f"Unknown VIN: {vin}", status=404)
    if not _supports_electric(car):
        return _error("This vehicle does not support electric charging features.", status=400)
    return None


def _energy(status, energy_type: str):
    try:
        return status.get_energy(energy_type)
    except (AttributeError, TypeError, ValueError, KeyError):
        return None


def _iso(value):
    return value.isoformat() if value is not None else None


def _coordinates(status):
    coordinates = getattr(getattr(getattr(status, "last_position", None), "geometry", None), "coordinates", None)
    if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
        longitude = coordinates[0]
        latitude = coordinates[1]
        altitude = coordinates[2] if len(coordinates) >= 3 else None
        return {
            "latitude": latitude,
            "longitude": longitude,
            "altitude": altitude,
            "google_maps_url": f"https://maps.google.com/maps?q={latitude},{longitude}",
        }
    return None


def _status_payload(status) -> Dict[str, Any]:
    electric = _energy(status, "Electric")
    fuel = _energy(status, "Fuel")
    charging = getattr(electric, "charging", None)
    preconditioning = getattr(getattr(getattr(status, "preconditionning", None), "air_conditioning", None), "status", None)
    timed_odometer = getattr(status, "timed_odometer", None)
    kinetic = getattr(status, "kinetic", None)

    return {
        "updated_at": _iso(getattr(electric, "updated_at", None)),
        "mileage": getattr(timed_odometer, "mileage", None),
        "moving": getattr(kinetic, "moving", None),
        "battery": {
            "level": getattr(electric, "level", None),
            "autonomy": getattr(electric, "autonomy", None),
            "charging_status": getattr(charging, "status", None),
            "charging_mode": getattr(charging, "charging_mode", None),
            "charging_rate": getattr(charging, "charging_rate", None),
            "next_delayed_time": getattr(charging, "next_delayed_time", None),
        },
        "fuel": {
            "level": getattr(fuel, "level", None),
            "autonomy": getattr(fuel, "autonomy", None),
        },
        "preconditioning_status": preconditioning,
        "position": _coordinates(status),
    }


def _vehicle_payload(vin: str, from_cache=False) -> Dict[str, Any]:
    car = _get_vehicle(vin)
    if car is None:
        raise KeyError(f"Unknown VIN: {vin}")

    status = APP.myp.get_vehicle_info(vin, from_cache)
    if status is None:
        status = car.status

    charge_control = None
    if APP.chc:
        control = APP.chc.get(vin)
        if control:
            charge_control = {
                "percentage_threshold": control.percentage_threshold,
                "stop_hour": control.get_stop_hour(),
            }

    charge_hour = None
    try:
        charge_hour = list(APP.myp.remote_client.get_charge_hour(vin))
    except (TypeError, AttributeError, IndexError):
        pass

    supports_electric = _supports_electric(car, status)

    return {
        "vin": car.vin,
        "label": car.label,
        "brand": car.brand,
        "brand_logo_url": _brand_logo_url(car.brand),
        "vehicle_id": car.vehicle_id,
        "has_battery": car.has_battery(),
        "has_fuel": car.has_fuel(),
        "supports_electric": supports_electric,
        "battery_power": car.battery_power,
        "fuel_capacity": car.fuel_capacity,
        "picture_url": f"/api/vehicle/{car.vin}/photo" if getattr(car, "picture_url", None) else None,
        "charge_hour": charge_hour,
        "soh": Database.get_last_soh_by_vin(vin),
        "status": _status_payload(status) if status else None,
        "charge_control": charge_control,
    }


def _load_trips(vin: Optional[str] = None) -> List[dict]:
    def _field(source: Any, *names: str):
        if source is None:
            return None
        for name in names:
            if isinstance(source, dict):
                value = source.get(name)
            else:
                value = getattr(source, name, None)
            if value is not None:
                return value
        return None

    def _duration_to_minutes(duration: Any) -> float:
        if duration is None:
            return 0
        if isinstance(duration, (int, float)):
            if duration <= 0:
                return 0
            return float(duration) / 60
        if isinstance(duration, str) and duration.startswith("PT"):
            try:
                hours, minutes, seconds = parse_hour(duration.upper())
                return hours * 60 + minutes + seconds / 60
            except (ValueError, TypeError, IndexError):
                return 0
        return 0

    def _normalize_consumption(value: Any, energy_type: str):
        try:
            number = float(value)
        except (TypeError, ValueError):
            return None

        if energy_type.lower() == "electric":
            # New API contract can provide Wh/100km.
            if number > 200:
                return number / 1000
            return number
        if energy_type.lower() == "fuel":
            # New API contract can provide cl/100km.
            if number > 30:
                return number / 100
            return number
        return number

    def _trip_consumption(avg_consumption: Optional[list], energy_type: str):
        if not isinstance(avg_consumption, list):
            return None
        for line in avg_consumption:
            line_type = _field(line, "type")
            if isinstance(line_type, str) and line_type.lower() == energy_type.lower():
                value = _field(line, "value", "avgConsumption", "consumption")
                return _normalize_consumption(value, energy_type)
        return None

    def _next_page_token(payload: Any):
        if not isinstance(payload, dict):
            return None
        links = payload.get("_links") or payload.get("links")
        if not isinstance(links, dict):
            return None
        next_link = links.get("next")
        if isinstance(next_link, dict):
            href = next_link.get("href")
        elif isinstance(next_link, str):
            href = next_link
        else:
            href = None
        if not isinstance(href, str):
            return None
        try:
            parsed = urlparse(href)
            return parse_qs(parsed.query).get("pageToken", [None])[0]
        except ValueError:
            return None

    def _normalize_remote_trip(trip, default_vin: str):
        duration_min = _duration_to_minutes(_field(trip, "duration"))
        distance = _field(trip, "distance")
        if distance is None:
            distance = 0
        try:
            distance = float(distance)
        except (TypeError, ValueError):
            distance = 0

        speed_average = _field(_field(trip, "kinetic"), "avgSpeed")
        if speed_average is None:
            speed_average = 0
            if duration_min > 0:
                speed_average = distance / (duration_min / 60)

        avg_consumption = _field(trip, "avg_consumption", "avgConsumption")
        if not isinstance(avg_consumption, list):
            avg_consumption = _field(trip, "energyConsumptions")

        start_at = _field(trip, "started_at", "startedAt") or _field(trip, "created_at", "createdAt") \
            or _field(trip, "stopped_at", "stoppedAt")
        row = {
            "id": _field(trip, "id"),
            "start_at": start_at,
            "duration": duration_min,
            "speed_average": speed_average,
            "distance": distance,
            "mileage": _field(trip, "odometer", "startMileage"),
            "consumption": None,
            "consumption_km": _trip_consumption(avg_consumption, "Electric"),
            "consumption_fuel_km": _trip_consumption(avg_consumption, "Fuel"),
            "consumption_by_temp": None,
            "positions": {"lat": [], "long": []},
            "altitude_diff": None,
            "vin": default_vin,
        }
        return row

    def _extract_embedded_trips(payload: Any) -> List[Any]:
        if payload is None:
            return []
        if isinstance(payload, list):
            return payload
        if not isinstance(payload, dict):
            return []

        embedded = payload.get("_embedded") or payload.get("embedded")
        if isinstance(embedded, dict):
            trips = embedded.get("trips")
            if isinstance(trips, list):
                return trips
        trips = payload.get("trips")
        if isinstance(trips, list):
            return trips
        return []

    def _load_remote_trips(vin_filter: Optional[str] = None) -> List[dict]:
        if not _client_available() or not APP.is_good:
            return []
        remote_trips = []
        try:
            cars = APP.myp.vehicles_list
            for car in cars:
                if vin_filter and car.vin != vin_filter:
                    continue
                seen_tokens = set()
                seen_trip_ids = set()
                page_token = None
                for _ in range(0, 20):
                    query_params = [("pageSize", 60), ("indexRange", "0-")]
                    if page_token:
                        if page_token in seen_tokens:
                            break
                        seen_tokens.add(page_token)
                        query_params.append(("pageToken", page_token))

                    try:
                        raw_payload = APP.myp.api().api_client.call_api(
                            "/user/vehicles/{id}/trips",
                            "GET",
                            path_params={"id": car.vehicle_id},
                            query_params=query_params,
                            response_type="object",
                            auth_settings=["Vehicle_auth", "client_id", "realm"],
                            _return_http_data_only=True,
                        )
                        raw_trips = _extract_embedded_trips(raw_payload)
                        for trip in raw_trips:
                            normalized = _normalize_remote_trip(trip, car.vin)
                            trip_id = normalized.get("id")
                            if trip_id and trip_id in seen_trip_ids:
                                continue
                            if trip_id:
                                seen_trip_ids.add(trip_id)
                            remote_trips.append(normalized)
                        page_token = _next_page_token(raw_payload)
                        if not page_token:
                            break
                    except ApiException as ex:
                        if ex.status == 403:
                            logger.warning(
                                "Trips access denied for VIN %s (403). Check that OAuth token has data:trip scope.",
                                car.vin,
                            )
                        else:
                            logger.debug("Raw remote trips fetch failed for VIN %s", car.vin, exc_info=True)
                        break
                    except (AttributeError, KeyError, TypeError, ValueError):
                        logger.debug("Raw remote trips payload invalid for VIN %s", car.vin, exc_info=True)
                        break
        except Exception:
            logger.debug("Remote trips fetch failed", exc_info=True)
        return remote_trips

    if not _client_available() or not APP.myp.vehicles_list:
        return []
    try:
        if vin:
            car = _get_vehicle(vin)
            if car is None:
                return []
            trips_by_vin = LocalTrips.get_trips(Cars([car]))
            local_trips = trips_by_vin.get(vin, LocalTrips()).get_trips_as_dict()
            if local_trips:
                return local_trips
            return _load_remote_trips(vin)

        merged = []
        trips_by_vin = LocalTrips.get_trips(APP.myp.vehicles_list)
        for vehicle_vin, trips in trips_by_vin.items():
            for trip in trips.get_trips_as_dict():
                trip["vin"] = vehicle_vin
                merged.append(trip)
        if merged:
            return merged
        return _load_remote_trips()
    except (KeyError, TypeError, IndexError):
        logger.debug("Failed to read trips", exc_info=True)
        return []


def _load_chargings(vin: Optional[str] = None) -> List[dict]:
    try:
        chargings = Charging.get_chargings()
        if vin:
            return [charging for charging in chargings if charging.get("VIN") == vin]
        return chargings
    except (TypeError, IndexError):
        logger.debug("Failed to read charging sessions", exc_info=True)
        return []


def _invoke_remote(action_name: str, fn, *args):
    if not APP.remote_control:
        return {"error": "Remote control is disabled"}, 400
    remote_error = _remote_auth_error()
    if remote_error:
        return {"error": remote_error}, 401
    try:
        result = fn(*args)
        return {"ok": True, "result": result}, 200
    except RateLimitException:
        return {"error": f"{action_name} rate limit exceeded"}, 429
    except Exception as ex:  # pragma: no cover - defensive handler
        logger.exception("%s failed", action_name)
        return {"error": str(ex)}, 500


def _coerce_for_config(value):
    if isinstance(value, str):
        return convert_to_number_if_number_else_return_str(value)
    return value


def _extract_oauth_code(raw_value: Optional[str]) -> Optional[str]:
    if raw_value is None:
        return None
    value = str(raw_value).strip()
    if not value:
        return None
    try:
        parsed = urlparse(value)
        if parsed.query:
            code = parse_qs(parsed.query).get("code", [None])[0]
            if code:
                return code
    except ValueError:
        pass
    if "code=" in value:
        query_part = value.split("?", 1)[-1]
        code = parse_qs(query_part).get("code", [None])[0]
        if code:
            return code
    return value


def _config_section(section: str) -> BaseModel:
    try:
        return getattr(APP.config, section.capitalize())
    except AttributeError as ex:
        raise KeyError(f"Unknown config section: {section}") from ex


@app.after_request
def after_request(response):
    response.headers["Access-Control-Allow-Origin"] = "*"
    return response


@app.route("/")
def index():
    return send_from_directory(PWA_DIR, "index.html")


@app.route("/manifest.webmanifest")
def manifest():
    return send_from_directory(PWA_DIR, "manifest.webmanifest", mimetype="application/manifest+json")


@app.route("/service-worker.js")
def service_worker():
    return send_from_directory(PWA_DIR, "service-worker.js", mimetype="application/javascript")


@app.route("/offline.html")
def offline_page():
    return send_from_directory(PWA_DIR, "offline.html")


@app.route("/favicon.ico")
def favicon():
    return send_from_directory(PWA_DIR / "icons", "icon-192.svg", mimetype="image/svg+xml")


@app.route("/assets/pwa/<path:filename>")
def pwa_assets(filename):
    return send_from_directory(PWA_DIR, filename)


@app.route("/control")
@app.route("/config")
@app.route("/config_login")
@app.route("/config_connect")
@app.route("/config_otp")
@app.route("/log")
def legacy_views():
    return send_from_directory(PWA_DIR, "index.html")


@app.route("/api/health")
def api_health():
    return jsonify({
        "configured": _client_available(),
        "authenticated": _authenticated(),
        "remote_control": APP.remote_control,
        "offline_mode": APP.offline,
        "remote_auth_error": _remote_auth_error(),
    })


@app.route("/api/vehicles")
def api_vehicles():
    if _authenticated():
        try:
            APP.myp.get_vehicles()
        except Exception:
            logger.debug("Unable to refresh vehicle list", exc_info=True)
    vehicles = []
    if _authenticated():
        vehicles = [{
            "vin": car.vin,
            "label": car.label,
            "brand": car.brand,
            "brand_logo_url": _brand_logo_url(car.brand),
            "vehicle_id": car.vehicle_id,
            "has_battery": car.has_battery(),
            "has_fuel": car.has_fuel(),
            "supports_electric": _supports_electric(car),
            "picture_url": f"/api/vehicle/{car.vin}/photo" if getattr(car, "picture_url", None) else None,
        } for car in APP.myp.vehicles_list]
    return jsonify({
        "configured": _client_available(),
        "authenticated": _authenticated(),
        "remote_auth_error": _remote_auth_error(),
        "vehicles": vehicles,
    })


@app.route("/api/vehicle/<string:vin>/photo")
def api_vehicle_photo(vin):
    missing = _require_client()
    if missing:
        return missing

    car = _get_vehicle(vin)
    if car is None:
        return _error(f"Unknown VIN: {vin}", status=404)

    picture_url = getattr(car, "picture_url", None)
    if not picture_url:
        return _error("No vehicle photo available for this VIN", status=404)

    resolved_picture_url = picture_url
    parsed = urlsplit(picture_url)
    if parsed.scheme not in {"http", "https"}:
        if picture_url.startswith("/"):
            try:
                host = APP.myp.api().api_client.configuration.host
            except Exception:
                host = None
            if not host:
                return _error("Vehicle photo URL is invalid", status=502)
            resolved_picture_url = urljoin(host.rstrip("/") + "/", picture_url.lstrip("/"))
        else:
            return _error("Vehicle photo URL is invalid", status=502)

    resolved_parsed = urlsplit(resolved_picture_url)
    if "groupe-psa" in resolved_parsed.netloc or "mpsa" in resolved_parsed.netloc:
        client_id = getattr(APP.myp, "client_id", None)
        if client_id:
            query = dict(parse_qsl(resolved_parsed.query, keep_blank_values=True))
            if "client_id" not in query:
                query["client_id"] = client_id
                resolved_picture_url = urlunsplit((
                    resolved_parsed.scheme,
                    resolved_parsed.netloc,
                    resolved_parsed.path,
                    urlencode(query),
                    resolved_parsed.fragment,
                ))

    headers = {
        "Accept": "image/*",
        "x-introspect-realm": getattr(APP.myp, "realm", ""),
    }
    access_token = getattr(getattr(APP.myp, "manager", None), "access_token", None)
    if access_token:
        headers["Authorization"] = f"Bearer {access_token}"

    def _extract_link_from_payload(value: Any, depth: int = 0):
        if depth > 7:
            return None
        if isinstance(value, str):
            if value.startswith(("https://", "http://", "/")):
                return value
            return None
        if isinstance(value, list):
            for item in value:
                candidate = _extract_link_from_payload(item, depth + 1)
                if candidate:
                    return candidate
            return None
        if isinstance(value, dict):
            for key in ("href", "url", "src", "link", "uri", "picture", "image", "contentUrl"):
                if key in value:
                    candidate = _extract_link_from_payload(value.get(key), depth + 1)
                    if candidate:
                        return candidate
            for nested_value in value.values():
                candidate = _extract_link_from_payload(nested_value, depth + 1)
                if candidate:
                    return candidate
        return None

    try:
        response = requests.get(resolved_picture_url, headers=headers, timeout=20)
        if response.status_code in {401, 403} and APP.myp.manager.refresh_token_now():
            refreshed_token = getattr(APP.myp.manager, "access_token", None)
            if refreshed_token:
                headers["Authorization"] = f"Bearer {refreshed_token}"
            response = requests.get(resolved_picture_url, headers=headers, timeout=20)

        if not response.ok:
            logger.debug("Vehicle photo request failed for %s via %s: %s", vin, resolved_picture_url, response.status_code)
            return _error(f"Vehicle photo request failed ({response.status_code})", status=response.status_code)

        mimetype = response.headers.get("Content-Type", "image/jpeg").split(";", 1)[0]
        if not mimetype.startswith("image/"):
            next_url = None
            try:
                payload = response.json()
                next_url = _extract_link_from_payload(payload)
            except ValueError:
                body_text = response.text.strip()
                if body_text.startswith(("https://", "http://", "/")):
                    next_url = body_text

            if next_url:
                if next_url.startswith("/"):
                    next_url = urljoin(resolved_picture_url, next_url)
                response = requests.get(next_url, headers=headers, timeout=20)
                if response.ok:
                    mimetype = response.headers.get("Content-Type", "image/jpeg").split(";", 1)[0]
                    resolved_picture_url = next_url

        if not mimetype.startswith("image/"):
            logger.debug(
                "Vehicle photo endpoint did not return image for %s via %s (mimetype=%s)",
                vin,
                resolved_picture_url,
                mimetype,
            )
            return _error("Vehicle photo endpoint did not return an image", status=502)

        photo_response = FlaskResponse(response.content, status=200, mimetype=mimetype)
        photo_response.headers["Cache-Control"] = "public, max-age=86400"
        return photo_response
    except requests.RequestException:
        logger.exception("Vehicle photo download failed for VIN %s", vin)
        return _error("Unable to download vehicle photo", status=502)


@app.route("/api/vehicle/<string:vin>")
def api_vehicle(vin):
    missing = _require_client()
    if missing:
        return missing
    from_cache = _bool(request.args.get("from_cache", "1"))
    try:
        return jsonify(_vehicle_payload(vin, from_cache=from_cache))
    except KeyError as ex:
        return _error(str(ex), status=404)
    except Exception as ex:  # pragma: no cover - defensive handler
        logger.exception("Failed to build vehicle payload for VIN %s", vin)
        return _error(str(ex), status=502)


@app.route("/api/dashboard/<string:vin>")
def api_dashboard(vin):
    missing = _require_client()
    if missing:
        return missing
    try:
        payload = _vehicle_payload(vin, from_cache=True)
    except KeyError as ex:
        return _error(str(ex), status=404)
    except Exception as ex:  # pragma: no cover - defensive handler
        logger.exception("Failed to build dashboard payload for VIN %s", vin)
        return _error(str(ex), status=502)
    payload["trips"] = _load_trips(vin)
    payload["chargings"] = _load_chargings(vin)
    payload["settings"] = APP.config.dict()
    payload["remote_auth_error"] = _remote_auth_error()
    if payload.get("status") is None and not _authenticated():
        payload["auth_error"] = "Session expired. Reconnect in Setup."
    return jsonify(payload)


@app.route("/api/trips")
def api_trips():
    vin = request.args.get("vin")
    return jsonify(_load_trips(vin))


@app.route("/api/chargings")
def api_chargings():
    vin = request.args.get("vin")
    return jsonify(_load_chargings(vin))


@app.route("/api/battery/soh/<string:vin>")
def api_battery_soh(vin):
    return jsonify({"soh": Database.get_last_soh_by_vin(vin)})


@app.route("/api/settings", methods=["GET"])
def api_settings():
    return _json_response(APP.config.dict())


@app.route("/api/settings/<string:section>", methods=["GET", "POST"])
def api_settings_section(section: str):
    try:
        config_section = _config_section(section)
    except KeyError as ex:
        return _error(str(ex), status=404)

    if request.method == "GET":
        return _json_response(config_section.dict())

    payload = request.get_json(silent=True) or {}
    if not isinstance(payload, dict):
        return _error("Invalid JSON payload", status=400)

    for key, value in payload.items():
        setattr(config_section, key, _coerce_for_config(value))
    APP.config.write_config()
    return _json_response(config_section.dict())


@app.route("/api/vehicle/<string:vin>/wakeup", methods=["POST"])
def api_wakeup(vin):
    missing = _require_client()
    if missing:
        return missing
    electric_only = _require_electric_vehicle(vin)
    if electric_only:
        return electric_only
    payload, status = _invoke_remote("Wakeup", APP.myp.remote_client.wakeup, vin)
    return jsonify(payload), status


@app.route("/api/vehicle/<string:vin>/charge", methods=["POST"])
def api_charge(vin):
    missing = _require_client()
    if missing:
        return missing
    electric_only = _require_electric_vehicle(vin)
    if electric_only:
        return electric_only
    body = request.get_json(silent=True) or {}
    enabled = _bool(body.get("enabled", True))
    payload, status = _invoke_remote("Charge", APP.myp.remote_client.charge_now, vin, enabled)
    return jsonify(payload), status


@app.route("/api/vehicle/<string:vin>/preconditioning", methods=["POST"])
def api_preconditioning(vin):
    missing = _require_client()
    if missing:
        return missing
    electric_only = _require_electric_vehicle(vin)
    if electric_only:
        return electric_only
    body = request.get_json(silent=True) or {}
    enabled = _bool(body.get("enabled", True))
    payload, status = _invoke_remote("Preconditioning", APP.myp.remote_client.preconditioning, vin, enabled)
    return jsonify(payload), status


@app.route("/api/vehicle/<string:vin>/horn", methods=["POST"])
def api_horn(vin):
    missing = _require_client()
    if missing:
        return missing
    body = request.get_json(silent=True) or {}
    count = int(body.get("count", 1))
    payload, status = _invoke_remote("Horn", APP.myp.remote_client.horn, vin, count)
    return jsonify(payload), status


@app.route("/api/vehicle/<string:vin>/lights", methods=["POST"])
def api_lights(vin):
    missing = _require_client()
    if missing:
        return missing
    body = request.get_json(silent=True) or {}
    duration = int(body.get("duration", 10))
    payload, status = _invoke_remote("Lights", APP.myp.remote_client.lights, vin, duration)
    return jsonify(payload), status


@app.route("/api/vehicle/<string:vin>/doors", methods=["POST"])
def api_doors(vin):
    missing = _require_client()
    if missing:
        return missing
    body = request.get_json(silent=True) or {}
    lock = _bool(body.get("lock", True))
    payload, status = _invoke_remote("Door lock", APP.myp.remote_client.lock_door, vin, lock)
    return jsonify(payload), status


@app.route("/api/vehicle/<string:vin>/charge-hour", methods=["POST"])
def api_charge_hour(vin):
    missing = _require_client()
    if missing:
        return missing
    electric_only = _require_electric_vehicle(vin)
    if electric_only:
        return electric_only
    body = request.get_json(silent=True) or {}
    hour = int(body.get("hour", 22))
    minute = int(body.get("minute", 30))
    payload, status = _invoke_remote("Charge hour", APP.myp.remote_client.change_charge_hour, vin, hour, minute)
    return jsonify(payload), status


@app.route("/api/vehicle/<string:vin>/charge-control", methods=["POST"])
def api_charge_control(vin):
    missing = _require_client()
    if missing:
        return missing
    electric_only = _require_electric_vehicle(vin)
    if electric_only:
        return electric_only
    if APP.chc is None:
        return _error("Charge control is not enabled", status=400)

    charge_control = APP.chc.get(vin)
    if charge_control is None:
        return _error("VIN not in charge control list", status=404)

    body = request.get_json(silent=True) or {}
    if "hour" in body and "minute" in body:
        charge_control.set_stop_hour([int(body["hour"]), int(body["minute"])])
    if "percentage" in body:
        charge_control.percentage_threshold = int(body["percentage"])
    APP.chc.save_config()
    return jsonify(charge_control.get_dict())


@app.route("/api/setup/login", methods=["POST"])
def api_setup_login():
    global INITIAL_SETUP
    from psa_car_controller.psa.setup.app_decoder import InitialSetup

    body = request.get_json(silent=True) or {}
    package_name = body.get("package_name")
    email = body.get("email")
    password = body.get("password")
    country_code = body.get("country_code")

    if not all([package_name, email, password, country_code]):
        return _error("package_name, email, password and country_code are required", status=400)

    try:
        INITIAL_SETUP = InitialSetup(package_name, email, password, country_code.upper())
        redirect_url = INITIAL_SETUP.psacc.manager.generate_redirect_url()
        return jsonify({"ok": True, "redirect_url": redirect_url})
    except Exception as ex:
        logger.exception("Initial setup failed")
        return _error(str(ex), status=500)


@app.route("/api/setup/oauth", methods=["POST"])
def api_setup_oauth():
    if INITIAL_SETUP is None:
        return _error("Setup session is missing. Run login setup first.", status=400)

    body = request.get_json(silent=True) or {}
    code = _extract_oauth_code(body.get("code") or body.get("redirect_url"))
    if not code:
        return _error("OAuth code is required", status=400)

    try:
        INITIAL_SETUP.connect(code)
        return jsonify({"ok": True, "message": "OAuth setup completed"})
    except Exception as ex:
        logger.exception("OAuth setup failed")
        return _error(str(ex), status=500)


@app.route("/api/setup/otp/sms", methods=["POST"])
def api_setup_otp_sms():
    missing = _require_client()
    if missing:
        return missing
    try:
        APP.myp.remote_client.get_sms_otp_code()
        return jsonify({"ok": True, "message": "SMS sent"})
    except Exception as ex:
        logger.exception("Failed to request OTP SMS")
        return _error(str(ex), status=500)


@app.route("/api/setup/otp", methods=["POST"])
def api_setup_otp_finish():
    from psa_car_controller.psa.otp.otp import new_otp_session

    missing = _require_client()
    if missing:
        return missing

    body = request.get_json(silent=True) or {}
    sms_code = body.get("sms_code")
    pin_code = body.get("pin_code")
    if not sms_code or not pin_code:
        return _error("sms_code and pin_code are required", status=400)

    try:
        otp_session = new_otp_session(sms_code, pin_code, APP.myp.remote_client.otp)
        if otp_session is None:
            return _error("Failed to create OTP session", status=500)
        APP.myp.remote_client.otp = otp_session
        APP.myp.save_config()
        remote_started = APP.start_remote_control()
        if APP.remote_control and not remote_started:
            remote_error = _remote_auth_error() or "OTP accepted but remote control setup failed. Retry OTP setup."
            return _error(remote_error, status=502)
        return jsonify({"ok": True, "message": "OTP setup completed"})
    except Exception as ex:
        logger.exception("OTP setup failed")
        return _error(str(ex), status=500)


# Legacy endpoints preserved for compatibility with existing automation and docs


@app.route("/get_vehicles")
def get_vehicules():
    missing = _require_client()
    if missing:
        return missing
    vehicles = [car.to_dict() for car in APP.myp.get_vehicles()]
    return _json_response(vehicles)


@app.route("/get_vehicleinfo/<string:vin>")
def get_vehicle_info(vin):
    missing = _require_client()
    if missing:
        return missing
    from_cache = int(request.args.get("from_cache", 0)) == 1
    status = APP.myp.get_vehicle_info(vin, from_cache)
    return _json_response(status.to_dict() if status else None)


@app.route("/style.json")
def get_style():
    global STYLE_CACHE
    if not STYLE_CACHE:
        style_file = Path(app.root_path) / "assets" / "style.json"
        with open(style_file, "r", encoding="utf-8") as style_json:
            STYLE_CACHE = json.load(style_json)
    url_root = request.url_root
    STYLE_CACHE["sprite"] = url_root + "assets/sprites/osm-liberty"
    return jsonify(STYLE_CACHE)


@app.route("/charge_now/<string:vin>/<int:charge>")
def charge_now(vin, charge):
    missing = _require_client()
    if missing:
        return missing
    payload, status = _invoke_remote("Charge", APP.myp.remote_client.charge_now, vin, charge != 0)
    return jsonify(payload), status


@app.route("/charge_hour")
def change_charge_hour():
    missing = _require_client()
    if missing:
        return missing
    payload, status = _invoke_remote(
        "Charge hour",
        APP.myp.remote_client.change_charge_hour,
        request.args["vin"],
        request.args["hour"],
        request.args["minute"],
    )
    return jsonify(payload), status


@app.route("/wakeup/<string:vin>")
def wakeup(vin):
    missing = _require_client()
    if missing:
        return missing
    payload, status = _invoke_remote("Wakeup", APP.myp.remote_client.wakeup, vin)
    return jsonify(payload), status


@app.route("/preconditioning/<string:vin>/<int:activate>")
def preconditioning(vin, activate):
    missing = _require_client()
    if missing:
        return missing
    payload, status = _invoke_remote("Preconditioning", APP.myp.remote_client.preconditioning, vin, activate)
    return jsonify(payload), status


@app.route("/position/<string:vin>")
def get_position(vin):
    missing = _require_client()
    if missing:
        return missing
    res = APP.myp.get_vehicle_info(vin)
    position = _coordinates(res)
    if not position:
        return jsonify({"error": "last_position not available from api"})
    return jsonify(position)


@app.route("/charge_control")
def get_charge_control():
    missing = _require_client()
    if missing:
        return missing
    vin = request.args["vin"]
    if APP.chc:
        charge_control = APP.chc.get(vin)
        if charge_control is None:
            return jsonify({"error": "VIN not in list"})
        if "hour" in request.args and "minute" in request.args:
            charge_control.set_stop_hour([int(request.args["hour"]), int(request.args["minute"])])
        if "percentage" in request.args:
            charge_control.percentage_threshold = int(request.args["percentage"])
        APP.chc.save_config()
        return jsonify(charge_control.get_dict())
    return jsonify({"error": "Charge control not setup check your PSACC configuration and logs"})


@app.route("/positions")
def get_recorded_position():
    return FlaskResponse(Database.get_recorded_position(), mimetype="application/json")


@app.route("/horn/<string:vin>/<int:count>")
def horn(vin, count):
    missing = _require_client()
    if missing:
        return missing
    payload, status = _invoke_remote("Horn", APP.myp.remote_client.horn, vin, count)
    return jsonify(payload), status


@app.route("/lights/<string:vin>/<int:duration>")
def lights(vin, duration):
    missing = _require_client()
    if missing:
        return missing
    payload, status = _invoke_remote("Lights", APP.myp.remote_client.lights, vin, duration)
    return jsonify(payload), status


@app.route("/lock_door/<string:vin>/<int:lock>")
def lock_door(vin, lock):
    missing = _require_client()
    if missing:
        return missing
    payload, status = _invoke_remote("Door lock", APP.myp.remote_client.lock_door, vin, lock)
    return jsonify(payload), status


@app.route("/settings/<string:section>")
def settings_section(section: str):
    try:
        config_section = _config_section(section)
    except KeyError as ex:
        return _error(str(ex), status=404)

    for key, value in request.args.items():
        setattr(config_section, key, convert_to_number_if_number_else_return_str(value))
    APP.config.write_config()
    return _json_response(config_section.dict())


@app.route("/vehicles/trips")
def get_trips():
    vin = request.args.get("vin")
    if vin:
        return jsonify(_load_trips(vin))
    return jsonify(_load_trips())


@app.route("/vehicles/chargings")
def get_chargings():
    vin = request.args.get("vin")
    return jsonify(_load_chargings(vin))


@app.route("/settings")
def settings():
    return _json_response(APP.config.dict())


@app.route("/battery/soh/<string:vin>")
def db(vin: str):
    soh = Database.get_last_soh_by_vin(vin)
    return jsonify({"soh": soh})
