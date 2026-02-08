package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "demandes_achat")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PurchaseRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_soumission")
    private LocalDateTime dateSubmission;

    @Column(name = "date_validite")
    private LocalDateTime dateValidity;

    @Column(name = "entrepot_id")
    private Long entrepotId;

    @Column(name = "montant_estime", precision = 15, scale = 2)
    private BigDecimal montantEstime;

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

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_approbation", length = 100)
    private String utilisateurApprobation;

    @Column(name = "motif_rejet", length = 500)
    private String motifRejet;

    @OneToMany(mappedBy = "purchaseRequest", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PurchaseRequestLine> lines = new ArrayList<>();
}
