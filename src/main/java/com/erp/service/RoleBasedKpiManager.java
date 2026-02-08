package com.erp.service;

import com.erp.domain.Role;
import com.erp.domain.User;
import com.erp.dto.KpiDTO;
import com.erp.dto.RoleKpiContainerDTO;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.*;
import java.util.stream.Collectors;

/**
 * RoleBasedKpiManager - Gestionnaire centralisé des KPIs par rôle
 * 
 * Responsabilités:
 * - Déterminer quels KPIs afficher selon le rôle de l'utilisateur
 * - Construire les conteneurs de KPIs pour chaque rôle
 * - Gérer les permissions d'accès aux KPIs
 * - Agréger les KPIs de plusieurs sources
 * 
 * TODO: Implémenter la sécurité granulaire (row-level security)
 * TODO: Ajouter le support des KPIs multi-sites
 * TODO: Implémenter les notifications d'alertes KPI
 * TODO: Ajouter l'export de rapports KPI
 */
@Service
@Transactional
public class RoleBasedKpiManager {

    @Autowired
    private KpiService kpiService;

    private static final Map<String, List<String>> ROLE_KPI_MAPPING = new HashMap<>();

    static {
        // Direction Générale KPIs
        ROLE_KPI_MAPPING.put("DIRECTION", Arrays.asList(
            "ca_total",
            "marge_brute",
            "marge_pourcentage",
            "stock_value_total",
            "stock_evolution_m1",
            "stock_evolution_m12",
            "stock_turnover",
            "top_surstocks",
            "taux_ecarts_inventaire_valeur",
            "taux_ecarts_inventaire_pourcentage"
        ));

        // Responsable Achats KPIs
        ROLE_KPI_MAPPING.put("ACHETEUR", Arrays.asList(
            "cycle_time_da_bc_median",
            "cycle_time_da_bc_p90",
            "otd_supplier",
            "reception_conform",
            "taux_litiges_facture",
            "concentration_fournisseurs",
            "evolution_prix_achat",
            "taux_commandes_urgentes"
        ));

        // Magasinier KPIs
        ROLE_KPI_MAPPING.put("MAGASINIER", Arrays.asList(
            "precision_stock_theorique_physique",
            "obsolescence_peremption_valeur",
            "lots_risque",
            "productivite_picking",
            "erreurs_picking",
            "temps_dock_to_stock"
        ));

        // Responsable Ventes KPIs
        ROLE_KPI_MAPPING.put("COMMERCIAL", Arrays.asList(
            "commandes_en_cours",
            "commandes_livrees",
            "commandes_en_retard",
            "taux_annulation_commandes",
            "motifs_annulation",
            "remises_vs_plafond",
            "avoirs_volume",
            "avoirs_valeur",
            "motifs_avoirs",
            "backlog_non_servi"
        ));

        // DAF / Finance KPIs
        ROLE_KPI_MAPPING.put("FINANCE", Arrays.asList(
            "factures_bloquees_3way",
            "valeur_stock_comptable",
            "valeur_stock_operationnelle",
            "ecart_stock_comptable_operationnel",
            "variation_marge",
            "tresorerie_position",
            "aged_receivables",
            "aged_payables"
        ));

        // Admin a accès à tous
        ROLE_KPI_MAPPING.put("ADMIN", Arrays.asList(
            "ca_total", "marge_brute", "marge_pourcentage", "stock_value_total",
            "stock_evolution_m1", "stock_evolution_m12", "stock_turnover",
            "top_surstocks", "taux_ecarts_inventaire_valeur", "taux_ecarts_inventaire_pourcentage",
            "cycle_time_da_bc_median", "cycle_time_da_bc_p90", "otd_supplier",
            "reception_conform", "taux_litiges_facture", "concentration_fournisseurs",
            "evolution_prix_achat", "taux_commandes_urgentes",
            "precision_stock_theorique_physique", "obsolescence_peremption_valeur",
            "lots_risque", "productivite_picking", "erreurs_picking", "temps_dock_to_stock",
            "commandes_en_cours", "commandes_livrees", "commandes_en_retard",
            "taux_annulation_commandes", "motifs_annulation", "remises_vs_plafond",
            "avoirs_volume", "avoirs_valeur", "motifs_avoirs", "backlog_non_servi",
            "factures_bloquees_3way", "valeur_stock_comptable", "valeur_stock_operationnelle",
            "ecart_stock_comptable_operationnel", "variation_marge", "tresorerie_position",
            "aged_receivables", "aged_payables"
        ));
    }

