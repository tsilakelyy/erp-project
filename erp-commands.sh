#!/bin/bash
# Useful commands for ERP application development and deployment
# Execute these commands from the project root directory

# ===== COMPILATION =====

# Clean build (remove all compiled artifacts)
alias clean="mvn clean"

# Compile only (no packaging)
alias compile="mvn compile"

# Build for development (with tests)
alias build-dev="mvn clean package -P dev"

# Build for production (without tests)
alias build-prod="mvn clean package -P prod -DskipTests"

# ===== TESTING =====

# Run all tests
alias test="mvn test"

# Run specific test class
test-class() {
    mvn test -Dtest="$1"
}

# Run specific test method
test-method() {
    mvn test -Dtest="$1#$2"
}

# Run tests with coverage
alias coverage="mvn clean test jacoco:report"

# ===== RUNNING APPLICATION =====

# Run with development profile
alias run-dev="mvn spring-boot:run -Dspring-boot.run.arguments='--spring.profiles.active=dev'"

# Run with test profile (H2 in-memory database)
alias run-test="mvn spring-boot:run -Dspring-boot.run.arguments='--spring.profiles.active=test'"

# Run with debugging enabled
run-debug() {
    mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
}

# ===== DATABASE COMMANDS =====

# Initialize database (MySQL)
init-db() {
    mysql -u "$1" -p < src/main/resources/db/schema.sql
    mysql -u "$1" -p < src/main/resources/db/data.sql
}

# Backup database
backup-db() {
    mysqldump -u "$1" -p "$2" > backup_$(date +%Y%m%d_%H%M%S).sql
}

# Restore database
restore-db() {
    mysql -u "$1" -p "$2" < "$3"
}

# ===== CODE QUALITY =====

# Check for dependency conflicts
alias check-deps="mvn dependency:analyze"

# Display dependency tree
alias deps-tree="mvn dependency:tree"

# Update dependency versions
alias check-updates="mvn versions:display-property-updates"

# Format code (if spotless configured)
alias format="mvn spotless:apply"

# ===== DOCKER COMMANDS =====

# Build Docker image
docker-build() {
    docker build -t erp-app:"$1" .
}

# Start Docker Compose services
alias docker-up="docker-compose up -d"

# Stop Docker Compose services
alias docker-down="docker-compose down"

# View Docker logs
alias docker-logs="docker-compose logs -f app"

# Restart services
alias docker-restart="docker-compose restart"

# ===== DEPLOYMENT COMMANDS =====

# Deploy to Tomcat Windows (from Windows batch)
deploy-tomcat() {
    ./deploy.bat
}

# Initialize Tomcat database (from Windows batch)
init-tomcat-db() {
    ./init-db.bat
}

# ===== UTILITY COMMANDS =====

# Show project version
alias version="mvn -q -Dexec.executable=echo -Dexec.args='\${project.version}' --non-recursive exec:exec"

# List all modules
alias modules="mvn help:describe -Dcmd=help"

# Generate project report
alias report="mvn site"

# Validate POM
alias validate-pom="mvn pom:help"

# ===== DEVELOPMENT WORKFLOW =====

# Complete development workflow
dev-workflow() {
    echo "=== Cleaning project ==="
    mvn clean
    
    echo "=== Running tests ==="
    mvn test
    
    echo "=== Building application ==="
    mvn package -P dev
    
    echo "=== Build complete ==="
    echo "Run with: mvn spring-boot:run -Dspring-boot.run.arguments='--spring.profiles.active=dev'"
}

# Complete production workflow
prod-workflow() {
    echo "=== Cleaning project ==="
    mvn clean
    
    echo "=== Running tests ==="
    mvn test
    
    echo "=== Building for production ==="
    mvn package -P prod
    
    echo "=== Production build complete ==="
    echo "WAR file: target/erp.war"
    echo "Deploy with: ./deploy.bat"
}

# ===== LOGGING =====

# Tail application logs
tail-logs() {
    if [ -f "logs/erp.log" ]; then
        tail -f "logs/erp.log"
    else
        echo "Logs not found. Application may not be running."
    fi
}

# Clear logs
clear-logs() {
    rm -f logs/erp.log*
    echo "Logs cleared"
}

# ===== GIT COMMANDS =====

# Git workflow
alias git-status="git status"
alias git-add="git add ."
git-commit() {
    git commit -m "$1"
}
alias git-push="git push"

# ===== HELP =====

show-help() {
    cat << EOF

ERP Application - Useful Commands

COMPILATION:
  clean              - Remove build artifacts
  compile            - Compile source code only
  build-dev          - Build for development
  build-prod         - Build for production

TESTING:
  test               - Run all tests
  test-class <name>  - Run specific test class
  test-method <c> <m> - Run specific test method
  coverage           - Generate test coverage report

RUNNING:
  run-dev            - Run with development profile
  run-test           - Run with H2 in-memory database
  run-debug          - Run with debugging enabled

DATABASE:
  init-db <user>     - Initialize database
  backup-db <u> <db> - Backup database
  restore-db <u> <db> <file> - Restore database

DOCKER:
  docker-build <tag> - Build Docker image
  docker-up          - Start services
  docker-down        - Stop services
  docker-logs        - View application logs
  docker-restart     - Restart services

DEPLOYMENT:
  deploy-tomcat      - Deploy to Tomcat
  init-tomcat-db     - Initialize Tomcat database

UTILITIES:
  version            - Show project version
  check-deps         - Check dependency conflicts
  deps-tree          - Show dependency tree
  format             - Format code

WORKFLOWS:
  dev-workflow       - Complete dev build and test
  prod-workflow      - Complete prod build and test

OTHER:
  tail-logs          - Watch application logs
  clear-logs         - Clear log files

EOF
}

# Show help when script is sourced
show-help

# ===== ALIASES SUMMARY =====
# Source this file in your .bashrc or .bash_profile:
# source erp-commands.sh
#
# Then use aliases directly:
# $ clean
# $ compile
# $ test
# $ run-dev
