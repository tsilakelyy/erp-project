package com.erp.controller;

import com.erp.domain.Warehouse;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/warehouses")
public class WarehouseApiController {

    @Autowired
    private WarehouseRepository warehouseRepository;

    @GetMapping
    public ResponseEntity<List<Warehouse>> getAllWarehouses() {
        return ResponseEntity.ok(warehouseRepository.findAll());
    }

    @GetMapping("/{id}")
    public ResponseEntity<Warehouse> getWarehouseById(@PathVariable Long id) {
        Optional<Warehouse> warehouse = warehouseRepository.findById(id);
        return warehouse.map(ResponseEntity::ok)
            .orElseGet(() -> ResponseEntity.notFound().build());
    }

    @PostMapping
    public ResponseEntity<?> createWarehouse(@RequestBody Warehouse warehouse, Authentication auth, HttpSession session) {
        try {
            String username = ControllerHelper.resolveUsername(null, session, auth);

            String code = warehouse.getCode() != null ? warehouse.getCode().trim() : "";
            String nomDepot = warehouse.getNomDepot() != null ? warehouse.getNomDepot().trim() : "";

            if (code.isEmpty()) {
                return ResponseEntity.badRequest().body(error("Le code est obligatoire"));
            }
            if (nomDepot.isEmpty()) {
                return ResponseEntity.badRequest().body(error("Le nom est obligatoire"));
            }

            if (warehouseRepository.findByCode(code).isPresent()) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(error("Un entrepot avec ce code existe deja"));
            }

            warehouse.setId(null);
            warehouse.setCode(code.toUpperCase(Locale.ROOT));
            warehouse.setNomDepot(nomDepot);
            if (warehouse.getActif() == null) {
                warehouse.setActif(true);
            }
            warehouse.setDateCreation(LocalDateTime.now());
            warehouse.setDateModification(LocalDateTime.now());
            warehouse.setUtilisateurCreation(username);
            warehouse.setUtilisateurModification(username);

            Warehouse saved = warehouseRepository.save(warehouse);
            return ResponseEntity.status(HttpStatus.CREATED).body(saved);
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error(humanize(e)));
        }
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> updateWarehouse(@PathVariable Long id, @RequestBody Warehouse warehouse, Authentication auth, HttpSession session) {
        try {
            Optional<Warehouse> existing = warehouseRepository.findById(id);
            if (existing.isPresent()) {
                String username = ControllerHelper.resolveUsername(null, session, auth);

                Warehouse wh = existing.get();
                if (warehouse.getCode() != null && !warehouse.getCode().trim().isEmpty()) {
                    String newCode = warehouse.getCode().trim().toUpperCase(Locale.ROOT);
                    warehouseRepository.findByCode(newCode)
                        .filter(other -> !other.getId().equals(id))
                        .ifPresent(other -> { throw new DataIntegrityViolationException("DUPLICATE_CODE"); });
                    wh.setCode(newCode);
                }
                if (warehouse.getNomDepot() != null && !warehouse.getNomDepot().trim().isEmpty()) {
                    wh.setNomDepot(warehouse.getNomDepot().trim());
                }
                wh.setAdresse(warehouse.getAdresse());
                wh.setTypeDepot(warehouse.getTypeDepot());
                wh.setCapaciteMaximale(warehouse.getCapaciteMaximale());
                wh.setDateModification(LocalDateTime.now());
                wh.setUtilisateurModification(username);

                if (warehouse.getActif() != null) {
                    wh.setActif(warehouse.getActif());
                }

                Warehouse updated = warehouseRepository.save(wh);
                return ResponseEntity.ok(updated);
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            if (e instanceof DataIntegrityViolationException && "DUPLICATE_CODE".equals(e.getMessage())) {
                return ResponseEntity.status(HttpStatus.CONFLICT).body(error("Un entrepot avec ce code existe deja"));
            }
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error(humanize(e)));
        }
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> deleteWarehouse(@PathVariable Long id) {
        try {
            if (warehouseRepository.existsById(id)) {
                warehouseRepository.deleteById(id);
                return ResponseEntity.ok().build();
            }
            return ResponseEntity.notFound().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(error(humanize(e)));
        }
    }

    private Map<String, Object> error(String message) {
        Map<String, Object> map = new HashMap<>();
        map.put("message", message != null ? message : "Erreur");
        return map;
    }

    private String humanize(Exception e) {
        if (e == null) return "Erreur serveur";
        String msg = e.getMessage();
        if (msg == null || msg.trim().isEmpty()) return "Erreur serveur";
        return msg;
    }
}
