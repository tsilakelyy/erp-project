package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PurchaseRequestDTO {
    private Long id;
    private String numero;
    private String statut;
    private LocalDateTime dateCreation;
    private LocalDateTime dateSubmission;
    private LocalDateTime dateValidity;
    private Long entrepotId;
    private BigDecimal montantEstime;
    private String utilisateurCreation;
    private String utilisateurApprobation;
    private String motifRejet;
    private List<PurchaseRequestLineDTO> lines;
}
