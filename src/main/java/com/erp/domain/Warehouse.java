package com.erp.domain;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "entrepots")
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
    private Boolean actif = true;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @Column(name = "utilisateur_creation", length = 100)
    private String utilisateurCreation;

    @Column(name = "utilisateur_modification", length = 100)
    private String utilisateurModification;

    public Warehouse() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getNomDepot() { return nomDepot; }
    public void setNomDepot(String nomDepot) { this.nomDepot = nomDepot; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getCodePostal() { return codePostal; }
    public void setCodePostal(String codePostal) { this.codePostal = codePostal; }

    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }

    public Long getResponsableId() { return responsableId; }
    public void setResponsableId(Long responsableId) { this.responsableId = responsableId; }

    public BigDecimal getCapaciteMaximale() { return capaciteMaximale; }
    public void setCapaciteMaximale(BigDecimal capaciteMaximale) { this.capaciteMaximale = capaciteMaximale; }

    public BigDecimal getNiveauStockSecurite() { return niveauStockSecurite; }
    public void setNiveauStockSecurite(BigDecimal niveauStockSecurite) { this.niveauStockSecurite = niveauStockSecurite; }

    public BigDecimal getNiveauStockAlerte() { return niveauStockAlerte; }
    public void setNiveauStockAlerte(BigDecimal niveauStockAlerte) { this.niveauStockAlerte = niveauStockAlerte; }

    public String getTypeDepot() { return typeDepot; }
    public void setTypeDepot(String typeDepot) { this.typeDepot = typeDepot; }

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
