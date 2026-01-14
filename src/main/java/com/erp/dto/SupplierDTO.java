package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SupplierDTO {
    private Long id;
    private String code;
    private String nomEntreprise;
    private String adresse;
    private String codePostal;
    private String ville;
    private String telephone;
    private String email;
    private String contactPrincipal;
    private String modalitePaiement;
    private Integer delaiLivraisonMoyen;
    private BigDecimal tauxRemise;
    private BigDecimal evaluationPerformance;
    private Boolean actif;
    private BigDecimal historiqueCa;
    private Integer nombreCommandesAnnee;
}
