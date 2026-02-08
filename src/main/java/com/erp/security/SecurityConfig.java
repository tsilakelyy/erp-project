package com.erp.security;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

import com.erp.config.SessionAuthFilter;

/**
 * Configuration de sécurité Spring Security
 * Utilise BCryptPasswordEncoder pour l'authentification
 */
@Configuration
@EnableWebSecurity
@EnableMethodSecurity(prePostEnabled = true, securedEnabled = true)
public class SecurityConfig {

    @Autowired
    private JwtAuthenticationEntryPoint jwtAuthenticationEntryPoint;

    @Autowired
    private JwtAuthenticationFilter jwtAuthenticationFilter;

    @Autowired
    private SessionAuthFilter sessionAuthFilter;

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
            // Désactiver CORS et CSRF pour développement
            .cors().disable()
            .csrf().disable()
            
            // Gestion des erreurs d'authentification
            .exceptionHandling()
                .authenticationEntryPoint(jwtAuthenticationEntryPoint)
                .accessDeniedPage("/login?error=Accès+refusé")
            .and()

            // Configuration des sessions
            .sessionManagement()
                .sessionCreationPolicy(SessionCreationPolicy.IF_REQUIRED)
                .maximumSessions(1)
                .maxSessionsPreventsLogin(false)
            .and()
            .and()

            // ⚠️ CONFIGURATION DES AUTORISATIONS
            .authorizeHttpRequests()
                // Ressources statiques - TOUJOURS EN PREMIER
                .antMatchers(
                    "/favicon.ico",
                    "/error",
                    "/error/**",
                    "/**/*.css",
                    "/**/*.js",
                    "/**/*.png",
                    "/**/*.jpg",
                    "/**/*.jpeg",
                    "/**/*.gif",
                    "/**/*.svg",
                    "/**/*.ico",
                    "/**/*.woff",
                    "/**/*.woff2",
                    "/**/*.ttf",
                    "/**/*.eot",
                    "/webjars/**"
                ).permitAll()
                
                // Endpoints d'authentification - PUBLICS
                .antMatchers(
                    "/",
                    "/login",
                    "/client/login",
                    "/logout",
                    "/api/auth/**",
                    "/api/debug/**",
                    "/debug",
                    "/debug/**"
                ).permitAll()
                
                // Dashboard et pages protégées - NÉCESSITE AUTHENTIFICATION
                .antMatchers(
                    "/dashboard",
                    "/dashboard/**",
                    "/admin/**",
                    "/customers/**",
                    "/products/**",
                    "/orders/**",
                    "/inventory/**"
                ).authenticated()
                
                // Tout le reste nécessite authentification
                .anyRequest().authenticated()
            .and()
            
            // Désactiver la page de login par défaut de Spring Security
            .formLogin().disable()
            .httpBasic().disable();

        // Ajout des filtres d'authentification
        http.addFilterBefore(sessionAuthFilter, UsernamePasswordAuthenticationFilter.class);
        http.addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }
}
