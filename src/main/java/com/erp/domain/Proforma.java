package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import org.springframework.format.annotation.DateTimeFormat;

/**
 * Facture proforma (achat) : document provisoire, validable par Finance/Direction,
 * puis transformable en Bon de commande.
 */
@Entity
@Table(name = "proformas")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Proforma {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_proforma")
    private LocalDateTime dateProforma;

    @Column(name = "date_validite")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime dateValidite;

    @Column(name = "demande_id")
    private Long demandeId;

    @Column(name = "fournisseur_id")
    private Long fournisseurId;

    @Column(name = "entrepot_id")
    private Long entrepotId;

    @Column(name = "importance", length = 20)
    private String importance;

    @Column(name = "validation_mode", length = 30)
    private String validationMode;

    @Column(name = "validation_finance_requise")
    private Boolean validationFinanceRequise;

    @Column(name = "validation_direction_requise")
    private Boolean validationDirectionRequise;

    @Column(name = "valide_finance")
    private Boolean valideFinance;

    @Column(name = "valide_direction")
    private Boolean valideDirection;

    @Column(name = "date_validation_finance")
    private LocalDateTime dateValidationFinance;

    @Column(name = "date_validation_direction")
    private LocalDateTime dateValidationDirection;

    @Column(name = "utilisateur_validation_finance", length = 100)
    private String utilisateurValidationFinance;

    @Column(name = "utilisateur_validation_direction", length = 100)
    private String utilisateurValidationDirection;

    @Column(name = "motif_rejet", length = 500)
    private String motifRejet;

    @Column(name = "montant_ht", precision = 15, scale = 2)
    private BigDecimal montantHt;

    @Column(name = "montant_tva", precision = 15, scale = 2)
    private BigDecimal montantTva;

    @Column(name = "montant_ttc", precision = 15, scale = 2)
    private BigDecimal montantTtc;

    @Column(name = "taux_tva", precision = 5, scale = 2)
    private BigDecimal tauxTva;

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @OneToMany(mappedBy = "proforma", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<ProformaLine> lines = new ArrayList<>();
}
