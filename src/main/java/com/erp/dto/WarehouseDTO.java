package com.erp.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WarehouseDTO {
    private Long id;
    private String code;
    private String nomDepot;
    private String adresse;
    private String ville;
    private String responsableNom;
    private java.math.BigDecimal capaciteMaximale;
    private java.math.BigDecimal capaciteUtilisee;
    private java.math.BigDecimal niveauStockSecurite;
    private java.math.BigDecimal niveauStockAlerte;
    private String typeDepot;
    private Boolean actif;
    private Integer nombreArticles;
    private java.math.BigDecimal stockTotal;
}
