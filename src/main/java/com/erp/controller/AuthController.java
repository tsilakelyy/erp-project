package com.erp.controller;

import com.erp.domain.User;
import com.erp.repository.UserRepository;
import com.erp.security.JwtTokenProvider;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.servlet.http.HttpServletRequest;
import java.io.BufferedReader;
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
     * Endpoint principal - accepte tous les formats de requêtes
     */
    @PostMapping(value = "/login", produces = "application/json")
    public ResponseEntity<?> login(HttpServletRequest request) {
        try {
            String login = null;
            String password = null;

            String contentType = request.getContentType();
            logger.info("Content-Type reçu: {}", contentType);

            // Méthode 1: JSON body
            if (contentType != null && contentType.contains("application/json")) {
                StringBuilder sb = new StringBuilder();
                BufferedReader reader = request.getReader();
                String line;
                while ((line = reader.readLine()) != null) {
                    sb.append(line);
                }
                String body = sb.toString();
                logger.info("Body JSON reçu: {}", body);

                if (!body.isEmpty()) {
                    login = extractValue(body, "login");
                    password = extractValue(body, "password");
                    if (login == null) {
                        login = extractValue(body, "username");
                    }
                }
            }

            // Méthode 2: Form parameters
            if (login == null) {
                login = request.getParameter("login");
                password = request.getParameter("password");
                if (login == null) {
                    login = request.getParameter("username");
                }
                if (password == null) {
                    password = request.getParameter("pwd");
                }
                logger.info("Form params: login={}", login);
            }

            // Log des valeurs reçues
            logger.info("Extraction - login: '{}', password: {}", login, password != null ? "***" : "null");

            // Validation
            if (login == null || login.trim().isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Login manquant");
                error.put("details", "Reçu - login: " + login + ", password: " + (password != null ? "***" : "null"));
                error.put("format", "Accepté: JSON {login, password}, Form {login, password}, ou GET params");
                return ResponseEntity.badRequest().body(error);
            }

            if (password == null || password.trim().isEmpty()) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "Password manquant");
                error.put("details", "Login: " + login);
                return ResponseEntity.badRequest().body(error);
            }

            // Authentification
            Authentication authentication = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(login, password)
            );

            SecurityContextHolder.getContext().setAuthentication(authentication);

            // Récupération utilisateur depuis la base
            User user = userRepository.findByUsername(login)
                .orElseThrow(() -> new RuntimeException("Utilisateur non trouvé: " + login));

            // Génération token JWT
            String jwt = jwtTokenProvider.generateToken(user);

            // Réponse
            Map<String, Object> response = new HashMap<>();
            response.put("token", jwt);
            response.put("user", user.getUsername());
            response.put("roles", user.getRoles());

            logger.info("Login réussi pour: {}", login);
            return ResponseEntity.ok(response);

        } catch (Exception e) {
            logger.error("Erreur login: {}", e.getMessage(), e);
            Map<String, String> error = new HashMap<>();
            error.put("error", "Authentification échouée");
            error.put("details", e.getMessage());
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(error);
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
            User user = userRepository.findByUsername(login)
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
            User user = userRepository.findByUsername(username)
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

    // Utilitaire pour extraire des valeurs JSON simples sans dépendance externe
    private String extractValue(String json, String key) {
        try {
            String searchKey = "\"" + key + "\"";
            int keyIndex = json.indexOf(searchKey);
            if (keyIndex == -1) {
                searchKey = "'" + key + "'";
                keyIndex = json.indexOf(searchKey);
                if (keyIndex == -1) return null;
            }

            int colonIndex = json.indexOf(':', keyIndex);
            if (colonIndex == -1) return null;

            int startIndex = colonIndex + 1;
            while (startIndex < json.length() && Character.isWhitespace(json.charAt(startIndex))) {
                startIndex++;
            }

            if (startIndex >= json.length()) return null;

            char quote = json.charAt(startIndex);
            if (quote != '"' && quote != '\'') {
                int endIndex = startIndex;
                while (endIndex < json.length() && json.charAt(endIndex) != ',' && json.charAt(endIndex) != '}') {
                    endIndex++;
                }
                return json.substring(startIndex, endIndex).trim();
            }

            int endIndex = json.indexOf(quote, startIndex + 1);
            if (endIndex == -1) return null;

            return json.substring(startIndex + 1, endIndex);
        } catch (Exception e) {
            return null;
        }
    }
}
