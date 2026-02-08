@echo off
REM =========================================
REM  ERP Application Launcher
REM =========================================
REM  Launch Spring Boot application on port 9091
REM  Access: http://localhost:9091/erp-system
REM  Login: admin / password123

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
setlocal enabledelayedexpansion
set "APP_PORT=9091"
set "APP_CONTEXT=/erp-system"

REM Kill any process already listening on 9091 to avoid startup failure
for /f "tokens=5" %%P in ('netstat -ano ^| findstr /r /c:":%APP_PORT% .*LISTENING"') do (
    if not "%%P"=="" (
        echo Detected PID %%P on port %APP_PORT% - stopping it...
        taskkill /F /PID %%P >nul 2>&1
    )
)

echo Listening on: http://localhost:%APP_PORT%%APP_CONTEXT%
echo.
timeout /t 3 /nobreak

REM Run from a temp copy to avoid locking target artifacts (which can break rebuilds on Windows)
set "RUN_WAR=%TEMP%\\erp-system-run-%RANDOM%.war"
copy /Y "target\\erp-system-exec.war" "%RUN_WAR%" >nul
echo Running: %RUN_WAR%
java -jar "%RUN_WAR%" --spring.profiles.active=prod --server.port=%APP_PORT% --server.servlet.context-path=%APP_CONTEXT%

pause
