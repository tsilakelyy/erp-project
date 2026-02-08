package com.erp.dto;

import lombok.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PricingListLineDTO {
    private Long id;
    private Long pricingListId;
    private Long articleId;
    private String articleCode;
    private String articleLibelle;
    private BigDecimal prixUnitaire;
    private BigDecimal remisePourcentage;
    private BigDecimal prixNet;
    private String remarque;
    private Boolean actif;
}
