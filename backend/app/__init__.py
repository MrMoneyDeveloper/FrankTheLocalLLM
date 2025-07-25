from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import Settings
from .db import Base, engine
from .services.example_service import router as example_router
from .services.trivia_service import router as trivia_router
from .services.auth_service import router as auth_router
from .services.user_service import router as user_router
from .services.agent_service import router as agent_router
from .services.chat_service import router as chat_router
from .services.entry_service import router as entry_router


settings = Settings()

app = FastAPI(title=settings.app_name, debug=settings.debug)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Ensure database tables exist
Base.metadata.create_all(bind=engine)

app.include_router(example_router, prefix="/api")
app.include_router(trivia_router, prefix="/api")
app.include_router(auth_router, prefix="/api")
app.include_router(user_router, prefix="/api")
app.include_router(agent_router, prefix="/api")
app.include_router(chat_router, prefix="/api")
app.include_router(entry_router, prefix="/api")

