package com.erp.domain;

import lombok.*;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.math.BigDecimal;

@Entity
@Table(name = "inventaires")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Inventory {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "type_inventaire", nullable = false, length = 50)
    private String typeInventaire;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "date_debut")
    private LocalDateTime dateDebut;

    @Column(name = "date_fin")
    private LocalDateTime dateFin;

    @Column(name = "entrepot_id")
    private Long entrepotId;

    @Column(name = "montant_theorique", precision = 15, scale = 2)
    private BigDecimal montantTheorique;

    @Column(name = "montant_compte", precision = 15, scale = 2)
    private BigDecimal montantCompte;

    @Column(name = "utilisateur_responsable", length = 100)
    private String utilisateurResponsable;

    @OneToMany(mappedBy = "inventaire", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<InventoryLine> lines = new ArrayList<>();
}
