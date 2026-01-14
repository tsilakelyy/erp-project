package com.erp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "articles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Article {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, length = 50, unique = true)
    private String code;

    @Column(name = "libelle", nullable = false, length = 200)
    private String libelle;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "unite_mesure", length = 10)
    private String uniteMesure;

    @Column(name = "prix_unitaire", precision = 15, scale = 2)
    private BigDecimal prixUnitaire;

    @Column(name = "taux_tva", precision = 5, scale = 2)
    private BigDecimal tauxTva;

    @Column(name = "quantite_minimale")
    private Long quantiteMinimale;

    @Column(name = "quantite_maximale")
    private Long quantiteMaximale;

    @Column(name = "actif")
    private Boolean actif = true;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;
}