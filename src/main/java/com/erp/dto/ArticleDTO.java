package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ArticleDTO {
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
    private Long stockDisponible;
    private Long stockReserve;
}
