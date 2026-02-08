package com.erp.service;

import com.erp.domain.Category;
import com.erp.repository.CategoryRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class CategoryService {
    
    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private AuditService auditService;

    public Category createCategory(Category category, String currentUsername) {
        if (category.getCode() == null || category.getCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Code category must not be empty");
        }
        if (categoryRepository.findByCode(category.getCode()).isPresent()) {
            throw new IllegalArgumentException("Code already exists");
        }
        category.setDateCreation(LocalDateTime.now());
        category.setUtilisateurCreation(currentUsername);
        Category saved = categoryRepository.save(category);
        auditService.logAction("Category", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Category updateCategory(Category category, String currentUsername) {
        Optional<Category> existing = categoryRepository.findById(category.getId());
        if (existing.isPresent()) {
            Category cat = existing.get();
            cat.setLibelle(category.getLibelle());
            cat.setDescription(category.getDescription());
            cat.setActif(category.getActif());
            cat.setUtilisateurModification(currentUsername);
            Category updated = categoryRepository.save(cat);
            auditService.logAction("Category", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public Optional<Category> findById(Long id) {
        return categoryRepository.findById(id);
    }

    public Optional<Category> findByCode(String code) {
        return categoryRepository.findByCode(code);
    }

    public List<Category> findAll() {
        return categoryRepository.findAll();
    }

    public List<Category> findAllActive() {
        return categoryRepository.findByActifTrue();
    }

    public void deleteCategory(Long id, String currentUsername) {
        if (categoryRepository.existsById(id)) {
            categoryRepository.deleteById(id);
            auditService.logAction("Category", id, "DELETE", currentUsername);
        }
    }
}
