package com.erp.dto;

import lombok.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class CategoryDTO {
    private Long id;
    private String code;
    private String libelle;
    private String description;
    private Boolean actif;
    private String utilisateurCreation;
}
