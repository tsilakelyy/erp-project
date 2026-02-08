package com.erp.controller;

import com.erp.domain.*;
import com.erp.repository.ArticleRepository;
import com.erp.repository.ClientRequestRepository;
import com.erp.repository.CustomerRepository;
import com.erp.service.SalesService;
import com.erp.service.CustomerService;
import com.erp.service.StockService;
import com.erp.service.SalesProformaService;
import com.erp.repository.WarehouseRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import javax.servlet.http.HttpSession;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Arrays;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Controller
@RequestMapping("/sales")
public class SalesController {
    private static final Logger log = LoggerFactory.getLogger(SalesController.class);

    @Autowired
    private SalesService salesService;

    @Autowired
    private CustomerService customerService;

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private ClientRequestRepository clientRequestRepository;

    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    @SuppressWarnings("unused")
    private StockService stockService;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private SalesProformaService salesProformaService;

    // ===== Sales Orders =====
    @GetMapping("/orders")
    public String listOrders(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<SalesOrder> orders = salesService.getAllSalesOrders();
        model.addAttribute("orders", orders);
        return "sales/orders-list";
    }

    // ===== Sales Proformas (devis) =====
    @GetMapping("/proformas")
    public String listProformas(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<SalesProforma> proformas = salesProformaService.findAll();
        Map<Long, String> customerNames = customerRepository.findAll().stream()
            .collect(Collectors.toMap(Customer::getId, Customer::getNomEntreprise));
        model.addAttribute("proformas", proformas);
        model.addAttribute("customerNames", customerNames);
        return "sales/proformas-list";
    }

