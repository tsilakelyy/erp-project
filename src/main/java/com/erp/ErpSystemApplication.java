package com.erp;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.transaction.annotation.EnableTransactionManagement;
import org.springframework.boot.builder.SpringApplicationBuilder;

@SpringBootApplication
@EnableTransactionManagement
@EnableScheduling
@ComponentScan(basePackages = {"com.erp"})
public class ErpSystemApplication extends SpringBootServletInitializer {
    
    @Override
    protected SpringApplicationBuilder configure(SpringApplicationBuilder application) {
        return application.sources(ErpSystemApplication.class);
    }
    
    public static void main(String[] args) {
        SpringApplication.run(ErpSystemApplication.class, args);
    }
}
