package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PurchaseRequestLineDTO {
    private Long id;
    private Long purchaseRequestId;
    private Long articleId;
    private Long quantiteDemandee;
    private BigDecimal prixUnitaireEstime;
    private String motivationDemande;
}
