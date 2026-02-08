package com.erp.controller;

import com.erp.domain.Article;
import com.erp.domain.Category;
import com.erp.domain.ClientRequest;
import com.erp.domain.Customer;
import com.erp.domain.Delivery;
import com.erp.domain.Invoice;
import com.erp.domain.Payment;
import com.erp.domain.SalesOrder;
import com.erp.domain.SalesProforma;
import com.erp.domain.User;
import com.erp.repository.ArticleRepository;
import com.erp.repository.CategoryRepository;
import com.erp.repository.ClientRequestRepository;
import com.erp.repository.CustomerRepository;
import com.erp.repository.DeliveryRepository;
import com.erp.repository.InvoiceRepository;
import com.erp.repository.PaymentRepository;
import com.erp.repository.SalesOrderRepository;
import com.erp.repository.SalesProformaRepository;
import com.erp.repository.UserRepository;
import com.erp.repository.WarehouseRepository;
import com.erp.service.CategoryService;
import com.erp.service.CustomerService;
import com.erp.service.SalesService;
import com.erp.service.SalesProformaService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestParam;

import javax.servlet.http.HttpSession;
import java.util.Collections;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/client")
public class ClientPortalController {

    @Autowired
    private CustomerRepository customerRepository;

    @Autowired
    private SalesOrderRepository salesOrderRepository;

    @Autowired
    private SalesProformaRepository salesProformaRepository;

    @Autowired
    private InvoiceRepository invoiceRepository;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private DeliveryRepository deliveryRepository;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private WarehouseRepository warehouseRepository;

    @Autowired
    private ArticleRepository articleRepository;

    @Autowired
    private CategoryRepository categoryRepository;

    @Autowired
    private CategoryService categoryService;

    @Autowired
    private ClientRequestRepository clientRequestRepository;

    @Autowired
    private SalesService salesService;

    @Autowired
    private SalesProformaService salesProformaService;

    @Autowired
    private CustomerService customerService;

    @GetMapping("/login")
    public String clientLogin() {
        return "client/login";
    }

    @GetMapping
    public String dashboard(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        List<SalesOrder> orders = customer != null ? salesOrderRepository.findByClientId(customer.getId()) : Collections.emptyList();
        List<Invoice> invoices = customer != null ? invoiceRepository.findByTiersIdAndTypeTiers(customer.getId(), "CLIENT") : Collections.emptyList();

        model.addAttribute("customer", customer);
        model.addAttribute("ordersCount", orders.size());
        model.addAttribute("invoicesCount", invoices.size());
        model.addAttribute("invoicesTotal", invoices.stream()
            .map(inv -> inv.getMontantTtc() != null ? inv.getMontantTtc() : java.math.BigDecimal.ZERO)
            .reduce(java.math.BigDecimal.ZERO, java.math.BigDecimal::add));
        return "client/dashboard";
    }

    @GetMapping("/orders")
    public String orders(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        List<SalesOrder> orders = customer != null ? salesOrderRepository.findByClientId(customer.getId()) : Collections.emptyList();
        model.addAttribute("customer", customer);
        model.addAttribute("orders", orders);
        return "client/orders-list";
    }

    @GetMapping("/orders/new")
    public String newOrder(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        model.addAttribute("customer", customer);
        model.addAttribute("order", new SalesOrder());
        model.addAttribute("warehouses", warehouseRepository.findAll());
        return "client/order-form";
    }

