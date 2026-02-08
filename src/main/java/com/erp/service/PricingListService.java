package com.erp.service;

import com.erp.domain.PricingList;
import com.erp.domain.PricingListLine;
import com.erp.domain.Article;
import com.erp.repository.PricingListRepository;
import com.erp.repository.PricingListLineRepository;
import com.erp.repository.ArticleRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class PricingListService {
    
    @Autowired
    private PricingListRepository pricingListRepository;

    @Autowired
    private PricingListLineRepository pricingListLineRepository;

    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private AuditService auditService;

    public PricingList createPricingList(PricingList pricingList, String currentUsername) {
        if (pricingList.getCode() == null || pricingList.getCode().trim().isEmpty()) {
            throw new IllegalArgumentException("Code must not be empty");
        }
        if (pricingListRepository.findByCode(pricingList.getCode()).isPresent()) {
            throw new IllegalArgumentException("Code already exists");
        }
        
        // Only one default pricing list per type
        if (Boolean.TRUE.equals(pricingList.getParDefaut())) {
            Optional<PricingList> existing = pricingListRepository.findByTypeListeAndParDefautTrue(pricingList.getTypeListe());
            if (existing.isPresent()) {
                throw new IllegalArgumentException("Default pricing list already exists for type: " + pricingList.getTypeListe());
            }
        }
        
        pricingList.setDateCreation(LocalDateTime.now());
        pricingList.setUtilisateurCreation(currentUsername);
        PricingList saved = pricingListRepository.save(pricingList);
        auditService.logAction("PricingList", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public PricingList updatePricingList(PricingList pricingList, String currentUsername) {
        Optional<PricingList> existing = pricingListRepository.findById(pricingList.getId());
        if (existing.isPresent()) {
            PricingList pl = existing.get();
            // Do NOT update code (it's unique and immutable once created)
            pl.setLibelle(pricingList.getLibelle());
            pl.setDescription(pricingList.getDescription());
            pl.setActif(pricingList.getActif());
            pl.setDateDebut(pricingList.getDateDebut());
            pl.setDateFin(pricingList.getDateFin());
            pl.setDevise(pricingList.getDevise());
            pl.setTypeListe(pricingList.getTypeListe());
            
            // Handle default flag - check against the NEW type
            String typeToCheck = pricingList.getTypeListe();
            
            if (Boolean.TRUE.equals(pricingList.getParDefaut())) {
                // If we're setting this as default, unset any other default for this type
                Optional<PricingList> other = pricingListRepository.findByTypeListeAndParDefautTrue(typeToCheck);
                if (other.isPresent() && !other.get().getId().equals(pl.getId())) {
                    PricingList otherList = other.get();
                    otherList.setParDefaut(false);
                    pricingListRepository.save(otherList);
                }
                pl.setParDefaut(true);
            } else {
                pl.setParDefaut(false);
            }
            
            pl.setUtilisateurModification(currentUsername);
            PricingList updated = pricingListRepository.save(pl);
            auditService.logAction("PricingList", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public Optional<PricingList> findById(Long id) {
        return pricingListRepository.findById(id);
    }

    public Optional<PricingList> findByCode(String code) {
        return pricingListRepository.findByCode(code);
    }

    public List<PricingList> findAll() {
        return pricingListRepository.findAll();
    }

    public List<PricingList> findByType(String typeListe) {
        return pricingListRepository.findByTypeListe(typeListe);
    }

    public Optional<PricingList> findDefaultByType(String typeListe) {
        return pricingListRepository.findByTypeListeAndParDefautTrue(typeListe);
    }

    public void deletePricingList(Long id, String currentUsername) {
        if (pricingListRepository.existsById(id)) {
            pricingListRepository.deleteById(id);
            auditService.logAction("PricingList", id, "DELETE", currentUsername);
        }
    }

    // ===== PricingListLine Methods =====
    
    public PricingListLine addLineItem(Long pricingListId, Long articleId, PricingListLine line, String currentUsername) {
        PricingList pricingList = pricingListRepository.findById(pricingListId)
            .orElseThrow(() -> new IllegalArgumentException("Pricing list not found"));
        Article article = articleRepository.findById(articleId)
            .orElseThrow(() -> new IllegalArgumentException("Article not found"));
        
        line.setPricingList(pricingList);
        line.setArticle(article);
        line.setDateCreation(LocalDateTime.now());
        
        PricingListLine saved = pricingListLineRepository.save(line);
        auditService.logAction("PricingListLine", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public PricingListLine updateLineItem(Long lineId, PricingListLine lineData, String currentUsername) {
        Optional<PricingListLine> existing = pricingListLineRepository.findById(lineId);
        if (existing.isPresent()) {
            PricingListLine line = existing.get();
            line.setPrixUnitaire(lineData.getPrixUnitaire());
            line.setRemisePourcentage(lineData.getRemisePourcentage());
            line.setRemarque(lineData.getRemarque());
            line.setActif(lineData.getActif());
            line.setDateModification(LocalDateTime.now());
            
            PricingListLine updated = pricingListLineRepository.save(line);
            auditService.logAction("PricingListLine", updated.getId(), "UPDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public List<PricingListLine> getLines(Long pricingListId) {
        return pricingListLineRepository.findByPricingListId(pricingListId);
    }

    public List<PricingListLine> getActiveLines(Long pricingListId) {
        return pricingListLineRepository.findByPricingListIdAndActifTrue(pricingListId);
    }

    public void deleteLine(Long lineId, String currentUsername) {
        if (pricingListLineRepository.existsById(lineId)) {
            pricingListLineRepository.deleteById(lineId);
            auditService.logAction("PricingListLine", lineId, "DELETE", currentUsername);
        }
    }
}
