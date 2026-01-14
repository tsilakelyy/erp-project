@echo off
REM ERP Database Initialization Script for Windows
REM Author: System Admin
REM Description: Creates database and imports schema and test data

setlocal enabledelayedexpansion

echo.
echo =========================================
echo    ERP Database Initialization Script
echo =========================================
echo.

REM Check MySQL installation
echo Checking MySQL installation...
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] MySQL is not installed or not in PATH
    echo Please install MySQL Server and add it to your system PATH
    exit /b 1
)
echo [OK] MySQL is installed

REM Database credentials
set DB_HOST=localhost
set DB_PORT=3307
set DB_USER=root
set DB_PASSWORD=password
set DB_NAME=erp_db

REM Ask for credentials
echo.
echo Enter database credentials:
echo Default values shown in brackets
set /p "DB_HOST=Database Host [%DB_HOST%]: "
set /p "DB_USER=Database User [%DB_USER%]: "
set /p "DB_PASSWORD=Database Password [%DB_PASSWORD%]: "

REM Create database
echo.
echo Step 1: Creating database...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "CREATE DATABASE IF NOT EXISTS %DB_NAME% DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;"
if %errorlevel% neq 0 (
    echo [ERROR] Failed to create database
    echo Check your MySQL credentials and server connection
    exit /b 1
)
echo [OK] Database created

REM Import schema
echo.
echo Step 2: Importing database schema...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% < src\main\resources\db\schema.sql
if %errorlevel% neq 0 (
    echo [ERROR] Failed to import schema
    exit /b 1
)
echo [OK] Schema imported

REM Import test data
echo.
echo Step 3: Importing test data...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% %DB_NAME% < src\main\resources\db\data.sql
if %errorlevel% neq 0 (
    echo [ERROR] Failed to import test data
    exit /b 1
)
echo [OK] Test data imported

REM Verify tables
echo.
echo Step 4: Verifying database setup...
mysql -h %DB_HOST% -u %DB_USER% -p%DB_PASSWORD% -e "USE %DB_NAME%; SELECT COUNT(*) as TableCount FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA='%DB_NAME%';"
if %errorlevel% equ 0 (
    echo [OK] Database setup completed successfully
    echo.
    echo =========================================
    echo    Database Initialization Successful!
    echo =========================================
    echo Database: %DB_NAME%
    echo Host: %DB_HOST%
    echo User: %DB_USER%
    echo.
    echo Test credentials:
    echo - Username: admin
    echo - Password: admin123
    echo.
) else (
    echo [ERROR] Database verification failed
    exit /b 1
)

endlocal
pause
