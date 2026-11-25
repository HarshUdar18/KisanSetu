@echo off
echo ========================================================
echo Starting KisanSetu Spring Boot Modular Monolith
echo ========================================================
cd /d "%~dp0\..\backend\spring-boot-application"
call .\mvnw.cmd spring-boot:run
pause