    @PostMapping("/orders")
    public String createOrder(@ModelAttribute SalesOrder order, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        if (customer == null) {
            return "redirect:/client/orders?error=Profil+client+introuvable";
        }

        ClientRequest request = new ClientRequest();
        request.setCustomerId(customer.getId());
        request.setRequestType("DEVIS");
        request.setStatut("EN_ATTENTE");
        request.setTitre("Demande devis client");
        StringBuilder desc = new StringBuilder("Demande issue du formulaire commande client");
        if (order.getEntrepotId() != null) {
            desc.append(" | Entrepot souhaite: ").append(order.getEntrepotId());
        }
        request.setDescription(desc.toString());
        request.setMontantEstime(order.getMontantHt());
        request.setDateCreation(java.time.LocalDateTime.now());
        request.setDateModification(java.time.LocalDateTime.now());
        try {
            clientRequestRepository.save(request);
            return "redirect:/client/requests?success=1";
        } catch (Exception e) {
            return "redirect:/client/orders/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @GetMapping("/proformas")
    public String proformas(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        List<SalesProforma> proformas = customer != null
            ? salesProformaRepository.findByClientId(customer.getId())
            : Collections.emptyList();
        model.addAttribute("customer", customer);
        model.addAttribute("proformas", proformas);
        return "client/proformas-list";
    }

    @PostMapping("/proformas/{id}/approve")
    public String approveProforma(@org.springframework.web.bind.annotation.PathVariable Long id,
                                  HttpSession session,
                                  Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }
        Customer customer = resolveCustomer(user);
        if (customer == null) {
            return "redirect:/client/proformas?error=Profil+client+introuvable";
        }
        SalesProforma proforma = salesProformaRepository.findById(id).orElse(null);
        if (proforma == null || !customer.getId().equals(proforma.getClientId())) {
            return "redirect:/client/proformas?error=Proforma+introuvable";
        }
        try {
            salesProformaService.validateByClient(id, user.getLogin());
            return "redirect:/client/proformas?success=1";
        } catch (Exception e) {
            return "redirect:/client/proformas?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @PostMapping("/proformas/{id}/reject")
    public String rejectProforma(@org.springframework.web.bind.annotation.PathVariable Long id,
                                 HttpSession session,
                                 Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }
        Customer customer = resolveCustomer(user);
        if (customer == null) {
            return "redirect:/client/proformas?error=Profil+client+introuvable";
        }
        SalesProforma proforma = salesProformaRepository.findById(id).orElse(null);
        if (proforma == null || !customer.getId().equals(proforma.getClientId())) {
            return "redirect:/client/proformas?error=Proforma+introuvable";
        }
        try {
            salesProformaService.reject(id, user.getLogin());
            return "redirect:/client/proformas?success=1";
        } catch (Exception e) {
            return "redirect:/client/proformas?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @GetMapping("/products")
    public String products(
            @RequestParam(required = false) String search,
            @RequestParam(required = false) Long categoryId,
            @RequestParam(required = false) java.math.BigDecimal priceMin,
            @RequestParam(required = false) java.math.BigDecimal priceMax,
            Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        // Get all active articles
        List<Article> articles = articleRepository.findByActifTrueOrderByLibelle();
        
        // Apply filters
        if (search != null && !search.isEmpty()) {
            String searchLower = search.toLowerCase();
            articles = articles.stream()
                .filter(a -> a.getCode().toLowerCase().contains(searchLower) 
                          || a.getLibelle().toLowerCase().contains(searchLower)
                          || (a.getDescription() != null && a.getDescription().toLowerCase().contains(searchLower)))
                .collect(Collectors.toList());
        }
        
        if (categoryId != null) {
            Optional<Category> category = categoryRepository.findById(categoryId);
            if (category.isPresent()) {
                articles = articles.stream()
                    .filter(a -> a.getCategory() != null && a.getCategory().getId().equals(categoryId))
                    .collect(Collectors.toList());
            }
        }
        
        if (priceMin != null) {
            articles = articles.stream()
                .filter(a -> a.getPrixUnitaire() != null && a.getPrixUnitaire().compareTo(priceMin) >= 0)
                .collect(Collectors.toList());
        }
        
        if (priceMax != null) {
            articles = articles.stream()
                .filter(a -> a.getPrixUnitaire() != null && a.getPrixUnitaire().compareTo(priceMax) <= 0)
                .collect(Collectors.toList());
        }
        
        // Get categories for filter dropdown
        List<Category> categories = categoryRepository.findByActifTrue();
        model.addAttribute("categories", categories);
        model.addAttribute("articles", articles);
        
        // Keep filter parameters for form
        model.addAttribute("filterSearch", search);
        model.addAttribute("filterCategoryId", categoryId);
        model.addAttribute("filterPriceMin", priceMin);
        model.addAttribute("filterPriceMax", priceMax);
        
        return "client/products";
    }

    @GetMapping("/requests")
    public String requests(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        List<ClientRequest> requests = customer != null
            ? clientRequestRepository.findByCustomerIdOrderByDateCreationDesc(customer.getId())
            : Collections.emptyList();
        model.addAttribute("articleNames", articleRepository.findByActifTrueOrderByLibelle().stream()
            .collect(Collectors.toMap(Article::getId, Article::getLibelle)));
        model.addAttribute("customer", customer);
        model.addAttribute("requests", requests);
        return "client/requests-list";
    }

    @GetMapping("/requests/new")
    public String newRequest(Model model,
                             HttpSession session,
                             Authentication auth,
                             @RequestParam(required = false) String type,
                             @RequestParam(required = false) Long articleId) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        model.addAttribute("request", new ClientRequest());
        model.addAttribute("requestType", type);
        model.addAttribute("articleId", articleId);
        model.addAttribute("articles", articleRepository.findByActifTrueOrderByLibelle());
        return "client/request-form";
    }

    @PostMapping("/requests")
    public String createRequest(@ModelAttribute ClientRequest request, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        if (customer == null) {
            return "redirect:/client/requests?error=Profil+client+introuvable";
        }

        request.setCustomerId(customer.getId());
        if (request.getStatut() == null || request.getStatut().trim().isEmpty()) {
            request.setStatut("EN_ATTENTE");
        }
        request.setDateCreation(java.time.LocalDateTime.now());
        request.setDateModification(java.time.LocalDateTime.now());
        try {
            clientRequestRepository.save(request);
            return "redirect:/client/requests?success=1";
        } catch (Exception e) {
            return "redirect:/client/requests/new?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    @GetMapping("/invoices")
    public String invoices(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        List<Invoice> invoices = customer != null ? invoiceRepository.findByTiersIdAndTypeTiers(customer.getId(), "CLIENT") : Collections.emptyList();
        model.addAttribute("customer", customer);
        model.addAttribute("invoices", invoices);
        return "client/invoices-list";
    }

    @GetMapping("/payments")
    public String payments(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        List<Invoice> invoices = customer != null
            ? invoiceRepository.findByTiersIdAndTypeTiers(customer.getId(), "CLIENT")
            : Collections.emptyList();
        List<Long> invoiceIds = invoices.stream().map(Invoice::getId).collect(Collectors.toList());
        List<Payment> payments = invoiceIds.isEmpty()
            ? Collections.emptyList()
            : paymentRepository.findByFactureIdIn(invoiceIds);

        model.addAttribute("customer", customer);
        model.addAttribute("payments", payments);
        model.addAttribute("invoicesById", invoices.stream().collect(Collectors.toMap(Invoice::getId, inv -> inv)));
        return "client/payments-list";
    }

    @GetMapping("/deliveries")
    public String deliveries(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        List<SalesOrder> orders = customer != null ? salesOrderRepository.findByClientId(customer.getId()) : Collections.emptyList();
        List<Long> orderIds = orders.stream().map(SalesOrder::getId).collect(Collectors.toList());
        List<Delivery> deliveries = orderIds.isEmpty() ? Collections.emptyList() : deliveryRepository.findByCommandeClientIdIn(orderIds);

        model.addAttribute("customer", customer);
        model.addAttribute("deliveries", deliveries);
        return "client/deliveries-list";
    }

    @GetMapping("/profile")
    public String profile(Model model, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        model.addAttribute("customer", customer);
        return "client/profile";
    }

    @GetMapping("/search")
    public String search(@RequestParam(required = false) String q,
                         Model model,
                         HttpSession session,
                         Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        String query = q != null ? q.trim() : "";
        Customer customer = resolveCustomer(user);

        // ✅ Charge les articles avec leurs catégories (Article + Catégorie + Prix TOUJOURS liés)
        List<Article> allArticles = articleRepository.findAllActiveWithCategory();
        List<Article> articles = filterArticles(allArticles, query);

        List<SalesOrder> allOrders = customer != null ? salesOrderRepository.findByClientId(customer.getId()) : Collections.emptyList();
        List<SalesOrder> orders = filterOrders(allOrders, query);

        List<Invoice> allInvoices = customer != null
            ? invoiceRepository.findByTiersIdAndTypeTiers(customer.getId(), "CLIENT")
            : Collections.emptyList();
        List<Invoice> invoices = filterInvoices(allInvoices, query);

        List<SalesProforma> allProformas = customer != null
            ? salesProformaRepository.findByClientId(customer.getId())
            : Collections.emptyList();
        List<SalesProforma> proformas = filterProformas(allProformas, query);

        List<Long> orderIds = allOrders.stream().map(SalesOrder::getId).collect(Collectors.toList());
        List<Delivery> allDeliveries = orderIds.isEmpty()
            ? Collections.emptyList()
            : deliveryRepository.findByCommandeClientIdIn(orderIds);
        List<Delivery> deliveries = filterDeliveries(allDeliveries, query);

        List<Long> invoiceIds = allInvoices.stream().map(Invoice::getId).collect(Collectors.toList());
        List<Payment> allPayments = invoiceIds.isEmpty()
            ? Collections.emptyList()
            : paymentRepository.findByFactureIdIn(invoiceIds);
        List<Payment> payments = filterPayments(allPayments, query);

        List<ClientRequest> allRequests = customer != null
            ? clientRequestRepository.findByCustomerIdOrderByDateCreationDesc(customer.getId())
            : Collections.emptyList();
        List<ClientRequest> requests = filterRequests(allRequests, query);

        model.addAttribute("customer", customer);
        model.addAttribute("query", query);
        model.addAttribute("articles", articles);
        model.addAttribute("orders", orders);
        model.addAttribute("invoices", invoices);
        model.addAttribute("proformas", proformas);
        model.addAttribute("deliveries", deliveries);
        model.addAttribute("payments", payments);
        model.addAttribute("requests", requests);
        model.addAttribute("articleNames", allArticles.stream()
            .collect(Collectors.toMap(Article::getId, Article::getLibelle)));
        model.addAttribute("invoicesById", allInvoices.stream()
            .collect(Collectors.toMap(Invoice::getId, inv -> inv)));
        return "client/search";
    }

    @PostMapping("/profile")
    public String updateProfile(@ModelAttribute Customer form, HttpSession session, Authentication auth) {
        User user = resolveUser(session, auth);
        if (user == null) {
            return "redirect:/client/login";
        }
        if (!hasAccess(user)) {
            return "redirect:/dashboard";
        }

        Customer customer = resolveCustomer(user);
        if (customer == null) {
            return "redirect:/client/profile?error=Profil+client+introuvable";
        }

        Customer updated = new Customer();
        updated.setId(customer.getId());
        updated.setCode(customer.getCode());
        updated.setNomEntreprise(customer.getNomEntreprise());
        updated.setLimiteCreditInitiale(customer.getLimiteCreditInitiale());
        updated.setLimiteCreditActuelle(customer.getLimiteCreditActuelle());
        updated.setRemisePourcentage(customer.getRemisePourcentage());
        updated.setDelaiPaiementJours(customer.getDelaiPaiementJours());
        updated.setActif(customer.getActif());

        updated.setEmail(form.getEmail());
        updated.setTelephone(form.getTelephone());
        updated.setAdresse(form.getAdresse());
        updated.setVille(form.getVille());
        updated.setCodePostal(form.getCodePostal());
        updated.setContactPrincipal(form.getContactPrincipal());

        try {
            customerService.updateCustomer(updated, user.getLogin());
            return "redirect:/client/profile?success=1";
        } catch (Exception e) {
            return "redirect:/client/profile?error=" + ControllerHelper.urlEncode(e.getMessage());
        }
    }

    private User resolveUser(HttpSession session, Authentication auth) {
        User user = session != null ? (User) session.getAttribute("user") : null;
        if (user == null && auth != null && auth.isAuthenticated()) {
            return userRepository.findByLogin(auth.getName()).orElse(null);
        }
        return user;
    }

    private boolean hasAccess(User user) {
        if (user == null || user.getRoles() == null) return false;
        return user.getRoles().stream().anyMatch(r -> "CLIENT".equalsIgnoreCase(r.getCode()) || "ADMIN".equalsIgnoreCase(r.getCode()));
    }

    private Customer resolveCustomer(User user) {
        if (user == null) return null;
        if (user.getEmail() != null) {
            Optional<Customer> byEmail = customerRepository.findByEmail(user.getEmail());
            if (byEmail.isPresent()) return byEmail.get();
        }
        return null;
    }

    private boolean matches(String query, String... values) {
        if (query == null || query.isEmpty()) return true;
        String needle = query.toLowerCase();
        for (String value : values) {
            if (value != null && value.toLowerCase().contains(needle)) {
                return true;
            }
        }
        return false;
    }

    private List<Article> filterArticles(List<Article> articles, String query) {
        if (query == null || query.isEmpty()) return articles;
        return articles.stream()
            .filter(a -> {
                // Filtre par code, libelle, ou description
                boolean codeMatch = matches(query, safe(a.getCode()), safe(a.getLibelle()), safe(a.getDescription()));
                // Filtre aussi par catégorie si disponible
                boolean categoryMatch = a.getCategory() != null && 
                                       matches(query, safe(a.getCategory().getCode()), safe(a.getCategory().getLibelle()));
                return codeMatch || categoryMatch;
            })
            .collect(Collectors.toList());
    }

    private List<SalesOrder> filterOrders(List<SalesOrder> orders, String query) {
        if (query == null || query.isEmpty()) return orders;
        return orders.stream()
            .filter(o -> matches(query,
                safe(o.getNumero()),
                safe(o.getStatut()),
                String.valueOf(o.getId())
            ))
            .collect(Collectors.toList());
    }

    private List<Invoice> filterInvoices(List<Invoice> invoices, String query) {
        if (query == null || query.isEmpty()) return invoices;
        return invoices.stream()
            .filter(i -> matches(query,
                safe(i.getNumero()),
                safe(i.getStatut()),
                safe(i.getTypeFacture()),
                String.valueOf(i.getId())
            ))
            .collect(Collectors.toList());
    }

    private List<Delivery> filterDeliveries(List<Delivery> deliveries, String query) {
        if (query == null || query.isEmpty()) return deliveries;
        return deliveries.stream()
            .filter(d -> matches(query,
                safe(d.getNumero()),
                safe(d.getStatut()),
                String.valueOf(d.getCommandeClientId())
            ))
            .collect(Collectors.toList());
    }

    private List<Payment> filterPayments(List<Payment> payments, String query) {
        if (query == null || query.isEmpty()) return payments;
        return payments.stream()
            .filter(p -> matches(query,
                safe(p.getNumero()),
                safe(p.getStatut()),
                safe(p.getMoyenPaiement()),
                safe(p.getReferenceTransaction()),
                String.valueOf(p.getFactureId())
            ))
            .collect(Collectors.toList());
    }

    private List<ClientRequest> filterRequests(List<ClientRequest> requests, String query) {
        if (query == null || query.isEmpty()) return requests;
        return requests.stream()
            .filter(r -> matches(query,
                safe(r.getRequestType()),
                safe(r.getStatut()),
                safe(r.getTitre()),
                safe(r.getDescription())
            ))
            .collect(Collectors.toList());
    }

    private List<SalesProforma> filterProformas(List<SalesProforma> proformas, String query) {
        if (query == null || query.isEmpty()) return proformas;
        return proformas.stream()
            .filter(p -> matches(query,
                safe(p.getNumero()),
                safe(p.getStatut()),
                String.valueOf(p.getId())
            ))
            .collect(Collectors.toList());
    }

    private String safe(String value) {
        return value != null ? value : "";
    }
}
