package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "factures")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Invoice {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "type_facture", length = 50)
    private String typeFacture;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_facture")
    private LocalDateTime dateFacture;

    @Column(name = "date_echeance")
    private LocalDateTime dateEcheance;

    @Column(name = "tiers_id")
    private Long tiersId;

    @Column(name = "commande_achat_id")
    private Long commandeAchatId;

    @Column(name = "commande_client_id")
    private Long commandeClientId;

    @Column(name = "montant_ht", precision = 15, scale = 2)
    private BigDecimal montantHt;

    @Column(name = "montant_tva", precision = 15, scale = 2)
    private BigDecimal montantTva;

    @Column(name = "montant_ttc", precision = 15, scale = 2)
    private BigDecimal montantTtc;

    @Column(name = "taux_tva", precision = 5, scale = 2)
    private BigDecimal tauxTva;

    @Column(name = "type_tiers", length = 50)
    private String typeTiers;

    @OneToMany(mappedBy = "facture", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<InvoiceLine> lines = new ArrayList<>();
}
