package com.erp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder.Default;

import javax.persistence.*;
import org.springframework.format.annotation.DateTimeFormat;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "listes_prix")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class PricingList {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 50)
    private String code;

    @Column(name = "libelle", nullable = false, length = 200)
    private String libelle;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "type_liste", nullable = false, length = 50)
    private String typeListe; // VENTE, ACHAT, GENERAL

    @Column(name = "date_debut", nullable = false)
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime dateDebut;

    @Column(name = "date_fin")
    @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm")
    private LocalDateTime dateFin;

    @Column(name = "devise", length = 10)
    @Default
    private String devise = "Ar";

    @Column(name = "actif")
    @Default
    private Boolean actif = true;

    @Column(name = "par_defaut")
    @Default
    private Boolean parDefaut = false;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;

    @OneToMany(mappedBy = "pricingList", cascade = CascadeType.ALL, orphanRemoval = true)
    @Builder.Default
    private List<PricingListLine> lines = new ArrayList<>();

    public String getName() {
        return this.libelle;
    }

    public void setName(String name) {
        this.libelle = name;
    }

    @PrePersist
    protected void onCreate() {
        if (this.dateCreation == null) {
            this.dateCreation = LocalDateTime.now();
        }
        if (this.actif == null) {
            this.actif = true;
        }
        if (this.parDefaut == null) {
            this.parDefaut = false;
        }
        if (this.devise == null) {
            this.devise = "Ar";
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.dateModification = LocalDateTime.now();
    }
}
