package com.erp.controller;

import com.erp.domain.GoodReceipt;
import com.erp.domain.GoodReceiptLine;
import com.erp.domain.PurchaseOrder;
import com.erp.domain.PurchaseOrderLine;
import com.erp.service.PurchaseService;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/purchases/receipts")
public class PurchaseReceiptController {

    @Autowired
    private PurchaseService purchaseService;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @GetMapping
    public String list(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        model.addAttribute("receipts", purchaseService.getAllGoodReceipts());
        return "purchases/receipts-list";
    }

    @GetMapping("/new")
    public String form(Model model, Authentication auth, HttpSession session,
                       @RequestParam(required = false) Long orderId) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        GoodReceipt receipt = new GoodReceipt();
        receipt.setCommandeId(orderId);

        // Proposer uniquement les commandes VALIDEES (sinon createGoodReceipt refusera).
        List<PurchaseOrder> validatedOrders = purchaseService.getAllPurchaseOrders().stream()
            .filter(o -> o.getStatut() != null && "VALIDEE".equalsIgnoreCase(o.getStatut()))
            .collect(Collectors.toList());

        model.addAttribute("receipt", receipt);
        model.addAttribute("orders", validatedOrders);
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "purchases/receipt-form";
    }

    @GetMapping("/form")
    public String receiptForm(Model model, Authentication auth, HttpSession session, @RequestParam(required = false) Long id) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        GoodReceipt receipt = new GoodReceipt();
        
        // If id is provided, load existing receipt for editing
        if (id != null) {
            Optional<GoodReceipt> existingReceipt = purchaseService.getGoodReceipt(id);
            if (existingReceipt.isPresent()) {
                receipt = existingReceipt.get();
            }
        }

        // Load orders and warehouses for dropdowns
        List<PurchaseOrder> validatedOrders = purchaseService.getAllPurchaseOrders().stream()
            .filter(o -> o.getStatut() != null && "VALIDEE".equalsIgnoreCase(o.getStatut()))
            .collect(Collectors.toList());

        model.addAttribute("receipt", receipt);
        model.addAttribute("orders", validatedOrders);
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "purchases/receipt-form";
    }

    @PostMapping("/form")
    public String saveForm(@ModelAttribute GoodReceipt receipt, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            if (receipt.getId() != null && receipt.getId() > 0) {
                // Update existing receipt
                purchaseService.updateGoodReceipt(receipt, username);
            } else {
                // Create new receipt
                // Copier les lignes de la commande si disponibles (seed data / commandes via API)
                if (receipt.getCommandeId() != null) {
                    Optional<PurchaseOrder> orderOpt = purchaseService.getPurchaseOrder(receipt.getCommandeId());
                    if (orderOpt.isPresent() && orderOpt.get().getLines() != null) {
                        receipt.getLines().clear();
                        for (PurchaseOrderLine pol : orderOpt.get().getLines()) {
                            if (pol.getArticle() == null) continue;
                            GoodReceiptLine grl = new GoodReceiptLine();
                            grl.setReception(receipt);
                            grl.setArticle(pol.getArticle());
                            grl.setQuantite(pol.getQuantite() != null ? pol.getQuantite() : 0);
                            grl.setLocation(null);
                            grl.setBatchNumber(null);
                            grl.setSerialNumber(null);
                            grl.setNotes(null);
                            receipt.getLines().add(grl);
                        }
                    }
                }
                receipt = purchaseService.createGoodReceipt(receipt, username);
            }
            return "redirect:/purchases/receipts?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/receipts/form?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping
    public String create(@ModelAttribute GoodReceipt receipt, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            // Copier les lignes de la commande si disponibles (seed data / commandes via API)
            if (receipt.getCommandeId() != null) {
                Optional<PurchaseOrder> orderOpt = purchaseService.getPurchaseOrder(receipt.getCommandeId());
                if (orderOpt.isPresent() && orderOpt.get().getLines() != null) {
                    receipt.getLines().clear();
                    for (PurchaseOrderLine pol : orderOpt.get().getLines()) {
                        if (pol.getArticle() == null) continue;
                        GoodReceiptLine grl = new GoodReceiptLine();
                        grl.setReception(receipt);
                        grl.setArticle(pol.getArticle());
                        grl.setQuantite(pol.getQuantite() != null ? pol.getQuantite() : 0);
                        grl.setLocation(null);
                        grl.setBatchNumber(null);
                        grl.setSerialNumber(null);
                        grl.setNotes(null);
                        receipt.getLines().add(grl);
                    }
                }
            }

            GoodReceipt saved = purchaseService.createGoodReceipt(receipt, username);
            return "redirect:/purchases/receipts/" + saved.getId() + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/receipts/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @GetMapping("/{id}")
    public String detail(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) return "redirect:/login";

        Optional<GoodReceipt> receipt = purchaseService.getGoodReceipt(id);
        if (receipt.isEmpty()) {
            return "redirect:/purchases/receipts?error=Reception+introuvable";
        }
        model.addAttribute("receipt", receipt.get());

        if (receipt.get().getCommandeId() != null) {
            purchaseService.getPurchaseOrder(receipt.get().getCommandeId())
                .ifPresent(order -> model.addAttribute("order", order));
        }
        if (receipt.get().getEntrepotId() != null) {
            warehouseRepository.findById(receipt.get().getEntrepotId())
                .ifPresent(wh -> model.addAttribute("warehouse", wh));
        }

        return "purchases/receipt-detail";
    }

    @PostMapping("/{id}/validate")
    public String validate(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            purchaseService.validateGoodReceipt(id, username);
            return "redirect:/purchases/receipts/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/receipts/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/invoice")
    public String generateInvoice(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            Long invoiceId = purchaseService.generatePurchaseInvoiceFromReceipt(id, username).getId();
            return "redirect:/purchases/invoices/" + invoiceId + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/receipts/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/{id}/cancel")
    public String cancel(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            purchaseService.cancelGoodReceipt(id, username);
            return "redirect:/purchases/receipts?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/receipts?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // REST API
    @GetMapping("/api/{id}")
    @ResponseBody
    public ResponseEntity<?> getReceiptApi(@PathVariable Long id) {
        Optional<GoodReceipt> receipt = purchaseService.getGoodReceipt(id);
        if (receipt.isPresent()) {
            return ResponseEntity.ok(receipt.get());
        }
        return ResponseEntity.notFound().build();
    }
}