    @GetMapping("/proformas/new")
    public String createProformaForm(Model model, Authentication auth, HttpSession session,
                                     @RequestParam(required = false) Long requestId) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        SalesProforma proforma = new SalesProforma();
        proforma.setRequestId(requestId);
        if (requestId != null) {
            clientRequestRepository.findById(requestId).ifPresent(req -> {
                proforma.setClientId(req.getCustomerId());
                proforma.setMontantHt(req.getMontantEstime());
            });
        }
        model.addAttribute("proforma", proforma);
        model.addAttribute("customers", customerService.findAllActive());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "sales/proforma-form";
    }

    @PostMapping("/proformas")
    public String createProforma(@ModelAttribute SalesProforma proforma, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            SalesProforma saved = salesProformaService.create(proforma, username);
            return "redirect:/sales/proformas?success=1";
        } catch (Exception e) {
            return "redirect:/sales/proformas/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @GetMapping("/proformas/{id}")
    public String detailProforma(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<SalesProforma> proforma = salesProformaService.get(id);
        if (proforma.isEmpty()) {
            return "redirect:/sales/proformas?error=Proforma+introuvable";
        }
        model.addAttribute("proforma", proforma.get());
        customerRepository.findById(proforma.get().getClientId())
            .ifPresent(c -> model.addAttribute("customer", c));
        warehouseRepository.findById(proforma.get().getEntrepotId())
            .ifPresent(w -> model.addAttribute("warehouse", w));
        return "sales/proforma-detail";
    }

    @PostMapping("/proformas/{id}/validate")
    public String validateProforma(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesProformaService.validateByClient(id, username);
            return "redirect:/sales/proformas/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/sales/proformas/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/proformas/{id}/reject")
    public String rejectProforma(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesProformaService.reject(id, username);
            return "redirect:/sales/proformas/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/sales/proformas/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/proformas/{id}/to-order")
    public String proformaToOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            SalesOrder order = salesService.createSalesOrderFromProforma(id, username);
            return "redirect:/sales/orders/" + order.getId() + "?success=1";
        } catch (Exception e) {
            return "redirect:/sales/proformas/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @GetMapping("/orders/{id}")
    public String detailOrder(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<SalesOrder> order = salesService.getSalesOrder(id);
        if (order.isPresent()) {
            model.addAttribute("order", order.get());
            return "sales/order-detail";
        }
        return "redirect:/sales/orders";
    }

    @GetMapping("/orders/new")
    public String createOrderForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        return "sales/order-form";
    }

    @PostMapping("/orders")
    public String createOrder(@ModelAttribute SalesOrder order, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            if (order.getProformaId() == null) {
                return "redirect:/sales/proformas?error=La+commande+doit+etre+cree+depuis+une+proforma+client+validee";
            }
            SalesOrder saved = salesService.createSalesOrder(order, username);
            return "redirect:/sales/orders/" + saved.getId() + "?success=1";
        } catch (Exception e) {
            return "redirect:/sales/proformas?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/orders/{id}/approve")
    public String approveOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesService.approveSalesOrder(id, username);
            return "redirect:/sales/orders/" + id;
        } catch (Exception e) {
            return "redirect:/sales/orders/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/orders/{id}/cancel")
    public String cancelOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesService.cancelSalesOrder(id, username);
            return "redirect:/sales/orders?success=1";
        } catch (Exception e) {
            return "redirect:/sales/orders?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== Deliveries =====
    @GetMapping("/deliveries")
    public String listDeliveries(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<Delivery> deliveries = salesService.getAllDeliveries();
        model.addAttribute("deliveries", deliveries);
        return "sales/deliveries-list";
    }

    @GetMapping("/deliveries/form")
    public String deliveryForm(Model model, Authentication auth, HttpSession session, @RequestParam(required = false) Long id) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        
        Delivery delivery = new Delivery();
        
        // If id is provided, load existing delivery for editing
        if (id != null) {
            Optional<Delivery> existingDelivery = salesService.getDelivery(id);
            if (existingDelivery.isPresent()) {
                delivery = existingDelivery.get();
            }
        }
        
        model.addAttribute("delivery", delivery);
        return "sales/delivery-form";
    }

    @PostMapping("/deliveries/form")
    public String saveDeliveryForm(@ModelAttribute Delivery delivery, 
                                   Authentication auth, 
                                   HttpSession session,
                                   RedirectAttributes redirectAttributes) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }

        try {
            // Create new delivery (editing not allowed for deliveries)
            salesService.createDelivery(delivery, username);
            return "redirect:/sales/deliveries";
        } catch (Exception e) {
            redirectAttributes.addAttribute("error", e.getMessage());
            return "redirect:/sales/deliveries/form";
        }
    }

    @GetMapping("/deliveries/{id}")
    public String detailDelivery(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Delivery> delivery = salesService.getDelivery(id);
        if (delivery.isPresent()) {
            model.addAttribute("delivery", delivery.get());
            return "sales/delivery-detail";
        }
        return "redirect:/sales/deliveries";
    }

    @PostMapping("/deliveries/{id}/ship")
    public String shipDelivery(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesService.shipDelivery(id, username);
            return "redirect:/sales/deliveries/" + id;
        } catch (Exception e) {
            return "redirect:/sales/deliveries/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/deliveries/{id}/receive")
    public String receiveDelivery(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesService.receiveDelivery(id, username);
            return "redirect:/sales/deliveries/" + id;
        } catch (Exception e) {
            return "redirect:/sales/deliveries/" + id + "?error=" + e.getMessage();
        }
    }

    @PostMapping("/deliveries/{id}/cancel")
    public String cancelDelivery(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesService.cancelDelivery(id, username);
            return "redirect:/sales/deliveries?success=1";
        } catch (Exception e) {
            return "redirect:/sales/deliveries?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== Invoices =====
    @GetMapping("/invoices")
    public String listInvoices(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        List<Invoice> invoices = salesService.getAllInvoices();
        model.addAttribute("invoices", invoices);
        return "sales/invoices-list";
    }

    @GetMapping("/invoices/{id}")
    public String detailInvoice(@PathVariable Long id, Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<Invoice> invoice = salesService.getInvoice(id);
        if (invoice.isPresent()) {
            model.addAttribute("invoice", invoice.get());
            return "sales/invoice-detail";
        }
        return "redirect:/sales/invoices";
    }

    @PostMapping("/invoices/{id}/cancel")
    public String cancelInvoice(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesService.cancelInvoice(id, username);
            return "redirect:/sales/invoices?success=1";
        } catch (Exception e) {
            return "redirect:/sales/invoices?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/invoices/{id}/pay")
    public String payInvoice(@PathVariable Long id,
                             @RequestParam(required = false) java.math.BigDecimal montant,
                             @RequestParam(required = false) String moyenPaiement,
                             @RequestParam(required = false) String reference,
                             Authentication auth,
                             HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            salesService.recordPayment(id, montant, moyenPaiement, reference, username);
            return "redirect:/sales/invoices/" + id + "?success=1";
        } catch (Exception e) {
            return "redirect:/sales/invoices/" + id + "?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== Client Requests =====
    @GetMapping("/client-requests")
    public String listClientRequests(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }

        List<ClientRequest> requests = clientRequestRepository.findAll();
        Map<Long, String> customerNames = customerRepository.findAll().stream()
            .collect(Collectors.toMap(Customer::getId, Customer::getNomEntreprise));
        Map<Long, String> articleNames = articleRepository.findAll().stream()
            .collect(Collectors.toMap(Article::getId, Article::getLibelle));

        model.addAttribute("requests", requests);
        model.addAttribute("customerNames", customerNames);
        model.addAttribute("articleNames", articleNames);
        log.info("Fetching client requests: {}", requests.size());
        log.info("Customer names: {}", customerNames);
        log.info("Article names: {}", articleNames);
        return "sales/client-requests";
    }

    @PostMapping("/client-requests/{id}/to-order")
    public String transformRequestToOrder(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        try {
            Optional<ClientRequest> request = clientRequestRepository.findById(id);
            if (request.isEmpty()) {
                return "redirect:/sales/client-requests?error=Demande+introuvable";
            }
            ClientRequest req = request.get();
            SalesProforma proforma = new SalesProforma();
            proforma.setRequestId(req.getId());
            proforma.setClientId(req.getCustomerId());
            proforma.setMontantHt(req.getMontantEstime());
            proforma.setTauxTva(new java.math.BigDecimal("20.00"));
            SalesProforma saved = salesProformaService.create(proforma, username);
            return "redirect:/sales/proformas/" + saved.getId() + "?success=1";
        } catch (Exception e) {
            return "redirect:/sales/client-requests?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    // ===== Bons (reduction/achat) =====
    @GetMapping("/bons")
    public String listBons(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }

        List<String> types = Arrays.asList("BON_REDUCTION", "BON_ACHAT", "DISCOUNT_REQUEST", "PURCHASE_VOUCHER");
        List<ClientRequest> requests = clientRequestRepository.findByRequestTypeInOrderByDateCreationDesc(types);
        Map<Long, String> customerNames = customerRepository.findAll().stream()
            .collect(Collectors.toMap(Customer::getId, Customer::getNomEntreprise));

        model.addAttribute("requests", requests);
        model.addAttribute("customerNames", customerNames);
        return "sales/bons-list";
    }

    @PostMapping("/bons/{id}/approve")
    public String approveBon(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<ClientRequest> request = clientRequestRepository.findById(id);
        if (request.isEmpty()) {
            return "redirect:/sales/bons?error=Bon+introuvable";
        }
        ClientRequest req = request.get();
        req.setStatut("VALIDEE");
        req.setDateModification(java.time.LocalDateTime.now());
        clientRequestRepository.save(req);
        return "redirect:/sales/bons?success=1";
    }

    @PostMapping("/bons/{id}/reject")
    public String rejectBon(@PathVariable Long id, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        Optional<ClientRequest> request = clientRequestRepository.findById(id);
        if (request.isEmpty()) {
            return "redirect:/sales/bons?error=Bon+introuvable";
        }
        ClientRequest req = request.get();
        req.setStatut("REJETEE");
        req.setDateModification(java.time.LocalDateTime.now());
        clientRequestRepository.save(req);
        return "redirect:/sales/bons?success=1";
    }

    @GetMapping("/orders/form")
    public String orderForm(Model model, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(model, session, auth);
        if (username == null) {
            return "redirect:/login";
        }
        return "sales/order-form";
    }

    @PostMapping("/orders/form")
    public String saveOrderForm(@ModelAttribute SalesOrder order, 
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
                Optional<SalesOrder> existingOpt = salesService.getSalesOrder(order.getId());
                if (existingOpt.isPresent()) {
                    SalesOrder existing = existingOpt.get();
                    existing.setClientId(order.getClientId());
                    existing.setMontantTtc(order.getMontantTtc());
                    existing.setStatut(order.getStatut());
                    salesService.updateSalesOrder(existing, username);
                }
            } else {
                // Create new order
                order.setStatut("PROVISOIRE");
                salesService.createSalesOrder(order, username);
            }
            return "redirect:/sales/orders";
        } catch (Exception e) {
            redirectAttributes.addAttribute("error", e.getMessage());
            return "redirect:/sales/orders/form";
        }
    }

    // REST API
    @GetMapping("/api/orders")
    @ResponseBody
    public ResponseEntity<List<SalesOrder>> getOrders() {
        return ResponseEntity.ok(salesService.getSalesOrdersByStatus("VALIDEE"));
    }

    @GetMapping("/api/orders/{id}")
    @ResponseBody
    public ResponseEntity<?> getOrder(@PathVariable Long id) {
        Optional<SalesOrder> order = salesService.getSalesOrder(id);
        if (order.isPresent()) {
            return ResponseEntity.ok(order.get());
        }
        return ResponseEntity.notFound().build();
    }

    @GetMapping("/api/deliveries")
    @ResponseBody
    public ResponseEntity<List<Delivery>> getDeliveries() {
        return ResponseEntity.ok(salesService.getDeliveriesByStatus("EXPEDIEE"));
    }

    @GetMapping("/api/deliveries/{id}")
    @ResponseBody
    public ResponseEntity<?> getDelivery(@PathVariable Long id) {
        Optional<Delivery> delivery = salesService.getDelivery(id);
        if (delivery.isPresent()) {
            return ResponseEntity.ok(delivery.get());
        }
        return ResponseEntity.notFound().build();
    }

    @PostMapping("/orders/{id}")
    public ResponseEntity<?> updateOrder(@PathVariable Long id, @RequestBody SalesOrder updatedOrder, Authentication auth, HttpSession session) {
        String username = ControllerHelper.resolveUsername(null, session, auth);
        if (username == null) {
            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).build();
        }

        try {
            SalesOrder existingOrder = salesService.getSalesOrder(id).orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "Order not found"));

            // Update the fields of the existing order
            existingOrder.setClientId(updatedOrder.getClientId());
            existingOrder.setMontantTtc(updatedOrder.getMontantTtc());
            existingOrder.setStatut(updatedOrder.getStatut());

            salesService.updateSalesOrder(existingOrder, username);
            return ResponseEntity.ok().build();
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(e.getMessage());
        }
    }
}
