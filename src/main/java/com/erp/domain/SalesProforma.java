package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "proformas_ventes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SalesProforma {
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

    @Column(name = "date_validation_client")
    private LocalDateTime dateValidationClient;

    @Column(name = "client_id")
    private Long clientId;

    @Column(name = "request_id")
    private Long requestId;

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

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;

    @OneToMany(mappedBy = "proforma", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<SalesProformaLine> lines = new ArrayList<>();
}
