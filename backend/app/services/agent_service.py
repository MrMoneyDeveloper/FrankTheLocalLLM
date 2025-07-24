from fastapi import APIRouter, Body, HTTPException, Depends
from langchain.agents import create_sql_agent
from langchain_community.utilities import SQLDatabase
from langchain_community.llms import Ollama

from ..db import engine
from . import CachedLLMService

router = APIRouter(tags=["agent"], prefix="/agent")


class AgentService(CachedLLMService):
    def __init__(self):
        super().__init__(Ollama(model="llama3"))
        self._db = SQLDatabase(engine)
        self._agent = create_sql_agent(llm=self._llm, db=self._db, agent_type="openai-tools")

    def run(self, command: str) -> dict:
        try:
            result = self._agent.invoke({"input": command})
            return {"response": result["output"]}
        except Exception as exc:  # pragma: no cover - runtime failure
            raise HTTPException(status_code=500, detail=str(exc))


def get_service() -> AgentService:
    return AgentService()


@router.post("/run")
def run_agent(command: str = Body(..., embed=True), service: AgentService = Depends(get_service)):
    return service.run(command)
