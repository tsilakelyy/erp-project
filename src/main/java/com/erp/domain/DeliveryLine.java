package com.erp.domain;

import lombok.*;

import javax.persistence.*;

@Entity
@Table(name = "delivery_lines")
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
    @JoinColumn(name = "delivery_id", nullable = false)
    private Delivery delivery;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(nullable = false)
    private Integer quantity;

    @Column(length = 100)
    private String batchNumber;

    @Column(length = 100)
    private String serialNumber;

    @Column(length = 500)
    private String notes;
}
