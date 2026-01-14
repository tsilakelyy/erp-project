@echo off
REM =========================================
REM  Initialize ERP Database
REM =========================================
REM  Creates database and loads schema + data

echo.
echo =========================================
echo    Database Initialization Script
echo =========================================
echo.

echo Initializing MySQL database...
echo.

REM Check if MySQL is available
mysql --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] MySQL is not installed or not in PATH
    echo.
    echo Solution: Add MySQL bin folder to PATH
    echo Example: C:\Program Files\MySQL\MySQL Server 8.0\bin
    pause
    exit /b 1
)

echo [OK] MySQL is available
echo.

REM Create database and load schema
echo Loading database schema...
mysql -h localhost -P 3307 -u root < src\main\resources\db\schema.sql
if %errorlevel% neq 0 (
    echo [ERROR] Failed to load schema
    pause
    exit /b 1
)
echo [OK] Schema loaded

REM Load test data
echo Loading test data...
mysql -h localhost -P 3307 -u root erp_db < src\main\resources\db\data.sql
if %errorlevel% neq 0 (
    echo [ERROR] Failed to load data
    pause
    exit /b 1
)
echo [OK] Data loaded

echo.
echo =========================================
echo    Database Initialization Complete
echo =========================================
echo.
echo Database: erp_db
echo Host: localhost:3307
echo User: root
echo.
echo Available test accounts:
echo   Login: admin           Password: admin
echo   Login: buyer1          Password: admin
echo   Login: warehouse1      Password: admin
echo   Login: sales1          Password: admin
echo   Login: finance         Password: admin
echo.
pause
