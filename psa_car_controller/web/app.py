import logging
import sys
from typing import Dict, Any

from flask import Flask
from werkzeug import run_simple
from werkzeug.middleware.proxy_fix import ProxyFix

try:
    from werkzeug.middleware.dispatcher import DispatcherMiddleware
except ImportError:
    from werkzeug import DispatcherMiddleware

from psa_car_controller.common.mylogger import file_handler
if sys.version_info >= (3, 8):
    import importlib
else:
    import importlib_metadata as importlib

# pylint: disable=invalid-name
app = None
logger = logging.getLogger(__name__)


def _normalize_base_path(base_path: str) -> str:
    if not base_path:
        return "/"
    if not base_path.startswith("/"):
        base_path = "/" + base_path
    base_path = base_path.rstrip("/")
    return base_path or "/"


class IngressProxyFix(ProxyFix):
    def __init__(self, flask_app):
        self.flask_app = flask_app
        super().__init__(flask_app.wsgi_app, x_host=1, x_port=1, x_prefix=1)

    def __call__(self, environ, start_response):
        prefix = environ.get("HTTP_X_INGRESS_PATH")
        if prefix:
            environ["HTTP_X_FORWARDED_PREFIX"] = prefix
            environ["SCRIPT_NAME"] = prefix
            self.flask_app.config["APPLICATION_ROOT"] = prefix
        return super().__call__(environ, start_response)


def start_app(*args, **kwargs):
    run(config_flask(*args, **kwargs))


def config_flask(title, base_path, debug: bool, host, port, reloader=False,
                 # pylint: disable=too-many-arguments,too-many-positional-arguments
                 view="psa_car_controller.web.view.api") -> Dict[str, Any]:
    global app
    base_path = _normalize_base_path(base_path)
    reload_view = app is not None
    app = Flask(__name__)
    app.logger.addHandler(file_handler)
    app.config["DEBUG"] = debug
    app.config["APPLICATION_TITLE"] = title
    app.config["APPLICATION_ROOT"] = base_path
    app.wsgi_app = IngressProxyFix(app)
    if base_path == "/":
        application = DispatcherMiddleware(app)
    else:
        application = DispatcherMiddleware(Flask("dummy_app"), {base_path: app})
    imported_view = importlib.import_module(view)
    if reload_view:
        importlib.reload(imported_view)
    return {
        "hostname": host,
        "port": port,
        "application": application,
        "use_reloader": reloader,
        "use_debugger": debug
    }


def run(config):
    return run_simple(**config)
