package com.erp.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryLineDTO {
    private Long id;
    private Long deliveryId;
    private Long articleId;
    private Long quantite;
    private String batchNumber;
    private String serialNumber;
}
