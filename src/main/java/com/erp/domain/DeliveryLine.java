package com.erp.domain;

import lombok.*;

import javax.persistence.*;

@Entity
@Table(name = "livraisons_lignes")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class DeliveryLine {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "livraison_id", nullable = false)
    private Delivery livraison;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(name = "quantite", nullable = false)
    private Integer quantite;

    @Column(name = "batch_number", length = 100)
    private String batchNumber;

    @Column(name = "serial_number", length = 100)
    private String serialNumber;
}
