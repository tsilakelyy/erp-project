0) creer des todo et des reverfications ainsi que des corrections selon les prochaines questions,JE TE DIS DE TOUT REVERIFIER ET CORRIGER1)reverife toutes les classes jsp et les controllers reverifie tous les fichiers car plusieurs liens ne marche pas encore  surtout quand tu vas dans new inventory 2)dans new inventory il y a loaded failed  )dans stock http://localhost:9091/erp-system/stocks/warehouse/id {"timestamp":"2026-02-05T15:16:32.3741294","status":500,"error":"Internal Server Error","code":"INTERNAL_ERROR","message":"An unexpected error occurred","errors":null,"path":null} "Unknown column 'stocklevel0_.cout_moyen' in 'field list'
2026-02-05 15:16:27 - Unexpected error: could not extract ResultSet; SQL [n/a]; nested exception is org.hibernate.exception.SQLGrammarException: could not extract ResultSet
org.springframework.dao.InvalidDataAccessResourceUsageException: could not extract ResultSet; SQL [n/a]; nested exception is org.hibernate.exception.SQLGrammarException: could not extract ResultSet
        at org.springframework.orm.jpa.vendor.HibernateJpaDialect.convertHibernateAccessException(HibernateJpaDialect.java:259)
        at org.springframework.orm.jpa.vendor.HibernateJpaDialect.translateExceptionIfPossible(HibernateJpaDialect.java:233)
        at org.springframework.orm.jpa.AbstractEntityManagerFactoryBean.translateExceptionIfPossible(AbstractEntityManagerFactoryBean.java:551)
        at org.springframework.dao.support.ChainedPersistenceExceptionTranslator.translateExceptionIfPossible(ChainedPersistenceExceptionTranslator.java:61)
        at org.springframework.dao.support.DataAccessUtils.translateIfNecessary(DataAccessUtils.java:242)    
        at org.springframework.dao.support.PersistenceExceptionTranslationInterceptor.invoke(PersistenceExceptionTranslationInterceptor.java:152)
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
        at org.springframework.data.jpa.repository.support.CrudMethodMetadataPostProcessor$CrudMethodMetadataPopulatingMethodInterceptor.invoke(CrudMethodMetadataPostProcessor.java:145)
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
        at org.springframework.aop.interceptor.ExposeInvocationInterceptor.invoke(ExposeInvocationInterceptor.java:97)
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
        at org.springframework.aop.framework.JdkDynamicAopProxy.invoke(JdkDynamicAopProxy.java:241)
        at jdk.proxy2/jdk.proxy2.$Proxy152.findByEntrepot_Id(Unknown Source)
        at com.erp.service.StockService.getWarehouseStock(StockService.java:107)
        at com.erp.service.StockService$$FastClassBySpringCGLIB$$bcef20f0.invoke(<generated>)
        at org.springframework.cglib.proxy.MethodProxy.invoke(MethodProxy.java:218)
        at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.invokeJoinpoint(CglibAopProxy.java:793)
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:163)
        at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
        at org.springframework.transaction.interceptor.TransactionInterceptor$1.proceedWithInvocation(TransactionInterceptor.java:123)
        at org.springframework.transaction.interceptor.TransactionAspectSupport.invokeWithinTransaction(TransactionAspectSupport.java:388)
        at org.springframework.transaction.interceptor.TransactionInterceptor.invoke(TransactionInterceptor.java:119)
        at org.springframework.aop.framework.ReflectiveMethodInvocation.proceed(ReflectiveMethodInvocation.java:186)
        at org.springframework.aop.framework.CglibAopProxy$CglibMethodInvocation.proceed(CglibAopProxy.java:763)
        at org.springframework.aop.framework.CglibAopProxy$DynamicAdvisedInterceptor.intercept(CglibAopProxy.java:708)
        at com.erp.service.StockService$$EnhancerBySpringCGLIB$$1e09cb71.getWarehouseStock(<generated>)      
        at com.erp.controller.StockController.warehouseStock(StockController.java:40)
        at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
        at java.base/jdk.internal.reflect.NativeMethodAccessorImpl.invoke(NativeMethodAccessorImpl.java:77)  
        at java.base/jdk.internal.reflect.DelegatingMethodAccessorImpl.invoke(DelegatingMethodAccessorImpl.java:43)
        at java.base/java.lang.reflect.Method.invoke(Method.java:568)
        at org.springframework.web.method.support.InvocableHandlerMethod.doInvoke(InvocableHandlerMethod.java:205)
        at org.springframework.web.method.support.InvocableHandlerMethod.invokeForRequest(InvocableHandlerMethod.java:150)
        at org.springframework.web.servlet.mvc.method.annotation.ServletInvocableHandlerMethod.invokeAndHandle(ServletInvocableHandlerMethod.java:117)
        at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.invokeHandlerMethod(RequestMappingHandlerAdapter.java:895)
        at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(RequestMappingHandlerAdapter.java:808)
        at org.springframework.web.servlet.mvc.method.AbstractHandlerMethodAdapter.handle(AbstractHandlerMethodAdapter.java:87)
        at org.springframework.web.servlet.DispatcherServlet.doDispatch(DispatcherServlet.java:1072)
        at org.springframework.web.servlet.DispatcherServlet.doService(DispatcherServlet.java:965)
        at org.springframework.web.servlet.FrameworkServlet.processRequest(FrameworkServlet.java:1006)       
        at org.springframework.web.servlet.FrameworkServlet.doGet(FrameworkServlet.java:898)
        at javax.servlet.http.HttpServlet.service(HttpServlet.java:529)
        at org.springframework.web.servlet.FrameworkServlet.service(FrameworkServlet.java:883)
        at javax.servlet.http.HttpServlet.service(HttpServlet.java:623)
        at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:209) 
        at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:153)
        at org.apache.tomcat.websocket.server.WsFilter.doFilter(WsFilter.java:51)
        at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:178) 
        at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:153)
        at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:111)       
        at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:178) 
        at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:153)
        at org.springframework.web.filter.OncePerRequestFilter.doFilter(OncePerRequestFilter.java:111)       
        at org.apache.catalina.core.ApplicationFilterChain.internalDoFilter(ApplicationFilterChain.java:178) 
        at org.apache.catalina.core.ApplicationFilterChain.doFilter(ApplicationFilterChain.java:153)
        at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:337)
        at org.springframework.security.web.access.intercept.AuthorizationFilter.doFilter(AuthorizationFilter.java:96)
        at org.springframework.security.web.FilterChainProxy$VirtualFilterChain.doFilter(FilterChainProxy.java:346)
        at org.springframework.security.web.access.ExceptionTranslationFilter.doFilter(ExceptionTranslationFilter.java:122)
        at org.springframework.security.web.access.ExceptionTranslationFilter.doFilter(ExceptionTranslationFilter.java:116)
        at org.springfram" 4) corrige la side bar dans new inventory pour qu'elle soit identique a l'original et qu'elle marche fais de meme pour les autres fichiers necessaires 5) il y a plusieurs erreurs typiques comme "http://localhost:9091/erp-system/purchases/orders/new?error=could%20not%20execute%20statement;%20SQL%20[n/a];%20constraint%20[null];%20nested%20exception%20is%20org.hibernate.exception.ConstraintViolationException:%20could%20not%20execute%20statement"  





