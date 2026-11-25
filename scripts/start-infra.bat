@echo off
echo ========================================================
echo Starting KisanSetu Local Infrastructure (Docker Compose)
echo ========================================================
cd /d "%~dp0\.."
docker compose up -d
echo.
echo Infrastructure containers started:
docker compose ps
pause
