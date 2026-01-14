@echo off
REM Useful commands for ERP application development and deployment
REM Save this file as erp-commands.bat and run: erp-commands.bat <command>

setlocal enabledelayedexpansion

if "%1"=="" (
    call :show-help
    exit /b 0
)

REM Parse command
if "%1"=="help" call :show-help && exit /b 0
if "%1"=="clean" call :clean && exit /b 0
if "%1"=="compile" call :compile && exit /b 0
if "%1"=="build-dev" call :build-dev && exit /b 0
if "%1"=="build-prod" call :build-prod && exit /b 0
if "%1"=="test" call :test && exit /b 0
if "%1"=="test-class" call :test-class %2 && exit /b 0
if "%1"=="coverage" call :coverage && exit /b 0
if "%1"=="run-dev" call :run-dev && exit /b 0
if "%1"=="run-test" call :run-test && exit /b 0
if "%1"=="run-debug" call :run-debug && exit /b 0
if "%1"=="version" call :version && exit /b 0
if "%1"=="check-deps" call :check-deps && exit /b 0
if "%1"=="docker-build" call :docker-build %2 && exit /b 0
if "%1"=="docker-up" call :docker-up && exit /b 0
if "%1"=="docker-down" call :docker-down && exit /b 0
if "%1"=="docker-logs" call :docker-logs && exit /b 0
if "%1"=="deploy" call :deploy && exit /b 0
if "%1"=="dev-workflow" call :dev-workflow && exit /b 0
if "%1"=="prod-workflow" call :prod-workflow && exit /b 0

echo Unknown command: %1
call :show-help
exit /b 1

REM ===== HELPER FUNCTIONS =====

:clean
echo Cleaning project...
call mvn clean
if !errorlevel! neq 0 (
    echo Error during clean
    exit /b 1
)
echo Clean complete
exit /b 0

:compile
echo Compiling source code...
call mvn compile
if !errorlevel! neq 0 (
    echo Error during compilation
    exit /b 1
)
echo Compilation complete
exit /b 0

:build-dev
echo Building for development...
call mvn clean package -P dev
if !errorlevel! neq 0 (
    echo Error during build
    exit /b 1
)
echo Development build complete
exit /b 0

:build-prod
echo Building for production...
call mvn clean package -P prod -DskipTests
if !errorlevel! neq 0 (
    echo Error during build
    exit /b 1
)
echo Production build complete
echo WAR file: target\erp.war
exit /b 0

:test
echo Running all tests...
call mvn test
if !errorlevel! neq 0 (
    echo Tests failed
    exit /b 1
)
echo Tests complete
exit /b 0

:test-class
if "%~1"=="" (
    echo Usage: erp-commands test-class ^<classname^>
    exit /b 1
)
echo Running test class: %~1
call mvn test -Dtest="%~1"
exit /b !errorlevel!

:coverage
echo Generating test coverage report...
call mvn clean test jacoco:report
if !errorlevel! neq 0 (
    echo Error during coverage generation
    exit /b 1
)
echo Coverage report: target\site\jacoco\index.html
exit /b 0

:run-dev
echo Starting application with development profile...
call mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"
exit /b !errorlevel!

:run-test
echo Starting application with test profile (H2 in-memory)...
call mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=test"
exit /b !errorlevel!

:run-debug
echo Starting application with debug mode...
echo Connect debugger to localhost:5005
call mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
exit /b !errorlevel!

:version
echo Showing project version...
call mvn -q -Dexec.executable=echo -Dexec.args="${project.version}" --non-recursive exec:exec
exit /b 0

:check-deps
echo Checking for dependency conflicts...
call mvn dependency:analyze
exit /b !errorlevel!

:docker-build
if "%~1"=="" (
    echo Usage: erp-commands docker-build ^<tag^>
    exit /b 1
)
echo Building Docker image: erp-app:%~1
call docker build -t erp-app:%~1 .
exit /b !errorlevel!

:docker-up
echo Starting Docker services...
call docker-compose up -d
exit /b !errorlevel!

:docker-down
echo Stopping Docker services...
call docker-compose down
exit /b !errorlevel!

:docker-logs
echo Showing Docker logs...
call docker-compose logs -f app
exit /b !errorlevel!

:deploy
echo Deploying to Tomcat...
if exist "deploy.bat" (
    call deploy.bat
) else (
    echo deploy.bat not found in current directory
    exit /b 1
)
exit /b !errorlevel!

:dev-workflow
echo.
echo ===== Development Workflow =====
echo.
echo 1. Cleaning project...
call mvn clean
if !errorlevel! neq 0 exit /b 1

echo.
echo 2. Running tests...
call mvn test
if !errorlevel! neq 0 exit /b 1

echo.
echo 3. Building application...
call mvn package -P dev
if !errorlevel! neq 0 exit /b 1

echo.
echo ===== Build Complete =====
echo.
echo Run with:
echo   mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"
echo.
exit /b 0

:prod-workflow
echo.
echo ===== Production Workflow =====
echo.
echo 1. Cleaning project...
call mvn clean
if !errorlevel! neq 0 exit /b 1

echo.
echo 2. Running tests...
call mvn test
if !errorlevel! neq 0 exit /b 1

echo.
echo 3. Building for production...
call mvn package -P prod
if !errorlevel! neq 0 exit /b 1

echo.
echo ===== Production Build Complete =====
echo.
echo WAR file: target\erp.war
echo Deploy with: deploy.bat
echo.
exit /b 0

:show-help
cls
echo.
echo ====================================
echo ERP Application - Command Reference
echo ====================================
echo.
echo USAGE: erp-commands.bat ^<command^> [arguments]
echo.
echo COMPILATION:
echo   clean              - Remove build artifacts
echo   compile            - Compile source code only
echo   build-dev          - Build for development
echo   build-prod         - Build for production
echo.
echo TESTING:
echo   test               - Run all tests
echo   test-class ^<name^>  - Run specific test class
echo   coverage           - Generate test coverage report
echo.
echo RUNNING:
echo   run-dev            - Run with development profile
echo   run-test           - Run with H2 in-memory database
echo   run-debug          - Run with debugging enabled
echo.
echo DOCKER:
echo   docker-build ^<tag^> - Build Docker image
echo   docker-up          - Start services
echo   docker-down        - Stop services
echo   docker-logs        - View application logs
echo.
echo DEPLOYMENT:
echo   deploy             - Deploy to Tomcat Windows
echo.
echo UTILITIES:
echo   version            - Show project version
echo   check-deps         - Check dependency conflicts
echo   help               - Show this help message
echo.
echo WORKFLOWS:
echo   dev-workflow       - Complete dev build and test
echo   prod-workflow      - Complete prod build and test
echo.
echo EXAMPLES:
echo   erp-commands.bat build-prod
echo   erp-commands.bat test-class ArticleServiceTest
echo   erp-commands.bat docker-build 1.0
echo   erp-commands.bat dev-workflow
echo.
exit /b 0

endlocal
