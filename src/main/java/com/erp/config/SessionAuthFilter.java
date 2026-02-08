package com.erp.config;

import com.erp.domain.User;
import com.erp.repository.UserRepository;
import com.erp.security.JwtTokenProvider;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Filtre pour reconstruire l'authentification Spring Security depuis la session HTTP
 * NE REDIRIGE PAS - Authentifie seulement si token valide en session
 */
@Component
public class SessionAuthFilter extends OncePerRequestFilter {

    private static final Logger logger = LoggerFactory.getLogger(SessionAuthFilter.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private UserDetailsService userDetailsService;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Override
    protected void doFilterInternal(HttpServletRequest request, 
                                   HttpServletResponse response, 
                                   FilterChain filterChain) throws ServletException, IOException {
        
        String path = request.getRequestURI();
        logger.debug("🔍 SessionAuthFilter - path: {}", path);
        
        // ⚠️ IGNORER TOUS LES CHEMINS PUBLICS - NE PAS BLOQUER
        if (shouldSkipFilter(path)) {
            logger.debug("⏭️ Skipping filter for public path: {}", path);
            filterChain.doFilter(request, response);
            return;
        }

        // Si déjà authentifié, continuer SANS REDIRECTION
        if (SecurityContextHolder.getContext().getAuthentication() != null 
            && SecurityContextHolder.getContext().getAuthentication().isAuthenticated()
            && !SecurityContextHolder.getContext().getAuthentication().getName().equals("anonymousUser")) {
            logger.debug("✅ Already authenticated: {}", 
                SecurityContextHolder.getContext().getAuthentication().getName());
            filterChain.doFilter(request, response);
            return;
        }

        // Essayer de récupérer depuis la session HTTP
        try {
            HttpSession session = request.getSession(false);
            if (session != null) {
                // Vérifier le flag d'authentification
                Boolean authenticated = (Boolean) session.getAttribute("authenticated");
                
                if (Boolean.TRUE.equals(authenticated)) {
                    User user = (User) session.getAttribute("user");
                    
                    if (user != null && user.getActive()) {
                        authenticateUser(user);
                        logger.debug("✅ Authentification restaurée depuis session pour: {}", user.getLogin());
                    } else {
                        // Token en session mais pas d'utilisateur - essayer JWT
                        String jwtToken = (String) session.getAttribute("jwtToken");
                        
                        if (jwtToken != null) {
                            String username = jwtTokenProvider.extractUsername(jwtToken);
                            User tokenUser = userRepository.findByLogin(username).orElse(null);
                            
                            if (tokenUser != null && tokenUser.getActive() 
                                && jwtTokenProvider.validateToken(jwtToken, tokenUser)) {
                                authenticateUser(tokenUser);
                                session.setAttribute("user", tokenUser);
                                session.setAttribute("authenticated", true);
                                logger.debug("✅ Authentification restaurée depuis JWT pour: {}", username);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            logger.error("❌ Erreur dans SessionAuthFilter: {}", e.getMessage());
            // NE PAS BLOQUER - Continuer même en cas d'erreur
        }
        
        // ⚠️ IMPORTANT : TOUJOURS CONTINUER - NE JAMAIS REDIRIGER ICI
        filterChain.doFilter(request, response);
    }

    /**
     * Authentifie un utilisateur dans Spring Security
     * NE FAIT QUE L'AUTHENTIFICATION - PAS DE REDIRECTION
     */
    private void authenticateUser(User user) {
        try {
            // ⚠️ NULL CHECK
            if (user == null || user.getLogin() == null) {
                return;
            }
            
            User freshUser = userRepository.findByLogin(user.getLogin()).orElse(null);
            
            if (freshUser != null && freshUser.getActive()) {
                UserDetails userDetails = userDetailsService.loadUserByUsername(freshUser.getLogin());
                // ⚠️ NULL CHECK for userDetails
                if (userDetails != null) {
                    UsernamePasswordAuthenticationToken auth = 
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    SecurityContextHolder.getContext().setAuthentication(auth);
                    logger.debug("✅ Authentifié: {}", freshUser.getLogin());
                }
            }
        } catch (Exception e) {
            logger.error("❌ Erreur authentification: {}", e.getMessage());
        }
    }

    /**
     * Détermine si le filtre doit être ignoré pour cette requête
     */
    private boolean shouldSkipFilter(String path) {
        // Liste COMPLÈTE des chemins à ignorer
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