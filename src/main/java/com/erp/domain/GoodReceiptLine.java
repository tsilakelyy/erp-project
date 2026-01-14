package com.erp.domain;

import lombok.*;

import javax.persistence.*;

@Entity
@Table(name = "good_receipt_lines")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GoodReceiptLine {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "good_receipt_id", nullable = false)
    private GoodReceipt goodReceipt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(nullable = false)
    private Integer quantity;

    @Column(length = 100)
    private String batchNumber;

    @Column(length = 100)
    private String serialNumber;

    @Column(length = 50)
    private String location;

    @Column(length = 500)
    private String notes;
}
