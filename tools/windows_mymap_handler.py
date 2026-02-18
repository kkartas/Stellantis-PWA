#!/usr/bin/env python3
"""
Windows protocol handler for mymap:// OAuth callback links.

Expected flow:
1. Browser invokes this script via protocol registration with the full mymap:// URL.
2. Script extracts OAuth code.
3. Script POSTs code to local PSACC endpoint /api/setup/oauth.
4. Script optionally opens the PSACC UI page.
"""

from __future__ import annotations

import json
import os
import re
import sys
import time
import traceback
import webbrowser
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from urllib.parse import parse_qs, parse_qsl, unquote, urlencode, urlparse, urlsplit, urlunsplit

import requests

DEFAULT_API_URL = os.environ.get("PSACC_OAUTH_API_URL", "http://127.0.0.1:5000/api/setup/oauth")
DEFAULT_RETRY_API_URL = os.environ.get("PSACC_OAUTH_RETRY_API_URL", "http://127.0.0.1:5000/api/setup/oauth/retry")
DEFAULT_UI_URL = os.environ.get("PSACC_UI_URL", "http://127.0.0.1:5000/")
REQUEST_TIMEOUT = float(os.environ.get("PSACC_OAUTH_TIMEOUT", "90"))
REQUEST_RETRIES = int(os.environ.get("PSACC_OAUTH_RETRIES", "0"))
FALLBACK_SCOPES = os.environ.get("PSACC_OAUTH_FALLBACK_SCOPES", "openid profile")

LOCAL_APP_DATA = os.environ.get("LOCALAPPDATA", str(Path.home()))
LOG_FILE = Path(LOCAL_APP_DATA) / "psacc-mymap-handler.log"
CODE_KEYS = {"code", "authorization_code", "auth_code", "authorizationcode"}


def _log(message: str):
    try:
        timestamp = datetime.now(timezone.utc).isoformat(timespec="seconds")
        LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(LOG_FILE, "a", encoding="utf-8") as log_file:
            log_file.write(f"{timestamp} {message}\n")
    except Exception:  # pragma: no cover - logging should never break callback flow
        pass


def _show_message(title: str, message: str, is_error=False):
    if os.environ.get("PSACC_HANDLER_SHOW_UI", "1") != "1":
        return
    try:
        import ctypes

        icon = 0x10 if is_error else 0x40
        ctypes.windll.user32.MessageBoxW(None, message, title, icon)
    except Exception:  # pragma: no cover - best effort UI
        _log("Failed to show message box")


def _normalize_key(value: str) -> str:
    return str(value).strip().lower().replace("-", "_")


def _normalize_scopes(raw_scopes) -> list[str]:
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


def _parse_pairs(value: str):
    if not value or "=" not in value:
        return {}
    try:
        return parse_qs(value, keep_blank_values=True)
    except ValueError:
        return {}


def _iter_candidates(raw_value: str, max_depth: int = 6):
    pending = [raw_value]
    seen = set()
    depth = 0
    while pending and depth < 256:
        depth += 1
        value = pending.pop(0)
        if value is None:
            continue
        candidate = str(value).strip().strip('"')
        if not candidate or candidate in seen:
            continue
        seen.add(candidate)
        yield candidate

        decoded = unquote(candidate)
        if decoded and decoded != candidate:
            pending.append(decoded)

        try:
            parsed = urlparse(candidate)
        except ValueError:
            continue

        parts = [parsed.query, parsed.fragment, parsed.path, parsed.netloc]
        for part in parts:
            part = str(part or "").strip()
            if not part:
                continue
            pending.append(part.lstrip("?#/"))
            for values in _parse_pairs(part.lstrip("?#/")).values():
                pending.extend(values)


def _extract_from_key_set(raw_value: str, keys: set[str]) -> Optional[str]:
    normalized_keys = {_normalize_key(key) for key in keys}
    for candidate in _iter_candidates(raw_value):
        try:
            parsed_candidate = urlparse(candidate)
        except ValueError:
            parsed_candidate = None
        sources = [candidate]
        if parsed_candidate is not None:
            sources.extend([parsed_candidate.query, parsed_candidate.fragment])
        for source in sources:
            for key, values in _parse_pairs(str(source).lstrip("?#")).items():
                if _normalize_key(key) in normalized_keys:
                    for value in values:
                        normalized_value = str(value).strip()
                        if normalized_value:
                            return normalized_value
    return None


