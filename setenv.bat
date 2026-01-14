@echo off
REM Tomcat Environment Configuration
REM This file should be placed in TOMCAT_HOME\bin\setenv.bat
REM It sets JVM and application-specific environment variables

REM Java Home
set JAVA_HOME=C:\Program Files\Java\jdk-17

REM Tomcat Home
set TOMCAT_HOME=C:\apache-tomcat-10.1.28

REM JVM Memory Settings
REM -Xmx: Maximum heap size
REM -Xms: Minimum/Initial heap size
set CATALINA_OPTS=-Xmx1024M -Xms512M

REM Database Configuration
set DB_HOST=localhost
set DB_PORT=3307
set DB_USER=root
set DB_PASSWORD=password
set DB_NAME=erp_db

REM Application Configuration
set APP_MODE=prod
set APP_CONTEXT=erp

REM Spring Boot Application Properties
set JAVA_OPTS=%JAVA_OPTS% -Dspring.profiles.active=%APP_MODE%
set JAVA_OPTS=%JAVA_OPTS% -Dspring.datasource.url=jdbc:mysql://%DB_HOST%:%DB_PORT%/%DB_NAME%
set JAVA_OPTS=%JAVA_OPTS% -Dspring.datasource.username=%DB_USER%
set JAVA_OPTS=%JAVA_OPTS% -Dspring.datasource.password=%DB_PASSWORD%
set JAVA_OPTS=%JAVA_OPTS% -Dserver.servlet.context-path=/%APP_CONTEXT%

REM Logging Configuration
set JAVA_OPTS=%JAVA_OPTS% -Dlogging.config=%TOMCAT_HOME%\webapps\%APP_CONTEXT%\WEB-INF\classes\logback-spring.xml

REM Additional JVM Settings
set JAVA_OPTS=%JAVA_OPTS% -Dfile.encoding=UTF-8
set JAVA_OPTS=%JAVA_OPTS% -Djava.net.preferIPv4Stack=true

echo Tomcat environment configured:
echo JAVA_HOME=%JAVA_HOME%
echo TOMCAT_HOME=%TOMCAT_HOME%
echo Database: %DB_HOST%:%DB_PORT%/%DB_NAME%
echo JVM Heap: %CATALINA_OPTS%
