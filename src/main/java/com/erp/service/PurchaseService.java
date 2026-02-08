package com.erp.service;

import com.erp.domain.*;
import com.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Locale;
import java.util.Optional;

@Service
@Transactional
public class PurchaseService {
    private static final BigDecimal DEFAULT_DIRECTION_THRESHOLD = new BigDecimal("1000000");

    @Autowired
    private PurchaseRequestRepository purchaseRequestRepository;

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    private ProformaRepository proformaRepository;

    @Autowired
    private GoodReceiptRepository goodReceiptRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private AuditService auditService;

    @Autowired
    @Qualifier("erpStockService")
    private StockService stockService;

    // ===== Purchase Request Management =====
    public PurchaseRequest createPurchaseRequest(PurchaseRequest request, String currentUsername) {
        if (request.getNumero() == null || request.getNumero().trim().isEmpty()) {
            request.setNumero(generateNumero("DA"));
        }
        request.setStatut("EN_ATTENTE");
        request.setDateCreation(LocalDateTime.now());
        request.setUtilisateurCreation(currentUsername);

        if (request.getImportance() == null || request.getImportance().trim().isEmpty()) {
            request.setImportance("MOYENNE");
        }
        if (request.getValidationMode() == null || request.getValidationMode().trim().isEmpty()) {
            request.setValidationMode("AUTO");
        }
        applyRequestValidationRules(request);
        
        PurchaseRequest saved = purchaseRequestRepository.save(request);
        auditService.logAction("PurchaseRequest", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public PurchaseRequest submitPurchaseRequest(Long requestId, String currentUsername) {
        Optional<PurchaseRequest> request = purchaseRequestRepository.findById(requestId);
        if (request.isPresent()) {
            PurchaseRequest pr = request.get();
            String statut = pr.getStatut();
            if (statut != null && "BROUILLON".equalsIgnoreCase(statut)) {
                pr.setStatut("EN_ATTENTE");
            } else if (statut != null && "EN_ATTENTE".equalsIgnoreCase(statut)) {
                // deja en attente
            } else {
                throw new IllegalArgumentException("La demande doit etre en BROUILLON pour etre soumise");
            }
            pr.setDateSubmission(LocalDateTime.now());
            
            PurchaseRequest updated = purchaseRequestRepository.save(pr);
            auditService.logAction("PurchaseRequest", updated.getId(), "SUBMIT", currentUsername);
            return updated;
        }
        return null;
    }

    public PurchaseRequest approvePurchaseRequest(Long requestId, String currentUsername) {
        Optional<PurchaseRequest> request = purchaseRequestRepository.findById(requestId);
        if (request.isPresent()) {
            PurchaseRequest pr = request.get();
            if (!"EN_ATTENTE".equalsIgnoreCase(pr.getStatut())) {
                throw new IllegalArgumentException("La demande doit etre en attente pour etre approuvee");
            }
            // Compatibilite: une approbation "globale" valide Finance + Direction si requis.
            if (Boolean.TRUE.equals(pr.getValidationFinanceRequise())) {
                pr.setValideFinance(true);
                pr.setDateValidationFinance(LocalDateTime.now());
                pr.setUtilisateurValidationFinance(currentUsername);
            }
            if (Boolean.TRUE.equals(pr.getValidationDirectionRequise())) {
                pr.setValideDirection(true);
                pr.setDateValidationDirection(LocalDateTime.now());
                pr.setUtilisateurValidationDirection(currentUsername);
            }
            finalizeRequestIfApproved(pr, currentUsername, "APPROVE");
            
            PurchaseRequest updated = purchaseRequestRepository.save(pr);
            auditService.logAction("PurchaseRequest", updated.getId(), "APPROVE", currentUsername);
            return updated;
        }
        return null;
    }

    public PurchaseRequest validateRequestFinance(Long requestId, String currentUsername) {
        PurchaseRequest pr = purchaseRequestRepository.findById(requestId)
            .orElseThrow(() -> new IllegalArgumentException("Demande introuvable"));

        if (!"EN_ATTENTE".equalsIgnoreCase(pr.getStatut()) && !"EN_COURS".equalsIgnoreCase(pr.getStatut())) {
            throw new IllegalArgumentException("La demande doit etre en attente");
        }

        pr.setValideFinance(true);
        pr.setDateValidationFinance(LocalDateTime.now());
        pr.setUtilisateurValidationFinance(currentUsername);

        finalizeRequestIfApproved(pr, currentUsername, "VALIDATE_FINANCE");
        return purchaseRequestRepository.save(pr);
    }

    public PurchaseRequest validateRequestDirection(Long requestId, String currentUsername) {
        PurchaseRequest pr = purchaseRequestRepository.findById(requestId)
            .orElseThrow(() -> new IllegalArgumentException("Demande introuvable"));

        if (!"EN_ATTENTE".equalsIgnoreCase(pr.getStatut()) && !"EN_COURS".equalsIgnoreCase(pr.getStatut())) {
            throw new IllegalArgumentException("La demande doit etre en attente");
        }

        pr.setValideDirection(true);
        pr.setDateValidationDirection(LocalDateTime.now());
        pr.setUtilisateurValidationDirection(currentUsername);

        finalizeRequestIfApproved(pr, currentUsername, "VALIDATE_DIRECTION");
        return purchaseRequestRepository.save(pr);
    }

    public void rejectPurchaseRequest(Long requestId, String motif, String currentUsername) {
        Optional<PurchaseRequest> request = purchaseRequestRepository.findById(requestId);
        if (request.isPresent()) {
            PurchaseRequest pr = request.get();
            pr.setStatut("REJETEE");
            pr.setMotifRejet(motif);
            purchaseRequestRepository.save(pr);
            auditService.logAction("PurchaseRequest", pr.getId(), "REJECT", currentUsername);
        }
    }

    public void rejectPurchaseRequest(Long requestId, String currentUsername) {
        rejectPurchaseRequest(requestId, null, currentUsername);
    }

    public Optional<PurchaseRequest> getPurchaseRequest(Long id) {
        return purchaseRequestRepository.findById(id);
    }

    public List<PurchaseRequest> getPurchaseRequestsByStatus(String status) {
        return purchaseRequestRepository.findByStatut(status);
    }

    public List<PurchaseRequest> getAllPurchaseRequests() {
        return purchaseRequestRepository.findAll();
    }

    // ===== Purchase Order Management =====
    public PurchaseOrder createPurchaseOrder(PurchaseOrder order, String currentUsername) {
        if (order.getProformaId() == null) {
            throw new IllegalArgumentException("Le bon de commande doit etre cree depuis une proforma validee");
        }

        List<PurchaseOrder> existing = purchaseOrderRepository.findByProformaId(order.getProformaId());
        if (existing != null && !existing.isEmpty()) {
            throw new IllegalArgumentException("Un bon de commande existe deja pour cette proforma");
        }

        Proforma proforma = proformaRepository.findById(order.getProformaId())
            .orElseThrow(() -> new IllegalArgumentException("Proforma introuvable pour la commande"));
        if (!"VALIDEE".equalsIgnoreCase(proforma.getStatut())
            && !"APPROUVEE".equalsIgnoreCase(proforma.getStatut())) {
            throw new IllegalArgumentException("La proforma doit etre validee avant la creation du bon de commande");
        }
        if (order.getFournisseurId() == null) {
            order.setFournisseurId(proforma.getFournisseurId());
        }
        if (order.getEntrepotId() == null) {
            order.setEntrepotId(proforma.getEntrepotId());
        }
        if (order.getMontantHt() == null) {
            order.setMontantHt(proforma.getMontantHt());
        }
        if (order.getTauxTva() == null) {
            order.setTauxTva(proforma.getTauxTva());
        }
        if (order.getNumero() == null || order.getNumero().trim().isEmpty()) {
            order.setNumero(generateNumero("CA"));
        }
        order.setStatut("BROUILLON");
        order.setDateCommande(LocalDateTime.now());
        order.setDateCreation(LocalDateTime.now());
        order.setUtilisateurCreation(currentUsername);
        
        calculateOrderTotals(order);
        PurchaseOrder saved = purchaseOrderRepository.save(order);
        auditService.logAction("PurchaseOrder", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public PurchaseOrder submitPurchaseOrder(Long orderId, String currentUsername) {
        Optional<PurchaseOrder> order = purchaseOrderRepository.findById(orderId);
        if (order.isPresent()) {
            PurchaseOrder po = order.get();
            if (!"BROUILLON".equalsIgnoreCase(po.getStatut())) {
                throw new IllegalArgumentException("La commande doit etre en BROUILLON pour etre soumise");
            }
            po.setStatut("EN_COURS");
            
            PurchaseOrder updated = purchaseOrderRepository.save(po);
            auditService.logAction("PurchaseOrder", updated.getId(), "SUBMIT", currentUsername);
            return updated;
        }
        return null;
    }

    public PurchaseOrder approvePurchaseOrder(Long orderId, String currentUsername) {
        Optional<PurchaseOrder> order = purchaseOrderRepository.findById(orderId);
        if (order.isPresent()) {
            PurchaseOrder po = order.get();
            if (!"EN_COURS".equalsIgnoreCase(po.getStatut())) {
                throw new IllegalArgumentException("La commande doit etre en cours pour etre approuvee");
            }
            po.setStatut("VALIDEE");
            po.setUtilisateurApprobation(currentUsername);
            
            PurchaseOrder updated = purchaseOrderRepository.save(po);
            auditService.logAction("PurchaseOrder", updated.getId(), "APPROVE", currentUsername);
            return updated;
        }
        return null;
    }

    public void cancelPurchaseOrder(Long orderId, String currentUsername) {
        Optional<PurchaseOrder> order = purchaseOrderRepository.findById(orderId);
        if (order.isPresent()) {
            PurchaseOrder po = order.get();
            if ("RECUE".equalsIgnoreCase(po.getStatut()) || "FACTUREE".equalsIgnoreCase(po.getStatut())) {
                throw new IllegalArgumentException("Cannot cancel order with status: " + po.getStatut());
            }
            po.setStatut("ANNULEE");
            purchaseOrderRepository.save(po);
            auditService.logAction("PurchaseOrder", po.getId(), "CANCEL", currentUsername);
        } else {
            throw new IllegalArgumentException("Purchase order not found");
        }

        // Log the cancellation attempt
        auditService.logAction("PurchaseOrder", orderId, "CANCEL_ATTEMPT", currentUsername);
    }

    public Optional<PurchaseOrder> getPurchaseOrder(Long id) {
        return purchaseOrderRepository.findByIdWithLines(id);
    }

    public List<PurchaseOrder> getPurchaseOrdersByStatus(String status) {
        return purchaseOrderRepository.findByStatut(status);
    }

    public List<PurchaseOrder> getAllPurchaseOrders() {
        return purchaseOrderRepository.findAll();
    }

    // ===== Good Receipt Management =====
    public GoodReceipt createGoodReceipt(GoodReceipt receipt, String currentUsername) {
        // Validate purchase order reference
        if (receipt.getCommandeId() == null) {
            throw new IllegalArgumentException("Purchase order is required");
        }
        if (receipt.getNumero() == null || receipt.getNumero().trim().isEmpty()) {
            receipt.setNumero(generateNumero("REC"));
        }
        
        Optional<PurchaseOrder> order = purchaseOrderRepository.findById(receipt.getCommandeId());
        if (order.isPresent() && !"VALIDEE".equalsIgnoreCase(order.get().getStatut())) {
            throw new IllegalArgumentException("La commande doit etre validee pour recevoir les articles");
        }
        
        receipt.setStatut("EN_COURS");
        receipt.setDateReception(LocalDateTime.now());
        receipt.setDateCreation(LocalDateTime.now());
        receipt.setUtilisateurReception(currentUsername);
        
        GoodReceipt saved = goodReceiptRepository.save(receipt);
        auditService.logAction("GoodReceipt", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public GoodReceipt updateGoodReceipt(GoodReceipt receipt, String currentUsername) {
        Optional<GoodReceipt> existing = goodReceiptRepository.findById(receipt.getId());
        if (!existing.isPresent()) {
            throw new IllegalArgumentException("Reception not found with id: " + receipt.getId());
        }
        
        GoodReceipt gr = existing.get();
        // Only allow updates if not yet validated
        if ("VALIDEE".equalsIgnoreCase(gr.getStatut()) || 
            "FACTUREE".equalsIgnoreCase(gr.getStatut()) || 
            "ANNULEE".equalsIgnoreCase(gr.getStatut())) {
            throw new IllegalArgumentException("Cannot update receipt in statut: " + gr.getStatut());
        }
        
        // Update allowed fields
        if (receipt.getNotes() != null) {
            gr.setNotes(receipt.getNotes());
        }
        if (receipt.getCommandeId() != null) {
            gr.setCommandeId(receipt.getCommandeId());
        }
        if (receipt.getEntrepotId() != null) {
            gr.setEntrepotId(receipt.getEntrepotId());
        }
        
        GoodReceipt updated = goodReceiptRepository.save(gr);
        auditService.logAction("GoodReceipt", updated.getId(), "UPDATE", currentUsername);
        return updated;
    }

    public GoodReceipt validateGoodReceipt(Long receiptId, String currentUsername) {
        Optional<GoodReceipt> receipt = goodReceiptRepository.findById(receiptId);
        if (receipt.isPresent()) {
            GoodReceipt gr = receipt.get();
            if (!"EN_COURS".equalsIgnoreCase(gr.getStatut())) {
                throw new IllegalArgumentException("La reception doit etre en cours pour etre validee");
            }
            gr.setStatut("VALIDEE");
            gr.setUtilisateurValidation(currentUsername);
            
            GoodReceipt updated = goodReceiptRepository.save(gr);

            // Create stock movements
            if (gr.getLines() != null && gr.getEntrepotId() != null) {
                Optional<Warehouse> warehouse = warehouseRepository.findById(gr.getEntrepotId());
                if (warehouse.isPresent()) {
                    for (GoodReceiptLine line : gr.getLines()) {
                        // ⚠️ NULL CHECK for article
                        if (line.getArticle() != null) {
                            stockService.recordStockMovement(
                                warehouse.get(),
                                line.getArticle(),
                                "ENTREE",
                                line.getQuantite(),
                                line.getLocation(),
                                line.getBatchNumber(),
                                line.getSerialNumber(),
                                "GR-" + gr.getNumero(),
                                currentUsername
                            );
                        }
                    }
                }
            }

            auditService.logAction("GoodReceipt", updated.getId(), "VALIDATE", currentUsername);

            // Update purchase order status (best-effort)
            if (gr.getCommandeId() != null) {
                purchaseOrderRepository.findById(gr.getCommandeId()).ifPresent(po -> {
                    if (!"FACTUREE".equalsIgnoreCase(po.getStatut())) {
                        po.setStatut("RECUE");
                        purchaseOrderRepository.save(po);
                    }
                });
            }
            return updated;
        }
        return null;
    }

    public void cancelGoodReceipt(Long receiptId, String currentUsername) {
        Optional<GoodReceipt> receipt = goodReceiptRepository.findById(receiptId);
        if (receipt.isPresent()) {
            GoodReceipt gr = receipt.get();
            if ("VALIDEE".equalsIgnoreCase(gr.getStatut())) {
                throw new IllegalArgumentException("Impossible d'annuler une reception deja validee");
            }
            gr.setStatut("ANNULEE");
            goodReceiptRepository.save(gr);
            auditService.logAction("GoodReceipt", gr.getId(), "CANCEL", currentUsername);
        }
    }

    public Invoice generatePurchaseInvoiceFromReceipt(Long receiptId, String currentUsername) {
        GoodReceipt receipt = goodReceiptRepository.findById(receiptId)
            .orElseThrow(() -> new IllegalArgumentException("Reception introuvable"));

        if (!"VALIDEE".equalsIgnoreCase(receipt.getStatut())) {
            throw new IllegalArgumentException("La reception doit etre validee pour generer une facture");
        }

        PurchaseOrder order = null;
        if (receipt.getCommandeId() != null) {
            order = purchaseOrderRepository.findByIdWithLines(receipt.getCommandeId())
                .orElse(null);
        }
        if (order == null) {
            throw new IllegalArgumentException("Commande d'achat introuvable pour cette reception");
        }

        Invoice invoice = new Invoice();
        invoice.setNumero(generateInvoiceNumero("FA"));
        invoice.setStatut("EN_ATTENTE");
        invoice.setTypeFacture("ACHAT");
        invoice.setDateCreation(LocalDateTime.now());
        invoice.setDateFacture(LocalDateTime.now());
        invoice.setTiersId(order.getFournisseurId());
        invoice.setCommandeAchatId(order.getId());
        invoice.setTypeTiers("FOURNISSEUR");
        invoice.setTauxTva(order.getTauxTva());
        invoice.setMontantHt(order.getMontantHt());
        invoice.setMontantTva(order.getMontantTva());
        invoice.setMontantTtc(order.getMontantTtc());

        if (order.getLines() != null) {
            for (PurchaseOrderLine pol : order.getLines()) {
                if (pol.getArticle() == null) continue;
                InvoiceLine il = new InvoiceLine();
                il.setFacture(invoice);
                il.setArticle(pol.getArticle());
                il.setQuantite(pol.getQuantite() != null ? pol.getQuantite() : 0);
                il.setPrixUnitaire(pol.getPrixUnitaire());
                il.setMontant(pol.getMontant());
                invoice.getLines().add(il);
            }
        }

        Invoice saved = invoiceRepository.save(invoice);
        auditService.logAction("Invoice", saved.getId(), "CREATE_PURCHASE_INVOICE", currentUsername);

        // Update order status (best-effort)
        order.setStatut("FACTUREE");
        purchaseOrderRepository.save(order);
        auditService.logAction("PurchaseOrder", order.getId(), "INVOICE", currentUsername);

        return saved;
    }

    public Optional<GoodReceipt> getGoodReceipt(Long id) {
        return goodReceiptRepository.findByIdWithLines(id);
    }

    public List<GoodReceipt> getGoodReceiptsByStatus(String status) {
        return goodReceiptRepository.findByStatut(status);
    }

    public List<GoodReceipt> getAllGoodReceipts() {
        return goodReceiptRepository.findAll();
    }

    private void calculateOrderTotals(PurchaseOrder order) {
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        if (order.getLines() != null) {
            for (PurchaseOrderLine line : order.getLines()) {
                BigDecimal lineTotal = line.getMontant() != null ? line.getMontant() : BigDecimal.ZERO;
                totalAmount = totalAmount.add(lineTotal);
            }
        }

        if (totalAmount.compareTo(BigDecimal.ZERO) == 0 && order.getMontantHt() != null) {
            totalAmount = order.getMontantHt();
        }
        if (order.getTauxTva() != null) {
            totalTax = totalAmount.multiply(order.getTauxTva()).divide(BigDecimal.valueOf(100));
        }

        order.setMontantHt(totalAmount);
        order.setMontantTva(totalTax);
        order.setMontantTtc(totalAmount.add(totalTax));
    }

    private String generateInvoiceNumero(String prefix) {
        String base = prefix + "-" + LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String numero = base;
        int suffix = 1;
        while (invoiceRepository.findByNumero(numero).isPresent()) {
            numero = base + "-" + suffix;
            suffix++;
        }
        return numero;
    }

    private void applyRequestValidationRules(PurchaseRequest request) {
        if (request.getValideFinance() == null) request.setValideFinance(false);
        if (request.getValideDirection() == null) request.setValideDirection(false);

        String mode = request.getValidationMode() != null ? request.getValidationMode().trim().toUpperCase(Locale.ROOT) : "AUTO";
        if ("FINANCE".equals(mode)) {
            request.setValidationFinanceRequise(true);
            request.setValidationDirectionRequise(false);
            return;
        }
        if ("DIRECTION".equals(mode)) {
            request.setValidationFinanceRequise(false);
            request.setValidationDirectionRequise(true);
            return;
        }
        if ("FINANCE_DIRECTION".equals(mode) || "FINANCE_ET_DIRECTION".equals(mode)) {
            request.setValidationFinanceRequise(true);
            request.setValidationDirectionRequise(true);
            return;
        }

        // AUTO
        BigDecimal amount = request.getMontantEstime() != null ? request.getMontantEstime() : BigDecimal.ZERO;
        boolean important = "ELEVEE".equalsIgnoreCase(request.getImportance()) || "HAUTE".equalsIgnoreCase(request.getImportance());
        boolean requireDirection = important || amount.compareTo(DEFAULT_DIRECTION_THRESHOLD) >= 0;

        request.setValidationFinanceRequise(true);
        request.setValidationDirectionRequise(requireDirection);
    }

    private void finalizeRequestIfApproved(PurchaseRequest request, String currentUsername, String auditAction) {
        boolean financeRequired = Boolean.TRUE.equals(request.getValidationFinanceRequise());
        boolean directionRequired = Boolean.TRUE.equals(request.getValidationDirectionRequise());
        boolean financeOk = !financeRequired || Boolean.TRUE.equals(request.getValideFinance());
        boolean directionOk = !directionRequired || Boolean.TRUE.equals(request.getValideDirection());

        if (financeOk && directionOk) {
            request.setStatut("APPROUVEE");
            request.setUtilisateurApprobation(currentUsername);
        } else {
            request.setStatut("EN_ATTENTE");
        }

        auditService.logAction("PurchaseRequest", request.getId(), auditAction, currentUsername);
    }

    private String generateNumero(String prefix) {
        String base = prefix + "-" + LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String numero = base;
        int suffix = 1;
        while (purchaseRequestRepository.findByNumero(numero).isPresent()
            || purchaseOrderRepository.findByNumero(numero).isPresent()
            || goodReceiptRepository.findByNumero(numero).isPresent()
            || invoiceRepository.findByNumero(numero).isPresent()) {
            numero = base + "-" + suffix;
            suffix++;
        }
        return numero;
    }

    public PurchaseOrder savePurchaseOrder(PurchaseOrder order) {
        return purchaseOrderRepository.save(order);
    }}