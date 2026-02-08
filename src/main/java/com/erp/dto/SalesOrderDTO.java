package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SalesOrderDTO {
    private Long id;
    private String numero;
    private String statut;
    private LocalDateTime dateCreation;
    private LocalDateTime dateCommande;
    private Long clientId;
    private Long entrepotId;
    private Long clientRequestId;
    private Long proformaId;
    private BigDecimal montantHt;
    private BigDecimal montantTva;
    private BigDecimal montantTtc;
    private BigDecimal tauxTva;
    private String utilisateurCreation;
    private String utilisateurApprobation;
    private List<SalesOrderLineDTO> lines;
}
