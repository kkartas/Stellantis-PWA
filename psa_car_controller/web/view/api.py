import json
import logging
import re
from pathlib import Path
from typing import Any, Dict, List, Optional
from urllib.parse import parse_qs, unquote, urlparse, urlsplit, urljoin, urlencode, parse_qsl, urlunsplit

import requests
from flask import Response as FlaskResponse
from flask import jsonify, redirect, request, send_from_directory
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
REVERSE_GEOCODE_CACHE: Dict[str, Dict[str, Any]] = {}
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


def _openstreetmap_url(latitude: Any, longitude: Any, zoom: int = 16) -> str:
    return f"https://www.openstreetmap.org/?mlat={latitude}&mlon={longitude}#map={zoom}/{latitude}/{longitude}"


def _bool(value: Any) -> bool:
    if isinstance(value, bool):
        return value
    if isinstance(value, (int, float)):
        return value != 0
    if isinstance(value, str):
        return value.strip().lower() in {"1", "true", "yes", "on"}
    return bool(value)


def _to_non_negative_number(value: Any) -> Optional[float]:
    try:
        number = float(value)
    except (TypeError, ValueError):
        return None
    if number < 0:
        return None
    return number


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


def _field_value(source: Any, *names: str):
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


def _to_float(value: Any) -> Optional[float]:
    try:
        return float(value)
    except (TypeError, ValueError):
        return None


def _trip_point_payload(latitude: Any, longitude: Any, altitude: Any = None):
    lat = _to_float(latitude)
    lon = _to_float(longitude)
    if lat is None or lon is None:
        return None
    alt = _to_float(altitude)
    return {
        "latitude": lat,
        "longitude": lon,
        "altitude": alt,
        "google_maps_url": f"https://maps.google.com/maps?q={lat},{lon}",
        "openstreetmap_url": _openstreetmap_url(lat, lon),
    }


def _trip_point_from_value(value: Any):
    if value is None:
        return None

    if isinstance(value, dict):
        geometry = value.get("geometry")
        if isinstance(geometry, dict):
            coordinates = geometry.get("coordinates")
            if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
                return _trip_point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

        coordinates = value.get("coordinates")
        if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
            return _trip_point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

        latitude = value.get("latitude", value.get("lat"))
        longitude = value.get("longitude", value.get("lng", value.get("lon")))
        altitude = value.get("altitude", value.get("alt"))
        return _trip_point_payload(latitude, longitude, altitude)

    geometry = getattr(value, "geometry", None)
    if geometry is not None:
        coordinates = getattr(geometry, "coordinates", None)
        if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
            return _trip_point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

    coordinates = getattr(value, "coordinates", None)
    if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
        return _trip_point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

    latitude = getattr(value, "latitude", getattr(value, "lat", None))
    longitude = getattr(value, "longitude", getattr(value, "lng", getattr(value, "lon", None)))
    altitude = getattr(value, "altitude", getattr(value, "alt", None))
    return _trip_point_payload(latitude, longitude, altitude)


def _trip_positions_from_value(value: Any) -> List[dict]:
    items = None
    if isinstance(value, dict):
        embedded = value.get("_embedded") or value.get("embedded")
        if isinstance(embedded, dict):
            items = embedded.get("positions")
        if items is None:
            items = value.get("positions")
    elif isinstance(value, list):
        items = value
    else:
        embedded = getattr(value, "_embedded", getattr(value, "embedded", None))
        if isinstance(embedded, dict):
            items = embedded.get("positions")
        elif embedded is not None:
            embedded_positions = getattr(embedded, "positions", None)
            if isinstance(embedded_positions, list):
                items = embedded_positions
        if items is None:
            positions = getattr(value, "positions", None)
            if isinstance(positions, list):
                items = positions

    if not isinstance(items, list):
        return []

    points = []
    for item in items:
        point = _trip_point_from_value(item)
        if point:
            points.append(point)
    return points


def _next_page_token_from_payload(payload: Any):
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


def _positions_from_points(points: List[dict]) -> Dict[str, List[float]]:
    latitudes = []
    longitudes = []
    for point in points:
        lat = _to_float(_field_value(point, "latitude", "lat"))
        lon = _to_float(_field_value(point, "longitude", "lng", "lon"))
        if lat is None or lon is None:
            continue
        latitudes.append(lat)
        longitudes.append(lon)
    return {"lat": latitudes, "long": longitudes}


