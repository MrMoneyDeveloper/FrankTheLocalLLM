from celery import Celery

from .config import Settings
from .db import SessionLocal
from .llm import OllamaLLM
from .services.summarization_service import SummarizationService

settings = Settings()

celery_app = Celery("worker", broker=settings.redis_url)
celery_app.conf.beat_schedule = {
    "summarize-entries": {
        "task": "app.tasks.summarize_entries",
        "schedule": 60.0,
    }
}


summarization_service = SummarizationService(OllamaLLM())


@celery_app.task
def summarize_entries():
    db = SessionLocal()
    try:
        summarization_service.summarize_pending_entries(db)
        db.commit()
    finally:
        db.close()
