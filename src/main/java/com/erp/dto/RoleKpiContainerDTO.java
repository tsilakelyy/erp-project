package com.erp.dto;

import lombok.*;
import java.util.Map;
import java.util.List;

/**
 * RoleKpiContainerDTO - Conteneur pour tous les KPIs d'un rôle
 * Permet de regrouper et d'organiser les KPIs par rôle
 * 
 * TODO: Ajouter des méthodes de tri et de filtrage des KPIs
 * TODO: Ajouter le support des KPIs personnalisés par utilisateur
 * TODO: Implémenter le caching avec TTL
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class RoleKpiContainerDTO {
    
    // Rôle et utilisateur
    private String roleCode;
    private String roleLabel;
    private String userName;
    private Long userId;
    
    // Map de KPIs: clé = code KPI, valeur = KpiDTO
    private Map<String, KpiDTO> kpis;
    
    // Métadonnées
    private long kpiCount;
    private String period;
    private String generatedAt;
    
    // Indicateurs de performance
    private int kpisOnTarget;
    private int kpisAtRisk;
    private int kpisInAlert;
    
    /**
     * Retourne les KPIs en alerte (variance > 10%)
     */
    public List<KpiDTO> getAlertKpis() {
        // TODO: Implémenter la logique pour retourner les KPIs critiques
        return List.of();
    }
    
    /**
     * Retourne les KPIs en bonne santé (variance <= 5%)
     */
    public List<KpiDTO> getHealthyKpis() {
        // TODO: Implémenter la logique
        return List.of();
    }
}
