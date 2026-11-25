from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "KisanSetu AI Intelligence Service"
    VERSION: str = "0.1.0"
    API_PREFIX: str = "/api/v1"
    PORT: int = 8000
    HOST: str = "0.0.0.0"
    BACKEND_API_URL: str = "http://localhost:8080/api/v1"

    class Config:
        env_file = ".env"
        extra = "ignore"

settings = Settings()
