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

@Service
@Transactional
public class StockService {
    @Autowired
    private StockLevelRepository stockLevelRepository;

    @Autowired
    private StockMovementRepository stockMovementRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuditService auditService;

    public void recordStockMovement(Warehouse warehouse, Article article, String type, Long quantity,
                                   String location, String batchNumber, String serialNumber,
                                   String reference, String currentUsername) {
        User user = userRepository.findByLogin(currentUsername)
            .orElseThrow(() -> new IllegalArgumentException("User not found: " + currentUsername));

        StockMovement movement = StockMovement.builder()
            .warehouse(warehouse)
            .article(article)
            .type(type)
            .quantity(quantity.intValue())
            .unitCost(article.getPrixUnitaire())
            .totalCost(article.getPrixUnitaire().multiply(new BigDecimal(quantity)))
            .location(location)
            .batchNumber(batchNumber)
            .serialNumber(serialNumber)
            .reference(reference)
            .referenceType(type)
            .movementDate(LocalDateTime.now())
            .creator(user)
            .createdAt(LocalDateTime.now())
            .build();

        StockMovement saved = stockMovementRepository.save(movement);
        updateStockLevel(warehouse, article, quantity);
        auditService.logAction("StockMovement", saved.getId(), "CREATE", currentUsername);
    }

    private void updateStockLevel(Warehouse warehouse, Article article, Long quantityChange) {
        Optional<StockLevel> level = stockLevelRepository.findByEntrepot_IdAndArticle_Id(
            warehouse.getId(), article.getId());

        StockLevel sl;
        if (level.isPresent()) {
            sl = level.get();
            sl.setQuantiteActuelle(sl.getQuantiteActuelle() + quantityChange);
        } else {
            sl = StockLevel.builder()
                .entrepot(warehouse)
                .article(article)
                .quantiteActuelle(quantityChange)
                .quantiteReservee(0L)
                .quantiteDisponible(quantityChange)
                .valeurTotale(article.getPrixUnitaire().multiply(new BigDecimal(quantityChange)))
                .coutMoyen(article.getPrixUnitaire())
                .build();
        }

        sl.setQuantiteDisponible(sl.getQuantiteActuelle() - sl.getQuantiteReservee());
        sl.setValeurTotale(sl.getCoutMoyen().multiply(new BigDecimal(sl.getQuantiteActuelle())));
        stockLevelRepository.save(sl);
    }

    public Long getAvailableQuantity(Long warehouseId, Long articleId) {
        Optional<StockLevel> level = stockLevelRepository.findByEntrepot_IdAndArticle_Id(warehouseId, articleId);
        return level.map(StockLevel::getQuantiteDisponible).orElse(0L);
    }

    public Long getTotalQuantity(Long warehouseId, Long articleId) {
        Optional<StockLevel> level = stockLevelRepository.findByEntrepot_IdAndArticle_Id(warehouseId, articleId);
        return level.map(StockLevel::getQuantiteActuelle).orElse(0L);
    }

    public List<StockLevel> getWarehouseStock(Long warehouseId) {
        return stockLevelRepository.findByEntrepot_Id(warehouseId);
    }

    public BigDecimal getWarehouseStockValue(Long warehouseId) {
        List<StockLevel> levels = stockLevelRepository.findByEntrepot_Id(warehouseId);
        return levels.stream()
            .map(StockLevel::getValeurTotale)
            .filter(val -> val != null)
            .reduce(BigDecimal.ZERO, BigDecimal::add);
    }

    public List<StockMovement> getArticleHistory(Long articleId) {
        return stockMovementRepository.findByArticleIdOrderByMovementDateAsc(articleId);
    }
}
