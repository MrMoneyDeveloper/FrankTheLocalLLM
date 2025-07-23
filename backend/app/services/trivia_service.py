from pathlib import Path

from fastapi import APIRouter, HTTPException, Query
from langchain.chains import RetrievalQA
from langchain_community.document_loaders import UnstructuredMarkdownLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter
from langchain_community.vectorstores import Chroma
from langchain_community.embeddings import OllamaEmbeddings
from langchain_community.llms import Ollama

router = APIRouter()

DATA_FILE = Path(__file__).resolve().parents[1] / "data" / "trivia.md"


def _create_chain() -> RetrievalQA:
    loader = UnstructuredMarkdownLoader(str(DATA_FILE))
    docs = loader.load()
    splitter = RecursiveCharacterTextSplitter(chunk_size=512, chunk_overlap=50)
    splits = splitter.split_documents(docs)

    embeddings = OllamaEmbeddings(model="nomic-embed-text")
    vectorstore = Chroma.from_documents(splits, embeddings)
    llm = Ollama(model="llama3")
    return RetrievalQA.from_chain_type(llm=llm, retriever=vectorstore.as_retriever())


_CHAIN: RetrievalQA | None = None


def get_chain() -> RetrievalQA:
    global _CHAIN
    if _CHAIN is None:
        _CHAIN = _create_chain()
    return _CHAIN


@router.get("/trivia")
def ask_trivia(q: str = Query(..., description="Question for the trivia bot")):
    try:
        answer = get_chain().run(q)
    except Exception as exc:  # pragma: no cover - runtime failure
        raise HTTPException(status_code=500, detail=str(exc))
    return {"answer": answer}
