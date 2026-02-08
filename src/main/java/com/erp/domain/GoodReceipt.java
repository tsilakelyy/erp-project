package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "receptions")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class GoodReceipt {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_reception")
    private LocalDateTime dateReception;

    @Column(name = "commande_id")
    private Long commandeId;

    @Column(name = "entrepot_id")
    private Long entrepotId;

    @Column(name = "utilisateur_reception", length = 100)
    private String utilisateurReception;

    @Column(name = "utilisateur_validation", length = 100)
    private String utilisateurValidation;

    @Column(name = "notes", length = 500)
    private String notes;

    @OneToMany(mappedBy = "reception", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<GoodReceiptLine> lines = new ArrayList<>();
}
