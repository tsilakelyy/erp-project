package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "client_requests")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ClientRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "customer_id", nullable = false)
    private Long customerId;

    @Column(name = "request_type", nullable = false, length = 50)
    private String requestType;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "titre", length = 150)
    private String titre;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "article_id")
    private Long articleId;

    @Column(name = "quantite", precision = 12, scale = 2)
    private BigDecimal quantite;

    @Column(name = "montant_estime", precision = 15, scale = 2)
    private BigDecimal montantEstime;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;
}