# Development Guide

## Setting Up Development Environment

### Prerequisites

- JDK 17 or higher
- Maven 3.8+
- MySQL 8.0 (or H2 in-memory for testing)
- IDE (IntelliJ IDEA or VS Code recommended)

### IDE Setup

#### IntelliJ IDEA

1. Open project: File → Open → Select project folder
2. Configure JDK: File → Project Structure → Project
   - Set SDK to JDK 17
3. Enable annotation processing:
   - Settings → Build, Execution, Deployment → Compiler → Annotation Processors
   - Enable "Enable annotation processing"
4. Import Maven project:
   - Maven panel on right → Reload projects

#### VS Code

1. Install extensions:
   - Extension Pack for Java (Microsoft)
   - Spring Boot Extension Pack (Pivotal)
   - Lombok Annotations Support for VS Code

2. Open project folder: File → Open Folder

## Building

### Development Build

```bash
# Build without tests
mvn clean compile -DskipTests

# Build with tests
mvn clean build
```

### Production Build

```bash
# Build for production
mvn clean package -P prod -DskipTests
```

### Build Profiles

- **default**: Development profile with DEBUG logging
- **dev**: Development-specific configuration
- **prod**: Production-specific configuration
- **test**: Test profile with in-memory H2 database

## Running Locally

