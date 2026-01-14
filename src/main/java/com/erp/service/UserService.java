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

@Service
@Transactional
public class UserService {
    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private PasswordEncoder passwordEncoder;

    @Autowired
    private AuditService auditService;

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

    public User createUser(User user, String currentUsername) {
        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setActive(true);
        user.setCreatedBy(currentUsername);
        User savedUser = userRepository.save(user);
        auditService.logAction("User", savedUser.getId(), "CREATE", currentUsername);
        return savedUser;
    }

    public User updateUser(User user, String currentUsername) {
        Optional<User> existing = userRepository.findById(user.getId());
        if (existing.isPresent()) {
            User u = existing.get();
            u.setFirstName(user.getFirstName());
            u.setLastName(user.getLastName());
            u.setEmail(user.getEmail());
            u.setActive(user.getActive());
            u.setUpdatedBy(currentUsername);
            User updated = userRepository.save(u);
            auditService.logAction("User", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public void changePassword(Long userId, String oldPassword, String newPassword, String currentUsername) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isPresent()) {
            User u = user.get();
            if (passwordEncoder.matches(oldPassword, u.getPassword())) {
                u.setPassword(passwordEncoder.encode(newPassword));
                u.setUpdatedBy(currentUsername);
                userRepository.save(u);
                auditService.logAction("User", u.getId(), "CHANGE_PASSWORD", currentUsername);
            } else {
                throw new IllegalArgumentException("Old password is incorrect");
            }
        }
    }

    // Méthode désactivée car la table sites n'existe pas
    public void addSiteAccess(Long userId, Long siteId, String currentUsername) {
        // Non implémenté - table sites non présente dans la base
    }
    
    // Méthode désactivée car la table sites non présente dans ce schéma
    public void removeSiteAccess(Long userId, Long siteId, String currentUsername) {
        // Ne rien faire
    }

    // Méthode pour ajouter un entrepôt
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
            u.setLastLogin(LocalDateTime.now());
            userRepository.save(u);
        }
    }

    public void deactivateUser(Long userId, String currentUsername) {
        Optional<User> user = userRepository.findById(userId);
        if (user.isPresent()) {
            User u = user.get();
            u.setActive(false);
            u.setUpdatedBy(currentUsername);
            userRepository.save(u);
            auditService.logAction("User", u.getId(), "DEACTIVATE", currentUsername);
        }
    }
}

