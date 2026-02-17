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
import sys
import traceback
import webbrowser
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional
from urllib.parse import parse_qs, unquote, urlparse

import requests

DEFAULT_API_URL = os.environ.get("PSACC_OAUTH_API_URL", "http://127.0.0.1:5000/api/setup/oauth")
DEFAULT_UI_URL = os.environ.get("PSACC_UI_URL", "http://127.0.0.1:5000/")
REQUEST_TIMEOUT = float(os.environ.get("PSACC_OAUTH_TIMEOUT", "12"))

LOCAL_APP_DATA = os.environ.get("LOCALAPPDATA", str(Path.home()))
LOG_FILE = Path(LOCAL_APP_DATA) / "psacc-mymap-handler.log"


def _log(message: str):
    try:
        timestamp = datetime.now(timezone.utc).isoformat(timespec="seconds")
        LOG_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(LOG_FILE, "a", encoding="utf-8") as log_file:
            log_file.write(f"{timestamp} {message}\n")
    except Exception:  # pragma: no cover - logging should never break callback flow
        pass


def _show_message(title: str, message: str, is_error=False):
    if os.environ.get("PSACC_HANDLER_SHOW_UI", "0") != "1":
        return
    try:
        import ctypes

        icon = 0x10 if is_error else 0x40
        ctypes.windll.user32.MessageBoxW(None, message, title, icon)
    except Exception:  # pragma: no cover - best effort UI
        _log("Failed to show message box")


def _first(query_params: dict, key: str) -> Optional[str]:
    values = query_params.get(key, None)
    if not values:
        return None
    return values[0]


def extract_code(raw_value: str) -> Optional[str]:
    value = raw_value.strip().strip('"')
    if not value:
        return None

    parsed = urlparse(value)
    query = parse_qs(parsed.query)
    fragment = parse_qs(parsed.fragment)

    for params in [query, fragment]:
        code = _first(params, "code")
        if code:
            return code

    # Some flows carry an encoded query in gotoparam.
    gotoparam = _first(query, "gotoparam") or _first(fragment, "gotoparam")
    if gotoparam:
        decoded = unquote(gotoparam)
        nested_query = decoded.split("?", 1)[-1] if "?" in decoded else decoded
        nested_params = parse_qs(nested_query)
        code = _first(nested_params, "code")
        if code:
            return code

    # Fallback for manually copied strings containing "...code=...".
    if "code=" in value:
        candidate = value.split("?", 1)[-1]
        fallback = parse_qs(candidate)
        code = _first(fallback, "code")
        if code:
            return code

    return None


def post_oauth_code(code: str, redirect_url: str) -> tuple[bool, str]:
    payload = {"code": code, "redirect_url": redirect_url}
    _log(f"Posting OAuth code to {DEFAULT_API_URL}")
    response = requests.post(DEFAULT_API_URL, json=payload, timeout=REQUEST_TIMEOUT)
    try:
        body = response.json()
    except ValueError:
        body = {"error": response.text}

    if response.ok and body.get("ok", True):
        return True, body.get("message", "OAuth completed")

    error = body.get("error", f"HTTP {response.status_code}")
    return False, error


def main() -> int:
    if len(sys.argv) < 2:
        _log("No protocol URL argument received")
        return 1

    deep_link = sys.argv[1]
    _log(f"Received deep link ({len(deep_link)} chars)")
    code = extract_code(deep_link)
    if not code:
        message = "Could not extract OAuth code from callback URL."
        _log(message)
        _show_message("PSACC OAuth", message, is_error=True)
        return 2

    _log(f"Extracted OAuth code (length={len(code)})")
    try:
        success, message = post_oauth_code(code, deep_link)
    except Exception as ex:  # pragma: no cover - defensive logging
        trace = traceback.format_exc()
        _log(f"OAuth POST failed: {ex}\n{trace}")
        _show_message("PSACC OAuth", f"OAuth callback failed: {ex}", is_error=True)
        return 3

    if success:
        _log(f"OAuth callback success: {message}")
        _show_message("PSACC OAuth", "OAuth completed. Return to PSACC app.", is_error=False)
        try:
            webbrowser.open(DEFAULT_UI_URL)
        except Exception:  # pragma: no cover - best effort
            _log("Failed to open PSACC UI URL")
        return 0

    _log(f"OAuth callback returned error: {message}")
    _show_message("PSACC OAuth", f"OAuth callback error: {message}", is_error=True)
    return 4


if __name__ == "__main__":
    sys.exit(main())
