from pathlib import Path
import json

from fastapi import APIRouter, HTTPException, Body
from langchain_community.llms import Ollama

router = APIRouter(tags=["chat"], prefix="/chat")

CACHE_FILE = Path(__file__).resolve().parents[1] / "data" / "chat_cache.json"
CACHE_FILE.parent.mkdir(parents=True, exist_ok=True)

if CACHE_FILE.exists():
    CACHE = json.loads(CACHE_FILE.read_text())
else:
    CACHE = {}

llm = Ollama(model="llama3")


def _save_cache() -> None:
    CACHE_FILE.write_text(json.dumps(CACHE))


@router.post("/")
def chat(message: str = Body(..., embed=True)):
    if message in CACHE:
        return {"response": CACHE[message], "cached": True}
    try:
        response = llm.invoke(message)
    except Exception as exc:  # pragma: no cover - runtime failure
        raise HTTPException(status_code=500, detail=str(exc))
    CACHE[message] = response
    _save_cache()
    return {"response": response, "cached": False}
