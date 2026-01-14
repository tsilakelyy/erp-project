package com.erp.domain;

import lombok.*;
import org.hibernate.annotations.UpdateTimestamp;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(
    name = "niveaux_stock",
    uniqueConstraints = {
        @UniqueConstraint(columnNames = {"entrepot_id", "article_id"})
    }
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StockLevel {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // 🔹 Entrepôt
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "entrepot_id", nullable = false)
    private Warehouse entrepot;

    // 🔹 Article
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    // 🔹 Quantité actuelle
    @Column(name = "quantite_actuelle", nullable = false)
    @Builder.Default
    private Long quantiteActuelle = 0L;

    // 🔹 Quantité réservée
    @Column(name = "quantite_reservee", nullable = false)
    @Builder.Default
    private Long quantiteReservee = 0L;

    // 🔹 Quantité disponible (calculée ou stockée)
    @Column(name = "quantite_disponible", nullable = false)
    @Builder.Default
    private Long quantiteDisponible = 0L;

    // 🔹 Valeur totale du stock
    @Column(name = "valeur_totale", precision = 12, scale = 2)
    @Builder.Default
    private BigDecimal valeurTotale = BigDecimal.ZERO;

    // 🔹 Coût moyen
    @Column(name = "cout_moyen", precision = 10, scale = 2)
    @Builder.Default
    private BigDecimal coutMoyen = BigDecimal.ZERO;

    // 🔹 Date de dernière mise à jour
    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;
}
