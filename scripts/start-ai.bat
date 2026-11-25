@echo off
echo ========================================================
echo Starting KisanSetu AI Service (FastAPI)
echo ========================================================
cd /d "%~dp0\..\ai-service"
uvicorn app.main:app --reload --port 8000
pause
