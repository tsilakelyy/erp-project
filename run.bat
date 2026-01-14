@echo off
REM =========================================
REM  ERP Application Launcher
REM =========================================
REM  Launch Spring Boot application on port 9091
REM  Access: http://localhost:9091/erp-system
REM  Login: admin / admin

cls
echo.
echo =========================================
echo    ERP System - Spring Boot
echo =========================================
echo.
echo Building application...
cd /d "%~dp0"
call mvn package -DskipTests -q

if %errorlevel% neq 0 (
    echo [ERROR] Build failed
    pause
    exit /b 1
)

echo.
echo Starting application...
echo Listening on: http://localhost:9091/erp-system
echo.
timeout /t 3 /nobreak

java -jar target/erp-system.war --spring.profiles.active=prod

pause
