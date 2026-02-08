package com.erp.controller;

import com.erp.domain.User;
import com.erp.domain.Role;
import com.erp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * Contrôleur de Debug et Direction
 * Affiche les informations d'authentification et les erreurs
 */
@Controller
@RequestMapping("/debug")
public class DebugDirectionController {

    private static final Logger logger = LoggerFactory.getLogger(DebugDirectionController.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    /**
     * Page principale de debug affichant l'état d'authentification
     */
    @GetMapping
    public String debug(Model model) {
        logger.info("📊 Accès à la page de debug direction");
        
        try {
            // Récupérer tous les utilisateurs
            List<User> users = userRepository.findAll();
            
            // Afficher les hashes SANS sérialiser les rôles (évite boucle infinie)
            model.addAttribute("debugInfo", users.stream().map(u -> {
                Map<String, Object> userInfo = new HashMap<>();
                userInfo.put("login", u.getLogin());
                userInfo.put("email", u.getEmail());
                userInfo.put("active", u.getActive());
                userInfo.put("passwordHash", u.getPassword());
                userInfo.put("passwordLength", u.getPassword() != null ? u.getPassword().length() : 0);
                // ✅ NE PAS inclure les rôles pour éviter la sérialisation circulaire
                userInfo.put("roleCount", u.getRoles() != null ? u.getRoles().size() : 0);
                userInfo.put("roleNames", u.getRoles() != null ? 
                    u.getRoles().stream().map(Role::getCode).collect(java.util.stream.Collectors.toList()) : 
                    java.util.Collections.emptyList());
                return userInfo;
            }).collect(java.util.stream.Collectors.toList()));
            
        } catch (Exception e) {
            logger.error("Erreur lors de la récupération des infos debug", e);
            model.addAttribute("error", e.getMessage());
        }
        
        return "debug/direction";
    }

    /**
     * Vérifie un mot de passe spécifique contre un utilisateur
     */
    @PostMapping("/verify-password")
    public String verifyPassword(@RequestParam String username,
                                 @RequestParam String password,
                                 Model model) {
        logger.info("🔍 Vérification du mot de passe pour: {}", username);
        
        try {
            Optional<User> userOpt = userRepository.findByLogin(username);
            
            if (userOpt.isEmpty()) {
                model.addAttribute("error", "Utilisateur '" + username + "' non trouvé");
                model.addAttribute("testUsername", username);
                return "debug/direction";
            }
            
            User user = userOpt.get();
            String storedHash = user.getPassword();
            
            // Test BCrypt
            boolean matches = passwordEncoder.matches(password, storedHash);
            
            Map<String, Object> result = new HashMap<>();
            result.put("username", username);
            result.put("testPassword", password);
            result.put("storedHash", storedHash);
            result.put("hashLength", storedHash != null ? storedHash.length() : 0);
            result.put("matches", matches);
            result.put("status", matches ? "✅ SUCCÈS - Mot de passe correct" : "❌ ÉCHEC - Mot de passe incorrect");
            
            model.addAttribute("verifyResult", result);
            model.addAttribute("testUsername", username);
            
            if (matches) {
                logger.info("✅ Mot de passe CORRECT pour: {}", username);
            } else {
                logger.warn("❌ Mot de passe INCORRECT pour: {}", username);
            }
            
        } catch (Exception e) {
            logger.error("Erreur lors de la vérification", e);
            model.addAttribute("error", e.getMessage());
        }
        
        return "debug/direction";
    }

    /**
     * Génère un nouveau hash BCrypt pour un mot de passe
     */
    @PostMapping("/generate-hash")
    public String generateHash(@RequestParam String password, Model model) {
        logger.info("🔐 Génération d'un hash BCrypt");
        
        try {
            String hash = passwordEncoder.encode(password);
            
            model.addAttribute("generatedHash", hash);
            model.addAttribute("generatedPassword", password);
            
            logger.info("✅ Hash généré pour le mot de passe");
            
        } catch (Exception e) {
            logger.error("Erreur lors de la génération", e);
            model.addAttribute("error", e.getMessage());
        }
        
        return "debug/direction";
    }

    /**
     * Teste la vérification BCrypt avec un hash et un mot de passe
     */
    @PostMapping("/test-bcrypt")
    public String testBcrypt(@RequestParam String testHash,
                             @RequestParam String testPassword,
                             Model model) {
        logger.info("🧪 Test BCrypt manuel");
        
        try {
            boolean matches = passwordEncoder.matches(testPassword, testHash);
            
            Map<String, Object> result = new HashMap<>();
            result.put("hash", testHash);
            result.put("password", testPassword);
            result.put("matches", matches);
            result.put("status", matches ? "✅ SUCCÈS" : "❌ ÉCHEC");
            
            model.addAttribute("bcryptTest", result);
            
            logger.info("🧪 Test BCrypt: {}", matches ? "SUCCÈS" : "ÉCHEC");
            
        } catch (Exception e) {
            logger.error("Erreur lors du test", e);
            model.addAttribute("error", e.getMessage());
        }
        
        return "debug/direction";
    }

    /**
     * Réinitialise le mot de passe d'un utilisateur
     */
    @PostMapping("/reset-password")
    public String resetPassword(@RequestParam String username,
                                @RequestParam String newPassword,
                                Model model) {
        logger.info("🔄 Réinitialisation du mot de passe pour: {}", username);
        
        try {
            Optional<User> userOpt = userRepository.findByLogin(username);
            
            if (userOpt.isEmpty()) {
                model.addAttribute("error", "Utilisateur '" + username + "' non trouvé");
                return "debug/direction";
            }
            
            User user = userOpt.get();
            String newHash = passwordEncoder.encode(newPassword);
            user.setPassword(newHash);
            userRepository.save(user);
            
            model.addAttribute("resetMessage", "✅ Mot de passe réinitialisé pour: " + username);
            model.addAttribute("resetHash", newHash);
            model.addAttribute("resetUsername", username);
            
            logger.info("✅ Mot de passe réinitialisé pour: {}", username);
            
        } catch (Exception e) {
            logger.error("Erreur lors de la réinitialisation", e);
            model.addAttribute("error", e.getMessage());
        }
        
        return "debug/direction";
    }
}
