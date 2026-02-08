package com.erp.config;

import org.springframework.context.annotation.Configuration;

@Configuration
public class SecurityBeansConfig {

    // PasswordEncoder is now defined in SecurityConfig.java
    // This prevents bean definition conflicts
}
