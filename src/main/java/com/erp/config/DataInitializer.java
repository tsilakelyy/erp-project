package com.erp.config;

import com.erp.domain.Role;
import com.erp.domain.User;
import com.erp.repository.RoleRepository;
import com.erp.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.LocalDateTime;
import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;

/**
 * Initialise les données de test si elles n'existent pas
 * Crée les utilisateurs par défaut avec mots de passe hashés en BCrypt
 * 
 * ✅ IMPORTANT: Cette classe CORRIGE AUSSI les hashes BCrypt invalides
 * dans la base de données lors du démarrage de l'application.
 */
@Configuration
public class DataInitializer {

    private static final Logger logger = LoggerFactory.getLogger(DataInitializer.class);

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private RoleRepository roleRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Bean
    public ApplicationRunner initializeData() {
        return args -> {
            try {
                logger.info("🚀 Initialisation de l'application ERP...");

                // Étape 1: Créer les rôles s'ils n'existent pas
                createRoles();

                // Étape 2: ⭐ CRÉER LES UTILISATEURS avec les bons hashes BCrypt
                createUsersIfNotExist();

                // Étape 3: Corriger les hashes invalides (si quelqu'un les ajoute manuellement)
                fixAllPasswords();

                // Étape 4: Vérifier et afficher les hashes
                verifyPasswords();

                logger.info("🎉 Initialisation complète! Application prête.");

            } catch (Exception e) {
                logger.error("❌ ERREUR lors de l'initialisation", e);
            }
        };
    }

    /**
     * Crée les rôles de base s'ils n'existent pas
     */
    private void createRoles() {
        String[][] roleData = {
            {"ADMIN", "Administrateur", "Accès complet au système"},
            {"ACHETEUR", "Acheteur", "Gestion des achats"},
            {"COMMERCIAL", "Commercial", "Gestion des ventes"},
            {"MAGASINIER", "Magasinier", "Gestion des stocks"},
            {"DIRECTION", "Direction", "Vue globale et reporting"},
            {"FINANCE", "Finance", "Gestion financière"},
            {"CLIENT", "Client", "Espace client"}
        };

        for (String[] data : roleData) {
            String code = data[0];
            String libelle = data[1];
            String description = data[2];

            if (roleRepository.findByCode(code).isEmpty()) {
                Role role = new Role();
                role.setCode(code);
                role.setLibelle(libelle);
                role.setDescription(description);
                roleRepository.save(role);
                logger.info("  ✅ Rôle créé: {}", code);
            }
        }
    }

    /**
     * ⭐ CRÉE LES UTILISATEURS DE TEST AVEC HASHES BCRYPT VALIDES ⭐
     * C'est LA solution à "Utilisateur non trouvé"
     */
    private void createUsersIfNotExist() {
        String testPassword = "password123";
        String passwordHash = passwordEncoder.encode(testPassword);
        
        logger.info("👥 Création des utilisateurs de test...");
        logger.info("   Password: password123");
        logger.info("   Hash BCrypt: {}", passwordHash.substring(0, 20) + "...");
        
        // Données des utilisateurs à créer
        String[][] userData = {
            {"admin", "admin@erp.com", "Administrateur", "Système", "ADMIN"},
            {"acheteur1", "acheteur1@erp.com", "Dupont", "Jean", "ACHETEUR"},
            {"commercial1", "commercial1@erp.com", "Martin", "Sophie", "COMMERCIAL"},
            {"magasinier1", "magasinier1@erp.com", "Bernard", "Luc", "MAGASINIER"},
            {"direction1", "direction1@erp.com", "Directeur", "Paul", "DIRECTION"},
            {"finance1", "finance1@erp.com", "Comptable", "Marie", "FINANCE"},
            {"client1", "contact@abc-industries.mg", "Client", "ABC", "CLIENT"}
        };
        
        for (String[] data : userData) {
            String login = data[0];
            String email = data[1];
            String nom = data[2];
            String prenom = data[3];
            String roleCode = data[4];
            
            // Vérifier si l'utilisateur existe déjà
            if (userRepository.findByLogin(login).isEmpty()) {
                try {
                    // Récupérer le rôle
                    Optional<Role> roleOpt = roleRepository.findByCode(roleCode);
                    if (roleOpt.isEmpty()) {
                        logger.error("  ❌ Rôle '{}' non trouvé pour créer l'utilisateur '{}'", roleCode, login);
                        continue;
                    }
                    
                    // Créer l'utilisateur
                    User user = new User();
                    user.setLogin(login);
                    user.setEmail(email);
                    user.setPassword(passwordHash);
                    user.setNom(nom);
                    user.setPrenom(prenom);
                    user.setActive(true);
                    user.setLocked(false);
                    user.setLoginAttempts(0);
                    user.setDateCreation(LocalDateTime.now());
                    
                    // Assigner le rôle
                    Set<Role> roles = new HashSet<>();
                    roles.add(roleOpt.get());
                    user.setRoles(roles);
                    
                    // Sauvegarder
                    userRepository.save(user);
                    logger.info("  ✅ Utilisateur créé: {} (rôle: {})", login, roleCode);
                    
                } catch (Exception e) {
                    logger.error("  ❌ Erreur lors de la création de l'utilisateur '{}': {}", login, e.getMessage());
                }
            } else {
                logger.debug("  ✓ Utilisateur déjà existant: {}", login);
            }
        }
    }

