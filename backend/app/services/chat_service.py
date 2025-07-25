from __future__ import annotations

from pathlib import Path
import json

from fastapi import APIRouter, Body, HTTPException
from langchain_community.llms import Ollama

router = APIRouter(tags=["chat"], prefix="/chat")

_CACHE_FILE = Path(__file__).resolve().parents[1] / "data" / "chat_cache.json"
_llm: Ollama | None = None


def _load_cache() -> dict[str, str]:
    if _CACHE_FILE.exists():
        try:
            return json.loads(_CACHE_FILE.read_text())
        except json.JSONDecodeError:  # pragma: no cover - corrupted file
            return {}
    return {}


def _save_cache(cache: dict[str, str]) -> None:
    _CACHE_FILE.write_text(json.dumps(cache))


def get_llm() -> Ollama:
    global _llm
    if _llm is None:
        _llm = Ollama(model="llama3")
    return _llm


@router.post("")
def chat(message: str = Body(..., embed=True)):
    cache = _load_cache()
    if message in cache:
        return {"response": cache[message], "cached": True}
    try:
        response = get_llm().invoke(message)
    except Exception as exc:  # pragma: no cover - runtime failure
        raise HTTPException(status_code=500, detail=str(exc))
    cache[message] = response
    _save_cache(cache)
    return {"response": response, "cached": False}
