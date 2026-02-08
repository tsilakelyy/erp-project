package com.erp.domain;

import lombok.*;

import javax.persistence.*;

@Entity
@Table(name = "inventaires_lignes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class InventoryLine {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "inventaire_id", nullable = false)
    private Inventory inventaire;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(name = "quantite_theorique")
    private Integer quantiteTheorique;

    @Column(name = "quantite_comptee")
    private Integer quantiteComptee;

    @Column(name = "variance")
    private Integer variance;

    @Column(name = "notes", length = 500)
    private String notes;
}
