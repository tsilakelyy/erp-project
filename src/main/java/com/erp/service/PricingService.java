package com.erp.service;

import com.erp.domain.Article;
import com.erp.domain.PricingList;
import com.erp.domain.PricingListLine;
import com.erp.repository.PricingListLineRepository;
import com.erp.repository.PricingListRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;

/**
 * Service pour gérer les prix des articles
 * Assure que Article + Catégorie + Prix sont TOUJOURS liés
 */
@Service
@Transactional
public class PricingService {

    @Autowired
    private PricingListRepository pricingListRepository;

    @Autowired
    private PricingListLineRepository pricingListLineRepository;

    /**
     * Récupère la liste de prix par défaut pour un type donné (VENTE, ACHAT, GENERAL)
     */
    public Optional<PricingList> getDefaultPricingList(String type) {
        return pricingListRepository.findByTypeListeAndParDefautTrue(type);
    }

    /**
     * Récupère le prix d'un article pour un type de liste donné
     */
    public Optional<PricingListLine> getPricingForArticle(Article article, String type) {
        if (article == null || article.getId() == null) {
            return Optional.empty();
        }
        
        Optional<PricingList> list = getDefaultPricingList(type);
        if (list.isEmpty()) {
            return Optional.empty();
        }
        
        return pricingListLineRepository.findByPricingListIdAndArticleId(list.get().getId(), article.getId());
    }

    /**
     * Récupère tous les prix d'un article
     */
    public List<PricingListLine> getAllPricingsForArticle(Article article) {
        if (article == null || article.getId() == null) {
            return List.of();
        }
        return pricingListLineRepository.findByArticleId(article.getId());
    }

    /**
     * Récupère le prix unitaire d'un article pour un type donné
     */
    public BigDecimal getPriceForType(Article article, String type) {
        Optional<PricingListLine> pricing = getPricingForArticle(article, type);
        if (pricing.isPresent()) {
            return pricing.get().getPrixUnitaire();
        }
        // Fallback : utiliser le prix dans l'article lui-même
        return article.getPrixUnitaire() != null ? article.getPrixUnitaire() : BigDecimal.ZERO;
    }

    /**
     * Calcule le prix net (prix unitaire - remise) pour un article
     */
    public BigDecimal getNetPriceForType(Article article, String type) {
        Optional<PricingListLine> pricing = getPricingForArticle(article, type);
        if (pricing.isPresent()) {
            return pricing.get().getPrixNet();
        }
        return getPriceForType(article, type);
    }
}
