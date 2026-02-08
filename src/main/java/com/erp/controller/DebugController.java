package com.erp.controller;

import com.erp.domain.User;
import com.erp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Contrôleur de debug pour vérifier les utilisateurs et les mots de passe
 */
@RestController
@RequestMapping("/api/debug")
public class DebugController {
    
    private static final Logger logger = LoggerFactory.getLogger(DebugController.class);
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private PasswordEncoder passwordEncoder;
    
    /**
     * Liste tous les utilisateurs en base
     */
    @GetMapping("/users")
    public Map<String, Object> listUsers() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<User> users = userRepository.findAll();
            response.put("total", users.size());
            response.put("users", users.stream()
                .map(u -> {
                    Map<String, Object> user = new HashMap<>();
                    user.put("id", u.getId());
                    user.put("login", u.getLogin());
                    user.put("email", u.getEmail());
                    user.put("password_hash", u.getPassword());
                    user.put("password_length", u.getPassword() != null ? u.getPassword().length() : 0);
                    user.put("active", u.getActive());
                    return user;
                })
                .toList());
        } catch (Exception e) {
            response.put("error", e.getMessage());
            logger.error("Erreur lors de la récupération des utilisateurs", e);
        }
        return response;
    }
    
    /**
     * Test de vérification de mot de passe
     */
    @GetMapping("/test-password")
    public Map<String, Object> testPassword() {
        Map<String, Object> response = new HashMap<>();
        
        String testPassword = "password123";
        Optional<User> adminUser = userRepository.findByLogin("admin");
        
        if (adminUser.isEmpty()) {
            response.put("error", "Utilisateur admin non trouvé");
            return response;
        }
        
        User user = adminUser.get();
        String storedHash = user.getPassword();
        
        response.put("username", "admin");
        response.put("test_password", testPassword);
        response.put("stored_hash", storedHash);
        response.put("hash_length", storedHash != null ? storedHash.length() : 0);
        
        if (storedHash == null) {
            response.put("error", "Password is NULL in database!");
            return response;
        }
        
        try {
            boolean matches = passwordEncoder.matches(testPassword, storedHash);
            response.put("password_matches", matches);
            response.put("status", matches ? "✅ SUCCESS" : "❌ FAIL");
        } catch (Exception e) {
            response.put("error", e.getMessage());
            logger.error("Erreur lors de la vérification du mot de passe", e);
        }
        
        return response;
    }
    
    /**
     * Génère un nouveau hash BCrypt pour un mot de passe
     */
    @GetMapping("/generate-hash")
    public Map<String, Object> generateHash() {
        Map<String, Object> response = new HashMap<>();
        
        String password = "password123";
        String hash = passwordEncoder.encode(password);
        
        response.put("password", password);
        response.put("generated_hash", hash);
        
        // Vérifier que le hash fonctionne
        boolean matches = passwordEncoder.matches(password, hash);
        response.put("verification", matches ? "✅ OK" : "❌ FAIL");
        
        return response;
    }
}
