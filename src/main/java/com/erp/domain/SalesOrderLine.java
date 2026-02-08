package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;

@Entity
@Table(name = "commandes_ventes_lignes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SalesOrderLine {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "commande_id", nullable = false)
    private SalesOrder salesOrder;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(name = "quantite_commandee", nullable = false)
    private Integer quantiteCommandee;

    @Column(name = "quantite_reservee")
    @Builder.Default
    private Integer quantiteReservee = 0;

    @Column(name = "prix_unitaire", precision = 15, scale = 2)
    private BigDecimal prixUnitaire;

    @Column(name = "montant", precision = 15, scale = 2)
    private BigDecimal montant;
}
