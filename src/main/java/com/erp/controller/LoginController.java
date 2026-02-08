package com.erp.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;

import com.erp.domain.User;
import com.erp.repository.UserRepository;
import com.erp.security.JwtTokenProvider;
import org.springframework.security.crypto.password.PasswordEncoder;
import javax.servlet.http.HttpSession;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import javax.servlet.http.Cookie;

/**
 * Contrôleur de login HTML
 * Utilise BCryptPasswordEncoder pour la vérification des mots de passe
 */
@Controller
public class LoginController {
    
    private static final Logger logger = LoggerFactory.getLogger(LoginController.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Affiche la page de login
     * Nettoie toute trace d'authentification persistante pour éviter une redirection automatique.
     */
    @GetMapping("/login")
public String login(HttpServletRequest request, HttpServletResponse response) {
    logger.info("📄 Affichage de la page de login - nettoyage complet de l'état d'authentification");

    // 1) Invalider la session existante (supprime JSESSIONID côté serveur)
    try {
        HttpSession session = request.getSession(false);
        if (session != null) {
            session.invalidate();
            logger.debug("Session HTTP invalidée");
        }
    } catch (Exception e) {
        logger.debug("Impossible d'invalider la session: {}", e.getMessage());
    }

    // 2) Supprimer les cookies potentiels (JSESSIONID, jwtToken, etc.)
    try {
        Cookie cookieJsession = new Cookie("JSESSIONID", "");
        cookieJsession.setPath("/");
        cookieJsession.setMaxAge(0);
        // si tu utilises secure / httpOnly, ajuste ces flags :
        cookieJsession.setHttpOnly(true);
        response.addCookie(cookieJsession);

        Cookie cookieJwt = new Cookie("jwtToken", "");
        cookieJwt.setPath("/");
        cookieJwt.setMaxAge(0);
        cookieJwt.setHttpOnly(true);
        response.addCookie(cookieJwt);

        // Si tu as un cookie custom "Authorization" ou autre, supprime-le aussi:
        Cookie cookieAuth = new Cookie("Authorization", "");
        cookieAuth.setPath("/");
        cookieAuth.setMaxAge(0);
        response.addCookie(cookieAuth);

        logger.debug("Cookies d'authentification supprimés (setMaxAge=0)");
    } catch (Exception e) {
        logger.debug("Erreur suppression cookies: {}", e.getMessage());
    }

    // 3) Vider le contexte de sécurité côté serveur
    try {
        SecurityContextHolder.clearContext();
        logger.debug("SecurityContext vidé");
    } catch (Exception e) {
        logger.debug("Erreur clear SecurityContext: {}", e.getMessage());
    }

    // 4) Empêcher le cache côté navigateur (idéal si page contient JS)
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

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
     * Login via formulaire HTML - SIMPLIFIÉ
     */
    @PostMapping("/login")
    public String loginForm(@RequestParam("username") String username, 
                           @RequestParam("password") String password,
                           HttpSession session) {
        try {
            logger.info("📝 Login formulaire - username: {}", username);

            // 1. Recherche de l'utilisateur
            User user = userRepository.findByLogin(username)
                .orElse(null);

            if (user == null) {
                logger.warn("❌ Utilisateur non trouvé: {}", username);
                return "redirect:/login?error=Utilisateur+non+trouvé";
            }

            // 2. Vérification utilisateur actif
            if (user.getActive() == null || !user.getActive()) {
                logger.warn("⚠️ Utilisateur désactivé: {}", username);
                return "redirect:/login?error=Utilisateur+désactivé";
            }

            // 3. COMPARAISON DES MOTS DE PASSE AVEC BCRYPT
            String storedPassword = user.getPassword();
            logger.info("🔑 Vérification password BCrypt pour: {}", username);
            
            if (!passwordEncoder.matches(password, storedPassword)) {
                logger.warn("❌ Mot de passe incorrect pour: {}", username);
                return "redirect:/login?error=Mot+de+passe+incorrect";
            }

            logger.info("✅ Authentification réussie pour: {}", username);

            // 4. Création de l'authentification Spring Security
            UsernamePasswordAuthenticationToken auth = 
                new UsernamePasswordAuthenticationToken(username, password);
            SecurityContextHolder.getContext().setAuthentication(auth);
            
            // 5. Génération token JWT et stockage en session
            String jwt = jwtTokenProvider.generateToken(user);
            session.setAttribute("jwtToken", jwt);
            session.setAttribute("user", user);
            session.setAttribute("authenticated", true);
            
            // 6. Mise à jour de la dernière connexion
            user.setDateLastLogin(java.time.LocalDateTime.now());
            userRepository.save(user);

            logger.info("✅ Login réussi pour: {} - Redirection vers dashboard", username);

            // 7. Redirection selon le role
            boolean isClient = user.getRoles() != null
                && user.getRoles().stream().anyMatch(r -> "CLIENT".equalsIgnoreCase(r.getCode()));
            if (isClient) {
                return "redirect:/client";
            }

            return "redirect:/dashboard";

        } catch (Exception e) {
            logger.error("❌ Erreur inattendue lors du login pour {}: {}", username, e.getMessage(), e);
            return "redirect:/login?error=Erreur+inattendue";
        }
    }

    /**
     * Logout
     */
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        logger.info("🚪 Logout - Invalidation de la session");
        session.invalidate();
        SecurityContextHolder.clearContext();
        return "redirect:/login?logout=true";
    }
}
