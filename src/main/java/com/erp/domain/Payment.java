package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "paiements")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Payment {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_paiement")
    private LocalDateTime datePaiement;

    @Column(name = "montant", precision = 15, scale = 2)
    private BigDecimal montant;

    @Column(name = "moyen_paiement", length = 50)
    private String moyenPaiement;

    @Column(name = "reference_transaction", length = 255)
    private String referenceTransaction;

    @Column(name = "facture_id")
    private Long factureId;

    @Column(name = "fournisseur_id")
    private Long fournisseurId;
}
