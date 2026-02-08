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
    private AuditService auditService;

    public Inventory createInventory(Inventory inventory, String currentUsername) {
        if (inventory.getNumero() == null || inventory.getNumero().trim().isEmpty()) {
            inventory.setNumero(generateNumero());
        }
        inventory.setStatut("EN_COURS");
        inventory.setDateDebut(LocalDateTime.now());
        inventory.setUtilisateurResponsable(currentUsername);
        
        Inventory saved = inventoryRepository.save(inventory);
        auditService.logAction("Inventory", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Inventory completeInventory(Long inventoryId, String currentUsername) {
        Optional<Inventory> inventory = inventoryRepository.findById(inventoryId);
        if (inventory.isPresent()) {
            Inventory inv = inventory.get();
            if (!"EN_COURS".equalsIgnoreCase(inv.getStatut())) {
                throw new IllegalArgumentException("L'inventaire doit etre en cours pour etre cloture");
            }
            inv.setStatut("CLOTURE");
            inv.setDateFin(LocalDateTime.now());
            
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
            if (!"EN_COURS".equalsIgnoreCase(inv.getStatut()) && !"CLOTURE".equalsIgnoreCase(inv.getStatut())) {
                throw new IllegalArgumentException("L'inventaire doit etre en cours ou cloture pour etre valide");
            }
            inv.setStatut("CLOTURE");
            
            Inventory updated = inventoryRepository.save(inv);

            // Apply adjustments
            if (inv.getLines() != null) {
                for (InventoryLine line : inv.getLines()) {
                    if (line.getVariance() != null && line.getVariance() != 0) {
                        applyAdjustment(line, inv, currentUsername);
                    }
                }
            }

            auditService.logAction("Inventory", updated.getId(), "VALIDATE", currentUsername);
            return updated;
        }
        return null;
    }

    private void applyAdjustment(InventoryLine line, Inventory inventory, String currentUsername) {
        // Implementation for stock adjustment based on inventory variance
        // ⚠️ NULL CHECKS for NPE prevention
        if (line == null || inventory == null || inventory.getEntrepotId() == null 
            || line.getArticle() == null) {
            return;
        }

        Optional<StockLevel> optionalLevel = stockLevelRepository.findByEntrepot_IdAndArticle_Id(
            inventory.getEntrepotId(), 
            line.getArticle().getId()
        );
        
        if (optionalLevel.isPresent()) {
            StockLevel level = optionalLevel.get();
            if (level.getQuantiteActuelle() != null && level.getQuantiteReservee() != null 
                && line.getVariance() != null) {
                level.setQuantiteActuelle(level.getQuantiteActuelle() + line.getVariance());
                level.setQuantiteDisponible(level.getQuantiteActuelle() - level.getQuantiteReservee());
                stockLevelRepository.save(level);
            }
        }
    }

    public Optional<Inventory> getInventory(Long id) {
        return inventoryRepository.findById(id);
    }

    public List<Inventory> getInventoriesByStatus(String status) {
        return inventoryRepository.findByStatut(status);
    }

    public List<Inventory> getAllInventories() {
        return inventoryRepository.findAll();
    }

    private String generateNumero() {
        String base = "INV-" + LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String numero = base;
        int suffix = 1;
        while (inventoryRepository.findByNumero(numero).isPresent()) {
            numero = base + "-" + suffix;
            suffix++;
        }
        return numero;
    }
}
