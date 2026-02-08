package com.erp.domain;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.Builder.Default;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "articles")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Article {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 50)
    private String code;

    @Column(name = "libelle", nullable = false, length = 200)
    private String libelle;

    @Column(name = "description", length = 500)
    private String description;

    @Column(name = "unite_mesure", length = 10)
    private String uniteMesure;

    @Column(name = "prix_unitaire", precision = 15, scale = 2)
    private BigDecimal prixUnitaire;

    @Column(name = "taux_tva", precision = 5, scale = 2)
    @Default
    private BigDecimal tauxTva = BigDecimal.valueOf(20.00);

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "category_id", nullable = true, foreignKey = @ForeignKey(name = "fk_article_category"))
    private Category category;

    @Column(name = "quantite_minimale")
    @Default
    private Long quantiteMinimale = 0L;

    @Column(name = "quantite_maximale")
    private Long quantiteMaximale;

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

    // Méthodes alias pour compatibilité avec ArticleService
    public String getName() {
        return this.libelle;
    }

    public void setName(String name) {
        this.libelle = name;
    }

    public BigDecimal getPurchasePrice() {
        return this.prixUnitaire;
    }

    public void setPurchasePrice(BigDecimal purchasePrice) {
        this.prixUnitaire = purchasePrice;
    }

    public BigDecimal getSellingPrice() {
        return this.prixUnitaire;
    }

    public void setSellingPrice(BigDecimal sellingPrice) {
        this.prixUnitaire = sellingPrice;
    }

    public Long getMinStock() {
        return this.quantiteMinimale;
    }

    public void setMinStock(Long minStock) {
        this.quantiteMinimale = minStock;
    }

    public Long getMaxStock() {
        return this.quantiteMaximale;
    }

    public void setMaxStock(Long maxStock) {
        this.quantiteMaximale = maxStock;
    }

    public Boolean getTracked() {
        return true; // Par défaut, tous les articles sont suivis
    }

    public void setTracked(Boolean tracked) {
        // Ne rien faire, car cette propriété n'existe pas en base
    }

    public Boolean getActive() {
        return this.actif;
    }

    public void setActive(Boolean active) {
        this.actif = active;
    }

    public String getCreatedBy() {
        return this.utilisateurCreation;
    }

    public void setCreatedBy(String createdBy) {
        this.utilisateurCreation = createdBy;
        if (this.dateCreation == null) {
            this.dateCreation = LocalDateTime.now();
        }
    }

    public String getUpdatedBy() {
        return this.utilisateurModification;
    }

    public void setUpdatedBy(String updatedBy) {
        this.utilisateurModification = updatedBy;
        this.dateModification = LocalDateTime.now();
    }

    @PrePersist
    protected void onCreate() {
        if (this.dateCreation == null) {
            this.dateCreation = LocalDateTime.now();
        }
        if (this.actif == null) {
            this.actif = true;
        }
        if (this.tauxTva == null) {
            this.tauxTva = BigDecimal.valueOf(20.00);
        }
    }

    // Getter/Setter pour uniteMesure (déjà généré par Lombok, mais explicit pour clarté)
    public String getUniteMesure() {
        return this.uniteMesure;
    }

    public void setUniteMesure(String uniteMesure) {
        this.uniteMesure = uniteMesure;
    }

    // Helper getter/setter pour categoryId (pour le formulaire JSP)
    public Long getCategoryId() {
        return this.category != null ? this.category.getId() : null;
    }

    public void setCategoryId(Long categoryId) {
        // Ce setter sera appelé depuis les formulaires JSP
        // La catégorie complète sera chargée par JPA si nécessaire
        if (categoryId != null && (this.category == null || !categoryId.equals(this.category.getId()))) {
            this.category = new Category();
            this.category.setId(categoryId);
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.dateModification = LocalDateTime.now();
    }
}