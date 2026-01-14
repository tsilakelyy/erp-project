package com.erp.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.util.*;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class UserDTO {
    private Long id;
    private String login;
    private String email;
    private String nom;
    private String prenom;
    private Boolean actif;
    private List<Long> depotsAutorises;
    private Map<Long, List<String>> rolesAssignes;
    private LocalDateTime dateLastLogin;
    private Integer loginAttempts;
    private Boolean locked;
}
