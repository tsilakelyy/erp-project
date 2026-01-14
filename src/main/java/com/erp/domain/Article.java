package com.erp.domain;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "articles")
public class Article {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, length = 50, unique = true)
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
    private BigDecimal tauxTva;

    @Column(name = "quantite_minimale")
    private Long quantiteMinimale;

    @Column(name = "quantite_maximale")
    private Long quantiteMaximale;

    @Column(name = "actif")
    private Boolean actif = true;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;

    public Article() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public String getUniteMesure() { return uniteMesure; }
    public void setUniteMesure(String uniteMesure) { this.uniteMesure = uniteMesure; }

    public BigDecimal getPrixUnitaire() { return prixUnitaire; }
    public void setPrixUnitaire(BigDecimal prixUnitaire) { this.prixUnitaire = prixUnitaire; }

    public BigDecimal getTauxTva() { return tauxTva; }
    public void setTauxTva(BigDecimal tauxTva) { this.tauxTva = tauxTva; }

    public Long getQuantiteMinimale() { return quantiteMinimale; }
    public void setQuantiteMinimale(Long quantiteMinimale) { this.quantiteMinimale = quantiteMinimale; }

    public Long getQuantiteMaximale() { return quantiteMaximale; }
    public void setQuantiteMaximale(Long quantiteMaximale) { this.quantiteMaximale = quantiteMaximale; }

    public Boolean getActif() { return actif; }
    public void setActif(Boolean actif) { this.actif = actif; }

    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }

    public LocalDateTime getDateModification() { return dateModification; }
    public void setDateModification(LocalDateTime dateModification) { this.dateModification = dateModification; }

    public String getUtilisateurCreation() { return utilisateurCreation; }
    public void setUtilisateurCreation(String utilisateurCreation) { this.utilisateurCreation = utilisateurCreation; }

    public String getUtilisateurModification() { return utilisateurModification; }
    public void setUtilisateurModification(String utilisateurModification) { this.utilisateurModification = utilisateurModification; }
}