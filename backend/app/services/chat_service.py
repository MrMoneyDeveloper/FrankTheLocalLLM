from pathlib import Path
from fastapi import APIRouter, HTTPException, Body, Depends

from ..llm import LLMClient, OllamaLLM
from ..utils.cache import Cache

router = APIRouter(tags=["chat"], prefix="/chat")

CACHE_FILE = Path(__file__).resolve().parents[1] / "data" / "chat_cache.json"


class ChatService:
    def __init__(self, llm: LLMClient, cache: Cache):
        self._llm = llm
        self._cache = cache

    def chat(self, message: str) -> dict:
        cached = self._cache.get(message)
        if cached is not None:
            return {"response": cached, "cached": True}
        try:
            response = self._llm.invoke(message)
        except Exception as exc:  # pragma: no cover - runtime failure
            raise HTTPException(status_code=500, detail=str(exc))
        self._cache.set(message, response)
        return {"response": response, "cached": False}


def get_service() -> ChatService:
    llm = OllamaLLM()
    cache = Cache(CACHE_FILE)
    return ChatService(llm, cache)


@router.post("/")
def chat(message: str = Body(..., embed=True), service: ChatService = Depends(get_service)):
    return service.chat(message)
