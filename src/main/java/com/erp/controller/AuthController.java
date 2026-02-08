package com.erp.controller;

import com.erp.domain.User;
import com.erp.dto.LoginRequest;
import com.erp.repository.UserRepository;
import com.erp.security.JwtTokenProvider;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.stream.Collectors;

/**
 * Contrôleur d'authentification
 * Utilise BCryptPasswordEncoder pour la vérification des mots de passe
 */
@RestController
@RequestMapping("/api/auth")
@CrossOrigin(origins = "*")
public class AuthController {

    private static final Logger logger = LoggerFactory.getLogger(AuthController.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private JwtTokenProvider jwtTokenProvider;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Login API - Accepte JSON
     * NOTE: on ajoute HttpSession pour persister l'auth côté serveur (JSESSIONID)
     */
    @PostMapping(value = "/login", produces = "application/json", consumes = "application/json")
    public ResponseEntity<?> loginJson(@RequestBody LoginRequest loginRequest, HttpSession session) {
        logger.info("🔍 Login JSON - username: {}", loginRequest.getUsername());
        return performLogin(loginRequest.getUsername(), loginRequest.getPassword(), session);
    }

    /**
     * Login API - Accepte form-urlencoded
     */
    @PostMapping(value = "/login", consumes = "application/x-www-form-urlencoded")
    public ResponseEntity<?> loginForm(@RequestParam("username") String username,
                                       @RequestParam("password") String password,
                                       HttpSession session) {
        logger.info("🔍 Login Form - username: {}", username);
        return performLogin(username, password, session);
    }

    /**
     * Logique d'authentification avec BCrypt
     * Vérification sécurisée des mots de passe
     */
    private ResponseEntity<?> performLogin(String username, String password, HttpSession session) {
        try {
            logger.info("🔐 Tentative de login pour: {}", username);

            // 1. Recherche de l'utilisateur
            User user = userRepository.findByLogin(username)
                .orElseThrow(() -> {
                    logger.warn("❌ Utilisateur non trouvé: {}", username);
                    return new RuntimeException("Utilisateur non trouvé");
                });

            logger.info("✅ Utilisateur trouvé: {} (actif: {})", user.getLogin(), user.getActive());

            // 2. Vérification si l'utilisateur est actif
            if (user.getActive() == null || !user.getActive()) {
                logger.warn("⚠️ Utilisateur désactivé: {}", username);
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Utilisateur désactivé"));
            }

            // 3. COMPARAISON DES MOTS DE PASSE AVEC BCRYPT
            String storedPassword = user.getPassword();
            logger.debug("🔑 Vérification password BCrypt pour: {}", username);
            
            if (!passwordEncoder.matches(password, storedPassword)) {
                logger.warn("❌ Mot de passe incorrect pour: {}", username);
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                    .body(Map.of("error", "Login ou mot de passe incorrect"));
            }

            logger.info("✅ Mot de passe correct pour: {}", username);

            // 4. Création de l'authentification Spring Security
            UsernamePasswordAuthenticationToken authentication = 
                new UsernamePasswordAuthenticationToken(user.getLogin(), null);
            SecurityContextHolder.getContext().setAuthentication(authentication);

            // 5. Génération token JWT
            String jwt = jwtTokenProvider.generateToken(user);
            logger.info("🎫 Token JWT généré pour: {}", username);

            // 6. Mise à jour dernière connexion
            user.setDateLastLogin(LocalDateTime.now());
            userRepository.save(user);

            // 7. Enregistrer l'état d'authentification dans la session HTTP
            try {
                session.setAttribute("authenticated", true);
                session.setAttribute("user", user);      // objet User sérialisable / pr session
                session.setAttribute("jwtToken", jwt);
                logger.debug("✅ Attributs de session définis pour {}", username);
            } catch (Exception e) {
                logger.warn("⚠️ Impossible de définir les attributs de session: {}", e.getMessage());
            }

            // 8. Préparation de la réponse JSON
            Map<String, Object> response = new HashMap<>();
            response.put("token", jwt);
            response.put("user", user.getLogin());
            response.put("roles", user.getRoles().stream()
                .map(role -> role.getCode())
                .collect(Collectors.toList()));

            logger.info("✅ Login API réussi pour: {}", username);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("❌ Erreur lors du login pour {}: {}", username, e.getMessage(), e);
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", "Login ou mot de passe incorrect"));
        }
    }

    /**
     * GET endpoint pour tests
     */
    @GetMapping("/login")
    public ResponseEntity<?> loginGet(@RequestParam(required = false) String username, 
                                     @RequestParam(required = false) String password) {
        
        if (username == null || password == null) {
            return ResponseEntity.ok(Map.of(
                "info", "Envoyez username et password",
                "example", "/api/auth/login?username=admin&password=password123"
            ));
        }

        return performLogin(username, password, null);
    }

    /**
     * Validation du token
     */
    @GetMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest()
                .body(Map.of("error", "Token manquant", "usage", "Authorization: Bearer <token>"));
        }

        String token = authHeader.substring(7);
        try {
            String username = jwtTokenProvider.extractUsername(token);
            User user = userRepository.findByLogin(username)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            if (jwtTokenProvider.validateToken(token, user)) {
                return ResponseEntity.ok(Map.of(
                    "valid", true,
                    "username", username,
                    "roles", user.getRoles().stream()
                        .map(role -> role.getCode())
                        .collect(Collectors.toList())
                ));
            }
        } catch (Exception e) {
            logger.error("Erreur validation: {}", e.getMessage());
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body(Map.of("valid", false, "error", "Token invalide"));
    }
}
