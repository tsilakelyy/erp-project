package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "commandes_achat")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class PurchaseOrder {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_commande")
    private LocalDateTime dateCommande;

    @Column(name = "date_echeance_estimee")
    private LocalDateTime dateEcheanceEstimee;

    @Column(name = "proforma_id")
    private Long proformaId;

    @Column(name = "fournisseur_id")
    private Long fournisseurId;

    @Column(name = "entrepot_id")
    private Long entrepotId;

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

    @Column(name = "utilisateur_approbation", length = 100)
    private String utilisateurApprobation;

    @OneToMany(mappedBy = "purchaseOrder", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PurchaseOrderLine> lines = new ArrayList<>();
}
