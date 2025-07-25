import logging
import socket
import sys

from uvicorn import run
from . import app, settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


def port_available(host: str, port: int) -> bool:
    """Return True if the given host/port can be bound."""
    with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as sock:
        try:
            sock.bind((host, port))
        except OSError as exc:
            logger.error("Cannot bind to %s:%s - %s", host, port, exc)
            return False
        logger.debug("Port %s on %s is free", port, host)
        return True

if __name__ == "__main__":
    logger.info("Starting %s on %s:%s", settings.app_name, settings.host, settings.port)
    if not port_available(settings.host, settings.port):
        logger.error(
            "Port %s is busy. Run 'netstat -aon | findstr :%s' to find the process using it or set PORT to another value.",
            settings.port,
            settings.port,
        )
        sys.exit(1)


    run(
        "backend.app:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
