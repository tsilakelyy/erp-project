package com.erp.controller;

import com.erp.dto.KpiDTO;
import com.erp.domain.User;
import com.erp.repository.UserRepository;
import com.erp.service.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import javax.servlet.http.HttpSession;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Controller
@RequestMapping("/dashboard")
public class DashboardController {
    @Autowired
    private PurchaseService purchaseService;

    @Autowired
    private SalesService salesService;

    @Autowired
    @SuppressWarnings("unused")
    private StockService stockService;

    @Autowired
    @SuppressWarnings("unused")
    private UserService userService;

    /**
     * Dashboard principal
     */
    @GetMapping
    public String dashboard(Model model, HttpSession session) {
        // Vérification session
        User user = (User) session.getAttribute("user");
        if (user == null) {
            return "redirect:/login";
        }

        model.addAttribute("username", user.getLogin());
        model.addAttribute("nom", user.getNom());
        model.addAttribute("prenom", user.getPrenom());
        
        // Récupération rôles pour affichage
        if (user.getRoles() != null) {
            model.addAttribute("roles", user.getRoles());
        }

        return "dashboard";
    }

       @GetMapping("/direction")
    public String directionDashboard(Model model, Authentication auth) {
        if (auth == null) return "redirect:/login";
        
        String username = auth.getName();
        model.addAttribute("username", username);
        
        // Create KPIs for direction dashboard
        KpiDTO purchaseKpi = KpiDTO.builder()
            .kpiName("Pending Orders")
            .value(purchaseService.getPurchaseOrdersByStatus("APPROVED").size())
            .unit("orders")
            .period("current")
            .trend("stable")
            .target(BigDecimal.valueOf(50))
            .calculatedAt(LocalDateTime.now())
            .build();
            
        KpiDTO deliveryKpi = KpiDTO.builder()
            .kpiName("Pending Deliveries")
            .value(salesService.getDeliveriesByStatus("SHIPPED").size())
            .unit("shipments")
            .period("current")
            .trend("increasing")
            .target(BigDecimal.valueOf(30))
            .calculatedAt(LocalDateTime.now())
            .build();
        
        model.addAttribute("purchaseKpi", purchaseKpi);
        model.addAttribute("deliveryKpi", deliveryKpi);
        
        return "dashboard/direction";
    }

    @GetMapping("/achats")
    public String purchaseDashboard(Model model, Authentication auth) {
        if (auth == null) return "redirect:/login";
        
        String username = auth.getName();
        model.addAttribute("username", username);
        model.addAttribute("draftRequests", purchaseService.getPurchaseRequestsByStatus("DRAFT").size());
        model.addAttribute("approvedRequests", purchaseService.getPurchaseRequestsByStatus("APPROVED").size());
        return "dashboard/achats";
    }

    @GetMapping("/stocks")
    public String stockDashboard(Model model, Authentication auth) {
        if (auth == null) return "redirect:/login";
        
        String username = auth.getName();
        model.addAttribute("username", username);
        return "dashboard/stocks";
    }

    @GetMapping("/ventes")
    public String salesDashboard(Model model, Authentication auth) {
        if (auth == null) return "redirect:/login";
        
        String username = auth.getName();
        model.addAttribute("username", username);
        model.addAttribute("pendingOrders", salesService.getSalesOrdersByStatus("DRAFT").size());
        return "dashboard/ventes";
    }

    @GetMapping("/finance")
    public String financeDashboard(Model model, Authentication auth) {
        if (auth == null) return "redirect:/login";
        
        String username = auth.getName();
        model.addAttribute("username", username);
        return "dashboard/finance";
    }
}