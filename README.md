# ERP System - Spring Boot Application

**Status:** ✅ FULLY OPERATIONAL

Complete Spring Boot ERP system for inventory, purchasing, and sales management.

## Quick Start

```bash
# Option 1: Run the launcher script
.\run.bat

# Option 2: Manual launch
mvn package -DskipTests
java -jar target/erp-system.war --spring.profiles.active=prod
```

**Access:** http://localhost:9091/erp-system  
**Login:** admin / admin

## Features

- **Spring Boot 2.7.14** with embedded Tomcat (port 9091)
- **User Authentication**: JWT-based with role-based access control
- **Spring Security**: Full authentication and authorization
- **Inventory Management**: Stock tracking and movements
- **Purchasing Module**: Orders and invoice management
- **Sales Module**: Quotes, orders, and invoicing
- **Audit Trail**: Complete audit logging

## Prerequisites

- JDK 17 or higher
- MySQL 8.0 on localhost:3307 (no password for root)
- Maven 3.8+
- Windows PowerShell or CMD

## Installation & Setup

This will:
- Create the database schema
- Import test data
- Configure user credentials

### 2. Build the Application

```bash
mvn clean package -P prod
```

### 3. Deploy to Tomcat

Copy the generated WAR file to Tomcat webapps folder:

```bash
deploy.bat
```

Or manually:
1. Copy `target/erp.war` to `C:\apache-tomcat-10.1.28\webapps\erp.war`
2. Start Tomcat service
3. Access the application at `http://localhost:8080/erp`

## Configuration

### Database Configuration

Edit `setenv.bat` to configure:
- `DB_HOST`: MySQL host
- `DB_PORT`: MySQL port
- `DB_USER`: Database username
- `DB_PASSWORD`: Database password

### Application Properties

- **Development**: Uses `application-dev.properties`
- **Production**: Uses `application-prod.properties`

Set active profile:
```
set APP_MODE=prod
```

## Default Login

- **Username**: admin
- **Password**: admin123

## Project Structure

```
src/main/
├── java/com/erp/
│   ├── controller/      # REST/MVC controllers
│   ├── service/         # Business logic
│   ├── repository/      # Data access layer
│   ├── domain/          # Entity classes
│   ├── dto/             # Data transfer objects
│   ├── config/          # Spring configuration
│   ├── exception/       # Custom exceptions
│   └── security/        # Authentication & authorization
├── resources/
│   ├── db/              # SQL scripts
│   ├── application.properties
│   └── logback-spring.xml
└── webapp/
    ├── WEB-INF/
    │   └── jsp/         # JSP pages
    └── assets/          # CSS, JS, images
```

## API Documentation

API endpoints are documented in [API.md](API.md)

## Security

- JWT token-based authentication
- Role-based access control (RBAC)
- Attribute-based access control (ABAC)
- Password encryption with BCrypt
- Audit logging for all operations

## Troubleshooting

### Database Connection Issues

1. Verify MySQL is running
2. Check credentials in `setenv.bat`
3. Ensure database is created: `init-db.bat`

### Tomcat Deployment Issues

1. Check Tomcat logs: `C:\apache-tomcat-10.1.28\logs\catalina.out`
2. Ensure port 8080 is available
3. Verify JAVA_HOME in `setenv.bat`

### Application Errors

1. Check application logs in Tomcat logs directory
2. Verify database is initialized
3. Check Spring configuration in `application.properties`

## Support

For issues and support, contact: support@erp.local

## License

Proprietary - All Rights Reserved
