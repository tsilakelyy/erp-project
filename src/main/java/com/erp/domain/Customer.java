package com.erp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "clients")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, length = 50, unique = true)
    private String code;

    @Column(name = "nom_entreprise", nullable = false, length = 200)
    private String nomEntreprise;

    @Column(name = "adresse", length = 255)
    private String adresse;

    @Column(name = "code_postal", length = 10)
    private String codePostal;

    @Column(name = "ville", length = 100)
    private String ville;

    @Column(name = "telephone", length = 20)
    private String telephone;

    @Column(name = "email", length = 100, unique = true)
    private String email;

    @Column(name = "contact_principal", length = 100)
    private String contactPrincipal;

    @Column(name = "limite_credit_initiale", precision = 15, scale = 2)
    private BigDecimal limiteCreditInitiale;

    @Column(name = "limite_credit_actuelle", precision = 15, scale = 2)
    private BigDecimal limiteCreditActuelle;

    @Column(name = "remise_pourcentage", precision = 5, scale = 2)
    private BigDecimal remisePourcentage;

    @Column(name = "delai_paiement_jours")
    private Integer delaiPaiementJours;

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
