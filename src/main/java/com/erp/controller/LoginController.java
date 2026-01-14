package com.erp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UserDetails;

import com.erp.domain.User;
import com.erp.repository.UserRepository;
import com.erp.security.JwtTokenProvider;
import javax.servlet.http.HttpSession;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
public class LoginController {
    
    private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuthenticationManager authenticationManager;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    /**
     * Affiche la page de login
     */
    @GetMapping("/login")
    public String login() {
        return "login";
    }

    /**
     * Redirection racine vers login
     */
    @GetMapping("/")
    public String index() {
        return "redirect:/login";
    }

    /**
     * Login via formulaire HTML - redirection vers dashboard si succès
     */
    @PostMapping("/login")
    public String loginForm(@RequestParam("username") String username, 
                           @RequestParam("password") String password,
                           HttpSession session) {
        try {
            logger.info("Login formulaire - username: {}", username);

            // Authentification Spring Security
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(username, password)
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);
            
            // Récupération de l'utilisateur authentifié
            User user = (User) authentication.getPrincipal();

            // Vérification utilisateur actif
            if (!user.getActive()) {
                logger.warn("Tentative de connexion de l'utilisateur désactivé: {}", username);
                return "redirect:/login?error=Utilisateur+désactivé";
            }

            // Génération token JWT et stockage en session
            String jwt = jwtTokenProvider.generateToken(user);
            session.setAttribute("jwtToken", jwt);
            session.setAttribute("user", user);
            
            // Mise à jour de la dernière connexion
            user.setDateLastLogin(java.time.LocalDateTime.now());
            userRepository.save(user);

            logger.info("Login réussi pour: {}", username);

            // Redirection vers dashboard
            return "redirect:/dashboard";

        } catch (BadCredentialsException e) {
            logger.warn("Login/password incorrect pour: {}", username);
            return "redirect:/login?error=Login+ou+password+incorrect";
        } catch (Exception e) {
            logger.error("Erreur inattendue lors du login pour {}: {}", username, e.getMessage());
            return "redirect:/login?error=Erreur+inattendue";
        }
    }

    /**
     * Logout
     */
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/login";
    }
}
