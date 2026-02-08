package com.erp.service;

import com.erp.domain.User;
import com.erp.domain.Warehouse;
import com.erp.repository.UserRepository;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

/**
 * Service utilisateur
 * Utilise BCryptPasswordEncoder pour l'encodage sécurisé des mots de passe
 */
@Service
@Transactional
public class UserService {
    
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private AuditService auditService;

    @Autowired
    private PasswordEncoder passwordEncoder;

    public Optional<User> findByUsername(String username) {
        return userRepository.findByLogin(username);
    }

    public Optional<User> findById(Long id) {
        return userRepository.findById(id);
    }

    public List<User> findAll() {
        return userRepository.findAll();
    }

    public List<User> findAllActive() {
        return userRepository.findByActiveTrue();
    }

    /**
     * Création d'utilisateur - mot de passe encodé en BCrypt
     */
    public User createUser(User user, String currentUsername) {
        // Encodage BCrypt du mot de passe avant stockage
        if (user.getPassword() != null && !user.getPassword().isEmpty()) {
            user.setPassword(passwordEncoder.encode(user.getPassword()));
        }
        user.setActive(true);
        user.setDateCreation(LocalDateTime.now());
        User savedUser = userRepository.save(user);
        auditService.logAction("User", savedUser.getId(), "CREATE", currentUsername);
        return savedUser;
    }

    public User updateUser(User user, String currentUsername) {
        Optional<User> existing = userRepository.findById(user.getId());
        if (existing.isPresent()) {
            User u = existing.get();
            u.setNom(user.getNom());
            u.setPrenom(user.getPrenom());
            u.setEmail(user.getEmail());
            u.setActive(user.getActive());
            u.setDateModification(LocalDateTime.now());
            User updated = userRepository.save(u);
            auditService.logAction("User", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    /**
     * Changement de mot de passe - comparaison et stockage AVEC BCrypt
     */
    public void changePassword(Long userId, String oldPassword, String newPassword, String currentUsername) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isPresent()) {
            User u = user.get();
            
            // Comparaison BCrypt des mots de passe
            if (passwordEncoder.matches(oldPassword, u.getPassword())) {
                // Encodage BCrypt du nouveau mot de passe
                u.setPassword(passwordEncoder.encode(newPassword));
                u.setDateModification(LocalDateTime.now());
                userRepository.save(u);
                auditService.logAction("User", u.getId(), "CHANGE_PASSWORD", currentUsername);
            } else {
                throw new IllegalArgumentException("Old password is incorrect");
            }
        }
    }

    public void addWarehouseAccess(Long userId, String warehouseCode) {
        Optional<User> userOpt = userRepository.findById(userId);
        Optional<Warehouse> warehouseOpt = warehouseRepository.findByCode(warehouseCode);
        if (userOpt.isPresent() && warehouseOpt.isPresent()) {
            // Logique d'ajout d'accès si nécessaire
        }
    }

    public void updateLastLogin(Long userId) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isPresent()) {
            User u = user.get();
            u.setDateLastLogin(LocalDateTime.now());
            userRepository.save(u);
        }
    }

    public void deactivateUser(Long userId, String currentUsername) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isPresent()) {
            User u = user.get();
            u.setActive(false);
            u.setDateModification(LocalDateTime.now());
            userRepository.save(u);
            auditService.logAction("User", u.getId(), "DEACTIVATE", currentUsername);
        }
    }
}