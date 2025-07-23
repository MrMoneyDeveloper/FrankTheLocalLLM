import logging
from uvicorn import run
from . import app, settings

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

if __name__ == "__main__":
    logger.info("Starting %s", settings.app_name)
    run(
        "app:app",
        host=settings.host,
        port=settings.port,
        reload=settings.debug,
    )
