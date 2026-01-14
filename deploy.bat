@echo off
setlocal enabledelayedexpansion
REM ERP Deployment Script for Windows Tomcat
REM Author: System Admin
REM Description: Compiles, packages and deploys ERP application to Tomcat

REM Colors and messages
set GREEN=
set RED=
set YELLOW=

echo.
echo =========================================
echo    ERP Application Deployment Script
echo =========================================
echo.

REM Check Maven installation
echo Checking Maven installation...
call mvn --version
if %errorlevel% neq 0 (
    echo [ERROR] Maven is not installed or not in PATH
    echo Please install Maven and add it to your system PATH
    exit /b 1
)
echo [OK] Maven is installed
echo.

REM Compile and package
echo.
echo Step 1: Compiling and packaging application...
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo [ERROR] Maven build failed
    exit /b 1
)
echo [OK] Build successful

REM Backup existing WAR
echo.
echo Step 2: Backing up existing deployment...
if exist "C:\apache-tomcat-10.1.28\webapps\erp-system.war" (
    ren "C:\apache-tomcat-10.1.28\webapps\erp-system.war" "erp-system.war.backup"
    echo [OK] Backup created
)

REM Stop Tomcat
echo.
echo Step 3: Stopping Tomcat...
taskkill /F /IM java.exe >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Tomcat stopped
) else (
    echo [WARNING] Tomcat not running or could not be stopped
)

REM Wait for Tomcat to stop
timeout /t 5 /nobreak

REM Delete old deployment
echo.
echo Step 4: Cleaning old deployment...
if exist "C:\apache-tomcat-10.1.28\work\Catalina\localhost\erp-system" (
    rmdir /s /q "C:\apache-tomcat-10.1.28\work\Catalina\localhost\erp-system"
    echo [OK] Old deployment removed
)

REM Copy new WAR file
echo.
echo Step 5: Deploying new application...
copy target\erp-system.war "C:\apache-tomcat-10.1.28\webapps\erp-system.war"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to copy WAR file
    exit /b 1
)
echo [OK] Application deployed

REM Start Tomcat
echo.
echo Step 6: Starting Tomcat...
cd /d C:\apache-tomcat-10.1.28\bin
call startup.bat >nul 2>&1
cd /d E:\S5\web\TOVO\app_default_26_01_11_09_03_07
echo [OK] Tomcat startup initiated

REM Wait for Tomcat to start
echo Waiting for Tomcat to start and deploy application...
timeout /t 20 /nobreak

REM Verify deployment
echo.
echo Step 7: Verifying deployment...
echo Checking application health...
curl -s http://localhost:9090/erp-system/ >nul 2>&1
if %errorlevel% equ 0 (
    echo [OK] Application is running
    echo.
    echo =========================================
    echo    Deployment Successful!
    echo =========================================
    echo Application URL: http://localhost:9090/erp-system
    echo Login with: admin / admin
    echo.
) else (
    echo [WARNING] Application may still be starting...
    echo Please check: http://localhost:9090/erp-system/
)

endlocal
pause
