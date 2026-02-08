package com.erp.controller;

import com.erp.domain.User;
import com.erp.dto.KpiDTO;
import com.erp.dto.RoleKpiContainerDTO;
import com.erp.repository.UserRepository;
import com.erp.service.KpiService;
import com.erp.service.RoleBasedKpiManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpSession;
import java.util.HashMap;
import java.util.Map;

/**
 * KpiController - API REST pour accéder aux KPIs
 * 
 * Endpoints:
 * - GET /api/kpis/user - KPIs de l'utilisateur connecté selon son rôle
 * - GET /api/kpis/direction - KPIs Direction
 * - GET /api/kpis/achats - KPIs Achats/Supply Chain
 * - GET /api/kpis/stock - KPIs Magasin/Stock
 * - GET /api/kpis/ventes - KPIs Ventes/Commercial
 * - GET /api/kpis/finance - KPIs Finance/DAF
 * 
 * TODO: Ajouter la sécurité fine par KPI
 * TODO: Implémenter le cache avec TTL
 * TODO: Ajouter les filtres par période (jour, semaine, mois, an)
 * TODO: Ajouter l'export CSV/PDF
 */
@RestController
@RequestMapping("/api/kpis")
public class KpiController {

    @Autowired
    private KpiService kpiService;

    @Autowired
    private RoleBasedKpiManager roleBasedKpiManager;

    @Autowired
    private UserRepository userRepository;

    /**
     * Récupère les KPIs pour l'utilisateur connecté selon son rôle
     */
    @GetMapping("/user")
    public ResponseEntity<?> getKpisForCurrentUser(HttpSession session, Authentication auth) {
        User user = (User) session.getAttribute("user");
        
        if (user == null && auth != null && auth.isAuthenticated()) {
            String username = auth.getName();
            user = userRepository.findByLogin(username).orElse(null);
        }
        
        if (user == null) {
            return ResponseEntity.status(401).body(new HashMap<String, String>() {{
                put("error", "Utilisateur non authentifié");
            }});
        }
        
        RoleKpiContainerDTO kpiContainer = roleBasedKpiManager.getKpisForUser(user);
        return ResponseEntity.ok(kpiContainer);
    }

    /**
     * Récupère tous les KPIs Direction Générale
     */
    @GetMapping("/direction")
    public ResponseEntity<Map<String, KpiDTO>> getDirectionKpis() {
        Map<String, KpiDTO> kpis = kpiService.getDirectionKpis();
        return ResponseEntity.ok(kpis);
    }

    /**
     * Récupère tous les KPIs Achats/Supply Chain
     */
    @GetMapping("/achats")
    public ResponseEntity<Map<String, KpiDTO>> getPurchaseKpis() {
        Map<String, KpiDTO> kpis = kpiService.getPurchaseKpis();
        return ResponseEntity.ok(kpis);
    }

    /**
     * Récupère tous les KPIs Magasin/Stock
     */
    @GetMapping("/stock")
    public ResponseEntity<Map<String, KpiDTO>> getWarehouseKpis() {
        Map<String, KpiDTO> kpis = kpiService.getWarehouseKpis();
        return ResponseEntity.ok(kpis);
    }

    /**
     * Récupère tous les KPIs Ventes/Commercial
     */
    @GetMapping("/ventes")
    public ResponseEntity<Map<String, KpiDTO>> getSalesKpis() {
        Map<String, KpiDTO> kpis = kpiService.getSalesKpis();
        return ResponseEntity.ok(kpis);
    }

    /**
     * Récupère tous les KPIs Finance/DAF
     */
    @GetMapping("/finance")
    public ResponseEntity<Map<String, KpiDTO>> getFinanceKpis() {
        Map<String, KpiDTO> kpis = kpiService.getFinanceKpis();
        return ResponseEntity.ok(kpis);
    }

    /**
     * Récupère un KPI spécifique par son code
     * 
     * TODO: Vérifier les permissions avant de retourner
     */
    @GetMapping("/{kpiCode}")
    public ResponseEntity<?> getKpiByCode(
            @PathVariable String kpiCode,
            HttpSession session,
            Authentication auth) {
        
        User user = (User) session.getAttribute("user");
        
        if (user == null && auth != null && auth.isAuthenticated()) {
            String username = auth.getName();
            user = userRepository.findByLogin(username).orElse(null);
        }
        
        if (user == null) {
            return ResponseEntity.status(401).body(new HashMap<String, String>() {{
                put("error", "Utilisateur non authentifié");
            }});
        }
        
        // Vérifier si l'utilisateur a accès à ce KPI
        if (!roleBasedKpiManager.userHasAccessToKpi(user, kpiCode)) {
            return ResponseEntity.status(403).body(new HashMap<String, String>() {{
                put("error", "Accès refusé à ce KPI");
            }});
        }
        
        // Récupérer le KPI depuis le service approprié
        Map<String, KpiDTO> allKpis = getAllAvailableKpis();
        
        if (allKpis.containsKey(kpiCode)) {
            return ResponseEntity.ok(allKpis.get(kpiCode));
        }
        
        return ResponseEntity.notFound().build();
    }

    /**
     * Récupère tous les KPIs disponibles (tous rôles)
     */
    @GetMapping
    public ResponseEntity<Map<String, KpiDTO>> getAllKpis() {
        Map<String, KpiDTO> allKpis = getAllAvailableKpis();
        return ResponseEntity.ok(allKpis);
    }

    /**
     * Retourne les statistiques globales des KPIs
     */
    @GetMapping("/stats/global")
    public ResponseEntity<Map<String, Object>> getGlobalKpiStats() {
        Map<String, Object> stats = new HashMap<>();
        
        Map<String, KpiDTO> allKpis = getAllAvailableKpis();
        
        stats.put("totalKpis", allKpis.size());
        stats.put("directionKpis", kpiService.getDirectionKpis().size());
        stats.put("purchaseKpis", kpiService.getPurchaseKpis().size());
        stats.put("warehouseKpis", kpiService.getWarehouseKpis().size());
        stats.put("salesKpis", kpiService.getSalesKpis().size());
        stats.put("financeKpis", kpiService.getFinanceKpis().size());
        
        return ResponseEntity.ok(stats);
    }

    /**
     * Helper method - récupère tous les KPIs disponibles
     */
    private Map<String, KpiDTO> getAllAvailableKpis() {
        Map<String, KpiDTO> allKpis = new HashMap<>();
        allKpis.putAll(kpiService.getDirectionKpis());
        allKpis.putAll(kpiService.getPurchaseKpis());
        allKpis.putAll(kpiService.getWarehouseKpis());
        allKpis.putAll(kpiService.getSalesKpis());
        allKpis.putAll(kpiService.getFinanceKpis());
        return allKpis;
    }
}
