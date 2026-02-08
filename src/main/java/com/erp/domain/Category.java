package com.erp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder.Default;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "categories_articles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Category {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 50)
    private String code;

    @Column(name = "libelle", nullable = false, length = 200)
    private String libelle;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "actif")
    @Default
    private Boolean actif = true;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;

    // Relation OneToMany vers les articles de cette catégorie
    @OneToMany(mappedBy = "category", fetch = FetchType.LAZY, cascade = CascadeType.REFRESH)
    @Builder.Default
    private List<Article> articles = new ArrayList<>();

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
    }

    @PreUpdate
    protected void onUpdate() {
        this.dateModification = LocalDateTime.now();
    }
}
