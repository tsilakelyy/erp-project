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
public class SalesService {
    @Autowired
    private SalesOrderRepository salesOrderRepository;

    @Autowired
    private DeliveryRepository deliveryRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private StockService stockService;

    @Autowired
    private AuditService auditService;

    // ===== Sales Order Management =====
    public SalesOrder createSalesOrder(SalesOrder order, String currentUsername) {
        order.setStatus("DRAFT");
        order.setOrderDate(LocalDateTime.now());
        Optional<User> creator = userRepository.findByLogin(currentUsername);
        if (creator.isPresent()) {
            order.setCreator(creator.get());
        }
        order.setCreatedByUser(currentUsername);
        calculateOrderTotals(order);

        // Check stock availability and reserve
        for (SalesOrderLine line : order.getLines()) {
            int available = stockService.getAvailableQuantity(order.getWarehouse().getId(), line.getArticle().getId());
            if (available < line.getOrderedQuantity()) {
                throw new IllegalArgumentException("Insufficient stock for article: " + line.getArticle().getCode());
            }
            line.setReservedQuantity(line.getOrderedQuantity());
        }

        SalesOrder saved = salesOrderRepository.save(order);
        auditService.logAction("SalesOrder", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public SalesOrder approveSalesOrder(Long orderId, String currentUsername) {
        Optional<SalesOrder> order = salesOrderRepository.findById(orderId);
        if (order.isPresent()) {
            SalesOrder so = order.get();
            if (!"DRAFT".equals(so.getStatus())) {
                throw new IllegalArgumentException("Order must be in DRAFT status to approve");
            }
            so.setStatus("APPROVED");
            so.setApprovalDate(LocalDateTime.now());
            Optional<User> approver = userRepository.findByLogin(currentUsername);
            if (approver.isPresent()) {
                so.setApprover(approver.get());
            }
            so.setUpdatedByUser(currentUsername);
            SalesOrder updated = salesOrderRepository.save(so);
            auditService.logAction("SalesOrder", updated.getId(), "APPROVE", currentUsername);
            return updated;
        }
        return null;
    }

    public void cancelSalesOrder(Long orderId, String currentUsername) {
        Optional<SalesOrder> order = salesOrderRepository.findById(orderId);
        if (order.isPresent()) {
            SalesOrder so = order.get();
            if ("SHIPPED".equals(so.getStatus()) || "INVOICED".equals(so.getStatus())) {
                throw new IllegalArgumentException("Cannot cancel order with status: " + so.getStatus());
            }
            so.setStatus("CANCELLED");
            so.setUpdatedByUser(currentUsername);
            salesOrderRepository.save(so);
            auditService.logAction("SalesOrder", so.getId(), "CANCEL", currentUsername);
        }
    }

    public Optional<SalesOrder> getSalesOrder(Long id) {
        return salesOrderRepository.findById(id);
    }

    public List<SalesOrder> getSalesOrdersByStatus(String status) {
        return salesOrderRepository.findByStatus(status);
    }

    // ===== Delivery Management =====
    public Delivery createDelivery(Delivery delivery, String currentUsername) {
        Optional<SalesOrder> order = salesOrderRepository.findById(delivery.getSalesOrder().getId());
        if (order.isPresent() && !"APPROVED".equals(order.get().getStatus())) {
            throw new IllegalArgumentException("Sales order must be approved to create delivery");
        }
        delivery.setStatus("DRAFT");
        delivery.setDeliveryDate(LocalDateTime.now());
        Optional<User> shipper = userRepository.findByLogin(currentUsername);
        if (shipper.isPresent()) {
            delivery.setShipper(shipper.get());
        }
        Delivery saved = deliveryRepository.save(delivery);
        auditService.logAction("Delivery", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Delivery shipDelivery(Long deliveryId, String currentUsername) {
        Optional<Delivery> delivery = deliveryRepository.findById(deliveryId);
        if (delivery.isPresent()) {
            Delivery d = delivery.get();
            if (!"DRAFT".equals(d.getStatus())) {
                throw new IllegalArgumentException("Delivery must be in DRAFT status to ship");
            }
            d.setStatus("SHIPPED");
            Delivery updated = deliveryRepository.save(d);

            // Reduce stock and create movements
            for (DeliveryLine line : d.getLines()) {
                stockService.recordStockMovement(
                    d.getWarehouse(),
                    line.getArticle(),
                    "DELIVERY",
                    -line.getQuantity(),
                    null,
                    line.getBatchNumber(),
                    line.getSerialNumber(),
                    "DEL-" + d.getNumber(),
                    currentUsername
                );
            }

            auditService.logAction("Delivery", updated.getId(), "SHIP", currentUsername);
            return updated;
        }
        return null;
    }

    public Delivery receiveDelivery(Long deliveryId, String currentUsername) {
        Optional<Delivery> delivery = deliveryRepository.findById(deliveryId);
        if (delivery.isPresent()) {
            Delivery d = delivery.get();
            if (!"SHIPPED".equals(d.getStatus())) {
                throw new IllegalArgumentException("Delivery must be in SHIPPED status to receive");
            }
            d.setStatus("RECEIVED");
            d.setReceivedDate(LocalDateTime.now());
            Optional<User> receiver = userRepository.findByLogin(currentUsername);
            if (receiver.isPresent()) {
                d.setReceiver(receiver.get());
            }
            Delivery updated = deliveryRepository.save(d);
            auditService.logAction("Delivery", updated.getId(), "RECEIVE", currentUsername);
            return updated;
        }
        return null;
    }

    public Optional<Delivery> getDelivery(Long id) {
        return deliveryRepository.findById(id);
    }

    public List<Delivery> getDeliveriesByStatus(String status) {
        return deliveryRepository.findByStatus(status);
    }

    // ===== Invoice Management =====
    public Invoice createInvoice(Invoice invoice, String currentUsername) {
        invoice.setStatus("DRAFT");
        invoice.setInvoiceDate(LocalDateTime.now());
        Optional<User> creator = userRepository.findByLogin(currentUsername);
        if (creator.isPresent()) {
            invoice.setCreator(creator.get());
        }
        invoice.setCreatedByUser(currentUsername);
        calculateInvoiceTotals(invoice);
        Invoice saved = invoiceRepository.save(invoice);
        auditService.logAction("Invoice", saved.getId(), "CREATE", currentUsername);
        return saved;
    }

    public Invoice validateInvoice(Long invoiceId, String currentUsername) {
        Optional<Invoice> invoice = invoiceRepository.findById(invoiceId);
        if (invoice.isPresent()) {
            Invoice inv = invoice.get();
            if (!"DRAFT".equals(inv.getStatus())) {
                throw new IllegalArgumentException("Invoice must be in DRAFT status to validate");
            }
            inv.setStatus("VALIDATED");
            inv.setUpdatedByUser(currentUsername);
            Invoice updated = invoiceRepository.save(inv);
            auditService.logAction("Invoice", updated.getId(), "VALIDATE", currentUsername);
            return updated;
        }
        return null;
    }

    public Optional<Invoice> getInvoice(Long id) {
        return invoiceRepository.findById(id);
    }

    public List<Invoice> getInvoicesByStatus(String status) {
        return invoiceRepository.findByStatus(status);
    }

    private void calculateOrderTotals(SalesOrder order) {
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        for (SalesOrderLine line : order.getLines()) {
            BigDecimal lineTotal = line.getTotalPrice() != null ? line.getTotalPrice() : BigDecimal.ZERO;
            totalAmount = totalAmount.add(lineTotal);
        }

        order.setTotalAmount(totalAmount);
        order.setTotalTax(totalTax);
        order.setNetAmount(totalAmount.add(totalTax));
    }

    private void calculateInvoiceTotals(Invoice invoice) {
        BigDecimal totalAmount = BigDecimal.ZERO;
        BigDecimal totalTax = BigDecimal.ZERO;

        for (InvoiceLine line : invoice.getLines()) {
            BigDecimal lineTotal = line.getTotalPrice() != null ? line.getTotalPrice() : BigDecimal.ZERO;
            totalAmount = totalAmount.add(lineTotal);
            BigDecimal tax = line.getTaxAmount() != null ? line.getTaxAmount() : BigDecimal.ZERO;
            totalTax = totalTax.add(tax);
        }

        invoice.setTotalAmount(totalAmount);
        invoice.setTotalTax(totalTax);
        invoice.setNetAmount(totalAmount.add(totalTax));
    }
}