def _trip_waypoints_for_vehicle(car, trip_id: str) -> List[dict]:
    points = []
    seen_tokens = set()
    page_token = None
    for _ in range(0, 20):
        query_params = []
        if page_token:
            if page_token in seen_tokens:
                break
            seen_tokens.add(page_token)
            query_params.append(("pageToken", page_token))

        payload = APP.myp.api().api_client.call_api(
            "/user/vehicles/{id}/trips/{tid}/wayPoints",
            "GET",
            path_params={"id": car.vehicle_id, "tid": trip_id},
            query_params=query_params,
            response_type="object",
            auth_settings=["Vehicle_auth", "client_id", "realm"],
            _return_http_data_only=True,
        )
        page_points = _trip_positions_from_value(payload)
        for point in page_points:
            if not points:
                points.append(point)
                continue
            if points[-1]["latitude"] != point["latitude"] or points[-1]["longitude"] != point["longitude"]:
                points.append(point)
        page_token = _next_page_token_from_payload(payload)
        if not page_token:
            break
    return points


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
            "openstreetmap_url": _openstreetmap_url(latitude, longitude),
        }
    return None


def _status_payload(status) -> Dict[str, Any]:
    electric = _energy(status, "Electric")
    fuel = _energy(status, "Fuel")
    charging = getattr(electric, "charging", None)
    preconditioning = getattr(getattr(getattr(status, "preconditionning", None), "air_conditioning", None), "status", None)
    timed_odometer = getattr(status, "timed_odometer", None)
    kinetic = getattr(status, "kinetic", None)
    doors_state = getattr(status, "doors_state", None)
    environment = getattr(status, "environment", None)
    ignition = getattr(status, "ignition", None)
    privacy = getattr(status, "privacy", None)
    electric_autonomy = _to_non_negative_number(getattr(electric, "autonomy", None))
    fuel_autonomy = _to_non_negative_number(getattr(fuel, "autonomy", None))
    locked_state = _field_value(doors_state, "locked_state", "lockedState")
    if isinstance(locked_state, tuple):
        locked_state = list(locked_state)
    if not isinstance(locked_state, list):
        locked_state = []

    open_doors = []
    door_opening_entries = _field_value(doors_state, "opening")
    if isinstance(door_opening_entries, list):
        for entry in door_opening_entries:
            state_value = _field_value(entry, "state")
            if isinstance(state_value, str) and state_value.lower() == "open":
                identifier = _field_value(entry, "identifier") or "Unknown"
                open_doors.append(str(identifier))

    speed = _field_value(kinetic, "speed", "pace")
    updated_at = _iso(getattr(electric, "updated_at", None))
    if updated_at is None:
        updated_at = _iso(getattr(fuel, "updated_at", None))
    if updated_at is None:
        updated_at = _iso(getattr(timed_odometer, "updated_at", None))

    total_autonomy = None
    if electric_autonomy is not None or fuel_autonomy is not None:
        total_autonomy = (electric_autonomy or 0) + (fuel_autonomy or 0)

    return {
        "updated_at": updated_at,
        "mileage": getattr(timed_odometer, "mileage", None),
        "moving": getattr(kinetic, "moving", None),
        "remaining_km": {
            "total": total_autonomy,
            "electric": electric_autonomy,
            "fuel": fuel_autonomy,
        },
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
        "signals": {
            "ignition": _field_value(ignition, "type"),
            "moving": _field_value(kinetic, "moving"),
            "speed": speed,
            "outside_temperature": _field_value(_field_value(environment, "air"), "temp"),
            "privacy_mode": _field_value(privacy, "state"),
            "lock_state": locked_state,
            "open_doors": open_doors,
            "open_doors_count": len(open_doors),
            "doors_updated_at": _iso(_field_value(doors_state, "updated_at", "updatedAt")),
        },
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

    def _normalize_avg_consumption(value: Any, energy_type: str):
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

    def _normalize_total_consumption(value: Any, energy_type: str):
        try:
            number = float(value)
        except (TypeError, ValueError):
            return None

        if energy_type.lower() == "fuel":
            # Most payloads provide liters. Some legacy payloads expose cL.
            if number > 200:
                return number / 100
            return number
        if energy_type.lower() == "electric":
            # Most payloads provide kWh. Some legacy payloads expose Wh.
            if number > 500:
                return number / 1000
            return number
        return number

    def _trip_consumption_per_100(energy_consumptions: Optional[list], energy_type: str, distance_km: Optional[float]):
        if not isinstance(energy_consumptions, list):
            return None
        for line in energy_consumptions:
            line_type = _field(line, "type")
            if isinstance(line_type, str) and line_type.lower() == energy_type.lower():
                avg_value = _field(line, "avg_consumption", "avgConsumption", "value")
                normalized_avg = _normalize_avg_consumption(avg_value, energy_type)
                if normalized_avg is not None:
                    return normalized_avg

                total_value = _field(line, "total")
                if total_value is None:
                    total_value = _field(line, "consumption")
                if isinstance(total_value, dict):
                    total_value = _field(total_value, "consumption", "total", "value")
                normalized_total = _normalize_total_consumption(total_value, energy_type)
                if normalized_total is not None and isinstance(distance_km, (int, float)) and distance_km > 0:
                    per_100 = 100 * normalized_total / float(distance_km)
                    if energy_type.lower() == "fuel" and per_100 > 40:
                        adjusted_total = normalized_total / 100
                        adjusted_per_100 = 100 * adjusted_total / float(distance_km)
                        if adjusted_per_100 <= 40:
                            per_100 = adjusted_per_100
                    if energy_type.lower() == "electric" and per_100 > 120:
                        adjusted_total = normalized_total / 1000
                        adjusted_per_100 = 100 * adjusted_total / float(distance_km)
                        if adjusted_per_100 <= 120:
                            per_100 = adjusted_per_100
                    return per_100
        return None

    def _trip_total_consumption(energy_consumptions: Optional[list], energy_type: str, distance_km: Optional[float]):
        if not isinstance(energy_consumptions, list):
            return None
        for line in energy_consumptions:
            line_type = _field(line, "type")
            if isinstance(line_type, str) and line_type.lower() == energy_type.lower():
                total_value = _field(line, "total")
                if total_value is None:
                    total_value = _field(line, "consumption")
                if isinstance(total_value, dict):
                    total_value = _field(total_value, "consumption", "total", "value")
                normalized_total = _normalize_total_consumption(total_value, energy_type)
                if normalized_total is not None:
                    if isinstance(distance_km, (int, float)) and distance_km > 0:
                        per_100 = 100 * normalized_total / float(distance_km)
                        if energy_type.lower() == "fuel" and per_100 > 40:
                            adjusted_total = normalized_total / 100
                            adjusted_per_100 = 100 * adjusted_total / float(distance_km)
                            if adjusted_per_100 <= 40:
                                normalized_total = adjusted_total
                        if energy_type.lower() == "electric" and per_100 > 120:
                            adjusted_total = normalized_total / 1000
                            adjusted_per_100 = 100 * adjusted_total / float(distance_km)
                            if adjusted_per_100 <= 120:
                                normalized_total = adjusted_total
                    return normalized_total

                avg_value = _field(line, "avg_consumption", "avgConsumption", "value")
                normalized_avg = _normalize_avg_consumption(avg_value, energy_type)
                if normalized_avg is not None and isinstance(distance_km, (int, float)) and distance_km > 0:
                    return normalized_avg * float(distance_km) / 100
        return None

    def _to_float(value: Any):
        try:
            number = float(value)
        except (TypeError, ValueError):
            return None
        return number

    def _point_payload(latitude: Any, longitude: Any, altitude: Any = None):
        lat = _to_float(latitude)
        lon = _to_float(longitude)
        if lat is None or lon is None:
            return None
        alt = _to_float(altitude)
        return {
            "latitude": lat,
            "longitude": lon,
            "altitude": alt,
            "google_maps_url": f"https://maps.google.com/maps?q={lat},{lon}",
            "openstreetmap_url": _openstreetmap_url(lat, lon),
        }

    def _point_from_value(value: Any):
        if value is None:
            return None

        if isinstance(value, dict):
            geometry = value.get("geometry")
            if isinstance(geometry, dict):
                coordinates = geometry.get("coordinates")
                if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
                    return _point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

            coordinates = value.get("coordinates")
            if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
                return _point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

            latitude = value.get("latitude", value.get("lat"))
            longitude = value.get("longitude", value.get("lng", value.get("lon")))
            altitude = value.get("altitude", value.get("alt"))
            point = _point_payload(latitude, longitude, altitude)
            if point:
                return point
            return None

        geometry = getattr(value, "geometry", None)
        if geometry is not None:
            coordinates = getattr(geometry, "coordinates", None)
            if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
                return _point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

        coordinates = getattr(value, "coordinates", None)
        if isinstance(coordinates, (list, tuple)) and len(coordinates) >= 2:
            return _point_payload(coordinates[1], coordinates[0], coordinates[2] if len(coordinates) >= 3 else None)

        latitude = getattr(value, "latitude", getattr(value, "lat", None))
        longitude = getattr(value, "longitude", getattr(value, "lng", getattr(value, "lon", None)))
        altitude = getattr(value, "altitude", getattr(value, "alt", None))
        return _point_payload(latitude, longitude, altitude)

    def _positions_from_value(value: Any):
        items = None
        if isinstance(value, dict):
            embedded = value.get("_embedded") or value.get("embedded")
            if isinstance(embedded, dict):
                items = embedded.get("positions")
            if items is None:
                items = value.get("positions")
        elif isinstance(value, list):
            items = value
        else:
            embedded = getattr(value, "_embedded", getattr(value, "embedded", None))
            if isinstance(embedded, dict):
                items = embedded.get("positions")
            elif embedded is not None:
                embedded_positions = getattr(embedded, "positions", None)
                if isinstance(embedded_positions, list):
                    items = embedded_positions
            if items is None:
                positions = getattr(value, "positions", None)
                if isinstance(positions, list):
                    items = positions

        if not isinstance(items, list):
            return {"lat": [], "long": []}

        latitudes = []
        longitudes = []
        for item in items:
            point = _point_from_value(item)
            if point:
                latitudes.append(point["latitude"])
                longitudes.append(point["longitude"])
        return {"lat": latitudes, "long": longitudes}

    def _enrich_trip_row(trip_row: dict):
        if not isinstance(trip_row, dict):
            return trip_row

        positions = trip_row.get("positions") or {}
        latitudes = positions.get("lat") if isinstance(positions, dict) else []
        longitudes = positions.get("long") if isinstance(positions, dict) else []
        if not isinstance(latitudes, list):
            latitudes = []
        if not isinstance(longitudes, list):
            longitudes = []

        start_position = _point_from_value(trip_row.get("start_position"))
        end_position = _point_from_value(trip_row.get("end_position"))

        if start_position is None and latitudes and longitudes:
            start_position = _point_payload(latitudes[0], longitudes[0])
        if end_position is None and latitudes and longitudes:
            end_position = _point_payload(latitudes[-1], longitudes[-1])

        if not latitudes and not longitudes:
            if start_position and end_position:
                latitudes = [start_position["latitude"], end_position["latitude"]]
                longitudes = [start_position["longitude"], end_position["longitude"]]
            elif start_position:
                latitudes = [start_position["latitude"]]
                longitudes = [start_position["longitude"]]

        trip_row["positions"] = {"lat": latitudes, "long": longitudes}
        trip_row["start_position"] = start_position
        trip_row["end_position"] = end_position
        return trip_row

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

        start_at = _field(trip, "started_at", "startedAt") or _field(trip, "created_at", "createdAt") or _field(
            trip, "stopped_at", "stoppedAt")
        end_at = _field(trip, "stopped_at", "stoppedAt")

        start_position = _point_from_value(_field(trip, "start_position", "startPosition"))
        end_position = _point_from_value(_field(trip, "stop_position", "stopPosition", "endPosition"))

        positions = _positions_from_value(_field(trip, "positions", "waypoints", "wayPoints", "path"))
        latitudes = positions.get("lat", [])
        longitudes = positions.get("long", [])
        if start_position is None and latitudes and longitudes:
            start_position = _point_payload(latitudes[0], longitudes[0])
        if end_position is None and latitudes and longitudes:
            end_position = _point_payload(latitudes[-1], longitudes[-1])

        consumption_km = _trip_consumption_per_100(avg_consumption, "Electric", distance)
        consumption_fuel_km = _trip_consumption_per_100(avg_consumption, "Fuel", distance)
        consumption_electric = _trip_total_consumption(avg_consumption, "Electric", distance)
        consumption_fuel = _trip_total_consumption(avg_consumption, "Fuel", distance)

        if consumption_km is None and consumption_electric is not None and distance > 0:
            consumption_km = 100 * consumption_electric / distance
        if consumption_fuel_km is None and consumption_fuel is not None and distance > 0:
            consumption_fuel_km = 100 * consumption_fuel / distance

        row = {
            "id": _field(trip, "id"),
            "start_at": start_at,
            "end_at": end_at,
            "duration": duration_min,
            "speed_average": speed_average,
            "max_speed": _field(_field(trip, "kinetic"), "maxSpeed"),
            "distance": distance,
            "mileage": _field(trip, "odometer", "startMileage"),
            "consumption": consumption_electric,
            "consumption_km": consumption_km,
            "consumption_fuel": consumption_fuel,
            "consumption_fuel_km": consumption_fuel_km,
            "consumption_by_temp": None,
            "positions": positions,
            "start_position": start_position,
            "end_position": end_position,
            "altitude_diff": None,
            "done": _field(trip, "done"),
            "vin": default_vin,
        }
        return _enrich_trip_row(row)

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

    def _is_missing_trip_value(value: Any) -> bool:
        if value is None:
            return True
        if isinstance(value, str):
            return value.strip() == ""
        if isinstance(value, (list, dict)):
            return len(value) == 0
        return False

    def _trip_merge_key(trip_row: dict):
        if not isinstance(trip_row, dict):
            return None

        vin_key = str(trip_row.get("vin") or "")
        trip_id = trip_row.get("id")
        if trip_id not in (None, ""):
            return "id", vin_key, str(trip_id)

        start_at = trip_row.get("start_at")
        end_at = trip_row.get("end_at")
        distance = _to_float(trip_row.get("distance"))
        duration = _to_float(trip_row.get("duration"))

        if start_at not in (None, "") or end_at not in (None, ""):
            return (
                "time",
                vin_key,
                str(start_at or end_at),
                round(distance, 3) if distance is not None else -1,
                round(duration, 3) if duration is not None else -1,
            )
        return None

    def _trip_quality_score(trip_row: dict) -> int:
        if not isinstance(trip_row, dict):
            return 0

        score = 0
        if _point_from_value(trip_row.get("start_position")):
            score += 3
        if _point_from_value(trip_row.get("end_position")):
            score += 3

        positions = trip_row.get("positions")
        if isinstance(positions, dict):
            latitudes = positions.get("lat")
            longitudes = positions.get("long")
            if isinstance(latitudes, list) and isinstance(longitudes, list):
                score += min(len(latitudes), len(longitudes), 4)

        if trip_row.get("end_at"):
            score += 1
        if trip_row.get("max_speed") is not None:
            score += 1
        if trip_row.get("done") is not None:
            score += 1
        if trip_row.get("consumption_fuel") is not None:
            score += 1
        return score

    def _merge_trip_rows(primary: dict, secondary: dict) -> dict:
        merged = dict(secondary or {})
        for key, value in (primary or {}).items():
            if not _is_missing_trip_value(value):
                merged[key] = value
        return _enrich_trip_row(merged)

    def _merge_trip_sources(remote_trips: List[dict], local_trips: List[dict]) -> List[dict]:
        merged_by_key = {}
        merged_unkeyed = []

        for source in (local_trips, remote_trips):
            for trip in source:
                trip_row = _enrich_trip_row(dict(trip))
                merge_key = _trip_merge_key(trip_row)
                if merge_key is None:
                    merged_unkeyed.append(trip_row)
                    continue

                existing = merged_by_key.get(merge_key)
                if existing is None:
                    merged_by_key[merge_key] = trip_row
                    continue

                if _trip_quality_score(trip_row) >= _trip_quality_score(existing):
                    merged_by_key[merge_key] = _merge_trip_rows(trip_row, existing)
                else:
                    merged_by_key[merge_key] = _merge_trip_rows(existing, trip_row)

        merged = list(merged_by_key.values()) + merged_unkeyed
        merged.sort(
            key=lambda trip: str(_field(trip, "start_at", "end_at", "created_at", "createdAt") or ""),
            reverse=True,
        )
        return merged

    def _trips_need_remote_enrichment(trips: List[dict]) -> bool:
        if not trips:
            return True
        points_found = 0
        for trip in trips:
            enriched = _enrich_trip_row(dict(trip))
            if enriched.get("start_position") or enriched.get("end_position"):
                points_found += 1
                if points_found >= 1:
                    return False
        return True

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
            local_trips = []
            for trip in trips_by_vin.get(vin, LocalTrips()).get_trips_as_dict():
                trip_row = dict(trip)
                trip_row["vin"] = vin
                local_trips.append(_enrich_trip_row(trip_row))

            remote_trips = []
            if not local_trips or _trips_need_remote_enrichment(local_trips):
                remote_trips = _load_remote_trips(vin)
            if remote_trips and local_trips:
                return _merge_trip_sources(remote_trips, local_trips)
            if remote_trips:
                return remote_trips
            return local_trips

        local_merged = []
        trips_by_vin = LocalTrips.get_trips(APP.myp.vehicles_list)
        for vehicle_vin, trips in trips_by_vin.items():
            for trip in trips.get_trips_as_dict():
                trip_row = dict(trip)
                trip_row["vin"] = vehicle_vin
                local_merged.append(_enrich_trip_row(trip_row))

        remote_trips = []
        if not local_merged or _trips_need_remote_enrichment(local_merged):
            remote_trips = _load_remote_trips()

        if remote_trips and local_merged:
            return _merge_trip_sources(remote_trips, local_merged)
        if remote_trips:
            return remote_trips
        return local_merged
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


def _reverse_geocode_cache_key(latitude: float, longitude: float) -> str:
    return f"{latitude:.5f},{longitude:.5f}"


def _reverse_geocode_label(payload: Dict[str, Any]) -> Optional[str]:
    if not isinstance(payload, dict):
        return None
    address = payload.get("address")
    if not isinstance(address, dict):
        address = {}

    road = (
        address.get("road")
        or address.get("pedestrian")
        or address.get("residential")
        or address.get("suburb")
        or address.get("neighbourhood")
    )
    city = (
        address.get("city")
        or address.get("town")
        or address.get("village")
        or address.get("municipality")
        or address.get("county")
    )
    country = address.get("country_code")
    if isinstance(country, str):
        country = country.upper()

    parts = [item for item in (road, city, country) if isinstance(item, str) and item.strip()]
    if parts:
        return ", ".join(parts)

    for field_name in ("name", "display_name"):
        value = payload.get(field_name)
        if isinstance(value, str) and value.strip():
            return value.strip()
    return None


def _extract_oauth_code(raw_value: Optional[str]) -> Optional[str]:
    if raw_value is None:
        return None
    value = str(raw_value).strip()
    if not value:
        return None

    # Handler can already provide the raw authorization code directly.
    if all(token not in value for token in ("://", "?", "&", "=")):
        return value

    def _normalize_key(key: str) -> str:
        return str(key).strip().lower().replace("-", "_")

    def _parse_pairs(candidate: str):
        if not candidate or "=" not in candidate:
            return {}
        try:
            return parse_qs(candidate, keep_blank_values=True)
        except ValueError:
            return {}

    def _iter_candidates(start_value: str):
        pending = [start_value]
        seen = set()
        while pending and len(seen) < 256:
            current = pending.pop(0)
            if current is None:
                continue
            candidate = str(current).strip().strip('"')
            if not candidate or candidate in seen:
                continue
            seen.add(candidate)
            yield candidate

            decoded = unquote(candidate)
            if decoded and decoded != candidate:
                pending.append(decoded)

            try:
                parsed_candidate = urlparse(candidate)
            except ValueError:
                parsed_candidate = None

            if parsed_candidate is None:
                continue

            for part in (parsed_candidate.query, parsed_candidate.fragment, parsed_candidate.path, parsed_candidate.netloc):
                normalized_part = str(part or "").strip()
                if not normalized_part:
                    continue
                normalized_part = normalized_part.lstrip("?#/")
                pending.append(normalized_part)
                for values in _parse_pairs(normalized_part).values():
                    pending.extend(values)

    code_keys = {"code", "authorization_code", "auth_code", "authorizationcode"}
    for candidate in _iter_candidates(value):
        try:
            parsed_candidate = urlparse(candidate)
        except ValueError:
            parsed_candidate = None

        sources = [candidate]
        if parsed_candidate is not None:
            sources.extend([parsed_candidate.query, parsed_candidate.fragment])

        for source in sources:
            for key, values in _parse_pairs(str(source).lstrip("?#")).items():
                if _normalize_key(key) in code_keys:
                    for item in values:
                        extracted = str(item).strip()
                        if extracted:
                            return extracted

        match = re.search(
            r"(?:^|[?&#])(?:code|authorization_code|auth_code)=([^&#]+)",
            candidate,
            flags=re.IGNORECASE,
        )
        if match:
            return unquote(match.group(1)).strip()
    return None


def _normalize_oauth_scopes(raw_scopes: Any) -> List[str]:
    if raw_scopes is None:
        return []
    if isinstance(raw_scopes, str):
        return [scope for scope in raw_scopes.replace(",", " ").split() if scope]
    if isinstance(raw_scopes, list):
        normalized = []
        for value in raw_scopes:
            scope = str(value).strip()
            if scope:
                normalized.append(scope)
        return normalized
    return []


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
    if resolved_parsed.scheme in {"http", "https"} and "groupe-psa" not in resolved_parsed.netloc and "mpsa" not in resolved_parsed.netloc:
        # 3D visual hosts (for example visuel3d-secure.*) are public image endpoints.
        # Redirecting avoids backend proxy incompatibilities and lets browser cache directly.
        return redirect(resolved_picture_url, code=302)

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
        "User-Agent": "PSACC-PWA/1.0",
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


@app.route("/api/trips/<string:vin>/<string:trip_id>/path")
def api_trip_path(vin: str, trip_id: str):
    missing = _require_client()
    if missing:
        return missing
    if not _authenticated():
        return _error("Authentication required", status=401)

    car = _get_vehicle(vin)
    if car is None:
        return _error(f"Unknown VIN: {vin}", status=404)
    if not trip_id:
        return _error("trip_id is required", status=400)

    points = []
    source = "waypoints"
    warning = None
    try:
        points = _trip_waypoints_for_vehicle(car, trip_id)
    except ApiException as ex:
        if ex.status in (401, 403):
            return _error(
                "Trip path access denied. Re-authenticate and ensure trip/location scopes are granted.",
                status=ex.status,
            )
        if ex.status == 404:
            source = "waypoints_not_found"
            warning = "Trip waypoints not available from provider for this trip."
            logger.info("Trip waypoints not found for VIN %s trip %s", vin, trip_id)
        else:
            source = "waypoints_provider_error"
            warning = "Trip waypoints provider error. Showing fallback map data."
            logger.warning(
                "Trip path request failed upstream for VIN %s trip %s (status=%s). Falling back to trip payload.",
                vin,
                trip_id,
                ex.status,
            )
    except Exception:  # pragma: no cover - defensive handler
        source = "waypoints_error"
        warning = "Trip waypoints request failed. Showing fallback map data."
        logger.warning("Trip path request failed for VIN %s trip %s. Falling back to trip payload.", vin, trip_id, exc_info=True)

    if not points:
        for trip in _load_trips(vin):
            trip_identifier = _field_value(trip, "id")
            if str(trip_identifier) != str(trip_id):
                continue
            positions = _field_value(trip, "positions")
            latitudes = _field_value(positions, "lat") if isinstance(positions, dict) else None
            longitudes = _field_value(positions, "long") if isinstance(positions, dict) else None
            if isinstance(latitudes, list) and isinstance(longitudes, list):
                fallback_points = []
                for latitude, longitude in zip(latitudes, longitudes):
                    point = _trip_point_payload(latitude, longitude)
                    if point:
                        fallback_points.append(point)
                points = fallback_points
                source = "trips_fallback"
            if not points:
                start_position = _trip_point_from_value(_field_value(trip, "start_position"))
                end_position = _trip_point_from_value(_field_value(trip, "end_position"))
                if start_position and end_position:
                    points = [start_position, end_position]
                    source = "trip_markers_fallback"
                elif start_position:
                    points = [start_position]
                    source = "trip_start_marker_fallback"
            break

    positions = _positions_from_points(points)
    start_position = points[0] if points else None
    end_position = points[-1] if points else None
    response_payload = {
        "ok": True,
        "vin": vin,
        "trip_id": trip_id,
        "source": source if points else "empty",
        "point_count": len(points),
        "points": points,
        "positions": positions,
        "start_position": start_position,
        "end_position": end_position,
    }
    if warning:
        response_payload["warning"] = warning
    return jsonify(response_payload)


@app.route("/api/chargings")
def api_chargings():
    vin = request.args.get("vin")
    return jsonify(_load_chargings(vin))


@app.route("/api/geocode/reverse")
def api_reverse_geocode():
    if not _authenticated():
        return _error("Authentication required", status=401)

    try:
        latitude = float(request.args.get("lat", ""))
        longitude = float(request.args.get("lon", ""))
    except (TypeError, ValueError):
        return _error("lat and lon query parameters are required", status=400)

    if latitude < -90 or latitude > 90 or longitude < -180 or longitude > 180:
        return _error("lat/lon out of range", status=400)

    cache_key = _reverse_geocode_cache_key(latitude, longitude)
    cached = REVERSE_GEOCODE_CACHE.get(cache_key)
    if cached:
        return jsonify(cached)

    try:
        response = requests.get(
            "https://nominatim.openstreetmap.org/reverse",
            params={
                "format": "jsonv2",
                "lat": latitude,
                "lon": longitude,
                "zoom": 16,
                "addressdetails": 1,
            },
            headers={
                "User-Agent": "PSACC-PWA/1.0 (self-hosted reverse geocoding)",
                "Accept-Language": "en",
            },
            timeout=10,
        )
    except requests.RequestException:
        logger.debug("Reverse geocode request failed for %s", cache_key, exc_info=True)
        return _error("Reverse geocoding service unavailable", status=502)

    if response.status_code == 429:
        return _error("Reverse geocoding rate limit reached. Try again in a moment.", status=429)
    if not response.ok:
        logger.debug("Reverse geocode failed status=%s body=%s", response.status_code, response.text)
        return _error("Reverse geocoding failed", status=502)

    try:
        payload = response.json()
    except ValueError:
        return _error("Reverse geocoding returned invalid payload", status=502)

    label = _reverse_geocode_label(payload) or f"{latitude:.5f}, {longitude:.5f}"
    result = {
        "ok": True,
        "label": label,
        "display_name": payload.get("display_name") if isinstance(payload.get("display_name"), str) else label,
        "openstreetmap_url": _openstreetmap_url(latitude, longitude),
    }
    REVERSE_GEOCODE_CACHE[cache_key] = result
    return jsonify(result)


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


@app.route("/api/setup/oauth/retry", methods=["POST"])
def api_setup_oauth_retry():
    if INITIAL_SETUP is None:
        return _error("Setup session is missing. Run login setup first.", status=400)

    body = request.get_json(silent=True) or {}
    scopes = _normalize_oauth_scopes(body.get("scopes")) or ["openid", "profile", "data:vehicle:devices:pnc"]

    try:
        INITIAL_SETUP.psacc.service_information.scopes = scopes
        INITIAL_SETUP.psacc.manager.service_information.scopes = scopes
        redirect_url = INITIAL_SETUP.psacc.manager.generate_redirect_url(scopes=scopes)
        return jsonify({
            "ok": True,
            "redirect_url": redirect_url,
            "scopes": scopes,
            "warning": "OAuth retried with reduced scopes. Trip/location data may be unavailable for this client.",
        })
    except Exception as ex:
        logger.exception("OAuth retry URL generation failed")
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
