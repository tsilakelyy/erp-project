package com.erp.service;

import com.erp.domain.*;
import com.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service("erpStockService")
@Transactional
public class StockService {
    @Autowired
    private StockLevelRepository stockLevelRepository;

    @Autowired
    private StockMovementRepository stockMovementRepository;

    @Autowired
    private AuditService auditService;

    public void recordStockMovement(Warehouse warehouse, Article article, String type, int quantity,
                                   String location, String batchNumber, String serialNumber,
                                   String reference, String currentUsername) {
        // ⚠️ NULL CHECKS to prevent NPE
        if (warehouse == null || article == null || warehouse.getId() == null || article.getId() == null) {
            throw new IllegalArgumentException("Warehouse and Article must not be null and have IDs");
        }

        StockMovement movement = StockMovement.builder()
            .entrepotId(warehouse.getId())
            .article(article)
            .type(type)
            .quantity(quantity)
            .unitCost(article.getPrixUnitaire())
            .totalCost(article.getPrixUnitaire() != null 
                ? article.getPrixUnitaire().multiply(new BigDecimal(quantity))
                : BigDecimal.ZERO)
            .userName(currentUsername)
            .motif(reference)
            .reference(reference)
            .movementDate(LocalDateTime.now())
            .build();

        StockMovement saved = stockMovementRepository.save(movement);
        updateStockLevel(warehouse, article, (long) quantity);
        auditService.logAction("StockMovement", saved.getId(), "CREATE", currentUsername);
    }

    private void updateStockLevel(Warehouse warehouse, Article article, Long quantityChange) {
        // ⚠️ NULL CHECKS to prevent NPE
        if (warehouse == null || article == null || warehouse.getId() == null || article.getId() == null) {
            return;
        }

        Optional<StockLevel> level = stockLevelRepository.findByEntrepot_IdAndArticle_Id(
            warehouse.getId(), article.getId());

        StockLevel sl;
        if (level.isPresent()) {
            sl = level.get();
            if (sl.getQuantiteActuelle() != null) {
                sl.setQuantiteActuelle(sl.getQuantiteActuelle() + quantityChange);
            } else {
                sl.setQuantiteActuelle(quantityChange);
            }
        } else {
            sl = StockLevel.builder()
                .entrepot(warehouse)
                .article(article)
                .quantiteActuelle(quantityChange)
                .quantiteReservee(0L)
                .quantiteDisponible(quantityChange)
                .valeurTotale(article.getPrixUnitaire() != null 
                    ? article.getPrixUnitaire().multiply(new BigDecimal(quantityChange))
                    : BigDecimal.ZERO)
                .coutMoyen(article.getPrixUnitaire() != null ? article.getPrixUnitaire() : BigDecimal.ZERO)
                .build();
        }

        if (sl.getQuantiteActuelle() != null && sl.getQuantiteReservee() != null) {
            sl.setQuantiteDisponible(sl.getQuantiteActuelle() - sl.getQuantiteReservee());
        }
        
        if (sl.getCoutMoyen() != null && sl.getQuantiteActuelle() != null) {
            sl.setValeurTotale(sl.getCoutMoyen().multiply(new BigDecimal(sl.getQuantiteActuelle())));
        }
        
        stockLevelRepository.save(sl);
    }

    public int getAvailableQuantity(Long warehouseId, Long articleId) {
        Optional<StockLevel> level = stockLevelRepository.findByEntrepot_IdAndArticle_Id(warehouseId, articleId);
        return level.map(sl -> sl.getQuantiteDisponible().intValue()).orElse(0);
    }

    public Long getTotalQuantity(Long warehouseId, Long articleId) {
        Optional<StockLevel> level = stockLevelRepository.findByEntrepot_IdAndArticle_Id(warehouseId, articleId);
        return level.map(StockLevel::getQuantiteActuelle).orElse(0L);
    }

    public List<StockLevel> getWarehouseStock(Long warehouseId) {
        return stockLevelRepository.findByEntrepotIdWithDetails(warehouseId);
    }

    public BigDecimal getWarehouseStockValue(Long warehouseId) {
        List<StockLevel> levels = stockLevelRepository.findByEntrepot_Id(warehouseId);
        return levels.stream()
            .map(StockLevel::getValeurTotale)
            .filter(val -> val != null)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public List<StockMovement> getArticleHistory(Long articleId) {
        return stockMovementRepository.findArticleMovementHistory(articleId);
    }

    public List<StockLevel> getAllStockLevels() {
        return stockLevelRepository.findAll();
    }

    public List<StockLevel> getAllStockLevelsWithDetails() {
        return stockLevelRepository.findAllWithDetails();
    }
}
