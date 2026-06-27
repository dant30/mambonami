# backend/fastapi_app/core/config.py
from pydantic_settings import BaseSettings
from typing import List

class Settings(BaseSettings):
    ENVIRONMENT: str = "development"
    DJANGO_BASE_URL: str = "http://127.0.0.1:8000"
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://localhost:8080",
        "https://mambonami.com",
        "https://www.mambonami.com",
        "https://api.mambonami.com",
        "https://admin.mambonami.com",
    ]
    ALLOWED_HOSTS: List[str] = ["*"]
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"

settings = Settings()
