import logging
import socket
from uvicorn import run
from . import app, settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def port_in_use(port: int) -> bool:
    """Return True if the given TCP port is in use."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        return sock.connect_ex(("localhost", port)) == 0

if __name__ == "__main__":
    logger.info("Starting %s on port %s", settings.app_name, settings.port)

    if port_in_use(settings.port):
        logger.error(
            "Port %s is already in use. Set PORT to another value or free the port and try again.",
            settings.port,
        )
        raise SystemExit(1)

    run(
        "backend.app:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
