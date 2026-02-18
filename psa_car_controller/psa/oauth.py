import logging
import hashlib
import secrets
import base64
import time
from typing import Tuple
from urllib.parse import quote

from http import HTTPStatus
from typing import Optional

from oauth2_client.credentials_manager import CredentialManager, OAuthError, ServiceInformation
from requests import Response, RequestException

from psa_car_controller.psa import connected_car_api
from psa_car_controller.psa.connected_car_api import ApiClient
from psa_car_controller.psa.connected_car_api.rest import ApiException

logger = logging.getLogger(__name__)


def generate_sha256_pkce(length: int) -> Tuple[str, str]:
    if not (43 <= length <= 128):
        raise ValueError("Invalid length: %d" % length)
    verifier = secrets.token_urlsafe(length)
    encoded = base64.urlsafe_b64encode(hashlib.sha256(verifier.encode('ascii')).digest())
    challenge = encoded.decode('ascii')[:-1]
    return verifier, challenge


class OpenIdCredentialManager(CredentialManager):
    @staticmethod
    def create(service_information: ServiceInformation, scheme: str, country_code: str,
               proxies: Optional[dict] = None):
        manager = OpenIdCredentialManager(service_information, proxies)
        manager.redirect_uri = scheme + "://oauth2redirect/" + country_code.lower()
        return manager

    def __init__(self, service_information: ServiceInformation, proxies: Optional[dict] = None):
        super().__init__(service_information, proxies)
        self.refresh_callbacks = []
        self.code_verifier = None
        self.redirect_uri = None
        self._refresh_limit = 6
        self._refresh_window_seconds = 1800
        self._refresh_window_started_at = 0.0
        self._refresh_window_count = 0
        self._refresh_retry_after = 0.0
        self._last_refresh_skip_log_at = 0.0

    def _grant_password_request_realm(self, login: str, password: str, realm: str) -> dict:
        return {"grant_type": 'password', "username": login, "scope": ' '.join(self.service_information.scopes),
                "password": password, "realm": realm}

    @staticmethod
    def _normalize_scopes(scopes) -> list:
        if scopes is None:
            return []
        if isinstance(scopes, str):
            return [scope for scope in scopes.replace(",", " ").split() if scope]
        try:
            return [str(scope).strip() for scope in scopes if str(scope).strip()]
        except TypeError:
            return []

    def generate_authorize_url_for_scopes(self, redirect_uri: str, state: str, scopes=None, **kwargs) -> str:
        requested_scopes = self._normalize_scopes(scopes) or list(self.service_information.scopes)
        parameters = dict(client_id=self.service_information.client_id,
                          redirect_uri=redirect_uri,
                          response_type='code',
                          scope=' '.join(requested_scopes),
                          state=state,
                          **kwargs)
        return '%s?%s' % (self.service_information.authorize_service,
                          '&'.join('%s=%s' % (k, quote(v, safe='~()*!.\'')) for k, v in parameters.items()))

    def generate_redirect_url(self, scopes=None):
        self.code_verifier, code_challenge = generate_sha256_pkce(64)
        return self.generate_authorize_url_for_scopes(self.redirect_uri, secrets.token_urlsafe(16), scopes=scopes,
                                                      code_challenge=code_challenge, code_challenge_method="S256")

    def connect_with_code(self, code: str):
        assert len(code) == 36, "Invalid code length"
        self._token_request({"grant_type": 'authorization_code', "code": code,
                             "redirect_uri": self.redirect_uri, "code_verifier": self.code_verifier},
                            False)

    @staticmethod
    def _is_token_expired(response: Response) -> bool:
        if response.status_code == HTTPStatus.UNAUTHORIZED.value:
            logger.info("token expired, renew")
            try:
                json_data = response.json()
                return json_data.get('moreInformation') == 'Token is invalid'
            except ValueError:
                return False
        else:
            return False

    @property
    def access_token(self):
        return self._access_token

    def _refresh_allowed(self, now: float) -> bool:
        if now < self._refresh_retry_after:
            if now - self._last_refresh_skip_log_at >= 60:
                wait_seconds = int(self._refresh_retry_after - now)
                logger.info("Skip token refresh during cooldown (%ss remaining)", wait_seconds)
                self._last_refresh_skip_log_at = now
            return False

        if self._refresh_window_started_at == 0.0 or now - self._refresh_window_started_at >= self._refresh_window_seconds:
            self._refresh_window_started_at = now
            self._refresh_window_count = 0

        if self._refresh_window_count >= self._refresh_limit:
            self._refresh_retry_after = self._refresh_window_started_at + self._refresh_window_seconds
            wait_seconds = int(max(0, self._refresh_retry_after - now))
            logger.warning("OAuth refresh throttled by local policy; next retry in %ss", wait_seconds)
            return False

        self._refresh_window_count += 1
        return True

    def refresh_token_now(self):
        now = time.monotonic()
        if not self._refresh_allowed(now):
            return False

        try:
            self._refresh_token()
            for refresh_callback in self.refresh_callbacks:
                refresh_callback()
            self._refresh_retry_after = 0.0
            return True
        except OAuthError as e:
            error_text = str(e)
            lowered_error = error_text.lower()
            if "invalid_scope" in lowered_error:
                current_scopes = self._normalize_scopes(self.service_information.scopes)
                fallback_candidates = []
                if any(scope in current_scopes for scope in ("data:trip", "data:position")):
                    fallback_candidates.append(["openid", "profile", "data:vehicle:devices:pnc"])
                fallback_candidates.append(["openid", "profile"])

                for fallback_scopes in fallback_candidates:
                    self.service_information.scopes = fallback_scopes
                    logger.warning(
                        "OAuth scopes rejected; retrying refresh with reduced scopes: %s",
                        " ".join(fallback_scopes),
                    )
                    try:
                        self._refresh_token()
                        for refresh_callback in self.refresh_callbacks:
                            refresh_callback()
                        self._refresh_retry_after = 0.0
                        return True
                    except OAuthError as fallback_error:
                        error_text = str(fallback_error)
                        logger.warning("Reduced-scope refresh failed: %s", fallback_error)
            retry_seconds = 900 if "invalid_grant" in error_text else 300
            self._refresh_retry_after = max(self._refresh_retry_after, now + retry_seconds)
            logger.warning("Can't refresh token: %s (next retry in %ss)", e, retry_seconds)
        except RequestException as e:
            retry_seconds = 120
            self._refresh_retry_after = max(self._refresh_retry_after, now + retry_seconds)
            logger.error("Can't refresh token %s (next retry in %ss)", e, retry_seconds)
        except Exception as e:  # pragma: no cover - defensive
            retry_seconds = 120
            self._refresh_retry_after = max(self._refresh_retry_after, now + retry_seconds)
            logger.error("Unexpected token refresh error %s (next retry in %ss)", e, retry_seconds)
        return False


