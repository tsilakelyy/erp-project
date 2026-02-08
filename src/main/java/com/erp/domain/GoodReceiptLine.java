package com.erp.domain;

import lombok.*;

import javax.persistence.*;

@Entity
@Table(name = "receptions_lignes")
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
    @JoinColumn(name = "reception_id", nullable = false)
    private GoodReceipt reception;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "article_id", nullable = false)
    private Article article;

    @Column(name = "quantite", nullable = false)
    private Integer quantite;

    @Column(name = "batch_number", length = 100)
    private String batchNumber;

    @Column(name = "serial_number", length = 100)
    private String serialNumber;

    @Column(name = "location", length = 50)
    private String location;

    @Column(name = "notes", length = 500)
    private String notes;
}
