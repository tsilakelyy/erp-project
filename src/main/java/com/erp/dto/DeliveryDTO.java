package com.erp.dto;

import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryDTO {
    private Long id;
    private String numero;
    private String statut;
    private LocalDateTime dateCreation;
    private LocalDate dateLivraison;
    private Long commandeClientId;
    private Long entrepotId;
    private String utilisateurPicking;
    private String utilisateurExpedition;
    private List<DeliveryLineDTO> lines;
}