### Option 1: Maven Spring Boot Plugin

```bash
# Run with development profile
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=dev"

# With debugging
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=5005"
```

### Option 2: IDE Run Configuration

**IntelliJ IDEA:**
1. Run → Edit Configurations
2. Create new "Spring Boot" configuration
3. Set main class: `com.erp.ErpSystemApplication`
4. Set program arguments: `--spring.profiles.active=dev`
5. Run

**VS Code:**
1. Debug → Add Configuration
2. Select Java (Spring Boot)
3. Run

## Database Setup for Development

### Using MySQL

```bash
# Create database
mysql -u root -p -e "CREATE DATABASE erp_dev CHARSET utf8mb4"

# Import schema
mysql -u root -p erp_dev < src/main/resources/db/schema.sql

# Import test data
mysql -u root -p erp_dev < src/main/resources/db/data.sql
```

### Using H2 In-Memory (No Installation Needed)

Set profile to "test":
```bash
mvn spring-boot:run -Dspring-boot.run.arguments="--spring.profiles.active=test"
```

H2 console available at: `http://localhost:8080/erp/h2-console`
- URL: `jdbc:h2:mem:testdb`
- User: `sa`
- Password: (leave empty)

## Testing

### Run All Tests

```bash
mvn clean test
```

### Run Specific Test Class

```bash
mvn test -Dtest=ArticleServiceTest
```

### Run Specific Test Method

```bash
mvn test -Dtest=ArticleServiceTest#testCreateArticle
```

### Coverage Report

```bash
mvn clean test jacoco:report
```

Report location: `target/site/jacoco/index.html`

## Code Style

### Format Code

```bash
# Format with Maven plugin (if configured)
mvn spotless:apply
```

### Code Style Standards

- Java: Google Java Style Guide
- Comments: Javadoc for public methods
- Naming: camelCase for variables/methods, PascalCase for classes
- Line length: Maximum 120 characters
- Indentation: 4 spaces

### Example Code Comment

```java
/**
 * Creates a new article in the system
 * 
 * @param article Article data to create
 * @return Created article with assigned ID
 * @throws ValidationException if article data is invalid
 * @throws ConflictException if article code already exists
 */
public ArticleDTO createArticle(ArticleDTO article) {
    // Implementation
}
```

## Debugging

### Set Breakpoints

1. Click on line number in IDE
2. Run in debug mode
3. Execution pauses at breakpoint

### Debug Configuration

```bash
# Run with debug port 5005
mvn spring-boot:run -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=n,address=5005"
```

Then connect IDE debugger to `localhost:5005`

### View Logs

```bash
# Watch logs in real-time
tail -f logs/erp.log

# Or with Windows
Get-Content logs/erp.log -Wait -Tail 50
```

## Project Structure

```
src/
├── main/
│   ├── java/com/erp/
│   │   ├── controller/          # REST/MVC endpoints
│   │   ├── service/             # Business logic
│   │   ├── repository/          # Data access (JPA)
│   │   ├── domain/              # Entity classes
│   │   ├── dto/                 # Data transfer objects
│   │   ├── config/              # Spring configuration
│   │   ├── exception/           # Custom exceptions
│   │   ├── security/            # Authentication/authorization
│   │   └── validator/           # Business rule validators
│   ├── resources/
│   │   ├── application.properties        # Default config
│   │   ├── application-dev.properties    # Dev profile
│   │   ├── application-prod.properties   # Prod profile
│   │   ├── application-test.properties   # Test profile
│   │   ├── db/
│   │   │   ├── schema.sql
│   │   │   └── data.sql
│   │   └── logback-spring.xml
│   └── webapp/
│       ├── WEB-INF/
│       │   └── jsp/             # JSP pages
│       └── assets/
│           ├── css/             # Stylesheets
│           └── js/              # JavaScript files
└── test/
    ├── java/com/erp/            # Test classes
    └── resources/               # Test configurations
```

