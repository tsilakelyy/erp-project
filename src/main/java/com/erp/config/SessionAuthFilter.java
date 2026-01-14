package com.erp.config;

import com.erp.domain.User;
import com.erp.repository.UserRepository;
import com.erp.security.JwtTokenProvider;
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
 * Utile pour les pages JSP qui utilisent HttpSession
 */
@Component
public class SessionAuthFilter extends OncePerRequestFilter {

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
        
        // Ignorer les requêtes vers les pages publiques et API
        if (path.startsWith("/login") || 
            path.startsWith("/api/auth/") || 
            path.startsWith("/error") ||
            !path.startsWith("/erp-system/dashboard") && 
            !path.startsWith("/erp-system/articles") && 
            !path.startsWith("/erp-system/customers") && 
            !path.startsWith("/erp-system/suppliers") && 
            !path.startsWith("/erp-system/stocks") && 
            !path.startsWith("/erp-system/purchases") && 
            !path.startsWith("/erp-system/sales") && 
            !path.startsWith("/erp-system/inventories") && 
            !path.startsWith("/erp-system/admin")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Vérifier si l'utilisateur est déjà authentifié dans SecurityContext
        if (SecurityContextHolder.getContext().getAuthentication() != null) {
            filterChain.doFilter(request, response);
            return;
        }

        // Essayer de récupérer depuis la session HTTP
        HttpSession session = request.getSession(false);
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                // Recharger l'utilisateur depuis la base
                User freshUser = userRepository.findByLogin(user.getLogin()).orElse(null);
                if (freshUser != null && freshUser.getActif()) {
                    // Reconstruire l'authentification
                    UserDetails userDetails = userDetailsService.loadUserByUsername(freshUser.getLogin());
                    UsernamePasswordAuthenticationToken auth = 
                        new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());
                    SecurityContextHolder.getContext().setAuthentication(auth);
                }
            }
        }

        filterChain.doFilter(request, response);
    }
}