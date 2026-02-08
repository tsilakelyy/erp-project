package com.erp.domain;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "mouvements_stock")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class StockMovement {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "type_mouvement", nullable = false, length = 50)
    private String type;

    @Column(name = "date_creation", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime movementDate;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(name = "entrepot_id", nullable = false)
    private Long entrepotId;

    @Column(name = "quantite", nullable = false)
    private Integer quantity;

    @Column(name = "prix_unitaire", precision = 15, scale = 2)
    private BigDecimal unitCost;

    @Column(name = "montant", precision = 15, scale = 2)
    private BigDecimal totalCost;

    @Column(name = "motif", length = 255)
    private String motif;

    @Column(name = "utilisateur", length = 100)
    private String userName;

    @Column(name = "reference_document", length = 255)
    private String reference;
}
