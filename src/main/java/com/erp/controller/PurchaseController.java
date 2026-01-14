package com.erp.controller;

import com.erp.domain.*;
import com.erp.service.PurchaseService;
import com.erp.service.SupplierService;
import com.erp.repository.SiteRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@Controller
@RequestMapping("/purchases")
public class PurchaseController {
    @Autowired
    private PurchaseService purchaseService;

    @Autowired
    private SupplierService supplierService;

    @Autowired
    private SiteRepository siteRepository;

    // ===== Purchase Requests =====
    @GetMapping("/requests")
    public String listRequests(Model model, Authentication auth) {
        List<PurchaseRequest> requests = purchaseService.getPurchaseRequestsByStatus("SUBMITTED");
        model.addAttribute("requests", requests);
        model.addAttribute("username", auth.getName());
        return "purchases/requests-list";
    }

    @GetMapping("/requests/{id}")
    public String detailRequest(@PathVariable Long id, Model model, Authentication auth) {
        Optional<PurchaseRequest> request = purchaseService.getPurchaseRequest(id);
        if (request.isPresent()) {
            model.addAttribute("request", request.get());
            model.addAttribute("username", auth.getName());
            return "purchases/request-detail";
        }
        return "redirect:/purchases/requests";
    }

    @GetMapping("/requests/new")
    public String createRequestForm(Model model, Authentication auth) {
        model.addAttribute("request", new PurchaseRequest());
        model.addAttribute("sites", siteRepository.findAll());
        model.addAttribute("username", auth.getName());
        return "purchases/request-form";
    }

    @PostMapping("/requests")
    public String createRequest(@ModelAttribute PurchaseRequest request, Authentication auth) {
        try {
            PurchaseRequest saved = purchaseService.createPurchaseRequest(request, auth.getName());
            return "redirect:/purchases/requests/" + saved.getId();
        } catch (Exception e) {
            return "redirect:/purchases/requests/new?error=" + e.getMessage();
        }
    }

    @PostMapping("/requests/{id}/submit")
    public String submitRequest(@PathVariable Long id, Authentication auth) {
        try {
            purchaseService.submitPurchaseRequest(id, auth.getName());
            return "redirect:/purchases/requests/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/requests/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/requests/{id}/approve")
    public String approveRequest(@PathVariable Long id, Authentication auth) {
        try {
            purchaseService.approvePurchaseRequest(id, auth.getName());
            return "redirect:/purchases/requests/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/requests/" + id + "?error=" + e.getMessage();
        }
    }

    // ===== Purchase Orders =====
    @GetMapping("/orders")
    public String listOrders(Model model, Authentication auth) {
        List<PurchaseOrder> orders = purchaseService.getPurchaseOrdersByStatus("APPROVED");
        model.addAttribute("orders", orders);
        model.addAttribute("username", auth.getName());
        return "purchases/orders-list";
    }

    @GetMapping("/orders/{id}")
    public String detailOrder(@PathVariable Long id, Model model, Authentication auth) {
        Optional<PurchaseOrder> order = purchaseService.getPurchaseOrder(id);
        if (order.isPresent()) {
            model.addAttribute("order", order.get());
            model.addAttribute("username", auth.getName());
            return "purchases/order-detail";
        }
        return "redirect:/purchases/orders";
    }

    @GetMapping("/orders/new")
    public String createOrderForm(Model model, Authentication auth) {
        model.addAttribute("order", new PurchaseOrder());
        model.addAttribute("suppliers", supplierService.findAllActive());
        model.addAttribute("sites", siteRepository.findAll());
        model.addAttribute("username", auth.getName());
        return "purchases/order-form";
    }

    @PostMapping("/orders")
    public String createOrder(@ModelAttribute PurchaseOrder order, Authentication auth) {
        try {
            PurchaseOrder saved = purchaseService.createPurchaseOrder(order, auth.getName());
            return "redirect:/purchases/orders/" + saved.getId();
        } catch (Exception e) {
            return "redirect:/purchases/orders/new?error=" + e.getMessage();
        }
    }

    @PostMapping("/orders/{id}/submit")
    public String submitOrder(@PathVariable Long id, Authentication auth) {
        try {
            purchaseService.submitPurchaseOrder(id, auth.getName());
            return "redirect:/purchases/orders/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/orders/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/orders/{id}/approve")
    public String approveOrder(@PathVariable Long id, Authentication auth) {
        try {
            purchaseService.approvePurchaseOrder(id, auth.getName());
            return "redirect:/purchases/orders/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/orders/" + id + "?error=" + e.getMessage();
        }
    }

    // REST API
    @GetMapping("/api/requests")
    @ResponseBody
    public ResponseEntity<List<PurchaseRequest>> getRequests() {
        return ResponseEntity.ok(purchaseService.getPurchaseRequestsByStatus("SUBMITTED"));
    }

    @GetMapping("/api/orders")
    @ResponseBody
    public ResponseEntity<List<PurchaseOrder>> getOrders() {
        return ResponseEntity.ok(purchaseService.getPurchaseOrdersByStatus("APPROVED"));
    }
}
