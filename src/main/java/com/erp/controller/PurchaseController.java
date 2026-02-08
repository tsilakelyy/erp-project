package com.erp.controller;

import com.erp.domain.*;
import com.erp.service.PurchaseService;
import com.erp.service.SupplierService;
import com.erp.repository.WarehouseRepository;
import com.erp.repository.ProformaRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
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
    private WarehouseRepository warehouseRepository;

    @Autowired
    private ProformaRepository proformaRepository;

    // ===== Purchase Requests =====
    @GetMapping("/requests")
    public String listRequests(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<PurchaseRequest> requests = purchaseService.getAllPurchaseRequests();
        model.addAttribute("requests", requests);
        return "purchases/requests-list";
    }

    @GetMapping("/requests/{id}")
    public String detailRequest(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<PurchaseRequest> request = purchaseService.getPurchaseRequest(id);
        if (request.isPresent()) {
            model.addAttribute("request", request.get());

            User sessionUser = (User) session.getAttribute("user");
            boolean isAdmin = sessionUser != null && sessionUser.getRoles() != null
                && sessionUser.getRoles().stream().anyMatch(r -> "ADMIN".equalsIgnoreCase(r.getCode()));
            boolean isFinance = sessionUser != null && sessionUser.getRoles() != null
                && sessionUser.getRoles().stream().anyMatch(r -> "FINANCE".equalsIgnoreCase(r.getCode()));
            boolean isDirection = sessionUser != null && sessionUser.getRoles() != null
                && sessionUser.getRoles().stream().anyMatch(r -> "DIRECTION".equalsIgnoreCase(r.getCode()));
            model.addAttribute("isFinance", isFinance || isAdmin);
            model.addAttribute("isDirection", isDirection || isAdmin);
            return "purchases/request-detail";
        }
        return "redirect:/purchases/requests";
    }

    @GetMapping("/requests/new")
    public String createRequestForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        model.addAttribute("request", new PurchaseRequest());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "purchases/request-form";
    }

    @PostMapping("/requests")
    public String createRequest(@ModelAttribute PurchaseRequest request, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            PurchaseRequest saved = purchaseService.createPurchaseRequest(request, username);
            return "redirect:/purchases/requests?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/requests/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/requests/{id}/submit")
    public String submitRequest(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            purchaseService.submitPurchaseRequest(id, username);
            return "redirect:/purchases/requests/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/requests/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/requests/{id}/approve")
    public String approveRequest(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            purchaseService.approvePurchaseRequest(id, username);
            return "redirect:/purchases/requests/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/requests/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/requests/{id}/validate-finance")
    public String validateRequestFinance(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        User sessionUser = (User) session.getAttribute("user");
        boolean isAdmin = sessionUser != null && sessionUser.getRoles() != null
            && sessionUser.getRoles().stream().anyMatch(r -> "ADMIN".equalsIgnoreCase(r.getCode()));
        boolean isFinance = sessionUser != null && sessionUser.getRoles() != null
            && sessionUser.getRoles().stream().anyMatch(r -> "FINANCE".equalsIgnoreCase(r.getCode()));
        if (!isFinance && !isAdmin) {
            return "redirect:/purchases/requests/" + id + "?error=Validation+reservee+au+role+FINANCE";
        }

        try {
            purchaseService.validateRequestFinance(id, username);
            return "redirect:/purchases/requests/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/requests/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/requests/{id}/validate-direction")
    public String validateRequestDirection(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        User sessionUser = (User) session.getAttribute("user");
        boolean isAdmin = sessionUser != null && sessionUser.getRoles() != null
            && sessionUser.getRoles().stream().anyMatch(r -> "ADMIN".equalsIgnoreCase(r.getCode()));
        boolean isDirection = sessionUser != null && sessionUser.getRoles() != null
            && sessionUser.getRoles().stream().anyMatch(r -> "DIRECTION".equalsIgnoreCase(r.getCode()));
        if (!isDirection && !isAdmin) {
            return "redirect:/purchases/requests/" + id + "?error=Validation+reservee+au+role+DIRECTION";
        }

        try {
            purchaseService.validateRequestDirection(id, username);
            return "redirect:/purchases/requests/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/requests/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/requests/{id}/reject")
    public String rejectRequest(@PathVariable Long id,
                                @RequestParam(required = false) String motif,
                                Authentication auth,
                                HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) return "redirect:/login";

        try {
            purchaseService.rejectPurchaseRequest(id, motif, username);
            return "redirect:/purchases/requests/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/requests/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== Purchase Orders =====
    @GetMapping("/orders")
    public String listOrders(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<PurchaseOrder> orders = purchaseService.getAllPurchaseOrders();
        model.addAttribute("orders", orders);
        return "purchases/orders-list";
    }

    @GetMapping("/orders/{id}")
    public String detailOrder(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<PurchaseOrder> order = purchaseService.getPurchaseOrder(id);
        if (order.isPresent()) {
            model.addAttribute("order", order.get());
            return "purchases/order-detail";
        }
        return "redirect:/purchases/orders";
    }

    @GetMapping("/orders/new")
    public String createOrderForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        model.addAttribute("order", new PurchaseOrder());
        model.addAttribute("suppliers", supplierService.findAllActive());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        List<Proforma> available = proformaRepository.findAll().stream()
            .filter(p -> p.getStatut() != null)
            .filter(p -> {
                String s = p.getStatut().toUpperCase();
                return s.equals("VALIDEE") || s.equals("APPROUVEE");
            })
            .collect(java.util.stream.Collectors.toList());
        model.addAttribute("proformas", available);
        return "purchases/order-form";
    }

    @PostMapping("/orders")
    public String createOrder(@ModelAttribute PurchaseOrder order, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            PurchaseOrder saved = purchaseService.createPurchaseOrder(order, username);
            return "redirect:/purchases/orders?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/orders/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/orders/{id}/submit")
    public String submitOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            purchaseService.submitPurchaseOrder(id, username);
            return "redirect:/purchases/orders/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/orders/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/orders/{id}/approve")
    public String approveOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            purchaseService.approvePurchaseOrder(id, username);
            return "redirect:/purchases/orders/" + id;
        } catch (Exception e) {
            return "redirect:/purchases/orders/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/orders/{id}/cancel")
    public String cancelOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            purchaseService.cancelPurchaseOrder(id, username);
            return "redirect:/purchases/orders?success=1";
        } catch (Exception e) {
            return "redirect:/purchases/orders?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/orders/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable Long id, @RequestBody PurchaseOrder updatedOrder, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        try {
            Optional<PurchaseOrder> existingOpt = purchaseService.getPurchaseOrder(id);
            if (!existingOpt.isPresent()) {
                return ResponseEntity.status(HttpStatus.NOT_FOUND).body("Order not found");
            }
            
            PurchaseOrder existingOrder = existingOpt.get();
            // Update only safe fields
            existingOrder.setFournisseurId(updatedOrder.getFournisseurId());
            existingOrder.setMontantTtc(updatedOrder.getMontantTtc());
            existingOrder.setStatut(updatedOrder.getStatut());

            // Save directly to repository since service doesn't have update method
            purchaseService.savePurchaseOrder(existingOrder);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }

    @GetMapping("/orders/form")
    public String orderForm(Model model, Authentication auth, HttpSession session, @RequestParam(required = false) Long id) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        
        PurchaseOrder order = new PurchaseOrder();
        
        // If id is provided, load existing order for editing
        if (id != null) {
            Optional<PurchaseOrder> existingOrder = purchaseService.getPurchaseOrder(id);
            if (existingOrder.isPresent()) {
                order = existingOrder.get();
            }
        }
        
        // Load all suppliers and warehouses for dropdowns
        model.addAttribute("order", order);
        model.addAttribute("suppliers", supplierService.findAll());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "purchases/order-form";
    }

    @PostMapping("/orders/form")
    public String saveOrderForm(@ModelAttribute PurchaseOrder order, 
                                Authentication auth, 
                                HttpSession session,
                                RedirectAttributes redirectAttributes) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }

        try {
            if (order.getId() != null && order.getId() > 0) {
                // Update existing order
                Optional<PurchaseOrder> existingOpt = purchaseService.getPurchaseOrder(order.getId());
                if (existingOpt.isPresent()) {
                    PurchaseOrder existing = existingOpt.get();
                    existing.setFournisseurId(order.getFournisseurId());
                    existing.setMontantHt(order.getMontantHt());
                    existing.setTauxTva(order.getTauxTva());
                    existing.setStatut(order.getStatut());
                    purchaseService.savePurchaseOrder(existing);
                }
            } else {
                // Create new order
                purchaseService.createPurchaseOrder(order, username);
            }
            return "redirect:/purchases/orders";
        } catch (Exception e) {
            redirectAttributes.addAttribute("error", e.getMessage());
            return "redirect:/purchases/orders/form";
        }
    }

    // REST API
    @GetMapping("/api/requests")
    @ResponseBody
    public ResponseEntity<List<PurchaseRequest>> getRequests() {
        return ResponseEntity.ok(purchaseService.getPurchaseRequestsByStatus("EN_ATTENTE"));
    }

    @GetMapping("/api/orders")
    @ResponseBody
    public ResponseEntity<List<PurchaseOrder>> getOrders() {
        return ResponseEntity.ok(purchaseService.getPurchaseOrdersByStatus("EN_COURS"));
    }

    @GetMapping("/api/orders/{id}")
    @ResponseBody
    public ResponseEntity<?> getOrder(@PathVariable Long id) {
        Optional<PurchaseOrder> order = purchaseService.getPurchaseOrder(id);
        if (order.isPresent()) {
            return ResponseEntity.ok(order.get());
        }
        return ResponseEntity.notFound().build();
    }
}
