package com.erp.service;

import com.erp.domain.Supplier;
import com.erp.repository.SupplierRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class SupplierService {
    @Autowired
    private SupplierRepository supplierRepository;

    @Autowired
    private AuditService auditService;

    public Optional<Supplier> findById(Long id) {
        return supplierRepository.findById(id);
    }

    public Optional<Supplier> findByCode(String code) {
        return supplierRepository.findByCode(code);
    }

    public List<Supplier> findAll() {
        return supplierRepository.findAll();
    }

    public List<Supplier> findAllActive() {
        return supplierRepository.findByActifTrue();
    }

    public Supplier createSupplier(Supplier supplier, String currentUsername) {
        if (supplierRepository.findByCode(supplier.getCode()).isPresent()) {
            throw new IllegalArgumentException("Supplier code already exists: " + supplier.getCode());
        }
        supplier.setActif(true);
        supplier.setDateCreation(LocalDateTime.now());
        supplier.setUtilisateurCreation(currentUsername);
        Supplier saved = supplierRepository.save(supplier);
        auditService.logAction("Supplier", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Supplier updateSupplier(Supplier supplier, String currentUsername) {
        Optional<Supplier> existing = supplierRepository.findById(supplier.getId());
        if (existing.isPresent()) {
            Supplier s = existing.get();
            s.setNomEntreprise(supplier.getNomEntreprise());
            s.setAdresse(supplier.getAdresse());
            s.setVille(supplier.getVille());
            s.setCodePostal(supplier.getCodePostal());
            s.setTelephone(supplier.getTelephone());
            s.setEmail(supplier.getEmail());
            s.setContactPrincipal(supplier.getContactPrincipal());
            s.setDelaiLivraisonMoyen(supplier.getDelaiLivraisonMoyen());
            s.setDateModification(LocalDateTime.now());
            s.setUtilisateurModification(currentUsername);
            Supplier updated = supplierRepository.save(s);
            auditService.logAction("Supplier", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public void deactivateSupplier(Long id, String currentUsername) {
        Optional<Supplier> supplier = supplierRepository.findById(id);
        if (supplier.isPresent()) {
            Supplier s = supplier.get();
            s.setActif(false);
            s.setDateModification(LocalDateTime.now());
            s.setUtilisateurModification(currentUsername);
            supplierRepository.save(s);
            auditService.logAction("Supplier", s.getId(), "DEACTIVATE", currentUsername);
        }
    }
}