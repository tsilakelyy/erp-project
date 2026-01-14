package com.erp.config;

import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.context.annotation.Configuration;

@Configuration
public class DataSourceConfig {
    // Spring Boot 2.7.14 manages DataSource automatically from application.properties
    // No need for manual bean configuration
}
