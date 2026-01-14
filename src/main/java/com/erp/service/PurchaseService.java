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
public class PurchaseService {
    @Autowired
    private PurchaseRequestRepository purchaseRequestRepository;

    @Autowired
    private PurchaseOrderRepository purchaseOrderRepository;

    @Autowired
    private GoodReceiptRepository goodReceiptRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private AuditService auditService;

    @Autowired
    private StockService stockService;

    // ===== Purchase Request Management =====
    public PurchaseRequest createPurchaseRequest(PurchaseRequest request, String currentUsername) {
        request.setStatus("DRAFT");
        request.setRequestDate(LocalDateTime.now());
        Optional<User> creator = userRepository.findByUsername(currentUsername);
        if (creator.isPresent()) {
            request.setCreator(creator.get());
        }
        request.setCreatedByUser(currentUsername);
        PurchaseRequest saved = purchaseRequestRepository.save(request);
        auditService.logAction("PurchaseRequest", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public PurchaseRequest submitPurchaseRequest(Long requestId, String currentUsername) {
        Optional<PurchaseRequest> request = purchaseRequestRepository.findById(requestId);
        if (request.isPresent()) {
            PurchaseRequest pr = request.get();
            if (!"DRAFT".equals(pr.getStatus())) {
                throw new IllegalArgumentException("Request must be in DRAFT status to submit");
            }
            pr.setStatus("SUBMITTED");
            pr.setUpdatedByUser(currentUsername);
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
            if (!"SUBMITTED".equals(pr.getStatus())) {
                throw new IllegalArgumentException("Request must be in SUBMITTED status to approve");
            }
            pr.setStatus("APPROVED");
            pr.setApprovalDate(LocalDateTime.now());
            Optional<User> approver = userRepository.findByUsername(currentUsername);
            if (approver.isPresent()) {
                pr.setApprover(approver.get());
            }
            pr.setUpdatedByUser(currentUsername);
            PurchaseRequest updated = purchaseRequestRepository.save(pr);
            auditService.logAction("PurchaseRequest", updated.getId(), "APPROVE", currentUsername);
            return updated;
        }
        return null;
    }

    public void rejectPurchaseRequest(Long requestId, String currentUsername) {
        Optional<PurchaseRequest> request = purchaseRequestRepository.findById(requestId);
        if (request.isPresent()) {
            PurchaseRequest pr = request.get();
            pr.setStatus("REJECTED");
            pr.setUpdatedByUser(currentUsername);
            purchaseRequestRepository.save(pr);
            auditService.logAction("PurchaseRequest", pr.getId(), "REJECT", currentUsername);
        }
    }

    public Optional<PurchaseRequest> getPurchaseRequest(Long id) {
        return purchaseRequestRepository.findById(id);
    }

    public List<PurchaseRequest> getPurchaseRequestsByStatus(String status) {
        return purchaseRequestRepository.findByStatus(status);
    }

    // ===== Purchase Order Management =====
    public PurchaseOrder createPurchaseOrder(PurchaseOrder order, String currentUsername) {
        order.setStatus("DRAFT");
        order.setOrderDate(LocalDateTime.now());
        Optional<User> creator = userRepository.findByUsername(currentUsername);
        if (creator.isPresent()) {
            order.setCreator(creator.get());
        }
        order.setCreatedByUser(currentUsername);
        calculateOrderTotals(order);
        PurchaseOrder saved = purchaseOrderRepository.save(order);
        auditService.logAction("PurchaseOrder", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public PurchaseOrder submitPurchaseOrder(Long orderId, String currentUsername) {
        Optional<PurchaseOrder> order = purchaseOrderRepository.findById(orderId);
        if (order.isPresent()) {
            PurchaseOrder po = order.get();
            if (!"DRAFT".equals(po.getStatus())) {
                throw new IllegalArgumentException("Order must be in DRAFT status to submit");
            }
            po.setStatus("SUBMITTED");
            po.setUpdatedByUser(currentUsername);
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
            if (!"SUBMITTED".equals(po.getStatus())) {
                throw new IllegalArgumentException("Order must be in SUBMITTED status to approve");
            }
            po.setStatus("APPROVED");
            po.setApprovalDate(LocalDateTime.now());
            Optional<User> approver = userRepository.findByUsername(currentUsername);
            if (approver.isPresent()) {
                po.setApprover(approver.get());
            }
            po.setUpdatedByUser(currentUsername);
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
            if ("RECEIVED".equals(po.getStatus()) || "INVOICED".equals(po.getStatus())) {
                throw new IllegalArgumentException("Cannot cancel order with status: " + po.getStatus());
            }
            po.setStatus("CANCELLED");
            po.setUpdatedByUser(currentUsername);
            purchaseOrderRepository.save(po);
            auditService.logAction("PurchaseOrder", po.getId(), "CANCEL", currentUsername);
        }
    }

    public Optional<PurchaseOrder> getPurchaseOrder(Long id) {
        return purchaseOrderRepository.findById(id);
    }

    public List<PurchaseOrder> getPurchaseOrdersByStatus(String status) {
        return purchaseOrderRepository.findByStatus(status);
    }

    // ===== Good Receipt Management =====
    public GoodReceipt createGoodReceipt(GoodReceipt receipt, String currentUsername) {
        Optional<PurchaseOrder> order = purchaseOrderRepository.findById(receipt.getPurchaseOrder().getId());
        if (order.isPresent() && !"APPROVED".equals(order.get().getStatus())) {
            throw new IllegalArgumentException("Purchase order must be approved to receive goods");
        }
        receipt.setStatus("DRAFT");
        receipt.setReceiptDate(LocalDateTime.now());
        Optional<User> receiver = userRepository.findByUsername(currentUsername);
        if (receiver.isPresent()) {
            receipt.setReceiver(receiver.get());
        }
        receipt.setCreatedByUser(currentUsername);
        GoodReceipt saved = goodReceiptRepository.save(receipt);
        auditService.logAction("GoodReceipt", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public GoodReceipt validateGoodReceipt(Long receiptId, String currentUsername) {
        Optional<GoodReceipt> receipt = goodReceiptRepository.findById(receiptId);
        if (receipt.isPresent()) {
            GoodReceipt gr = receipt.get();
            if (!"DRAFT".equals(gr.getStatus())) {
                throw new IllegalArgumentException("Receipt must be in DRAFT status to validate");
            }
            gr.setStatus("VALIDATED");
            gr.setValidationDate(LocalDateTime.now());
            Optional<User> validator = userRepository.findByUsername(currentUsername);
            if (validator.isPresent()) {
                gr.setValidator(validator.get());
            }
            gr.setUpdatedByUser(currentUsername);
            GoodReceipt updated = goodReceiptRepository.save(gr);

            // Create stock movements
            for (GoodReceiptLine line : gr.getLines()) {
                stockService.recordStockMovement(
                    gr.getWarehouse(),
                    line.getArticle(),
                    "RECEIPT",
                    line.getQuantity(),
                    line.getLocation(),
                    line.getBatchNumber(),
                    line.getSerialNumber(),
                    "GR-" + gr.getNumber(),
                    currentUsername
                );
            }

            auditService.logAction("GoodReceipt", updated.getId(), "VALIDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public Optional<GoodReceipt> getGoodReceipt(Long id) {
        return goodReceiptRepository.findById(id);
    }

    public List<GoodReceipt> getGoodReceiptsByStatus(String status) {
        return goodReceiptRepository.findByStatus(status);
    }

    private void calculateOrderTotals(PurchaseOrder order) {
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        for (PurchaseOrderLine line : order.getLines()) {
            BigDecimal lineTotal = line.getTotalPrice() != null ? line.getTotalPrice() : BigDecimal.ZERO;
            totalAmount = totalAmount.add(lineTotal);
        }

        order.setTotalAmount(totalAmount);
        order.setTotalTax(totalTax);
        order.setNetAmount(totalAmount.add(totalTax));
    }
}
