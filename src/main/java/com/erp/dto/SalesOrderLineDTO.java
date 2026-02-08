package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SalesOrderLineDTO {
    private Long id;
    private Long salesOrderId;
    private Long articleId;
    private Long quantiteCommandee;
    private Long quantiteReservee;
    private Long quantiteLivree;
    private BigDecimal prixUnitaire;
    private BigDecimal remise;
    private BigDecimal montantLigne;
}