def extract_oauth_error(raw_value: str) -> Optional[str]:
    error = _extract_from_key_set(raw_value, {"error"})
    if not error:
        return None
    description = _extract_from_key_set(raw_value, {"error_description"})
    if description:
        return f"{error}: {description}"
    return error


def extract_code(raw_value: str) -> Optional[str]:
    value = raw_value.strip().strip('"')
    if not value:
        return None
    code = _extract_from_key_set(value, CODE_KEYS)
    if code:
        return code
    for candidate in _iter_candidates(value):
        match = re.search(
            r"(?:^|[?&#])(?:code|authorization_code|auth_code)=([^&#]+)",
            candidate,
            flags=re.IGNORECASE,
        )
        if match:
            return unquote(match.group(1)).strip()
    return None


def describe_callback_url(raw_value: str) -> str:
    try:
        parsed = urlparse(raw_value)
    except ValueError:
        return "unparseable callback URL"
    query_keys = sorted(_parse_pairs(parsed.query).keys())
    fragment_keys = sorted(_parse_pairs(parsed.fragment).keys())
    return f"scheme={parsed.scheme} netloc={parsed.netloc} path={parsed.path} query_keys={query_keys} fragment_keys={fragment_keys}"


def _sanitize_for_log(raw_value: str, limit: int = 420) -> str:
    sanitized = re.sub(r"(?i)(code=)[^&#]+", r"\1***", str(raw_value))
    sanitized = re.sub(r"(?i)(password=)[^&#]+", r"\1***", sanitized)
    sanitized = sanitized.replace("\r", " ").replace("\n", " ")
    if len(sanitized) > limit:
        return sanitized[:limit] + "...(truncated)"
    return sanitized


def _extract_authorize_url(raw_value: str) -> Optional[str]:
    try:
        parsed_root = urlparse(str(raw_value))
    except ValueError:
        parsed_root = None

    if parsed_root is not None and parsed_root.scheme not in {"http", "https"}:
        host = parsed_root.netloc.strip()
        if host and "." in host:
            root_params = _parse_pairs(parsed_root.query)
            gotoparam = root_params.get("gotoparam", [None])[0]
            if gotoparam:
                decoded = unquote(gotoparam)
                if decoded.startswith(("http://", "https://")):
                    return decoded
                if "=" in decoded:
                    path = parsed_root.path or "/"
                    return f"https://{host}{path}?{decoded}"

    for candidate in _iter_candidates(raw_value):
        stripped = candidate.strip()
        if not stripped.startswith(("https://", "http://")):
            continue
        try:
            parsed = urlparse(stripped)
        except ValueError:
            continue
        query_params = _parse_pairs(parsed.query)
        fragment_params = _parse_pairs(parsed.fragment)
        keys = {key.lower() for key in query_params.keys()} | {key.lower() for key in fragment_params.keys()}
        if "response_type" in keys and "client_id" in keys and "redirect_uri" in keys:
            return stripped
    return None


def request_oauth_retry_url(scopes: list[str]) -> Optional[str]:
    payload = {"scopes": scopes}
    try:
        _log(f"Requesting OAuth retry URL from {DEFAULT_RETRY_API_URL} with scopes={scopes}")
        response = requests.post(DEFAULT_RETRY_API_URL, json=payload, timeout=(6, 20))
        try:
            body = response.json()
        except ValueError:
            body = {"error": response.text}
        if not response.ok:
            _log(f"OAuth retry endpoint error ({response.status_code}): {body.get('error')}")
            return None
        retry_url = body.get("redirect_url")
        if isinstance(retry_url, str) and retry_url:
            return retry_url
    except requests.RequestException as ex:
        _log(f"OAuth retry endpoint request failed: {ex}")
    return None


def post_oauth_code(code: Optional[str], redirect_url: str) -> tuple[bool, str]:
    payload = {"redirect_url": redirect_url}
    if code:
        payload["code"] = code
    attempts = max(1, REQUEST_RETRIES + 1)
    for attempt in range(1, attempts + 1):
        try:
            _log(f"Posting OAuth code to {DEFAULT_API_URL} (attempt {attempt}/{attempts})")
            response = requests.post(DEFAULT_API_URL, json=payload, timeout=(8, REQUEST_TIMEOUT))
            try:
                body = response.json()
            except ValueError:
                body = {"error": response.text}

            if response.ok and body.get("ok", True):
                return True, body.get("message", "OAuth completed")

            error = body.get("error", f"HTTP {response.status_code}")
            if response.status_code >= 500 and attempt < attempts:
                _log(f"OAuth callback failed with {response.status_code}, retrying: {error}")
                time.sleep(min(2 * attempt, 6))
                continue
            return False, error
        except requests.Timeout:
            if attempt < attempts:
                _log(f"OAuth callback timed out after {REQUEST_TIMEOUT}s, retrying")
                time.sleep(min(2 * attempt, 6))
                continue
            return False, f"Backend timeout after {REQUEST_TIMEOUT}s while completing OAuth"
        except requests.RequestException as ex:
            if attempt < attempts:
                _log(f"OAuth callback network error, retrying: {ex}")
                time.sleep(min(2 * attempt, 6))
                continue
            return False, f"Network error during OAuth callback: {ex}"
    return False, "OAuth callback failed"


