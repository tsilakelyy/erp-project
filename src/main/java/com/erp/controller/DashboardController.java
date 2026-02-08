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
import java.util.Map;

@Controller
@RequestMapping("/dashboard")
public class DashboardController {
    
    @Autowired
    private PurchaseService purchaseService;

    @Autowired
    private SalesService salesService;

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private KpiService kpiService;

    /**
     * Dashboard principal
     * Gère à la fois l'authentification par session HTTP et par Spring Security
     */
    @GetMapping
    public String dashboard(Model model, HttpSession session, Authentication auth) {
        User user = null;

        // 1. Essayer de récupérer depuis la session HTTP
        user = (User) session.getAttribute("user");

        // 2. Si pas en session, essayer via Spring Security Authentication
        if (user == null && auth != null && auth.isAuthenticated()) {
            String username = auth.getName();
            user = userRepository.findByLogin(username).orElse(null);
            
            // Stocker en session pour les prochaines requêtes
            if (user != null) {
                session.setAttribute("user", user);
            }
        }

        // 3. Si toujours pas d'utilisateur, rediriger vers login
        if (user == null) {
            return "redirect:/login";
        }

        // 4. Vérifier que l'utilisateur est actif
        if (user.getActive() == null || !user.getActive()) {
            session.invalidate();
            return "redirect:/login?error=Utilisateur+désactivé";
        }

        // 5. Ajouter les informations au modèle
        model.addAttribute("username", user.getLogin());
        model.addAttribute("nom", user.getNom());
        model.addAttribute("prenom", user.getPrenom());
        model.addAttribute("email", user.getEmail());
        
        // Récupération rôles pour affichage
        if (user.getRoles() != null && !user.getRoles().isEmpty()) {
            model.addAttribute("roles", user.getRoles());
            // Ajouter le premier rôle comme rôle principal
            model.addAttribute("roleActuel", user.getRoles().iterator().next().getLibelle());
            if (hasRole(user, "CLIENT")) {
                return "redirect:/client";
            }
        }

        return "dashboard";
    }

    @GetMapping("/direction")
    public String directionDashboard(Model model, HttpSession session, Authentication auth) {
        if (!addUserToModel(model, session, auth)) {
            return "redirect:/login";
        }
        
        // Récupérer les KPIs pour la Direction avec le KpiService
        Map<String, KpiDTO> directionKpis = kpiService.getDirectionKpis();
        
        model.addAttribute("kpis", directionKpis);
        model.addAttribute("kpiCount", directionKpis.size());
        model.addAttribute("roleBasedMessage", "KPIs Direction Générale / Comité de Direction");
        
        // Ajouter les KPIs individuels pour la JSP (backward compatibility)
        if (directionKpis.containsKey("ca_total")) {
            model.addAttribute("caTotal", directionKpis.get("ca_total"));
        }
        if (directionKpis.containsKey("stock_value_total")) {
            model.addAttribute("stockValue", directionKpis.get("stock_value_total"));
        }
        if (directionKpis.containsKey("stock_turnover")) {
            model.addAttribute("stockTurnover", directionKpis.get("stock_turnover"));
        }
        
        return "dashboard-direction";
    }

    @GetMapping("/achats")
    public String purchaseDashboard(Model model, HttpSession session, Authentication auth) {
        if (!addUserToModel(model, session, auth)) {
            return "redirect:/login";
        }
        
        // Récupérer les KPIs pour les Achats/Supply Chain
        Map<String, KpiDTO> purchaseKpis = kpiService.getPurchaseKpis();
        
        model.addAttribute("kpis", purchaseKpis);
        model.addAttribute("kpiCount", purchaseKpis.size());
        model.addAttribute("roleBasedMessage", "KPIs Responsable Achats / Supply Chain");
        
        // Backward compatibility
        model.addAttribute("draftRequests", purchaseService.getPurchaseRequestsByStatus("BROUILLON").size());
        model.addAttribute("approvedRequests", purchaseService.getPurchaseRequestsByStatus("APPROUVEE").size());
        
        return "dashboard-acheteur";
    }

    @GetMapping("/stocks")
    public String stockDashboard(Model model, HttpSession session, Authentication auth) {
        if (!addUserToModel(model, session, auth)) {
            return "redirect:/login";
        }
        
        // Récupérer les KPIs pour le Magasinier/Stock
        Map<String, KpiDTO> warehouseKpis = kpiService.getWarehouseKpis();
        
        model.addAttribute("kpis", warehouseKpis);
        model.addAttribute("kpiCount", warehouseKpis.size());
        model.addAttribute("roleBasedMessage", "KPIs Magasin / Responsable Stock");
        
        return "dashboard-magasinier";
    }

    @GetMapping("/ventes")
    public String salesDashboard(Model model, HttpSession session, Authentication auth) {
        if (!addUserToModel(model, session, auth)) {
            return "redirect:/login";
        }
        
        // Récupérer les KPIs pour les Ventes/Commercial
        Map<String, KpiDTO> salesKpis = kpiService.getSalesKpis();
        
        model.addAttribute("kpis", salesKpis);
        model.addAttribute("kpiCount", salesKpis.size());
        model.addAttribute("roleBasedMessage", "KPIs Ventes / Responsable Commercial");
        
        // Backward compatibility
        model.addAttribute("pendingOrders", salesService.getSalesOrdersByStatus("BROUILLON").size());
        
        return "dashboard-commercial";
    }

    @GetMapping("/finance")
    public String financeDashboard(Model model, HttpSession session, Authentication auth) {
        if (!addUserToModel(model, session, auth)) {
            return "redirect:/login";
        }
        
        // Récupérer les KPIs pour la Finance/DAF
        Map<String, KpiDTO> financeKpis = kpiService.getFinanceKpis();
        
        model.addAttribute("kpis", financeKpis);
        model.addAttribute("kpiCount", financeKpis.size());
        model.addAttribute("roleBasedMessage", "KPIs Finance / DAF");
        
        return "dashboard-finance";
    }

    /**
     * Méthode utilitaire pour ajouter l'utilisateur au modèle
     * Retourne true si l'utilisateur est trouvé, false sinon
     */
    private boolean addUserToModel(Model model, HttpSession session, Authentication auth) {
        User user = (User) session.getAttribute("user");

        if (user == null && auth != null && auth.isAuthenticated()) {
            String username = auth.getName();
            user = userRepository.findByLogin(username).orElse(null);
            
            if (user != null) {
                session.setAttribute("user", user);
            }
        }

        if (user == null || user.getActive() == null || !user.getActive()) {
            return false;
        }

        model.addAttribute("username", user.getLogin());
        model.addAttribute("nom", user.getNom());
        model.addAttribute("prenom", user.getPrenom());
        
        if (user.getRoles() != null) {
            model.addAttribute("roles", user.getRoles());
        }

        return true;
    }

    private boolean hasRole(User user, String roleCode) {
        if (user == null || user.getRoles() == null || roleCode == null) {
            return false;
        }
        return user.getRoles().stream().anyMatch(r -> roleCode.equalsIgnoreCase(r.getCode()));
    }
}
