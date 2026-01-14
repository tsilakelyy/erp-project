package com.erp.controller;

import com.erp.domain.User;
import com.erp.dto.LoginRequest;
import com.erp.repository.UserRepository;
import com.erp.security.JwtTokenProvider;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

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
    private AuthenticationManager authenticationManager;

    /**
     * Endpoint d'authentification pour l'API
     */
    @PostMapping(value = "/login", produces = "application/json", consumes = "application/json")
    public ResponseEntity<?> login(@RequestBody LoginRequest loginRequest) {

        String username = loginRequest.getUsername();
        String password = loginRequest.getPassword();

        try {
            logger.info("Tentative de login API pour: {}", username);

            // Authentification via Spring Security
            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(username, password)
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);

            // Récupération de l'utilisateur authentifié
            User user = (User) authentication.getPrincipal();

            // Vérification que l'utilisateur est actif
            if (!user.getActive()) {
                logger.warn("Tentative de connexion de l'utilisateur désactivé: {}", username);
                Map<String, String> error = new HashMap<>();
                error.put("error", "Utilisateur désactivé");
                return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
            }

            // Génération du token JWT
            String jwt = jwtTokenProvider.generateToken(user);

            // Création de la réponse
            Map<String, Object> response = new HashMap<>();
            response.put("token", jwt);
            response.put("user", user.getUsername());
            response.put("roles", user.getRoles());

            logger.info("Login API réussi pour: {}", username);
            return ResponseEntity.ok(response);

        } catch (BadCredentialsException e) {
            logger.warn("Login/password incorrect pour: {}", username);
            Map<String, String> error = new HashMap<>();
            error.put("error", "Login ou mot de passe incorrect");
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
        } catch (Exception e) {
            logger.error("Erreur inattendue lors du login pour {}: {}", username, e.getMessage());
            Map<String, String> error = new HashMap<>();
            error.put("error", "Erreur inattendue lors de l'authentification");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error);
        }
    }

    // GET fallback pour tests simples
    @GetMapping("/login")
    public ResponseEntity<?> loginGet(@RequestParam(required = false) String login, 
                                     @RequestParam(required = false) String password) {
        
        if (login == null || password == null) {
            Map<String, String> info = new HashMap<>();
            info.put("info", "GET endpoint - envoyez les paramètres login et password");
            info.put("example", "/api/auth/login?login=admin&password=admin");
            return ResponseEntity.ok(info);
        }

        try {
            User user = userRepository.findByLogin(login)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé"));

            Authentication authentication = authenticationManager.authenticate(
                new UsernamePasswordAuthenticationToken(login, password)
            );
            SecurityContextHolder.getContext().setAuthentication(authentication);

            String jwt = jwtTokenProvider.generateToken(user);

            Map<String, Object> response = new HashMap<>();
            response.put("token", jwt);
            response.put("user", user.getUsername());
            response.put("roles", user.getRoles());

            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("GET login error: {}", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
                .body(Map.of("error", e.getMessage()));
        }
    }

    // Validation du token
    @GetMapping("/validate")
    public ResponseEntity<?> validateToken(@RequestHeader(value = "Authorization", required = false) String authHeader) {
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            return ResponseEntity.badRequest().body(Map.of("error", "Token manquant", "usage", "Authorization: Bearer <token>"));
        }

        String token = authHeader.substring(7);
        try {
            String username = jwtTokenProvider.extractUsername(token);
            User user = userRepository.findByLogin(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

            if (jwtTokenProvider.validateToken(token, user)) {
                Map<String, Object> response = new HashMap<>();
                response.put("valid", true);
                response.put("username", username);
                response.put("roles", user.getRoles());
                return ResponseEntity.ok(response);
            }
        } catch (Exception e) {
            logger.error("Validation error: {}", e.getMessage());
        }

        return ResponseEntity.status(HttpStatus.UNAUTHORIZED)
            .body(Map.of("valid", false, "error", "Token invalide"));
    }
}