    /**
     * ⭐ SOLUTION AU PROBLÈME D'AUTHENTIFICATION ⭐
     * 
     * Cette méthode CORRIGE tous les hashes BCrypt invalides en base de données.
     * Les hashes dans data.sql peuvent être corrompus ou invalides.
     * Cette méthode régénère les bons hashes au démarrage de l'application.
     */
    private void fixAllPasswords() {
        String testPassword = "password123";
        String correctHash = passwordEncoder.encode(testPassword);
        
        logger.info("🔐 Génération du hash BCrypt correct...");
        logger.info("   Nouveau hash: {}", correctHash.substring(0, 20) + "...");
        
        List<User> allUsers = userRepository.findAll();
        int fixedCount = 0;
        
        for (User user : allUsers) {
            // Vérifier si le hash actuel est valide
            boolean isValid = user.getPassword() != null && 
                              user.getPassword().length() >= 60 &&
                              passwordEncoder.matches(testPassword, user.getPassword());
            
            if (!isValid) {
                logger.warn("  ⚠️  Hash INVALIDE pour '{}' - Correction en cours...", user.getLogin());
                
                if (user.getPassword() != null) {
                    logger.debug("     Old Hash: {}", user.getPassword());
                }
                
                // Remplacer par le bon hash
                user.setPassword(correctHash);
                userRepository.save(user);
                fixedCount++;
                
                logger.info("  ✅ Hash corrigé pour: {}", user.getLogin());
            } else {
                logger.debug("  ✓ Hash valide pour: {}", user.getLogin());
            }
        }
        
        if (fixedCount > 0) {
            logger.info("📊 {} hashes BCrypt corrigés", fixedCount);
        }
    }

    /**
     * Affiche les résultats de la vérification des hashes
     */
    private void verifyPasswords() {
        try {
            logger.info("🔍 Vérification finale des hashes BCrypt...");
            
            Optional<User> admin = userRepository.findByLogin("admin");
            if (admin.isPresent()) {
                boolean matches = passwordEncoder.matches("password123", admin.get().getPassword());
                
                if (matches) {
                    logger.info("✅ SUCCÈS - Test BCrypt pour admin/password123");
                    logger.info("   Hash correct: {}", admin.get().getPassword().substring(0, 20) + "...");
                } else {
                    logger.error("❌ ÉCHEC - Le hash pour admin n'est pas correct!");
                    logger.error("   Hash: {}", admin.get().getPassword());
                }
            } else {
                logger.warn("⚠️  Utilisateur admin non trouvé");
            }
            
        } catch (Exception e) {
            logger.error("Erreur lors de la vérification", e);
        }
    }
}
