import json
import threading
import time
from datetime import datetime, timedelta, timezone
from json import JSONEncoder
from hashlib import md5
from sqlite3.dbapi2 import IntegrityError
from typing import Any, Dict, List

from oauth2_client.credentials_manager import ServiceInformation
from urllib3.exceptions import InvalidHeader

from psa_car_controller.psa.connected_car_api.api.vehicles_api import VehiclesApi
from psa_car_controller.psa.connected_car_api.rest import ApiException
from psa_car_controller.psacc.model.car import Cars, Car
from psa_car_controller.psacc.application.charging import Charging
from psa_car_controller.psa.AccountInformation import AccountInformation
from psa_car_controller.psa.RemoteClient import RemoteClient
from psa_car_controller.psa.RemoteCredentials import RemoteCredentials
from psa_car_controller.psa.oauth import OpenIdCredentialManager, Oauth2PSACCApiConfig, OauthAPIClient
from .ecomix import Ecomix
from psa_car_controller.psa.constants import realm_info, AUTHORIZE_SERVICE

from .abrp import Abrp
from psa_car_controller.psacc.repository.db import Database
from psa_car_controller.common.mylogger import CustomLogger

DEFAULT_OAUTH_SCOPES = ["openid", "profile", "data:vehicle:devices:pnc", "data:trip", "data:position"]
CARS_FILE = "cars.json"
DEFAULT_CONFIG_FILENAME = "config.json"

logger = CustomLogger.getLogger(__name__)


