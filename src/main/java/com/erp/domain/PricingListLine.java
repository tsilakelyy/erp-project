package com.erp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "listes_prix_lignes")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PricingListLine {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "liste_prix_id", nullable = false)
    private PricingList pricingList;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(name = "prix_unitaire", precision = 15, scale = 2, nullable = false)
    private BigDecimal prixUnitaire;

    @Column(name = "remise_pourcentage", precision = 5, scale = 2)
    private BigDecimal remisePourcentage = BigDecimal.ZERO;

    @Column(name = "prix_net", precision = 15, scale = 2)
    private BigDecimal prixNet;

    @Column(name = "remarque", length = 500)
    private String remarque;

    @Column(name = "actif")
    private Boolean actif = true;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @PrePersist
    protected void onCreate() {
        if (this.dateCreation == null) {
            this.dateCreation = LocalDateTime.now();
        }
        if (this.actif == null) {
            this.actif = true;
        }
        if (this.remisePourcentage == null) {
            this.remisePourcentage = BigDecimal.ZERO;
        }
        calculatePrixNet();
    }

    @PreUpdate
    protected void onUpdate() {
        this.dateModification = LocalDateTime.now();
        calculatePrixNet();
    }

    private void calculatePrixNet() {
        if (prixUnitaire != null) {
            if (remisePourcentage != null && remisePourcentage.compareTo(BigDecimal.ZERO) > 0) {
                BigDecimal discount = prixUnitaire.multiply(remisePourcentage).divide(BigDecimal.valueOf(100), 2, java.math.RoundingMode.HALF_UP);
                this.prixNet = prixUnitaire.subtract(discount);
            } else {
                this.prixNet = prixUnitaire;
            }
        }
    }
}
