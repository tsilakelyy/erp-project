package com.erp.security;

import com.erp.domain.User;
import com.erp.repository.UserRepository;
import io.jsonwebtoken.ExpiredJwtException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
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

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthenticationFilter.class);

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private CustomUserDetailsService userDetailsService;

    @Autowired
    private UserRepository userRepository;

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {
        
        String path = request.getRequestURI();
        logger.debug("🔍 JwtAuthFilter - path: {}", path);
        
        // ⚠️ IGNORER les chemins publics - NE JAMAIS BLOQUER
        if (isPublicPath(path)) {
            logger.debug("⏭️ Public path, skipping JWT filter: {}", path);
            filterChain.doFilter(request, response);
            return;
        }

        final String requestTokenHeader = request.getHeader("Authorization");
        String username = null;
        String jwtToken = null;

        // JWT Token is in the form "Bearer token"
        if (requestTokenHeader != null && requestTokenHeader.startsWith("Bearer ")) {
            jwtToken = requestTokenHeader.substring(7);
            try {
                username = jwtTokenProvider.extractUsername(jwtToken);
            } catch (ExpiredJwtException e) {
                logger.warn("JWT Token expired: {}", e.getMessage());
            } catch (Exception e) {
                logger.error("Cannot extract username from JWT: {}", e.getMessage());
            }
        }

        // Validate token and set authentication
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            try {
                User user = userRepository.findByLogin(username).orElse(null);
                
                if (user != null && user.getActive() && jwtTokenProvider.validateToken(jwtToken, user)) {
                    UserDetails userDetails = this.userDetailsService.loadUserByUsername(username);
                    
                    UsernamePasswordAuthenticationToken authenticationToken = 
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    
                    authenticationToken.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));
                    SecurityContextHolder.getContext().setAuthentication(authenticationToken);
                    logger.debug("✅ JWT authentification OK pour: {}", username);
                }
            } catch (Exception e) {
                logger.error("❌ Erreur JWT authentification: {}", e.getMessage());
            }
        }
        
        filterChain.doFilter(request, response);
    }

    /**
     * Vérifie si le chemin est public (ne nécessite pas d'authentification)
     */
    private boolean isPublicPath(String path) {
        return path.equals("/")
            || path.equals("/login")
            || path.equals("/logout")
            || path.startsWith("/api/auth")
            || path.startsWith("/error")
            || path.startsWith("/api/debug")
            || path.contains("/webjars/")
            || path.endsWith(".css")
            || path.endsWith(".js")
            || path.endsWith(".png")
            || path.endsWith(".jpg")
            || path.endsWith(".jpeg")
            || path.endsWith(".gif")
            || path.endsWith(".ico")
            || path.endsWith(".svg")
            || path.endsWith(".woff")
            || path.endsWith(".woff2")
            || path.endsWith(".ttf")
            || path.endsWith(".eot");
    }
}