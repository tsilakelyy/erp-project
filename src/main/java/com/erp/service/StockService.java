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

    public void recordStockMovement(Warehouse warehouse, Article article, String type, Integer quantity,
                                   String location, String batchNumber, String serialNumber,
                                   String reference, String currentUsername) {
        Optional<User> user = userRepository.findByLogin(currentUsername);
        if (!user.isPresent()) {
            throw new IllegalArgumentException("User not found: " + currentUsername);
        }

        StockMovement movement = StockMovement.builder()
            .warehouse(warehouse)
            .article(article)
            .type(type)
            .quantity(quantity)
            .unitCost(article.getPurchasePrice())
            .totalCost(article.getPurchasePrice().multiply(new BigDecimal(quantity)))
            .location(location)
            .batchNumber(batchNumber)
            .serialNumber(serialNumber)
            .reference(reference)
            .referenceType(type)
            .movementDate(LocalDateTime.now())
            .creator(user.get())
            .createdAt(LocalDateTime.now())
            .build();

        StockMovement saved = stockMovementRepository.save(movement);
        updateStockLevel(warehouse, article, quantity);
        auditService.logAction("StockMovement", saved.getId(), "CREATE", currentUsername);
    }

    private void updateStockLevel(Warehouse warehouse, Article article, Integer quantityChange) {
        Optional<StockLevel> level = stockLevelRepository.findByWarehouseIdAndArticleId(
            warehouse.getId(), article.getId());

        StockLevel sl;
        if (level.isPresent()) {
            sl = level.get();
            sl.setQuantity(sl.getQuantity() + quantityChange);
        } else {
            sl = StockLevel.builder()
                .warehouse(warehouse)
                .article(article)
                .quantity(quantityChange)
                .reserved(0)
                .available(quantityChange)
                .totalValue(article.getPurchasePrice().multiply(new BigDecimal(quantityChange)))
                .averageCost(article.getPurchasePrice())
                .build();
        }

        sl.setAvailable(sl.getQuantity() - sl.getReserved());
        sl.setTotalValue(article.getPurchasePrice().multiply(new BigDecimal(sl.getQuantity())));
        stockLevelRepository.save(sl);
    }

    public int getAvailableQuantity(Long warehouseId, Long articleId) {
        Optional<StockLevel> level = stockLevelRepository.findByWarehouseIdAndArticleId(warehouseId, articleId);
        if (level.isPresent()) {
            return level.get().getAvailable();
        }
        return 0;
    }

    public int getTotalQuantity(Long warehouseId, Long articleId) {
        Optional<StockLevel> level = stockLevelRepository.findByWarehouseIdAndArticleId(warehouseId, articleId);
        if (level.isPresent()) {
            return level.get().getQuantity();
        }
        return 0;
    }

    public List<StockLevel> getWarehouseStock(Long warehouseId) {
        return stockLevelRepository.findByWarehouseId(warehouseId);
    }

    public BigDecimal getWarehouseStockValue(Long warehouseId) {
        List<StockLevel> levels = stockLevelRepository.findByWarehouseId(warehouseId);
        BigDecimal totalValue = BigDecimal.ZERO;
        for (StockLevel level : levels) {
            totalValue = totalValue.add(level.getTotalValue() != null ? level.getTotalValue() : BigDecimal.ZERO);
        }
        return totalValue;
    }

    public List<StockMovement> getArticleHistory(Long articleId) {
        return stockMovementRepository.findByArticleIdOrderByMovementDateAsc(articleId);
    }
}
