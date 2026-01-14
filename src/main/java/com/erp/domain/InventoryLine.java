package com.erp.domain;

import lombok.*;

import javax.persistence.*;

@Entity
@Table(name = "inventory_lines")
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
    @JoinColumn(name = "inventory_id", nullable = false)
    private Inventory inventory;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(nullable = false)
    private Integer theoreticalQuantity;

    @Column(nullable = false)
    private Integer countedQuantity;

    @Column(nullable = false)
    private Integer variance;

    @Column(length = 20)
    private String status;

    @Column(length = 500)
    private String notes;
}
