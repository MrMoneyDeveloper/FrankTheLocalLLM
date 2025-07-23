from celery import Celery
from langchain_community.llms import Ollama

from .config import Settings
from .db import SessionLocal
from .models import Entry

settings = Settings()

celery_app = Celery("worker", broker=settings.redis_url)
celery_app.conf.beat_schedule = {
    "summarize-entries": {
        "task": "app.tasks.summarize_entries",
        "schedule": 60.0,
    }
}


@celery_app.task
def summarize_entries():
    db = SessionLocal()
    try:
        llm = Ollama(model="llama3")
        entries = db.query(Entry).filter(Entry.summarized == False).all()
        for entry in entries:
            summary = llm.invoke(f"Summarize the following text:\n{entry.content}")
            entry.summary = summary.strip()
            entry.summarized = True
        db.commit()
    finally:
        db.close()
