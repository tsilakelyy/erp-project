package com.erp.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.erp.config.SessionAuthFilter; // Preserved from original

@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    // Preserved from original to support JSP Session Auth
     @Autowired
    private SessionAuthFilter sessionAuthFilter;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    // 🔐 Chaîne de sécurité principale
    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {

        http
            .cors().and()
            .csrf().disable()

            .exceptionHandling()
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
            .and()

            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
            .and()

            .authorizeHttpRequests()
                // Ressources statiques et API publiques
                .antMatchers(
                        "/", "/favicon.ico", "/**/*.css", "/**/*.js", "/**/*.png", "/**/*.jpg",
                        "/webjars/**", "/error/**"
                ).permitAll()
                .antMatchers("/api/auth/**", "/login", "/logout").permitAll()
                // Tout le reste nécessite authentification
                .anyRequest().authenticated();

        // 🔑 Filtre JWT - pour les API REST
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        // 🔑 Filtre Session - pour les pages JSP (KEPT FROM ORIGINAL)
        http.addFilterBefore(sessionAuthFilter, JwtAuthenticationFilter.class);

        return http.build();
    }

    // 🔐 AuthenticationManager (version simplifiée pour Spring Boot 2.x/3.x)
    @Bean
    public AuthenticationManager authenticationManager() throws Exception {
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService);
        provider.setPasswordEncoder(passwordEncoder());

        // Return a ProviderManager directly instead of using AuthenticationManagerBuilder
        return new org.springframework.security.authentication.ProviderManager(provider);
    }

    // 🔐 Password encoder
    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }
}

