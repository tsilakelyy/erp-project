package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class WarehouseDTO {
    private Long id;
    private String code;
    private String nomDepot;
    private String adresse;
    private String codePostal;
    private String ville;
    private Long responsableId;
    private BigDecimal capaciteMaximale;
    private BigDecimal niveauStockSecurite;
    private BigDecimal niveauStockAlerte;
    private String typeDepot;
    private Boolean actif;
    private LocalDateTime dateCreation;
    private LocalDateTime dateModification;
    private String utilisateurCreation;
    private String utilisateurModification;
}