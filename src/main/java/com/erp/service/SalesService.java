package com.erp.service;

import com.erp.domain.*;
import com.erp.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
@Transactional
public class SalesService {
    @Autowired
    private SalesOrderRepository salesOrderRepository;

    @Autowired
    private DeliveryRepository deliveryRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private ClientRequestRepository clientRequestRepository;

    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private SalesProformaRepository salesProformaRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    @Qualifier("erpStockService")
    private StockService stockService;

    @Autowired
    private AuditService auditService;

    // ===== Sales Order Management =====
    public SalesOrder createSalesOrder(SalesOrder order, String currentUsername) {
        if (order.getProformaId() == null) {
            throw new IllegalArgumentException("La commande doit etre creee depuis une proforma client validee");
        }
        Optional<SalesOrder> existing = salesOrderRepository.findFirstByProformaId(order.getProformaId());
        if (existing.isPresent()) {
            throw new IllegalArgumentException("Une commande existe deja pour cette proforma");
        }
        SalesProforma proforma = salesProformaRepository.findById(order.getProformaId())
            .orElseThrow(() -> new IllegalArgumentException("Proforma client introuvable"));
        String pfStatus = proforma.getStatut() != null ? proforma.getStatut().trim().toUpperCase() : "";
        if (!"VALIDEE_CLIENT".equals(pfStatus) && !"TRANSFORMEE".equals(pfStatus)) {
            throw new IllegalArgumentException("La proforma doit etre validee par le client avant la creation de la commande");
        }
        if (order.getClientId() == null) {
            order.setClientId(proforma.getClientId());
        }
        if (order.getEntrepotId() == null) {
            order.setEntrepotId(proforma.getEntrepotId());
        }
        if (order.getMontantHt() == null) {
            order.setMontantHt(proforma.getMontantHt());
        }
        if (order.getMontantTva() == null) {
            order.setMontantTva(proforma.getMontantTva());
        }
        if (order.getMontantTtc() == null) {
            order.setMontantTtc(proforma.getMontantTtc());
        }
        if (order.getTauxTva() == null) {
            order.setTauxTva(proforma.getTauxTva());
        }
        if (order.getClientRequestId() == null) {
            order.setClientRequestId(proforma.getRequestId());
        }
        if ((order.getLines() == null || order.getLines().isEmpty()) && proforma.getLines() != null) {
            for (SalesProformaLine pl : proforma.getLines()) {
                if (pl.getArticle() == null) continue;
                SalesOrderLine line = new SalesOrderLine();
                line.setSalesOrder(order);
                line.setArticle(pl.getArticle());
                line.setQuantiteCommandee(pl.getQuantite() != null ? pl.getQuantite() : 0);
                line.setQuantiteReservee(0);
                line.setPrixUnitaire(pl.getPrixUnitaire());
                line.setMontant(pl.getMontant());
                order.getLines().add(line);
            }
        }

        if (order.getNumero() == null || order.getNumero().trim().isEmpty()) {
            order.setNumero(generateNumero("CV"));
        }
        String statut = order.getStatut();
        if (statut == null || statut.trim().isEmpty()) {
            statut = "BROUILLON";
        }
        order.setStatut(statut);
        if (order.getDateCommande() == null) {
            order.setDateCommande(LocalDateTime.now());
        }
        if (order.getDateCreation() == null) {
            order.setDateCreation(LocalDateTime.now());
        }
        order.setUtilisateurCreation(currentUsername);
        
        calculateOrderTotals(order);

        // Check stock availability and reserve
        if (order.getLines() != null && order.getEntrepotId() != null) {
            for (SalesOrderLine line : order.getLines()) {
                if (line.getSalesOrder() == null) {
                    line.setSalesOrder(order);
                }
                if (line.getArticle() == null) {
                    continue;
                }
                int available = stockService.getAvailableQuantity(
                    order.getEntrepotId(), 
                    line.getArticle().getId()
                );
                if (available < line.getQuantiteCommandee()) {
                    throw new IllegalArgumentException(
                        "Insufficient stock for article: " + line.getArticle().getCode()
                    );
                }
                line.setQuantiteReservee(line.getQuantiteCommandee());
            }
        }

        SalesOrder saved = salesOrderRepository.save(order);
        auditService.logAction("SalesOrder", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public SalesOrder createSalesOrderFromRequest(Long requestId, String currentUsername) {
        ClientRequest request = clientRequestRepository.findById(requestId)
            .orElseThrow(() -> new IllegalArgumentException("Demande client introuvable"));

        throw new IllegalArgumentException("La transformation directe en commande est desactivee. Creez une proforma client.");
    }

    public SalesOrder createSalesOrderFromProforma(Long proformaId, String currentUsername) {
        SalesProforma proforma = salesProformaRepository.findById(proformaId)
            .orElseThrow(() -> new IllegalArgumentException("Proforma client introuvable"));

        Optional<SalesOrder> existing = salesOrderRepository.findFirstByProformaId(proformaId);
        if (existing.isPresent()) {
            return existing.get();
        }

        if (!"VALIDEE_CLIENT".equalsIgnoreCase(proforma.getStatut())) {
            throw new IllegalArgumentException("La proforma doit etre validee par le client pour creer la commande");
        }

        SalesOrder order = new SalesOrder();
        order.setClientId(proforma.getClientId());
        order.setEntrepotId(proforma.getEntrepotId());
        order.setProformaId(proforma.getId());
        order.setClientRequestId(proforma.getRequestId());
        order.setStatut("VALIDEE");
        order.setMontantHt(proforma.getMontantHt());
        order.setMontantTva(proforma.getMontantTva());
        order.setMontantTtc(proforma.getMontantTtc());
        order.setTauxTva(proforma.getTauxTva());

        if (proforma.getLines() != null) {
            for (SalesProformaLine pl : proforma.getLines()) {
                if (pl.getArticle() == null) continue;
                SalesOrderLine line = new SalesOrderLine();
                line.setSalesOrder(order);
                line.setArticle(pl.getArticle());
                line.setQuantiteCommandee(pl.getQuantite() != null ? pl.getQuantite() : 0);
                line.setQuantiteReservee(0);
                line.setPrixUnitaire(pl.getPrixUnitaire());
                line.setMontant(pl.getMontant());
                order.getLines().add(line);
            }
        }

        SalesOrder saved = createSalesOrder(order, currentUsername);
        proforma.setStatut("TRANSFORMEE");
        proforma.setUtilisateurModification(currentUsername);
        salesProformaRepository.save(proforma);
        auditService.logAction("SalesProforma", proforma.getId(), "TO_ORDER", currentUsername);

        if (proforma.getRequestId() != null) {
            clientRequestRepository.findById(proforma.getRequestId()).ifPresent(req -> {
                req.setStatut("TRANSFORMEE");
                req.setDateModification(LocalDateTime.now());
                clientRequestRepository.save(req);
            });
        }

        ensureDeliveryForOrder(saved, currentUsername);
        return saved;
    }

    public SalesOrder approveSalesOrder(Long orderId, String currentUsername) {
        Optional<SalesOrder> order = salesOrderRepository.findById(orderId);
        if (order.isPresent()) {
            SalesOrder so = order.get();
            if (!"BROUILLON".equalsIgnoreCase(so.getStatut())
                && !"EN_COURS".equalsIgnoreCase(so.getStatut())
                && !"DEVIS".equalsIgnoreCase(so.getStatut())) {
                throw new IllegalArgumentException("La commande doit etre en brouillon pour etre validee");
            }
            if (so.getProformaId() == null) {
                throw new IllegalArgumentException("La validation exige une proforma client validee");
            }
            SalesProforma proforma = salesProformaRepository.findById(so.getProformaId())
                .orElseThrow(() -> new IllegalArgumentException("Proforma client introuvable"));
            String pfStatus = proforma.getStatut() != null ? proforma.getStatut().trim().toUpperCase() : "";
            if (!"VALIDEE_CLIENT".equals(pfStatus) && !"TRANSFORMEE".equals(pfStatus)) {
                throw new IllegalArgumentException("La proforma doit etre validee par le client");
            }
            so.setStatut("VALIDEE");
            so.setUtilisateurApprobation(currentUsername);
            
            SalesOrder updated = salesOrderRepository.save(so);
            auditService.logAction("SalesOrder", updated.getId(), "APPROVE", currentUsername);
            ensureDeliveryForOrder(updated, currentUsername);
            return updated;
        }
        return null;
    }

    public void cancelSalesOrder(Long orderId, String currentUsername) {
        Optional<SalesOrder> order = salesOrderRepository.findById(orderId);
        if (order.isPresent()) {
            SalesOrder so = order.get();
            if ("LIVREE".equalsIgnoreCase(so.getStatut()) || "FACTUREE".equalsIgnoreCase(so.getStatut())) {
                throw new IllegalArgumentException("Impossible d'annuler une commande au statut: " + so.getStatut());
            }
            so.setStatut("ANNULEE");
            salesOrderRepository.save(so);
            auditService.logAction("SalesOrder", so.getId(), "CANCEL", currentUsername);
        }
    }

    public Optional<SalesOrder> getSalesOrder(Long id) {
        return salesOrderRepository.findById(id);
    }

    public List<SalesOrder> getSalesOrdersByStatus(String status) {
        return salesOrderRepository.findByStatut(status);
    }

    public List<SalesOrder> getAllSalesOrders() {
        return salesOrderRepository.findAll();
    }

    // ===== Delivery Management =====
    public Delivery createDelivery(Delivery delivery, String currentUsername) {
        // Validate sales order reference
        if (delivery.getCommandeClientId() == null) {
            throw new IllegalArgumentException("Sales order is required");
        }

        if (delivery.getNumero() == null || delivery.getNumero().trim().isEmpty()) {
            delivery.setNumero(generateNumero("LIV"));
        }
        
        Optional<SalesOrder> order = salesOrderRepository.findById(delivery.getCommandeClientId());
        if (order.isPresent() && !"VALIDEE".equalsIgnoreCase(order.get().getStatut())) {
            throw new IllegalArgumentException("La commande doit etre validee pour creer une livraison");
        }
        
        delivery.setStatut("EN_PREPARATION");
        delivery.setDateLivraison(LocalDate.now());
        delivery.setDateCreation(LocalDateTime.now());
        delivery.setUtilisateurPicking(currentUsername);
        
        Delivery saved = deliveryRepository.save(delivery);
        auditService.logAction("Delivery", saved.getId(), "CREATE", currentUsername);
        return saved;
    }



    public Delivery shipDelivery(Long deliveryId, String currentUsername) {
        Optional<Delivery> delivery = deliveryRepository.findById(deliveryId);
        if (delivery.isPresent()) {
            Delivery d = delivery.get();
            if (!"EN_PREPARATION".equalsIgnoreCase(d.getStatut())) {
                throw new IllegalArgumentException("La livraison doit etre en preparation pour etre expediee");
            }
            d.setStatut("EXPEDIEE");
            d.setUtilisateurExpedition(currentUsername);
            Delivery updated = deliveryRepository.save(d);

            // Reduce stock and create movements
            Warehouse warehouse = null;
            if (d.getEntrepotId() != null) {
                warehouse = warehouseRepository.findById(d.getEntrepotId()).orElse(null);
            }
            if (d.getLines() != null && d.getEntrepotId() != null && warehouse != null) {
                for (DeliveryLine line : d.getLines()) {
                    // ⚠️ NULL CHECK for article
                    if (line.getArticle() != null) {
                        stockService.recordStockMovement(
                            warehouse,
                            line.getArticle(),
                            "SORTIE",
                            -line.getQuantite(),
                            null,
                            line.getBatchNumber(),
                            line.getSerialNumber(),
                            "DEL-" + d.getNumero(),
                            currentUsername
                        );
                    }
                }
            }

            auditService.logAction("Delivery", updated.getId(), "SHIP", currentUsername);

            if (d.getCommandeClientId() != null) {
                salesOrderRepository.findById(d.getCommandeClientId()).ifPresent(order -> {
                    if (!"LIVREE".equalsIgnoreCase(order.getStatut()) && !"FACTUREE".equalsIgnoreCase(order.getStatut()) && !"PAYEE".equalsIgnoreCase(order.getStatut())) {
                        order.setStatut("EN_COURS");
                        salesOrderRepository.save(order);
                    }
                });
            }
            return updated;
        }
        return null;
    }

    public Delivery receiveDelivery(Long deliveryId, String currentUsername) {
        Optional<Delivery> delivery = deliveryRepository.findById(deliveryId);
        if (delivery.isPresent()) {
            Delivery d = delivery.get();
            if (!"EXPEDIEE".equalsIgnoreCase(d.getStatut())) {
                throw new IllegalArgumentException("La livraison doit etre expediee pour etre receptionnee");
            }
            d.setStatut("VALIDEE");
            
            Delivery updated = deliveryRepository.save(d);
            auditService.logAction("Delivery", updated.getId(), "RECEIVE", currentUsername);

            if (d.getCommandeClientId() != null) {
                salesOrderRepository.findById(d.getCommandeClientId()).ifPresent(order -> {
                    order.setStatut("LIVREE");
                    salesOrderRepository.save(order);
                });
                generateInvoiceForOrder(d.getCommandeClientId(), currentUsername);
            }
            return updated;
        }
        return null;
    }

    public void cancelDelivery(Long deliveryId, String currentUsername) {
        Optional<Delivery> delivery = deliveryRepository.findById(deliveryId);
        if (delivery.isPresent()) {
            Delivery d = delivery.get();
            if ("VALIDEE".equalsIgnoreCase(d.getStatut())) {
                throw new IllegalArgumentException("Impossible d'annuler une livraison deja validee");
            }
            d.setStatut("ANNULEE");
            deliveryRepository.save(d);
            auditService.logAction("Delivery", d.getId(), "CANCEL", currentUsername);
        }
    }

    public Optional<Delivery> getDelivery(Long id) {
        return deliveryRepository.findById(id);
    }

    public List<Delivery> getDeliveriesByStatus(String status) {
        return deliveryRepository.findByStatut(status);
    }

    public List<Delivery> getAllDeliveries() {
        return deliveryRepository.findAll();
    }

    // ===== Invoice Management =====
    public Invoice createInvoice(Invoice invoice, String currentUsername) {
        invoice.setStatut("EN_ATTENTE");
        invoice.setDateFacture(LocalDateTime.now());
        invoice.setDateCreation(LocalDateTime.now());
        
        calculateInvoiceTotals(invoice);
        Invoice saved = invoiceRepository.save(invoice);
        auditService.logAction("Invoice", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Invoice validateInvoice(Long invoiceId, String currentUsername) {
        Optional<Invoice> invoice = invoiceRepository.findById(invoiceId);
        if (invoice.isPresent()) {
            Invoice inv = invoice.get();
            if (!"EN_ATTENTE".equalsIgnoreCase(inv.getStatut())) {
                throw new IllegalArgumentException("La facture doit etre en attente pour etre payee");
            }
            inv.setStatut("PAYEE");
            
            Invoice updated = invoiceRepository.save(inv);
            auditService.logAction("Invoice", updated.getId(), "VALIDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public void cancelInvoice(Long invoiceId, String currentUsername) {
        Optional<Invoice> invoice = invoiceRepository.findById(invoiceId);
        if (invoice.isPresent()) {
            Invoice inv = invoice.get();
            if ("PAYEE".equalsIgnoreCase(inv.getStatut())) {
                throw new IllegalArgumentException("Impossible d'annuler une facture payee");
            }
            inv.setStatut("ANNULEE");
            invoiceRepository.save(inv);
            auditService.logAction("Invoice", inv.getId(), "CANCEL", currentUsername);
        }
    }

    public Optional<Invoice> getInvoice(Long id) {
        return invoiceRepository.findById(id);
    }

    public List<Invoice> getInvoicesByStatus(String status) {
        return invoiceRepository.findByStatut(status);
    }

    public List<Invoice> getAllInvoices() {
        return invoiceRepository.findAll();
    }

    // ===== Sales Flow Helpers =====
    public Delivery ensureDeliveryForOrder(SalesOrder order, String currentUsername) {
        if (order == null || order.getId() == null) return null;

        Optional<Delivery> existing = deliveryRepository.findFirstByCommandeClientIdOrderByDateCreationDesc(order.getId());
        if (existing.isPresent()) {
            return existing.get();
        }

        if (order.getEntrepotId() == null) {
            return null;
        }

        Delivery delivery = new Delivery();
        delivery.setNumero(generateNumero("LIV"));
        delivery.setStatut("EN_PREPARATION");
        delivery.setDateCreation(LocalDateTime.now());
        delivery.setCommandeClientId(order.getId());
        delivery.setEntrepotId(order.getEntrepotId());
        delivery.setUtilisateurPicking(currentUsername);

        List<DeliveryLine> lines = new ArrayList<>();
        if (order.getLines() != null) {
            for (SalesOrderLine line : order.getLines()) {
                if (line.getArticle() == null) continue;
                int requested = line.getQuantiteCommandee() != null ? line.getQuantiteCommandee() : 0;
                if (requested <= 0) continue;

                int qty = requested;
                if (order.getEntrepotId() != null) {
                    int available = stockService.getAvailableQuantity(order.getEntrepotId(), line.getArticle().getId());
                    if (available <= 0) continue;
                    qty = Math.min(requested, available);
                }
                if (qty <= 0) continue;

                DeliveryLine dl = new DeliveryLine();
                dl.setLivraison(delivery);
                dl.setArticle(line.getArticle());
                dl.setQuantite(qty);
                lines.add(dl);
            }
        }
        delivery.setLines(lines);

        Delivery saved = deliveryRepository.save(delivery);
        auditService.logAction("Delivery", saved.getId(), "CREATE_AUTO", currentUsername);

        if (!"EN_COURS".equalsIgnoreCase(order.getStatut())
            && !"LIVREE".equalsIgnoreCase(order.getStatut())
            && !"FACTUREE".equalsIgnoreCase(order.getStatut())
            && !"PAYEE".equalsIgnoreCase(order.getStatut())) {
            order.setStatut("EN_COURS");
            salesOrderRepository.save(order);
        }
        return saved;
    }

    public Invoice generateInvoiceForOrder(Long orderId, String currentUsername) {
        if (orderId == null) return null;
        Optional<Invoice> existing = invoiceRepository.findFirstByCommandeClientId(orderId);
        if (existing.isPresent()) {
            return existing.get();
        }

        SalesOrder order = salesOrderRepository.findById(orderId)
            .orElseThrow(() -> new IllegalArgumentException("Commande client introuvable"));

        Invoice invoice = new Invoice();
        invoice.setNumero(generateNumero("FV"));
        invoice.setStatut("EN_ATTENTE");
        invoice.setTypeFacture("VENTE");
        invoice.setDateCreation(LocalDateTime.now());
        invoice.setDateFacture(LocalDateTime.now());
        invoice.setTiersId(order.getClientId());
        invoice.setCommandeClientId(order.getId());
        invoice.setTypeTiers("CLIENT");
        invoice.setTauxTva(order.getTauxTva());
        invoice.setMontantHt(order.getMontantHt());
        invoice.setMontantTva(order.getMontantTva());
        invoice.setMontantTtc(order.getMontantTtc());

        if (order.getLines() != null) {
            for (SalesOrderLine sol : order.getLines()) {
                if (sol.getArticle() == null) continue;
                InvoiceLine il = new InvoiceLine();
                il.setFacture(invoice);
                il.setArticle(sol.getArticle());
                il.setQuantite(sol.getQuantiteCommandee() != null ? sol.getQuantiteCommandee() : 0);
                il.setPrixUnitaire(sol.getPrixUnitaire());
                il.setMontant(sol.getMontant());
                invoice.getLines().add(il);
            }
        }

        Invoice saved = invoiceRepository.save(invoice);
        auditService.logAction("Invoice", saved.getId(), "CREATE_SALES_INVOICE", currentUsername);

        order.setStatut("FACTUREE");
        salesOrderRepository.save(order);
        auditService.logAction("SalesOrder", order.getId(), "INVOICE", currentUsername);

        return saved;
    }

    public Invoice recordPayment(Long invoiceId, BigDecimal amount, String method, String reference, String currentUsername) {
        Invoice invoice = invoiceRepository.findById(invoiceId)
            .orElseThrow(() -> new IllegalArgumentException("Facture introuvable"));

        if (!"PAYEE".equalsIgnoreCase(invoice.getStatut())) {
            invoice.setStatut("PAYEE");
            invoiceRepository.save(invoice);
        }

        Payment payment = new Payment();
        payment.setNumero(generateNumero("PAY"));
        payment.setStatut("COMPLETE");
        payment.setDateCreation(LocalDateTime.now());
        payment.setDatePaiement(LocalDateTime.now());
        payment.setMontant(amount != null ? amount : invoice.getMontantTtc());
        payment.setMoyenPaiement(method != null && !method.trim().isEmpty() ? method : "VIREMENT");
        payment.setReferenceTransaction(reference);
        payment.setFactureId(invoice.getId());
        paymentRepository.save(payment);
        auditService.logAction("Payment", payment.getId(), "CREATE", currentUsername);

        if (invoice.getCommandeClientId() != null) {
            salesOrderRepository.findById(invoice.getCommandeClientId()).ifPresent(order -> {
                order.setStatut("PAYEE");
                salesOrderRepository.save(order);
            });
        }
        return invoice;
    }

    private void calculateOrderTotals(SalesOrder order) {
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        if (order.getLines() != null) {
            for (SalesOrderLine line : order.getLines()) {
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

    private String generateNumero(String prefix) {
        String base = prefix + "-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMddHHmmss"));
        String numero = base;
        int suffix = 1;
        while (salesOrderRepository.findByNumero(numero).isPresent()
            || deliveryRepository.findByNumero(numero).isPresent()
            || invoiceRepository.findByNumero(numero).isPresent()
            || paymentRepository.findByNumero(numero).isPresent()) {
            numero = base + "-" + suffix;
            suffix++;
        }
        return numero;
    }

    private void calculateInvoiceTotals(Invoice invoice) {
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        if (invoice.getLines() != null) {
            for (InvoiceLine line : invoice.getLines()) {
                BigDecimal lineTotal = line.getMontant() != null ? line.getMontant() : BigDecimal.ZERO;
                totalAmount = totalAmount.add(lineTotal);
            }
        }

        if (totalAmount.compareTo(BigDecimal.ZERO) == 0 && invoice.getMontantHt() != null) {
            totalAmount = invoice.getMontantHt();
        }
        if (invoice.getTauxTva() != null) {
            totalTax = totalAmount.multiply(invoice.getTauxTva()).divide(BigDecimal.valueOf(100));
        }

        invoice.setMontantHt(totalAmount);
        invoice.setMontantTva(totalTax);
        invoice.setMontantTtc(totalAmount.add(totalTax));
    }

    public SalesOrder updateSalesOrder(SalesOrder order, String currentUsername) {
        if (order.getId() == null) {
            throw new IllegalArgumentException("Order ID is required for update");
        }

        SalesOrder existingOrder = salesOrderRepository.findById(order.getId())
            .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        if (order.getClientId() == null || order.getMontantTtc() == null || order.getStatut() == null) {
            throw new IllegalArgumentException("Client ID, Montant TTC, and Statut are required fields");
        }

        // Log the update attempt
        auditService.logAction("SalesOrder", order.getId(), "UPDATE_ATTEMPT", currentUsername);

        // Update fields
        existingOrder.setClientId(order.getClientId());
        existingOrder.setMontantTtc(order.getMontantTtc());
        existingOrder.setStatut(order.getStatut());

        existingOrder.setDateModification(LocalDateTime.now());
        existingOrder.setUtilisateurModification(currentUsername);

        return salesOrderRepository.save(existingOrder);
    }
}