    /**
     * Récupère le conteneur de KPIs complètement configuré pour un utilisateur
     * selon ses rôles
     */
    public RoleKpiContainerDTO getKpisForUser(User user) {
        if (user == null || user.getRoles() == null || user.getRoles().isEmpty()) {
            return null;
        }

        // Prendre le premier rôle (TODO: gérer les rôles multiples)
        Role primaryRole = user.getRoles().iterator().next();
        if (primaryRole == null || primaryRole.getCode() == null) {
            return null;
        }
        
        String roleCode = primaryRole.getCode();

        // Récupérer tous les KPIs selon le type de rôle
        Map<String, KpiDTO> allKpis = getAllKpisForRole(roleCode);

        // Filtrer selon les permissions spécifiques
        List<String> allowedKpis = ROLE_KPI_MAPPING.getOrDefault(roleCode.toUpperCase(), new ArrayList<>());
        Map<String, KpiDTO> filteredKpis = allKpis.entrySet().stream()
            .filter(e -> allowedKpis.contains(e.getKey()))
            .collect(Collectors.toMap(
                Map.Entry::getKey, 
                Map.Entry::getValue,
                (e1, e2) -> e1,
                LinkedHashMap::new
            ));

        // Construire le conteneur
        return RoleKpiContainerDTO.builder()
            .roleCode(roleCode)
            .roleLabel(primaryRole.getLibelle() != null ? primaryRole.getLibelle() : "Rôle inconnu")
            .userName(user.getLogin())
            .userId(user.getId())
            .kpis(filteredKpis)
            .kpiCount(filteredKpis.size())
            .period("current")
            .generatedAt(LocalDateTime.now().format(DateTimeFormatter.ISO_LOCAL_DATE_TIME))
            .kpisOnTarget(countKpisOnTarget(filteredKpis))
            .kpisAtRisk(countKpisAtRisk(filteredKpis))
            .kpisInAlert(countKpisInAlert(filteredKpis))
            .build();
    }

    /**
     * Récupère tous les KPIs pour un rôle spécifique
     * TODO: Implémenter la stratégie pour chaque rôle avec des données réelles
     */
    private Map<String, KpiDTO> getAllKpisForRole(String roleCode) {
        Map<String, KpiDTO> allKpis = new HashMap<>();

        switch (roleCode.toUpperCase()) {
            case "DIRECTION":
            case "COMITE_DIRECTION":
                allKpis.putAll(kpiService.getDirectionKpis());
                break;
            case "ACHETEUR":
            case "SUPPLY_CHAIN":
                allKpis.putAll(kpiService.getPurchaseKpis());
                break;
            case "MAGASINIER":
            case "RESPONSABLE_STOCK":
                allKpis.putAll(kpiService.getWarehouseKpis());
                break;
            case "COMMERCIAL":
            case "RESPONSABLE_VENTES":
                allKpis.putAll(kpiService.getSalesKpis());
                break;
            case "FINANCE":
            case "DAF":
                allKpis.putAll(kpiService.getFinanceKpis());
                break;
            case "ADMIN":
                // Admin voit tous les KPIs
                allKpis.putAll(kpiService.getDirectionKpis());
                allKpis.putAll(kpiService.getPurchaseKpis());
                allKpis.putAll(kpiService.getWarehouseKpis());
                allKpis.putAll(kpiService.getSalesKpis());
                allKpis.putAll(kpiService.getFinanceKpis());
                break;
            default:
                // Rôle inconnu - pas de KPIs
                return new HashMap<>();
        }

        return allKpis;
    }

    /**
     * Compte les KPIs qui sont dans la cible
     * TODO: Améliorer la logique de calcul
     */
    private int countKpisOnTarget(Map<String, KpiDTO> kpis) {
        if (kpis == null || kpis.isEmpty()) {
            return 0;
        }
        return (int) kpis.values().stream()
            .filter(kpi -> {
                if (kpi == null || kpi.getValue() == null || kpi.getTarget() == null) {
                    return true;
                }
                // Logique simplifiée - à améliorer
                String trend = kpi.getTrend();
                return "stable".equals(trend) || "increasing".equals(trend);
            })
            .count();
    }

    /**
     * Compte les KPIs à risque
     * TODO: Améliorer la logique de calcul
     */
    private int countKpisAtRisk(Map<String, KpiDTO> kpis) {
        if (kpis == null || kpis.isEmpty()) {
            return 0;
        }
        return (int) kpis.values().stream()
            .filter(kpi -> kpi != null && "decreasing".equals(kpi.getTrend()))
            .count();
    }

    /**
     * Compte les KPIs en alerte
     * TODO: Améliorer la logique de calcul
     */
    private int countKpisInAlert(Map<String, KpiDTO> kpis) {
        return 0; // TODO: Implémenter la logique d'alerte
    }

    /**
     * Vérifie si un utilisateur a accès à un KPI spécifique
     * TODO: Implémenter la sécurité fine par KPI
     */
    public boolean userHasAccessToKpi(User user, String kpiCode) {
        if (user == null || user.getRoles() == null || user.getRoles().isEmpty()) {
            return false;
        }

        Role primaryRole = user.getRoles().iterator().next();
        if (primaryRole == null || primaryRole.getCode() == null) {
            return false;
        }
        
        String roleCode = primaryRole.getCode();

        List<String> allowedKpis = ROLE_KPI_MAPPING.getOrDefault(roleCode.toUpperCase(), new ArrayList<>());
        return kpiCode != null && allowedKpis.contains(kpiCode);
    }

    /**
     * Récupère tous les KPIs disponibles (tous rôles confondus)
     * TODO: Utile pour les rapports et exports
     */
    public Map<String, KpiDTO> getAllAvailableKpis() {
        Map<String, KpiDTO> allKpis = new HashMap<>();
        allKpis.putAll(kpiService.getDirectionKpis());
        allKpis.putAll(kpiService.getPurchaseKpis());
        allKpis.putAll(kpiService.getWarehouseKpis());
        allKpis.putAll(kpiService.getSalesKpis());
        allKpis.putAll(kpiService.getFinanceKpis());
        return allKpis;
    }
}