class Oauth2PSACCApiConfig(connected_car_api.Configuration):
    def __init__(self):
        super().__init__()
        self.refresh_callback = lambda: True

    def auth_settings(self):
        # Some environments can leave access_token to None after a failed refresh.
        # Keep auth header construction safe and let API flow handle unauthorized responses.
        access_token = self.access_token or ""
        return {
            'Vehicle_auth':
                {
                    'type': 'oauth2',
                    'in': 'header',
                    'key': 'Authorization',
                    'value': 'Bearer ' + access_token
                },
            'client_id':
                {
                    'type': 'api_key',
                    'in': 'query',
                    'key': 'client_id',
                    'value': self.get_api_key_with_prefix('client_id')
                },
            'realm':
                {
                    'type': 'api_key',
                    'in': 'header',
                    'key': 'x-introspect-realm',
                    'value': self.get_api_key_with_prefix('x-introspect-realm')
                },
        }

    def set_refresh_callback(self, callback):
        self.refresh_callback = callback


class OauthAPIClient(ApiClient):
    @staticmethod
    def _is_unauthorized(api_exception: ApiException) -> bool:
        status = getattr(api_exception, "status", None)
        reason = str(getattr(api_exception, "reason", "") or "").lower()
        body = str(getattr(api_exception, "body", "") or "").lower()
        return status == 401 or "unauthorized" in reason or "token is invalid" in body

    def _refresh_if_needed(self, auth_settings=None, force=False):
        needs_vehicle_auth = bool(auth_settings and 'Vehicle_auth' in auth_settings)
        if not needs_vehicle_auth:
            return True
        if self.configuration.access_token and not force:
            return True
        try:
            return bool(self.configuration.refresh_callback())
        except Exception:
            logger.debug("OAuth token refresh failed", exc_info=True)
            return False

    # pylint: disable=no-member,too-many-arguments,too-many-positional-arguments
    def call_api(self, resource_path, method,
                 path_params=None, query_params=None, header_params=None,
                 body=None, post_params=None, files=None,
                 response_type=None, auth_settings=None, async_req=None,
                 _return_http_data_only=None, collection_formats=None,
                 _preload_content=True, _request_timeout=None):
        if not self._refresh_if_needed(auth_settings):
            raise ApiException(status=401, reason="Unauthorized")

        for _ in range(0, 2):
            try:
                if not async_req:
                    return self._ApiClient__call_api(resource_path, method,
                                                     path_params, query_params, header_params,
                                                     body, post_params, files,
                                                     response_type, auth_settings,
                                                     _return_http_data_only, collection_formats,
                                                     _preload_content, _request_timeout)
                return self.pool.apply_async(self.__call_api, (resource_path,
                                                               method, path_params, query_params,
                                                               header_params, body,
                                                               post_params, files,
                                                               response_type, auth_settings,
                                                               _return_http_data_only,
                                                               collection_formats,
                                                               _preload_content, _request_timeout))
            except ApiException as e:
                if self._is_unauthorized(e):
                    if not self._refresh_if_needed(auth_settings, force=True):
                        raise e
                else:
                    raise e
        raise ApiException(status=401, reason="Unauthorized")
