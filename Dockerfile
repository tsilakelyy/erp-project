# Multi-stage build
FROM maven:3.8.1-openjdk-17 AS builder

WORKDIR /app

# Copy source code
COPY pom.xml .
COPY src ./src

# Build application
RUN mvn clean package -P prod -DskipTests

# Runtime stage
FROM openjdk:17-jdk-slim

# Install Tomcat
RUN apt-get update && apt-get install -y tomcat10 && rm -rf /var/lib/apt/lists/*

# Copy built WAR to Tomcat
COPY --from=builder /app/target/erp.war /usr/share/tomcat/webapps/erp.war

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/erp/api/health || exit 1

# Start Tomcat
CMD ["catalina.sh", "run"]