def open_ui(extra_query: Optional[dict[str, str]] = None):
    target_url = DEFAULT_UI_URL
    if extra_query:
        try:
            parsed = urlsplit(DEFAULT_UI_URL)
            query = parse_qsl(parsed.query, keep_blank_values=True)
            for key, value in extra_query.items():
                query.append((key, value))
            target_url = urlunsplit((
                parsed.scheme,
                parsed.netloc,
                parsed.path,
                urlencode(query),
                parsed.fragment,
            ))
        except ValueError:
            _log("Unable to append query parameters to UI URL")
    try:
        webbrowser.open(target_url)
        _log(f"Opened UI URL: {target_url}")
    except Exception:  # pragma: no cover - best effort
        _log("Failed to open PSACC UI URL")


def main() -> int:
    if len(sys.argv) < 2:
        _log("No protocol URL argument received")
        return 1

    deep_link = sys.argv[1]
    _log(f"Received deep link ({len(deep_link)} chars)")
    _log(describe_callback_url(deep_link))
    _log(f"Callback preview: {_sanitize_for_log(deep_link)}")
    code = extract_code(deep_link)
    if code:
        _log(f"Extracted OAuth code (length={len(code)})")
    else:
        oauth_error = extract_oauth_error(deep_link)
        if oauth_error:
            lowered_error = oauth_error.lower()
            if "invalid_scope" in lowered_error and any(
                    token in lowered_error for token in ("data:trip", "data:position")):
                retry_scopes = _normalize_scopes(FALLBACK_SCOPES) or ["openid", "profile"]
                retry_url = request_oauth_retry_url(retry_scopes)
                if retry_url:
                    _log(f"Retrying OAuth with reduced scopes: {retry_scopes}")
                    _log(f"Retry URL preview: {_sanitize_for_log(retry_url)}")
                    try:
                        webbrowser.open(retry_url)
                        _show_message(
                            "PSACC OAuth",
                            "Provider rejected trip/location scopes. Retrying login with supported scopes.",
                            is_error=False,
                        )
                        return 2
                    except Exception:
                        _log("Failed to open OAuth retry URL")
            message = f"OAuth provider returned an error callback: {oauth_error}"
            _log(message)
            open_ui({"oauth": "error"})
            _show_message("PSACC OAuth", message, is_error=True)
            return 2

        authorize_url = _extract_authorize_url(deep_link)
        if authorize_url:
            _log("No OAuth code in callback URL. Opening nested authorize URL in browser.")
            _log(f"Authorize URL preview: {_sanitize_for_log(authorize_url)}")
            try:
                webbrowser.open(authorize_url)
            except Exception:
                _log("Failed to open nested authorize URL")
            _show_message(
                "PSACC OAuth",
                "OAuth flow needs one more browser step. Continue login in the opened page.",
                is_error=False,
            )
            return 2

        _log("No OAuth code found in callback URL, trying backend fallback with redirect_url only")
    try:
        success, message = post_oauth_code(code, deep_link)
    except Exception as ex:  # pragma: no cover - defensive logging
        trace = traceback.format_exc()
        _log(f"OAuth POST failed: {ex}\n{trace}")
        open_ui({"oauth": "error"})
        _show_message("PSACC OAuth", f"OAuth callback failed: {ex}", is_error=True)
        return 3

    if success:
        _log(f"OAuth callback success: {message}")
        open_ui({"oauth": "done"})
        _show_message("PSACC OAuth", "OAuth completed. Return to PSACC app.", is_error=False)
        return 0

    _log(f"OAuth callback returned error: {message}")
    open_ui({"oauth": "error"})
    _show_message("PSACC OAuth", f"OAuth callback error: {message}", is_error=True)
    return 4


if __name__ == "__main__":
    sys.exit(main())
