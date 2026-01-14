# ERP Deployment Guide

## Prerequisites

- Windows Server 2016+ or Windows 10/11
- JDK 17.x installed
- Tomcat 10.x installed
- MySQL 8.0+ installed
- Maven 3.8+ installed

## Environment Setup

### 1. JDK Installation

1. Download JDK 17 from Oracle
2. Install to `C:\Program Files\Java\jdk-17`
3. Add to PATH:
   - Set `JAVA_HOME=C:\Program Files\Java\jdk-17`
   - Add `%JAVA_HOME%\bin` to PATH

Verify:
```bash
java -version
```

### 2. Tomcat Installation

1. Download Tomcat 10.x
2. Extract to `C:\apache-tomcat-10.1.28`
3. Create `bin\setenv.bat` (use provided template)
4. Install as service:

```bash
cd C:\apache-tomcat-10.1.28\bin
service.bat install
```

### 3. MySQL Installation

1. Download MySQL 8.0
2. Install with default settings
3. Create root user with password
4. Verify connection:

```bash
mysql -u root -p
```

### 4. Maven Installation

1. Download Maven 3.8+
2. Extract to `C:\Maven`
3. Set environment variables:
   - `MAVEN_HOME=C:\Maven`
   - Add `%MAVEN_HOME%\bin` to PATH

Verify:
```bash
mvn --version
```

## Application Deployment

### Step 1: Database Initialization

```bash
# Run from project root
init-db.bat

# Enter database credentials when prompted
# Default: localhost:3306, root, password
```

This script:
- Creates `erp_db` database
- Imports schema from `schema.sql`
- Imports test data from `data.sql`

### Step 2: Configure Application

Edit `setenv.bat` in Tomcat bin directory:

```batch
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=your_password
set APP_MODE=prod
```

### Step 3: Build Application

```bash
# From project root
mvn clean package -P prod -DskipTests
```

Output: `target\erp.war`

### Step 4: Deploy to Tomcat

Option A - Automated:
```bash
deploy.bat
```

Option B - Manual:
1. Copy `target\erp.war` to `C:\apache-tomcat-10.1.28\webapps\erp.war`
2. Delete `C:\apache-tomcat-10.1.28\work\Catalina\localhost\erp` if exists
3. Start Tomcat service:
   ```bash
   net start Tomcat10
   ```
4. Wait 15-30 seconds for deployment
5. Access application: `http://localhost:8080/erp`

### Step 5: Verify Deployment

1. Check application is running:
   ```
   http://localhost:8080/erp/api/health
   ```
   Expected: HTTP 200 with status "UP"

2. Login with default credentials:
   - Username: `admin`
   - Password: `admin123`

3. Check logs in `C:\apache-tomcat-10.1.28\logs\catalina.out`

## Configuration Files

### application.properties
Main application configuration (Spring Boot)

### application-prod.properties
Production-specific settings:
- Database connection pooling
- Logging levels
- Performance settings

### logback-spring.xml
Logging configuration:
- Log file location: `C:\apache-tomcat-10.1.28\logs\erp.log`
- Log rotation: 10MB files, 30-day retention
- Async logging enabled

## Troubleshooting

### Database Connection Error

**Error**: `java.sql.SQLException: Cannot get a connection, pool error`

**Solutions**:
1. Verify MySQL is running
2. Check database credentials in `setenv.bat`
3. Verify database exists: `mysql -u root -p -e "SHOW DATABASES"`
4. Restart Tomcat service

### Port 8080 Already in Use

**Solutions**:
1. Change port in `application.properties`:
   ```
   server.port=8081
   ```
2. Kill process using port:
   ```bash
   netstat -ano | findstr :8080
   taskkill /PID <PID> /F
   ```

### Tomcat Service Won't Start

**Solutions**:
1. Check JAVA_HOME in `setenv.bat`
2. Verify JDK is installed correctly
3. Check Tomcat logs: `C:\apache-tomcat-10.1.28\logs\catalina.out`
4. Ensure port 8080 is available

### Application Crashes on Startup

**Check logs**:
```bash
# View recent logs
type C:\apache-tomcat-10.1.28\logs\catalina.out | tail -50

# Or use PowerShell
Get-Content C:\apache-tomcat-10.1.28\logs\catalina.out -Tail 50
```

**Common causes**:
1. Database not initialized
2. Wrong database password
3. Missing JAVA_HOME
4. Corrupted WAR file

### Can't Login with admin/admin123

**Solutions**:
1. Verify database data was imported: `init-db.bat`
2. Check user exists:
   ```sql
   mysql> USE erp_db;
   mysql> SELECT * FROM utilisateurs WHERE login='admin';
   ```
3. Reset password if needed

## Performance Tuning

### JVM Heap Size

Edit `setenv.bat`:
```batch
set CATALINA_OPTS=-Xmx2048M -Xms1024M
```

For systems with:
- < 4GB RAM: Use `-Xmx1024M -Xms512M`
- 4-8GB RAM: Use `-Xmx2048M -Xms1024M`
- > 8GB RAM: Use `-Xmx4096M -Xms2048M`

### Database Connection Pool

Edit `application-prod.properties`:
```properties
spring.datasource.hikari.maximum-pool-size=30
spring.datasource.hikari.minimum-idle=5
```

### Cache Configuration

KPI data cached for 5 minutes by default:
```properties
cache.duration=300000
```

## Backup and Recovery

### Database Backup

```bash
# Schedule daily backup
mysqldump -u root -p erp_db > backup_erp_%DATE%.sql
```

### Application Backup

- Backup WAR file before deployments
- Deployment script automatically creates `erp.war.backup`

### Disaster Recovery

1. Restore database:
   ```bash
   mysql -u root -p erp_db < backup_erp_YYYYMMDD.sql
   ```

2. Restore WAR:
   ```bash
   copy erp.war.backup C:\apache-tomcat-10.1.28\webapps\erp.war
   ```

3. Restart Tomcat and verify

## Monitoring

### Access Logs

```bash
# View real-time logs
type C:\apache-tomcat-10.1.28\logs\erp.log

# Or with PowerShell tail
Get-Content C:\apache-tomcat-10.1.28\logs\erp.log -Wait -Tail 100
```

### Performance Metrics

Access dashboard:
```
http://localhost:8080/erp/dashboard
```

Monitor:
- User login counts
- Active sessions
- Database response times
- Stock levels
- Order status

## Security Hardening

1. **Change Default Passwords**:
   - MySQL root password
   - Admin user password (after first login)

2. **Update Application**:
   - Keep Spring Boot and dependencies updated
   - Review security advisories

3. **Firewall Rules**:
   - Only allow necessary ports (8080, 3306 internally)
   - Restrict admin interface access

4. **HTTPS**:
   - Generate SSL certificate
   - Configure Tomcat for HTTPS
   - Update application.properties with SSL settings

## Support and Maintenance

- **Weekly**: Review error logs
- **Monthly**: Backup databases
- **Quarterly**: Update dependencies and security patches
- **As needed**: Monitor performance and scale if necessary

For issues: Contact system administrator or support team
