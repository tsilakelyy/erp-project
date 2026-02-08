package com.erp.service;

import com.erp.domain.Proforma;
import com.erp.domain.ProformaLine;
import com.erp.domain.PurchaseOrder;
import com.erp.domain.PurchaseOrderLine;
import com.erp.domain.PurchaseRequest;
import com.erp.repository.ProformaRepository;
import com.erp.repository.PurchaseOrderRepository;
import com.erp.repository.PurchaseRequestRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@Transactional
public class ProformaService {

    // Seuil "par defaut" pour exiger la Direction en mode AUTO.
    // Peut etre ajuste plus tard via des proprietes.
    private static final BigDecimal DEFAULT_DIRECTION_THRESHOLD = new BigDecimal("1000000");

    @Autowired
    private ProformaRepository proformaRepository;

    @Autowired
    private PurchaseRequestRepository purchaseRequestRepository;

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    private PurchaseService purchaseService;

    @Autowired
    private AuditService auditService;

    public Proforma create(Proforma proforma, String currentUsername) {
        if (proforma.getDemandeId() != null) {
            PurchaseRequest request = purchaseRequestRepository.findById(proforma.getDemandeId())
                .orElseThrow(() -> new IllegalArgumentException("Demande d'achat introuvable"));

            if (!"APPROUVEE".equalsIgnoreCase(request.getStatut())) {
                throw new IllegalArgumentException("La demande d'achat doit etre approuvee avant la creation d'une proforma");
            }

            if (proforma.getImportance() == null || proforma.getImportance().trim().isEmpty()) {
                proforma.setImportance(request.getImportance());
            }
            if (proforma.getValidationMode() == null || proforma.getValidationMode().trim().isEmpty()) {
                proforma.setValidationMode(request.getValidationMode());
            }
            if (proforma.getEntrepotId() == null) {
                proforma.setEntrepotId(request.getEntrepotId());
            }
        }

        if (proforma.getNumero() == null || proforma.getNumero().trim().isEmpty()) {
            proforma.setNumero(generateNumero("PF"));
        }

        if (proforma.getStatut() == null || proforma.getStatut().trim().isEmpty()) {
            proforma.setStatut("EN_ATTENTE");
        }

        LocalDateTime now = LocalDateTime.now();
        proforma.setDateCreation(now);
        proforma.setDateProforma(proforma.getDateProforma() != null ? proforma.getDateProforma() : now);
        proforma.setDateModification(now);
        proforma.setUtilisateurCreation(currentUsername);
        proforma.setUtilisateurModification(currentUsername);

        // Normalisation
        if (proforma.getImportance() == null || proforma.getImportance().trim().isEmpty()) {
            proforma.setImportance("MOYENNE");
        }
        if (proforma.getValidationMode() == null || proforma.getValidationMode().trim().isEmpty()) {
            proforma.setValidationMode("AUTO");
        }

        // Initialiser les flags de validation selon le mode choisi
        applyValidationRules(proforma);

        calculateTotals(proforma);

        Proforma saved = proformaRepository.save(proforma);
        auditService.logAction("Proforma", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Optional<Proforma> get(Long id) {
        return proformaRepository.findById(id);
    }

    public List<Proforma> findAll() {
        return proformaRepository.findAll();
    }

    public Proforma validateFinance(Long id, String currentUsername) {
        Proforma proforma = proformaRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Proforma introuvable"));

        proforma.setValideFinance(true);
        proforma.setDateValidationFinance(LocalDateTime.now());
        proforma.setUtilisateurValidationFinance(currentUsername);

        finalizeIfApproved(proforma, currentUsername, "VALIDATE_FINANCE");
        return proforma;
    }

    public Proforma validateDirection(Long id, String currentUsername) {
        Proforma proforma = proformaRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Proforma introuvable"));

        proforma.setValideDirection(true);
        proforma.setDateValidationDirection(LocalDateTime.now());
        proforma.setUtilisateurValidationDirection(currentUsername);

        finalizeIfApproved(proforma, currentUsername, "VALIDATE_DIRECTION");
        return proforma;
    }

    public Proforma reject(Long id, String motif, String currentUsername) {
        Proforma proforma = proformaRepository.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Proforma introuvable"));

        proforma.setStatut("REJETEE");
        proforma.setMotifRejet(motif);
        proforma.setDateModification(LocalDateTime.now());
        proforma.setUtilisateurModification(currentUsername);

        Proforma updated = proformaRepository.save(proforma);
        auditService.logAction("Proforma", updated.getId(), "REJECT", currentUsername);
        return updated;
    }

    public PurchaseOrder transformToPurchaseOrder(Long proformaId, String currentUsername) {
        Proforma proforma = proformaRepository.findById(proformaId)
            .orElseThrow(() -> new IllegalArgumentException("Proforma introuvable"));

        if (!"VALIDEE".equalsIgnoreCase(proforma.getStatut()) && !"APPROUVEE".equalsIgnoreCase(proforma.getStatut())) {
            throw new IllegalArgumentException("La proforma doit etre validee pour creer un bon de commande");
        }

        PurchaseOrder order = new PurchaseOrder();
        order.setProformaId(proforma.getId());
        order.setFournisseurId(proforma.getFournisseurId());
        order.setEntrepotId(proforma.getEntrepotId());
        order.setMontantHt(proforma.getMontantHt());
        order.setTauxTva(proforma.getTauxTva());

        // Copier les lignes si elles existent.
        if (proforma.getLines() != null) {
            for (ProformaLine pl : proforma.getLines()) {
                if (pl.getArticle() == null) continue;
                PurchaseOrderLine line = new PurchaseOrderLine();
                line.setPurchaseOrder(order);
                line.setArticle(pl.getArticle());
                line.setQuantite(pl.getQuantite() != null ? pl.getQuantite() : 0);
                line.setPrixUnitaire(pl.getPrixUnitaire());
                line.setMontant(pl.getMontant());
                order.getLines().add(line);
            }
        }

        PurchaseOrder saved = purchaseService.createPurchaseOrder(order, currentUsername);
        // Le bon de commande conserve son cycle de validation (soumission puis approbation).

        proforma.setStatut("TRANSFORMEE_BC");
        proforma.setDateModification(LocalDateTime.now());
        proforma.setUtilisateurModification(currentUsername);
        proformaRepository.save(proforma);
        auditService.logAction("Proforma", proforma.getId(), "TO_PURCHASE_ORDER", currentUsername);

        return saved;
    }

    private void finalizeIfApproved(Proforma proforma, String currentUsername, String auditAction) {
        boolean financeRequired = Boolean.TRUE.equals(proforma.getValidationFinanceRequise());
        boolean directionRequired = Boolean.TRUE.equals(proforma.getValidationDirectionRequise());
        boolean financeOk = !financeRequired || Boolean.TRUE.equals(proforma.getValideFinance());
        boolean directionOk = !directionRequired || Boolean.TRUE.equals(proforma.getValideDirection());

        if (financeOk && directionOk) {
            enforceCheapestProforma(proforma);
            proforma.setStatut("VALIDEE");
        } else {
            proforma.setStatut("EN_ATTENTE");
        }

        proforma.setDateModification(LocalDateTime.now());
        proforma.setUtilisateurModification(currentUsername);
        Proforma updated = proformaRepository.save(proforma);
        auditService.logAction("Proforma", updated.getId(), auditAction, currentUsername);
    }

    private void enforceCheapestProforma(Proforma proforma) {
        if (proforma.getDemandeId() == null) return;
        List<Proforma> candidates = proformaRepository.findByDemandeId(proforma.getDemandeId());
        if (candidates == null || candidates.isEmpty()) return;

        BigDecimal current = proforma.getMontantTtc() != null ? proforma.getMontantTtc() : proforma.getMontantHt();
        if (current == null) current = BigDecimal.ZERO;

        BigDecimal min = null;
        for (Proforma pf : candidates) {
            if (pf.getId() != null && pf.getId().equals(proforma.getId())) continue;
            BigDecimal amount = pf.getMontantTtc() != null ? pf.getMontantTtc() : pf.getMontantHt();
            if (amount == null) continue;
            if (min == null || amount.compareTo(min) < 0) {
                min = amount;
            }
        }
        if (min != null && current.compareTo(min) > 0) {
            throw new IllegalArgumentException("Une proforma moins chere existe pour cette demande. Selectionnez la proforma la plus avantageuse.");
        }
    }

    private void applyValidationRules(Proforma proforma) {
        // Defaults
        if (proforma.getValideFinance() == null) proforma.setValideFinance(false);
        if (proforma.getValideDirection() == null) proforma.setValideDirection(false);

        String mode = proforma.getValidationMode() != null ? proforma.getValidationMode().trim().toUpperCase(Locale.ROOT) : "AUTO";
        if ("FINANCE".equals(mode)) {
            proforma.setValidationFinanceRequise(true);
            proforma.setValidationDirectionRequise(false);
            return;
        }
        if ("DIRECTION".equals(mode)) {
            proforma.setValidationFinanceRequise(false);
            proforma.setValidationDirectionRequise(true);
            return;
        }
        if ("FINANCE_DIRECTION".equals(mode) || "FINANCE_ET_DIRECTION".equals(mode)) {
            proforma.setValidationFinanceRequise(true);
            proforma.setValidationDirectionRequise(true);
            return;
        }

        // AUTO
        BigDecimal amount = proforma.getMontantTtc();
        if (amount == null) {
            amount = proforma.getMontantHt();
        }
        if (amount == null) {
            amount = BigDecimal.ZERO;
        }

        boolean important = "ELEVEE".equalsIgnoreCase(proforma.getImportance()) || "HAUTE".equalsIgnoreCase(proforma.getImportance());
        boolean requireDirection = important || amount.compareTo(DEFAULT_DIRECTION_THRESHOLD) >= 0;

        proforma.setValidationFinanceRequise(true);
        proforma.setValidationDirectionRequise(requireDirection);
    }

    private void calculateTotals(Proforma proforma) {
        BigDecimal totalHt = BigDecimal.ZERO;
        if (proforma.getLines() != null && !proforma.getLines().isEmpty()) {
            for (ProformaLine line : proforma.getLines()) {
                BigDecimal lineTotal = line.getMontant() != null ? line.getMontant() : BigDecimal.ZERO;
                totalHt = totalHt.add(lineTotal);
            }
        } else if (proforma.getMontantHt() != null) {
            totalHt = proforma.getMontantHt();
        }

        BigDecimal tauxTva = proforma.getTauxTva() != null ? proforma.getTauxTva() : BigDecimal.ZERO;
        BigDecimal tva = totalHt.multiply(tauxTva).divide(BigDecimal.valueOf(100));

        proforma.setMontantHt(totalHt);
        proforma.setMontantTva(tva);
        proforma.setMontantTtc(totalHt.add(tva));
    }

    private String generateNumero(String prefix) {
        String base = prefix + "-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String numero = base;
        int suffix = 1;
        while (proformaRepository.findByNumero(numero).isPresent()
            || purchaseRequestRepository.findByNumero(numero).isPresent()
            || purchaseOrderRepository.findByNumero(numero).isPresent()) {
            numero = base + "-" + suffix;
            suffix++;
        }
        return numero;
    }
}
