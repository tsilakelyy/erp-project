package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CustomerDTO {
    private Long id;
    private String code;
    private String nomEntreprise;
    private String adresse;
    private String codePostal;
    private String ville;
    private String telephone;
    private String email;
    private String contactPrincipal;
    private BigDecimal limiteCreditInitiale;
    private BigDecimal creditUtilise;
    private BigDecimal creditDisponible;
    private BigDecimal remisePourcentage;
    private Integer delaiPaiementJours;
    private Boolean actif;
    private BigDecimal caAnnuel;
    private BigDecimal soldeFactureNonLettrees;
}
