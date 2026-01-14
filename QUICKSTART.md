# Quick Start Guide - ERP Application

## 5-Minute Setup

### Prerequisites
- JDK 17 installed
- MySQL 8.0 installed and running
- Tomcat 10.x installed

### Step 1: Prepare Database (1 min)

```bash
# From project root directory
init-db.bat

# When prompted, use defaults:
# Host: localhost
# User: root
# Password: password
```

### Step 2: Build Application (2 min)

```bash
mvn clean package -P prod -DskipTests
```

### Step 3: Deploy to Tomcat (1 min)

```bash
deploy.bat
```

The application will automatically:
- Build with Maven
- Backup existing WAR
- Stop Tomcat service
- Copy new WAR
- Start Tomcat
- Verify deployment

### Step 4: Access Application (1 min)

1. Open browser: `http://localhost:8080/erp`
2. Login with:
   - **Username**: `admin`
   - **Password**: `admin123`

## Verify Installation

### Check Application Health

```bash
curl http://localhost:8080/erp/api/health
```

Expected response:
```json
{
  "status": "UP",
  "database": "UP"
}
```

### Login with Test Users

The database comes pre-loaded with test users:

| Username | Password | Role | Depot |
|----------|----------|------|-------|
| admin | admin123 | DIRECTION | MAIN |
| buyer1 | admin123 | ACHETEUR | MAIN |
| warehouse1 | admin123 | MAGASINIER | MAIN |
| sales1 | admin123 | COMMERCIAL | MAIN |

## Environment Settings

Edit `C:\apache-tomcat-10.1.28\bin\setenv.bat` if needed:

```batch
REM Database connection
set DB_HOST=localhost
set DB_PORT=3306
set DB_USER=root
set DB_PASSWORD=password

REM Application
set APP_MODE=prod
set APP_CONTEXT=erp

REM JVM Settings (adjust for your system)
set CATALINA_OPTS=-Xmx1024M -Xms512M
```

## Common Tasks

### Change Database Password

1. Edit `setenv.bat`:
   ```batch
   set DB_PASSWORD=your_new_password
   ```

2. Restart Tomcat:
   ```bash
   net stop Tomcat10
   net start Tomcat10
   ```

### View Application Logs

```bash
# Real-time logs
type C:\apache-tomcat-10.1.28\logs\erp.log

# Or with PowerShell
Get-Content C:\apache-tomcat-10.1.28\logs\erp.log -Wait -Tail 100
```

### Backup Database

```bash
mysqldump -u root -p erp_db > erp_backup.sql
```

### Restore Database

```bash
mysql -u root -p erp_db < erp_backup.sql
```

## Troubleshooting

### Application Won't Start

1. **Check Tomcat logs**:
   ```bash
   type C:\apache-tomcat-10.1.28\logs\catalina.out
   ```

2. **Verify database connection**:
   ```bash
   mysql -u root -p -e "SELECT COUNT(*) FROM erp_db.utilisateurs"
   ```

3. **Check port 8080 is available**:
   ```bash
   netstat -ano | findstr :8080
   ```

### Can't Login

1. **Verify database data**:
   ```bash
   mysql -u root -p erp_db
   SELECT login, nom FROM utilisateurs;
   EXIT;
   ```

2. **Reinitialize database**:
   ```bash
   init-db.bat
   ```

### Database Connection Error

1. **Check MySQL is running**:
   ```bash
   mysql -u root -p -e "SELECT 1"
   ```

2. **Verify credentials in `setenv.bat`**

3. **Check database exists**:
   ```bash
   mysql -u root -p -e "USE erp_db; SELECT COUNT(*) FROM articles"
   ```

## Development Configuration

For development (auto-reload, verbose logging), change in `setenv.bat`:

```batch
set APP_MODE=dev
```

Then restart Tomcat.

## Production Configuration

For production (optimized, minimal logging):

```batch
set APP_MODE=prod
set CATALINA_OPTS=-Xmx2048M -Xms1024M
```

## Next Steps

1. **Explore Dashboard**: `http://localhost:8080/erp/dashboard`
2. **Create Test Data**: Use admin interface to add articles, suppliers, customers
3. **Test Workflows**: Create purchase requisitions → orders → invoices
4. **Review Logs**: Monitor application logs for issues
5. **Read Documentation**: See [README.md](README.md), [ARCHITECTURE.md](ARCHITECTURE.md)

## Support

For detailed information, see:
- [API Documentation](API.md)
- [Architecture Guide](ARCHITECTURE.md)
- [Deployment Guide](DEPLOYMENT.md)

---

**Version**: 1.0  
**Updated**: 2024-01-11
