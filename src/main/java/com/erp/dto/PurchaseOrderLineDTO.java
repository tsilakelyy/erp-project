package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PurchaseOrderLineDTO {
    private Long id;
    private Long purchaseOrderId;
    private Long articleId;
    private Long quantiteCommandee;
    private Long quantiteReceptionnee;
    private BigDecimal prixUnitaire;
    private BigDecimal remise;
    private BigDecimal montantLigne;
}
