from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description="KisanSetu AI Intelligence Service for Agricultural Demand Forecasting, Crop Advisory, and RAG Intelligence"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/health", tags=["Health"])
def health_check():
    return {
        "status": "UP",
        "service": "kisansetu-ai-service",
        "phase": "PHASE_0",
        "version": settings.VERSION,
        "message": "AI Service baseline foundation is healthy and ready for Phase 1 intelligence models."
    }

@app.get("/", tags=["Root"])
def root():
    return {
        "service": settings.PROJECT_NAME,
        "health": "/health",
        "docs": "/docs"
    }
