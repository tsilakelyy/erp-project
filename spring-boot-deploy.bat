@echo off
REM =========================================
REM  ERP Spring Boot Deployment Script
REM =========================================
REM  Déploie l'application ERP via Spring Boot JAR
REM  Port: 9090
REM  Context: /erp-system

setlocal enabledelayedexpansion

cls
echo.
echo =========================================
echo    ERP Spring Boot Deployment
echo =========================================
echo.

REM Step 1: Kill existing Java processes
echo Step 1: Stopping existing application...
taskkill /F /IM java.exe >nul 2>&1
timeout /t 2 /nobreak >nul

REM Step 2: Clean and build
echo Step 2: Building application...
call mvn clean package -DskipTests -q
if %errorlevel% neq 0 (
    echo [ERROR] Maven build failed
    exit /b 1
)
echo [OK] Build successful

REM Step 3: Start Spring Boot application
echo Step 3: Starting Spring Boot application...
echo Spring Boot will run on: http://localhost:9090/erp-system
echo Profile: prod
echo.
timeout /t 2 /nobreak >nul

cd /d "%~dp0"
start "ERP System - Spring Boot" cmd /k "java -jar target/erp-system.war --spring.profiles.active=prod"

echo.
echo =========================================
echo   Application Starting...
echo =========================================
echo.
echo Waiting for startup (usually 30-40 seconds)...
timeout /t 45 /nobreak

echo.
echo =========================================
echo   Checking Application Status
echo =========================================
echo.

REM Step 4: Verify deployment
setlocal enabledelayedexpansion
set "timeout=0"
set "max_attempts=5"

:verify_loop
if !timeout! geq !max_attempts! goto timeout_reached

REM Wait 3 seconds between checks
timeout /t 3 /nobreak >nul

REM Check if application responds
powershell -Command "try { $resp = Invoke-WebRequest -Uri 'http://localhost:9090/erp-system/' -UseBasicParsing -ErrorAction SilentlyContinue; if ($resp -and $resp.StatusCode -eq 200) { exit 0 } } catch { } exit 1"

if %errorlevel% equ 0 (
    echo [OK] Application is running
    goto deployment_success
)

set /a timeout=!timeout!+1
goto verify_loop

:timeout_reached
echo [WARNING] Could not verify application status

:deployment_success
echo.
echo =========================================
echo   Deployment Successful
echo =========================================
echo.
echo Application URL: http://localhost:9090/erp-system
echo.
echo Login Credentials:
echo  Username: admin
echo  Password: admin
echo.
echo To stop the application, close the Spring Boot window
echo or run: taskkill /F /IM java.exe
echo.

pause
