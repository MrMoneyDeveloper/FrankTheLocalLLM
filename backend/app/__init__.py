from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import Settings
from .services.example_service import router as example_router
from .services.trivia_service import router as trivia_router

settings = Settings()

app = FastAPI(title=settings.app_name, debug=settings.debug)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(example_router, prefix="/api")
app.include_router(trivia_router, prefix="/api")
