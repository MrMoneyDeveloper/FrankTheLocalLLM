from fastapi import APIRouter, Body, HTTPException
from langchain.agents import create_sql_agent
from langchain_community.utilities import SQLDatabase
from langchain_community.llms import Ollama

from ..db import engine

router = APIRouter(tags=["sql"], prefix="/sql")

_AGENT = None


def get_agent():
    global _AGENT
    if _AGENT is None:
        db = SQLDatabase(engine)
        llm = Ollama(model="llama3")
        _AGENT = create_sql_agent(llm=llm, db=db, agent_type="openai-tools")
    return _AGENT


@router.post("/query")
def query_sql(query: str = Body(..., embed=True)):
    try:
        result = get_agent().invoke({"input": query})
        return {"result": result["output"]}
    except Exception as exc:  # pragma: no cover - runtime failure
        raise HTTPException(status_code=500, detail=str(exc))