## Adding New Features

### 1. Create Entity Class

```java
@Entity
@Table(name = "my_table")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MyEntity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    
    @Column(unique = true)
    private String code;
    
    @Column(nullable = false)
    private String name;
}
```

### 2. Create Repository

```java
@Repository
public interface MyEntityRepository extends JpaRepository<MyEntity, Long> {
    Optional<MyEntity> findByCode(String code);
    List<MyEntity> findAllByActif(Boolean actif);
}
```

### 3. Create DTO

```java
@Data
@Builder
public class MyEntityDTO {
    @NotBlank(message = "Code is required")
    private String code;
    
    @NotBlank(message = "Name is required")
    private String name;
}
```

### 4. Create Service

```java
@Service
@Transactional
public class MyEntityService {
    @Autowired
    private MyEntityRepository repository;
    
    public MyEntityDTO create(MyEntityDTO dto) {
        // Validate, convert, save
    }
}
```

### 5. Create Controller

```java
@RestController
@RequestMapping("/api/my-entities")
public class MyEntityController {
    @Autowired
    private MyEntityService service;
    
    @PostMapping
    public ResponseEntity<MyEntityDTO> create(@RequestBody @Valid MyEntityDTO dto) {
        return ResponseEntity.status(HttpStatus.CREATED)
            .body(service.create(dto));
    }
}
```

### 6. Add Tests

```java
@SpringBootTest
class MyEntityServiceTest {
    @Autowired
    private MyEntityService service;
    
    @Test
    void testCreate() {
        MyEntityDTO dto = new MyEntityDTO();
        MyEntityDTO result = service.create(dto);
        assertNotNull(result.getId());
    }
}
```

## Dependencies

Main dependencies (see pom.xml for versions):
- Spring Boot 3.x
- Spring Data JPA
- Spring Security
- Hibernate
- MySQL Connector
- Lombok
- Jackson
- JUnit 5 + Mockito (for tests)

## Commit Guidelines

```bash
# Commit message format: <type>(<scope>): <subject>

# Types: feat, fix, refactor, test, docs, chore
# Scope: area being changed (controller, service, etc)
# Subject: brief description (imperative mood)

git commit -m "feat(article): add article validation service"
git commit -m "fix(purchase): handle null supplier in order creation"
git commit -m "test(invoice): add invoice calculation tests"
```

## Useful Commands

```bash
# Clean build artifacts
mvn clean

# Install dependencies
mvn install

# Compile only
mvn compile

# Run specific profile
mvn spring-boot:run -Dspring.profiles.active=dev

# Check dependencies
mvn dependency:tree

# Find dependency conflicts
mvn dependency:analyze

# Update Maven plugins
mvn versions:display-plugin-updates
```

## Performance Tips

1. **Database Queries**: Use `@Query` annotations to fetch only needed fields
2. **N+1 Problem**: Use `@EntityGraph` or `fetch = FetchType.EAGER` wisely
3. **Caching**: Use `@Cacheable` for frequently accessed data
4. **Lazy Loading**: Be aware of lazy loading in detached entities
5. **Connection Pool**: HikariCP configured with 20 max connections

## Security Development

- **Passwords**: Never hardcode, use `application.properties`
- **Secrets**: Use environment variables for sensitive data
- **SQL Injection**: Always use JPA named parameters or `@Query`
- **CORS**: Configure CORS only for trusted origins
- **HTTPS**: Use HTTPS in production

## Common Issues

### "Method not found" in tests
- Ensure `@SpringBootTest` is used for integration tests
- Use `@MockBean` for mocking dependencies

### Lazy initialization exception
- Use `@Transactional` on service methods
- Or use `@EntityGraph` to fetch relations

### Test database not initialized
- Check `application-test.properties` points to correct H2 database
- Ensure `schema.sql` and `data.sql` are in test resources

---

**Last Updated**: 2024-01-11
