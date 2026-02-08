package com.erp.domain;

import lombok.*;
import org.springframework.format.annotation.DateTimeFormat;

import javax.persistence.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "livraisons")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Delivery {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "numero", nullable = false, length = 50, unique = true)
    private String numero;

    @Column(name = "statut", nullable = false, length = 50)
    private String statut;

    @Column(name = "date_creation")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime dateCreation;

    @Column(name = "date_livraison")
    @DateTimeFormat(pattern = "yyyy-MM-dd")
    private LocalDate dateLivraison;

    @Column(name = "commande_client_id")
    private Long commandeClientId;

    @Column(name = "entrepot_id")
    private Long entrepotId;

    @Column(name = "utilisateur_picking", length = 100)
    private String utilisateurPicking;

    @Column(name = "utilisateur_expedition", length = 100)
    private String utilisateurExpedition;

    @OneToMany(mappedBy = "livraison", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<DeliveryLine> lines = new ArrayList<>();
}
