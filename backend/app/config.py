from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    app_name: str = "FrankTheLocalLLM"
    host: str = "0.0.0.0"
    port: int = 8000
    debug: bool = False
    allowed_origins: list[str] = ["*"]
    redis_url: str = "redis://localhost:6379/0"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
