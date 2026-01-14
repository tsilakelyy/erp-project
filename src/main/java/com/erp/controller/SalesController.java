package com.erp.controller;

import com.erp.domain.*;
import com.erp.service.SalesService;
import com.erp.service.CustomerService;
import com.erp.service.StockService;
import com.erp.repository.SiteRepository;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/sales")
public class SalesController {
    @Autowired
    private SalesService salesService;

    @Autowired
    private CustomerService customerService;

    @Autowired
    @SuppressWarnings("unused")
    private StockService stockService;

    @Autowired
    private SiteRepository siteRepository;

    @Autowired
    @SuppressWarnings("unused")
    private WarehouseRepository warehouseRepository;

    // ===== Sales Orders =====
    @GetMapping("/orders")
    public String listOrders(Model model, Authentication auth) {
        List<SalesOrder> orders = salesService.getSalesOrdersByStatus("APPROVED");
        model.addAttribute("orders", orders);
        model.addAttribute("username", auth.getName());
        return "sales/orders-list";
    }

    @GetMapping("/orders/{id}")
    public String detailOrder(@PathVariable Long id, Model model, Authentication auth) {
        Optional<SalesOrder> order = salesService.getSalesOrder(id);
        if (order.isPresent()) {
            model.addAttribute("order", order.get());
            model.addAttribute("username", auth.getName());
            return "sales/order-detail";
        }
        return "redirect:/sales/orders";
    }

    @GetMapping("/orders/new")
    public String createOrderForm(Model model, Authentication auth) {
        model.addAttribute("order", new SalesOrder());
        model.addAttribute("customers", customerService.findAllActive());
        model.addAttribute("sites", siteRepository.findAll());
        model.addAttribute("username", auth.getName());
        return "sales/order-form";
    }

    @PostMapping("/orders")
    public String createOrder(@ModelAttribute SalesOrder order, Authentication auth) {
        try {
            SalesOrder saved = salesService.createSalesOrder(order, auth.getName());
            return "redirect:/sales/orders/" + saved.getId();
        } catch (Exception e) {
            return "redirect:/sales/orders/new?error=" + e.getMessage();
        }
    }

    @PostMapping("/orders/{id}/approve")
    public String approveOrder(@PathVariable Long id, Authentication auth) {
        try {
            salesService.approveSalesOrder(id, auth.getName());
            return "redirect:/sales/orders/" + id;
        } catch (Exception e) {
            return "redirect:/sales/orders/" + id + "?error=" + e.getMessage();
        }
    }

    // ===== Deliveries =====
    @GetMapping("/deliveries")
    public String listDeliveries(Model model, Authentication auth) {
        List<Delivery> deliveries = salesService.getDeliveriesByStatus("SHIPPED");
        model.addAttribute("deliveries", deliveries);
        model.addAttribute("username", auth.getName());
        return "sales/deliveries-list";
    }

    @GetMapping("/deliveries/{id}")
    public String detailDelivery(@PathVariable Long id, Model model, Authentication auth) {
        Optional<Delivery> delivery = salesService.getDelivery(id);
        if (delivery.isPresent()) {
            model.addAttribute("delivery", delivery.get());
            model.addAttribute("username", auth.getName());
            return "sales/delivery-detail";
        }
        return "redirect:/sales/deliveries";
    }

    @PostMapping("/deliveries/{id}/ship")
    public String shipDelivery(@PathVariable Long id, Authentication auth) {
        try {
            salesService.shipDelivery(id, auth.getName());
            return "redirect:/sales/deliveries/" + id;
        } catch (Exception e) {
            return "redirect:/sales/deliveries/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/deliveries/{id}/receive")
    public String receiveDelivery(@PathVariable Long id, Authentication auth) {
        try {
            salesService.receiveDelivery(id, auth.getName());
            return "redirect:/sales/deliveries/" + id;
        } catch (Exception e) {
            return "redirect:/sales/deliveries/" + id + "?error=" + e.getMessage();
        }
    }

    // ===== Invoices =====
    @GetMapping("/invoices")
    public String listInvoices(Model model, Authentication auth) {
        List<Invoice> invoices = salesService.getInvoicesByStatus("DRAFT");
        model.addAttribute("invoices", invoices);
        model.addAttribute("username", auth.getName());
        return "sales/invoices-list";
    }

    @GetMapping("/invoices/{id}")
    public String detailInvoice(@PathVariable Long id, Model model, Authentication auth) {
        Optional<Invoice> invoice = salesService.getInvoice(id);
        if (invoice.isPresent()) {
            model.addAttribute("invoice", invoice.get());
            model.addAttribute("username", auth.getName());
            return "sales/invoice-detail";
        }
        return "redirect:/sales/invoices";
    }

    // REST API
    @GetMapping("/api/orders")
    @ResponseBody
    public ResponseEntity<List<SalesOrder>> getOrders() {
        return ResponseEntity.ok(salesService.getSalesOrdersByStatus("APPROVED"));
    }

    @GetMapping("/api/deliveries")
    @ResponseBody
    public ResponseEntity<List<Delivery>> getDeliveries() {
        return ResponseEntity.ok(salesService.getDeliveriesByStatus("SHIPPED"));
    }
}
