package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;
import java.util.List;

/**
 * DTO enrichi pour Article + Catégorie + Prix
 * Assure que ces trois éléments sont TOUJOURS liés
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ArticleWithDetailsDTO {
    // Article fields
    private Long id;
    private String code;
    private String libelle;
    private String description;
    private String uniteMesure;
    private BigDecimal prixUnitaire;
    private BigDecimal tauxTva;
    private Long quantiteMinimale;
    private Long quantiteMaximale;
    private Boolean actif;
    
    // Category fields
    private Long categoryId;
    private String categoryCode;
    private String categoryLibelle;
    private String categoryDescription;
    
    // Pricing fields
    private BigDecimal prixVente;          // Prix de vente (VENTE)
    private BigDecimal remiseVente;        // Remise en %
    private BigDecimal prixNetVente;       // Prix net après remise
    
    private BigDecimal prixAchat;          // Prix d'achat (ACHAT)
    private BigDecimal remiseAchat;        // Remise en %
    private BigDecimal prixNetAchat;       // Prix net après remise
    
    // Stock fields
    private Long stockDisponible;
    private Long stockReserve;
}
