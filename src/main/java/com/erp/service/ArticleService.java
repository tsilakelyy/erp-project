package com.erp.service;

import com.erp.domain.Article;
import com.erp.domain.Category;
import com.erp.domain.PricingListLine;
import com.erp.dto.ArticleWithDetailsDTO;
import com.erp.repository.ArticleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@Transactional
public class ArticleService {
    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private AuditService auditService;

    @Autowired
    private PricingService pricingService;

    public Optional<Article> findById(Long id) {
        // Charger l'article avec sa catégorie pour assurer la liaison
        return articleRepository.findByIdWithCategory(id);
    }

    public Optional<Article> findByCode(String code) {
        return articleRepository.findByCode(code);
    }

    public List<Article> findAll() {
        // Charger tous les articles avec leurs catégories
        return articleRepository.findAllWithCategory();
    }

    public List<Article> findAllActive() {
        // Charger les articles actifs avec leurs catégories
        return articleRepository.findAllActiveWithCategory();
    }

    public List<Article> findByCategory(Category category) {
        if (category == null) {
            return List.of();
        }
        return articleRepository.findByCategory(category);
    }
    
    /**
     * Récupère tous les articles actifs avec leurs catégories ET leurs prix
     * Assure que Article + Catégorie + Prix sont TOUJOURS liés
     */
    public List<ArticleWithDetailsDTO> findAllActiveWithDetails() {
        List<Article> articles = findAllActive();
        return articles.stream()
            .map(this::enrichArticleWithDetails)
            .collect(Collectors.toList());
    }
    
    /**
     * Récupère un article par ID avec ses catégories ET ses prix
     */
    public Optional<ArticleWithDetailsDTO> findByIdWithDetails(Long id) {
        return findById(id).map(this::enrichArticleWithDetails);
    }
    
    /**
     * Enrichit un article avec ses détails (catégorie + prix)
     */
    private ArticleWithDetailsDTO enrichArticleWithDetails(Article article) {
        ArticleWithDetailsDTO dto = ArticleWithDetailsDTO.builder()
            .id(article.getId())
            .code(article.getCode())
            .libelle(article.getLibelle())
            .description(article.getDescription())
            .uniteMesure(article.getUniteMesure())
            .prixUnitaire(article.getPrixUnitaire())
            .tauxTva(article.getTauxTva())
            .quantiteMinimale(article.getQuantiteMinimale())
            .quantiteMaximale(article.getQuantiteMaximale())
            .actif(article.getActif())
            .build();
        
        // Ajouter les détails de la catégorie
        if (article.getCategory() != null) {
            dto.setCategoryId(article.getCategory().getId());
            dto.setCategoryCode(article.getCategory().getCode());
            dto.setCategoryLibelle(article.getCategory().getLibelle());
            dto.setCategoryDescription(article.getCategory().getDescription());
        }
        
        // Ajouter les prix de vente
        Optional<PricingListLine> ventePricing = pricingService.getPricingForArticle(article, "VENTE");
        if (ventePricing.isPresent()) {
            PricingListLine vente = ventePricing.get();
            dto.setPrixVente(vente.getPrixUnitaire());
            dto.setRemiseVente(vente.getRemisePourcentage());
            dto.setPrixNetVente(vente.getPrixNet());
        } else {
            dto.setPrixVente(article.getPrixUnitaire());
        }
        
        // Ajouter les prix d'achat
        Optional<PricingListLine> achatPricing = pricingService.getPricingForArticle(article, "ACHAT");
        if (achatPricing.isPresent()) {
            PricingListLine achat = achatPricing.get();
            dto.setPrixAchat(achat.getPrixUnitaire());
            dto.setRemiseAchat(achat.getRemisePourcentage());
            dto.setPrixNetAchat(achat.getPrixNet());
        } else {
            dto.setPrixAchat(article.getPrixUnitaire());
        }
        
        return dto;
    }

    public Article createArticle(Article article, String currentUsername) {
        if (articleRepository.findByCode(article.getCode()).isPresent()) {
            throw new IllegalArgumentException("Article code already exists: " + article.getCode());
        }
        article.setActif(true);
        article.setDateCreation(LocalDateTime.now());
        article.setUtilisateurCreation(currentUsername);
        Article saved = articleRepository.save(article);
        auditService.logAction("Article", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Article updateArticle(Article article, String currentUsername) {
        Optional<Article> existing = articleRepository.findById(article.getId());
        if (existing.isPresent()) {
            Article a = existing.get();
            a.setLibelle(article.getLibelle());
            a.setDescription(article.getDescription());
            a.setPrixUnitaire(article.getPrixUnitaire());
            a.setQuantiteMinimale(article.getQuantiteMinimale());
            a.setQuantiteMaximale(article.getQuantiteMaximale());
            a.setCategory(article.getCategory());
            a.setTauxTva(article.getTauxTva());
            a.setUniteMesure(article.getUniteMesure());
            a.setActif(article.getActif());
            a.setDateModification(LocalDateTime.now());
            a.setUtilisateurModification(currentUsername);
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
            a.setActif(false);
            a.setDateModification(LocalDateTime.now());
            a.setUtilisateurModification(currentUsername);
            articleRepository.save(a);
            auditService.logAction("Article", a.getId(), "DEACTIVATE", currentUsername);
        }
    }
}