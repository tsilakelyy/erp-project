package com.erp.domain;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "taxes_vente", uniqueConstraints = @UniqueConstraint(columnNames = "code"))
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Tax {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, length = 10, unique = true)
    private String code;

    @Column(name = "libelle", nullable = false, length = 100)
    private String name;

    @Column(name = "taux", nullable = false, precision = 5, scale = 2)
    private BigDecimal rate;

    @Column(name = "actif", nullable = false)
    @Builder.Default
    private Boolean active = true;

    @Column(name = "date_debut", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "date_fin")
    private LocalDateTime dateEcheance;
}
