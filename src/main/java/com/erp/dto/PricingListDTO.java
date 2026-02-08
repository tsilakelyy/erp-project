package com.erp.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PricingListDTO {
    private Long id;
    private String code;
    private String libelle;
    private String description;
    private String typeListe;
    private LocalDateTime dateDebut;
    private LocalDateTime dateFin;
    private String devise;
    private Boolean actif;
    private Boolean parDefaut;
    private Integer lineCount;
    private String utilisateurCreation;
}
