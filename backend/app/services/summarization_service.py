from sqlalchemy.orm import Session

from ..llm import LLMClient
from ..models import Entry

class SummarizationService:
    def __init__(self, llm: LLMClient):
        self._llm = llm

    def summarize_pending_entries(self, db: Session) -> None:
        entries = db.query(Entry).filter(Entry.summarized == False).all()
        for entry in entries:
            summary = self._llm.invoke(f"Summarize the following text:\n{entry.content}")
            entry.summary = summary.strip()
            entry.summarized = True
