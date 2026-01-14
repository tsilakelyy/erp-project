package com.erp.service;

import com.erp.domain.Article;
import com.erp.repository.ArticleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class ArticleService {
    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private AuditService auditService;

    public Optional<Article> findById(Long id) {
        return articleRepository.findById(id);
    }

    public Optional<Article> findByCode(String code) {
        return articleRepository.findByCode(code);
    }

    public List<Article> findAll() {
        return articleRepository.findAll();
    }

    public List<Article> findAllActive() {
        return articleRepository.findByActiveTrueOrderByName();
    }

    public Article createArticle(Article article, String currentUsername) {
        if (articleRepository.findByCode(article.getCode()).isPresent()) {
            throw new IllegalArgumentException("Article code already exists: " + article.getCode());
        }
        article.setCreatedBy(currentUsername);
        article.setActive(true);
        Article saved = articleRepository.save(article);
        auditService.logAction("Article", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Article updateArticle(Article article, String currentUsername) {
        Optional<Article> existing = articleRepository.findById(article.getId());
        if (existing.isPresent()) {
            Article a = existing.get();
            a.setName(article.getName());
            a.setDescription(article.getDescription());
            a.setPurchasePrice(article.getPurchasePrice());
            a.setSellingPrice(article.getSellingPrice());
            a.setMinStock(article.getMinStock());
            a.setMaxStock(article.getMaxStock());
            a.setTracked(article.getTracked());
            a.setUpdatedBy(currentUsername);
            Article updated = articleRepository.save(a);
            auditService.logAction("Article", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public void deactivateArticle(Long id, String currentUsername) {
        Optional<Article> article = articleRepository.findById(id);
        if (article.isPresent()) {
            Article a = article.get();
            a.setActive(false);
            a.setUpdatedBy(currentUsername);
            articleRepository.save(a);
            auditService.logAction("Article", a.getId(), "DEACTIVATE", currentUsername);
        }
    }
}
