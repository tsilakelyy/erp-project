package com.erp.security;

import com.erp.service.UserService;
import com.erp.domain.User;
import com.erp.repository.UserRepository;
import io.jsonwebtoken.ExpiredJwtException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        final String requestTokenHeader = request.getHeader("Authorization");
        String username = null;
        String jwtToken = null;

        // Ignorer les requêtes d'authentification
        String path = request.getRequestURI();
        if (path != null && (path.contains("/api/auth/login") || path.contains("/api/auth/validate"))) {
            filterChain.doFilter(request, response);
            return;
        }

        // JWT Token is in the form "Bearer token"
        if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            jwtToken = requestTokenHeader.substring(7);
            try {
                username = jwtTokenProvider.extractUsername(jwtToken);
            } catch (ExpiredJwtException e) {
                logger.error("JWT Token has expired");
            } catch (Exception e) {
                logger.error("Cannot extract username from JWT token: {}", e.getMessage());
            }
        }

        // Validate token and set authentication
               // Validate token and set authentication
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            // Récupération utilisateur par login
            User user = userRepository.findByLogin(username).orElse(null);
            
            if (user != null && jwtTokenProvider.validateToken(jwtToken, user)) {
                UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);
                
                UsernamePasswordAuthenticationToken authenticationToken = 
                    new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                
                authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                SecurityContextHolder.getContext().setAuthentication(authenticationToken);
            }
        }
        
        filterChain.doFilter(request, response);
    }
}
