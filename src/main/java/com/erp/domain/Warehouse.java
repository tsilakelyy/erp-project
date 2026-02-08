package com.erp.domain;

import lombok.*;
import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "entrepots")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Warehouse {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, length = 20, unique = true)
    private String code;

    @Column(name = "nom_depot", nullable = false, length = 100)
    private String nomDepot;

    @Column(name = "adresse", length = 255)
    private String adresse;

    @Column(name = "code_postal", length = 10)
    private String codePostal;

    @Column(name = "ville", length = 100)
    private String ville;

    @Column(name = "responsable_id")
    private Long responsableId;

    @Column(name = "capacite_maximale", precision = 15, scale = 2)
    private BigDecimal capaciteMaximale;

    @Column(name = "niveau_stock_securite", precision = 15, scale = 2)
    private BigDecimal niveauStockSecurite;

    @Column(name = "niveau_stock_alerte", precision = 15, scale = 2)
    private BigDecimal niveauStockAlerte;

    @Column(name = "type_depot", length = 50)
    private String typeDepot;

    @Column(name = "actif")
    @Builder.Default
    private Boolean actif = true;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;
}