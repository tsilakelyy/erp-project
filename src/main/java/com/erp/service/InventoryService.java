package com.erp.service;

import com.erp.domain.*;
import com.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class InventoryService {
    @Autowired
    private InventoryRepository inventoryRepository;

    @Autowired
    private StockLevelRepository stockLevelRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuditService auditService;

    public Inventory createInventory(Inventory inventory, String currentUsername) {
        inventory.setStatus("DRAFT");
        inventory.setInventoryDate(LocalDateTime.now());
        Optional<User> creator = userRepository.findByLogin(currentUsername);
        if (creator.isPresent()) {
            inventory.setCreator(creator.get());
        }
        inventory.setCreatedByUser(currentUsername);
        Inventory saved = inventoryRepository.save(inventory);
        auditService.logAction("Inventory", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Inventory completeInventory(Long inventoryId, String currentUsername) {
        Optional<Inventory> inventory = inventoryRepository.findById(inventoryId);
        if (inventory.isPresent()) {
            Inventory inv = inventory.get();
            if (!"DRAFT".equals(inv.getStatus())) {
                throw new IllegalArgumentException("Inventory must be in DRAFT status to complete");
            }
            inv.setStatus("COMPLETED");
            inv.setCompletionDate(LocalDateTime.now());
            inv.setUpdatedByUser(currentUsername);
            Inventory updated = inventoryRepository.save(inv);
            auditService.logAction("Inventory", updated.getId(), "COMPLETE", currentUsername);
            return updated;
        }
        return null;
    }

    public Inventory validateInventory(Long inventoryId, String currentUsername) {
        Optional<Inventory> inventory = inventoryRepository.findById(inventoryId);
        if (inventory.isPresent()) {
            Inventory inv = inventory.get();
            if (!"COMPLETED".equals(inv.getStatus())) {
                throw new IllegalArgumentException("Inventory must be in COMPLETED status to validate");
            }
            inv.setStatus("VALIDATED");
            inv.setValidationDate(LocalDateTime.now());
            Optional<User> validator = userRepository.findByLogin(currentUsername);
            if (validator.isPresent()) {
                inv.setValidator(validator.get());
            }
            inv.setUpdatedByUser(currentUsername);
            Inventory updated = inventoryRepository.save(inv);

            // Apply adjustments
            for (InventoryLine line : inv.getLines()) {
                if (line.getVariance() != 0) {
                    applyAdjustment(line, currentUsername);
                }
            }

            auditService.logAction("Inventory", updated.getId(), "VALIDATE", currentUsername);
            return updated;
        }
        return null;
    }

    private void applyAdjustment(InventoryLine line, String currentUsername) {
        // Implementation for stock adjustment based on inventory variance
        Optional<StockLevel> optionalLevel = stockLevelRepository.findByWarehouseIdAndArticleId(
            line.getInventory().getWarehouse().getId(), 
            line.getArticle().getId()
        );
        
        if (optionalLevel.isPresent()) {
            StockLevel level = optionalLevel.get();
            level.setQuantity(level.getQuantity() + line.getVariance());
            level.setAvailable(level.getQuantity() - level.getReserved());
            stockLevelRepository.save(level);
        }
    }

    public Optional<Inventory> getInventory(Long id) {
        return inventoryRepository.findById(id);
    }

    public List<Inventory> getInventoriesByStatus(String status) {
        return inventoryRepository.findByStatus(status);
    }

    public List<Inventory> getInventoriesByWarehouse(Long warehouseId) {
        return inventoryRepository.findByWarehouseIdAndStatusOrderByCreatedAtDesc(warehouseId, "VALIDATED");
    }
}
