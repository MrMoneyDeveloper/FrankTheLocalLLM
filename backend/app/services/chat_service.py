from pathlib import Path
from fastapi import APIRouter, HTTPException, Body, Depends

from ..llm import LLMClient, OllamaLLM
from . import CachedLLMService

router = APIRouter(tags=["chat"], prefix="/chat")


class ChatService(CachedLLMService):
    _llm: LLMClient | None = None  # allow monkeypatching in tests
    _cache = None  # compat for tests

    def __init__(self, llm: LLMClient):
        super().__init__(llm)

    def chat(self, message: str) -> dict:
        try:
            response = self.llm_invoke(message)
            cached = self.was_cached()
        except Exception as exc:  # pragma: no cover - runtime failure
            raise HTTPException(status_code=500, detail=str(exc))
        return {"response": response, "cached": cached}


def get_service() -> ChatService:
    llm = OllamaLLM()
    return ChatService(llm)


@router.post("/")
def chat(message: str = Body(..., embed=True), service: ChatService = Depends(get_service)):
    return service.chat(message)