class PSAClient:
    @staticmethod
    def _to_dict_payload(value: Any):
        if isinstance(value, dict):
            return value
        if hasattr(value, "to_dict"):
            try:
                converted = value.to_dict()
                if isinstance(converted, dict):
                    return converted
            except Exception:
                logger.debug("Unable to convert payload to dict", exc_info=True)
        return None

    @staticmethod
    def _normalize_scopes(scopes):
        if scopes is None:
            return []
        if isinstance(scopes, str):
            return [scope for scope in scopes.replace(",", " ").split() if scope]
        try:
            return [str(scope).strip() for scope in scopes if str(scope).strip()]
        except TypeError:
            return []

    def connect(self, code: str):
        self.manager.connect_with_code(code)
        self.api_config.access_token = self.manager.access_token or ""
        self._next_refresh_retry_at = 0.0

    # pylint: disable=too-many-arguments,too-many-positional-arguments
    def __init__(self, refresh_token, client_id, client_secret, remote_refresh_token, customer_id, realm, country_code,
                 brand=None, proxies=None, weather_api=None, abrp=None, co2_signal_api=None, scopes=None):
        self.realm = realm
        oauth_scopes = self._normalize_scopes(scopes) or list(DEFAULT_OAUTH_SCOPES)
        self.service_information = ServiceInformation(AUTHORIZE_SERVICE[self.realm],
                                                      realm_info[self.realm]['oauth_url'],
                                                      client_id,
                                                      client_secret,
                                                      oauth_scopes, True)
        self.client_id = client_id
        self.country_code = country_code
        self.manager = OpenIdCredentialManager.create(self.service_information,
                                                      realm_info[self.realm]["scheme"], self.country_code)
        self.api_config = Oauth2PSACCApiConfig()
        self.api_config.set_refresh_callback(self._refresh_access_token)
        self.manager.refresh_token = refresh_token
        self.account_info = AccountInformation(client_id, customer_id, realm, country_code)
        self.remote_access_token = None
        self.vehicles_list = Cars.load_cars(CARS_FILE)
        self.customer_id = customer_id
        self._config_hash = None
        self.api_config.verify_ssl = True
        self.api_config.api_key['client_id'] = self.client_id
        self.api_config.api_key['x-introspect-realm'] = self.realm
        self.remote_token_last_update = None
        self._record_enabled = False
        self._next_refresh_retry_at = 0.0
        self._refresh_backoff_seconds = 300
        self.weather_api = weather_api
        self.brand = brand
        self.info_callback = []
        self.info_refresh_rate = 120
        if abrp is None:
            self.abrp = Abrp()
        else:
            self.abrp: Abrp = Abrp(**abrp)
        self.set_proxies(proxies)
        self.config_file = DEFAULT_CONFIG_FILENAME
        Ecomix.co2_signal_key = co2_signal_api
        self.refresh_thread: threading.Timer = None
        remote_credentials = RemoteCredentials(remote_refresh_token)
        remote_credentials.update_callbacks.append(self.save_config)
        self.remote_client = RemoteClient(self.account_info,
                                          self.vehicles_list,
                                          self.manager,
                                          remote_credentials)

    def get_app_name(self):
        return realm_info[self.realm]['app_name']

    def _refresh_access_token(self):
        now = time.monotonic()
        if now < self._next_refresh_retry_at:
            return False
        refreshed = self.manager.refresh_token_now()
        self.api_config.access_token = self.manager.access_token or ""
        if refreshed:
            self._next_refresh_retry_at = 0.0
            return True
        self._next_refresh_retry_at = now + self._refresh_backoff_seconds
        logger.warning("OAuth refresh failed; next retry in %ss", self._refresh_backoff_seconds)
        return refreshed

    def api(self) -> VehiclesApi:
        self.api_config.access_token = self.manager.access_token or ""
        api_instance = VehiclesApi(OauthAPIClient(self.api_config))
        return api_instance

    def set_proxies(self, proxies):
        if proxies is None:
            proxies = {"http": '', "https": ''}
            self.api_config.proxy = None
        else:
            self.api_config.proxy = proxies['http']
            self.abrp.proxies = proxies
        self.manager.proxies = proxies

    @staticmethod
    def _extract_embedded_vehicles(payload: Any) -> List[Dict[str, Any]]:
        payload_dict = PSAClient._to_dict_payload(payload)
        if not isinstance(payload_dict, dict):
            return []
        embedded = payload_dict.get("_embedded") or payload_dict.get("embedded")
        if isinstance(embedded, dict):
            vehicles = embedded.get("vehicles")
            if isinstance(vehicles, list):
                normalized = []
                for vehicle in vehicles:
                    vehicle_dict = PSAClient._to_dict_payload(vehicle)
                    if isinstance(vehicle_dict, dict):
                        normalized.append(vehicle_dict)
                return normalized
        vehicles = payload_dict.get("vehicles")
        if isinstance(vehicles, list):
            normalized = []
            for vehicle in vehicles:
                vehicle_dict = PSAClient._to_dict_payload(vehicle)
                if isinstance(vehicle_dict, dict):
                    normalized.append(vehicle_dict)
            return normalized
        return []

    @staticmethod
    def _looks_like_url(value: Any) -> bool:
        if not isinstance(value, str):
            return False
        return value.startswith(("https://", "http://", "/"))

    @classmethod
    def _extract_picture_from_value(cls, value: Any, depth: int = 0):
        if depth > 8:
            return None
        if isinstance(value, str):
            if cls._looks_like_url(value):
                return value
            return None
        if isinstance(value, list):
            for item in value:
                candidate = cls._extract_picture_from_value(item, depth + 1)
                if candidate:
                    return candidate
            return None
        if isinstance(value, dict):
            for key in (
                "href",
                "url",
                "src",
                "link",
                "uri",
                "picture",
                "pictureUrl",
                "pictureURL",
                "image",
                "imageUrl",
            ):
                if key in value:
                    candidate = cls._extract_picture_from_value(value.get(key), depth + 1)
                    if candidate:
                        return candidate
            for nested_value in value.values():
                candidate = cls._extract_picture_from_value(nested_value, depth + 1)
                if candidate:
                    return candidate
        return None

    @classmethod
    def _extract_picture_url(cls, raw_vehicle: Dict[str, Any]):
        raw_vehicle = cls._to_dict_payload(raw_vehicle)
        if not isinstance(raw_vehicle, dict):
            return None
        containers = []
        extension = None
        embedded = raw_vehicle.get("_embedded") or raw_vehicle.get("embedded")
        if isinstance(embedded, dict):
            extension = embedded.get("extension")
        if extension is None:
            extension = raw_vehicle.get("extension")
        branding = raw_vehicle.get("branding")
        if isinstance(branding, dict):
            containers.append(branding.get("pictures"))
            containers.append(branding)
        if isinstance(extension, dict):
            containers.append(extension.get("pictures"))
            containers.append(extension.get("branding"))
        containers.append(raw_vehicle.get("pictures"))

        for container in containers:
            if container is None:
                continue
            candidate = cls._extract_picture_from_value(container)
            if candidate:
                return candidate
        return None

    @staticmethod
    def _extract_supports_electric(raw_vehicle: Dict[str, Any]):
        raw_vehicle = PSAClient._to_dict_payload(raw_vehicle)
        if not isinstance(raw_vehicle, dict):
            return None
        engines = raw_vehicle.get("engine")
        if not isinstance(engines, list):
            return None

        has_electric = False
        for engine in engines:
            if not isinstance(engine, dict):
                continue
            engine_class = engine.get("class") or engine.get("_class")
            if isinstance(engine_class, str) and engine_class.lower() == "electric":
                has_electric = True
                break
        if has_electric:
            return True

        onboard_capabilities = raw_vehicle.get("onboardCapabilities")
        if isinstance(onboard_capabilities, list):
            for capability in onboard_capabilities:
                if isinstance(capability, str):
                    lowered = capability.lower()
                    if any(token in lowered for token in ("electric", "battery", "charge", "precond")):
                        return True
                elif isinstance(capability, dict):
                    for key, value in capability.items():
                        if isinstance(key, str) and isinstance(value, bool) and value:
                            lowered = key.lower()
                            if any(token in lowered for token in ("electric", "battery", "charge", "precond")):
                                return True
        elif isinstance(onboard_capabilities, dict):
            for key, value in onboard_capabilities.items():
                if isinstance(key, str) and isinstance(value, bool) and value:
                    lowered = key.lower()
                    if any(token in lowered for token in ("electric", "battery", "charge", "precond")):
                        return True
        return has_electric

    @staticmethod
    def _extract_brand_and_label(raw_vehicle: Dict[str, Any]):
        raw_vehicle = PSAClient._to_dict_payload(raw_vehicle)
        if not isinstance(raw_vehicle, dict):
            return None, None
        brand = raw_vehicle.get("brand")
        label = raw_vehicle.get("label")
        branding = raw_vehicle.get("branding")
        if isinstance(branding, dict):
            if not brand:
                brand = branding.get("brand") or branding.get("manufacturer")
            if not label:
                label = branding.get("label") or branding.get("name") or branding.get("model")
        return brand, label

    def _load_raw_vehicles_payload(self):
        query_variants = [
            [("extension", "branding"), ("extension", "pictures"), ("extension", "onboardCapabilities")],
            [("extension", "pictures"), ("extension", "branding")],
            [("extension", "pictures")],
            [("extension", "branding")],
            None,
        ]
        last_error = None
        for query_params in query_variants:
            try:
                payload = self.api().api_client.call_api(
                    "/user/vehicles",
                    "GET",
                    query_params=query_params,
                    response_type="object",
                    auth_settings=["Vehicle_auth", "client_id", "realm"],
                    _return_http_data_only=True,
                )
                payload_dict = self._to_dict_payload(payload)
                if isinstance(payload_dict, dict):
                    return payload_dict
                return payload
            except ApiException as ex:
                last_error = ex
                if ex.status in {400, 404, 422, 500, 502, 503, 504}:
                    logger.debug("raw vehicles fetch failed for params=%s status=%s", query_params, ex.status)
                    continue
                if ex.status in {401, 403}:
                    raise
                logger.debug("raw vehicles fetch unexpected failure for params=%s", query_params, exc_info=True)
                continue
        if last_error is not None:
            logger.debug("All raw vehicles query variants failed; using fallback paths", exc_info=True)
        return None

    def _load_raw_vehicle_detail(self, vehicle_id: str):
        if not vehicle_id:
            return None
        query_variants = [
            [("extension", "branding"), ("extension", "pictures"), ("extension", "onboardCapabilities")],
            [("extension", "pictures"), ("extension", "branding")],
            [("extension", "pictures")],
            [("extension", "branding")],
            None,
        ]
        for query_params in query_variants:
            try:
                payload = self.api().api_client.call_api(
                    "/user/vehicles/{id}",
                    "GET",
                    path_params={"id": vehicle_id},
                    query_params=query_params,
                    response_type="object",
                    auth_settings=["Vehicle_auth", "client_id", "realm"],
                    _return_http_data_only=True,
                )
                payload_dict = self._to_dict_payload(payload)
                if isinstance(payload_dict, dict):
                    return payload_dict
                return payload
            except ApiException as ex:
                if ex.status in {400, 404, 422, 500, 502, 503, 504}:
                    logger.debug("raw vehicle detail fetch failed for %s params=%s status=%s",
                                 vehicle_id, query_params, ex.status)
                    continue
                if ex.status in {401, 403}:
                    break
                logger.debug("raw vehicle detail fetch failed for %s", vehicle_id, exc_info=True)
                break
            except (TypeError, ValueError, AttributeError):
                logger.debug("raw vehicle detail payload invalid for %s", vehicle_id, exc_info=True)
                break
        return None

    def _load_raw_vehicle_metadata(self) -> Dict[str, Dict[str, Any]]:
        metadata_by_vin = {}
        try:
            raw_payload = self._load_raw_vehicles_payload()
            for vehicle in self._extract_embedded_vehicles(raw_payload):
                vin = vehicle.get("vin")
                if not vin:
                    continue
                vehicle_id = vehicle.get("id")
                brand, label = self._extract_brand_and_label(vehicle)
                picture_url = self._extract_picture_url(vehicle)
                supports_electric = self._extract_supports_electric(vehicle)

                if (not picture_url or brand is None or label is None) and vehicle_id:
                    detailed = self._load_raw_vehicle_detail(vehicle_id)
                    if isinstance(detailed, dict):
                        detailed_brand, detailed_label = self._extract_brand_and_label(detailed)
                        if brand is None:
                            brand = detailed_brand
                        if label is None:
                            label = detailed_label
                        if not picture_url:
                            picture_url = self._extract_picture_url(detailed)
                        if supports_electric is None:
                            supports_electric = self._extract_supports_electric(detailed)

                metadata_by_vin[vin] = {
                    "vehicle_id": vehicle_id,
                    "brand": brand,
                    "label": label,
                    "picture_url": picture_url,
                    "supports_electric": supports_electric,
                }
        except ApiException as ex:
            if ex.status == 401:
                logger.warning("get_vehicles raw metadata: unauthorized; re-authentication required")
            else:
                logger.debug("get_vehicles raw metadata failed", exc_info=True)
        except (InvalidHeader, TypeError, ValueError, AttributeError):
            logger.debug("get_vehicles raw metadata invalid", exc_info=True)
        return metadata_by_vin

    def get_vehicle_info(self, vin, cache=False):
        res = None
        car = self.vehicles_list.get_car_by_vin(vin)
        if cache and car.status is not None:
            res = car.status
        else:
            for _ in range(0, 2):
                try:
                    res = self.api().get_vehicle_status(car.vehicle_id)
                    if res is not None:
                        car.status = res
                        if self._record_enabled:
                            self.record_info(car)
                        return res
                except ApiException as ex:
                    if ex.status == 401:
                        logger.warning("get_vehicle_info: unauthorized; re-authentication required")
                        break
                    logger.error("get_vehicle_info: ApiException: %s", ex, exc_info_debug=True)
                except (InvalidHeader, TypeError) as ex:
                    logger.error("get_vehicle_info: ApiException: %s", ex, exc_info_debug=True)
            car.status = res
        return res

    def __refresh_vehicle_info(self):
        if self.info_refresh_rate is not None:
            if self.refresh_thread and self.refresh_thread.is_alive():
                logger.debug("refresh_vehicle_info: precedent task still alive")
                self.refresh_thread.cancel()
            self.refresh_thread = threading.Timer(self.info_refresh_rate, self.__refresh_vehicle_info)
            self.refresh_thread.daemon = True
            self.refresh_thread.start()
            try:
                logger.debug("refresh_vehicle_info")
                for car in self.vehicles_list:
                    self.get_vehicle_info(car.vin)
                for callback in self.info_callback:
                    callback()
            except BaseException:
                logger.exception("refresh_vehicle_info: ")

    def start_refresh_thread(self):
        if self.refresh_thread is None:
            self.__refresh_vehicle_info()

    def get_vehicles(self):
        raw_metadata = self._load_raw_vehicle_metadata()
        try:
            res = self.api().get_vehicles_by_device()
            embedded = getattr(res, "embedded", None)
            vehicles = getattr(embedded, "vehicles", None) if embedded else None
            if vehicles is None:
                vehicles = []

            for vehicle in vehicles:
                vin = getattr(vehicle, "vin", None)
                if not vin:
                    continue
                metadata = raw_metadata.get(vin, {})
                vehicle_id = getattr(vehicle, "id", None) or metadata.get("vehicle_id")

                fallback_detail = None
                if vehicle_id:
                    fallback_detail = self._load_raw_vehicle_detail(vehicle_id)

                picture_url = metadata.get("picture_url")
                if not picture_url and fallback_detail is not None:
                    picture_url = self._extract_picture_url(fallback_detail)
                if not picture_url and vehicle_id:
                    try:
                        generated_detail = self.api().get_vehicle_byid(vehicle_id)
                        picture_url = self._extract_picture_url(generated_detail)
                        if not metadata.get("brand") or not metadata.get("label"):
                            detail_brand, detail_label = self._extract_brand_and_label(generated_detail)
                            metadata["brand"] = metadata.get("brand") or detail_brand
                            metadata["label"] = metadata.get("label") or detail_label
                        if metadata.get("supports_electric") is None:
                            metadata["supports_electric"] = self._extract_supports_electric(generated_detail)
                    except ApiException:
                        logger.debug("generated vehicle detail fetch failed for %s", vehicle_id, exc_info=True)
                    except (InvalidHeader, TypeError, ValueError, AttributeError):
                        logger.debug("generated vehicle detail payload invalid for %s", vehicle_id, exc_info=True)
                metadata["picture_url"] = picture_url

                supports_electric = None
                engines = getattr(vehicle, "engine", None)
                if isinstance(engines, list):
                    for engine in engines:
                        engine_class = getattr(engine, "_class", None)
                        if isinstance(engine, dict):
                            engine_class = engine.get("class") or engine.get("_class") or engine_class
                        if isinstance(engine_class, str) and engine_class.lower() == "electric":
                            supports_electric = True
                            break

                if supports_electric is None:
                    supports_electric = metadata.get("supports_electric")

                self.vehicles_list.add(Car(
                    vin,
                    vehicle_id,
                    getattr(vehicle, "brand", None) or metadata.get("brand") or "Unknown",
                    getattr(vehicle, "label", None) or metadata.get("label"),
                    picture_url=metadata.get("picture_url"),
                    supports_electric=supports_electric,
                ))

            for vin, metadata in raw_metadata.items():
                if self.vehicles_list.get_car_by_vin(vin):
                    continue
                if not metadata.get("vehicle_id") or not metadata.get("brand"):
                    continue
                self.vehicles_list.add(Car(
                    vin,
                    metadata["vehicle_id"],
                    metadata["brand"],
                    metadata.get("label"),
                    picture_url=metadata.get("picture_url"),
                    supports_electric=metadata.get("supports_electric"),
                ))

            self.vehicles_list.save_cars()
        except ApiException as ex:
            if ex.status == 401:
                logger.warning("get_vehicles: unauthorized; re-authentication required")
            else:
                logger.exception("get_vehicles:")
        except (InvalidHeader, TypeError):
            logger.exception("get_vehicles:")
        return self.vehicles_list

    def get_charge_status(self, vin):
        data = self.get_vehicle_info(vin)
        status = data.get_energy('Electric').charging.status
        return status

    def save_config(self, name=None, force=False):
        if name is None:
            name = self.config_file
        config_str = json.dumps(self, cls=PSAClientEncoder, sort_keys=True, indent=4).encode("utf8")
        new_hash = md5(config_str).hexdigest()
        if force or self._config_hash != new_hash:
            with open(name, "wb") as f:
                f.write(config_str)
            self._config_hash = new_hash
            logger.info("save config change")

    @staticmethod
    def load_config(name="config.json"):
        with open(name, "r", encoding="utf-8") as f:
            config_str = f.read()
            config = {**json.loads(config_str)}
            if "country_code" not in config:
                config["country_code"] = input("What is your country code ? (ex: FR, GB, DE, ES...)\n")
            for new_el in ["abrp", "co2_signal_api"]:
                if new_el not in config:
                    config[new_el] = None
            psacc = PSAClient(**config)
            psacc.config_file = name
            return psacc

    def set_record(self, value: bool):
        self._record_enabled = value

    def record_info(self, car: Car):  # pylint: disable=too-many-locals
        mileage = car.status.timed_odometer.mileage
        level = car.status.get_energy('Electric').level
        level_fuel = car.status.get_energy('Fuel').level
        if car.is_thermal():
            charge_date = car.status.get_energy('Fuel').updated_at
        else:
            charge_date = car.status.get_energy('Electric').updated_at
        moving = car.status.kinetic.moving

        longitude = car.status.last_position.geometry.coordinates[0]
        latitude = car.status.last_position.geometry.coordinates[1]
        altitude = car.status.last_position.geometry.coordinates[2]
        date = car.status.last_position.properties.updated_at
        if date is None or date < datetime.now(timezone.utc) - timedelta(days=1):  # if position isn't updated
            date = charge_date

        temp = getattr(getattr(getattr(car.status, "environment", None), "air", None), "temp", None)

        logger.debug("vin:%s longitude:%s latitude:%s date:%s mileage:%s level:%s charge_date:%s level_fuel:"
                     "%s moving:%s temp:%s", car.vin, longitude, latitude, date, mileage, level, charge_date,
                     level_fuel, moving, temp)
        Database.record_position(self.weather_api, car.vin, mileage, latitude, longitude, altitude, date, level,
                                 level_fuel, moving, temp)
        self.abrp.call(car, Database.get_last_temp(car.vin))
        if car.has_battery():
            electric_energy_status = car.status.get_energy('Electric')
            try:
                charging_status = electric_energy_status.charging.status
                charging_mode = electric_energy_status.charging.charging_mode
                charging_rate = electric_energy_status.charging.charging_rate
                autonomy = electric_energy_status.autonomy
                Charging.record_charging(car, charging_status, charge_date, level, latitude, longitude,
                                         self.country_code,
                                         charging_mode, charging_rate, autonomy, mileage)
                logger.debug("charging_status:%s ", charging_status)
            except AttributeError as ex:
                logger.error("charging status not available from api")
                logger.debug(ex)
            try:
                soh = electric_energy_status.battery.health.resistance
                Database.record_battery_soh(car.vin, charge_date, soh)
            except IntegrityError:
                logger.debug("SOH already recorded")
            except AttributeError as ex:
                logger.debug("Failed to record SOH: %s", ex)

    def __iter__(self):
        for key, value in self.__dict__.items():
            yield key, value


class PSAClientEncoder(JSONEncoder):

    def default(self, mp: PSAClient):  # pylint: disable=arguments-renamed
        mpd = {"proxies": mp.manager.proxies,
               "refresh_token": mp.manager.refresh_token,
               "client_secret": mp.service_information.client_secret,
               "abrp": dict(mp.abrp),
               "remote_refresh_token": mp.remote_client.remoteCredentials.refresh_token,
               "customer_id": mp.account_info.customer_id,
               "client_id": mp.account_info.client_id,
               "realm": mp.account_info.realm,
               "country_code": mp.account_info.country_code,
               "scopes": list(mp.service_information.scopes),
               "weather_api": mp.weather_api,
               "co2_signal_api": Ecomix.co2_signal_key
               }
        return mpd
