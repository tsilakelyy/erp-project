package com.erp.domain;

import javax.persistence.*;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "fournisseurs")
public class Supplier {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, length = 50, unique = true)
    private String code;

    @Column(name = "nom_entreprise", nullable = false, length = 200)
    private String nomEntreprise;

    @Column(name = "adresse", length = 255)
    private String adresse;

    @Column(name = "code_postal", length = 10)
    private String codePostal;

    @Column(name = "ville", length = 100)
    private String ville;

    @Column(name = "telephone", length = 20)
    private String telephone;

    @Column(name = "email", length = 100, unique = true)
    private String email;

    @Column(name = "contact_principal", length = 100)
    private String contactPrincipal;

    @Column(name = "modalite_paiement", length = 50)
    private String modalitePaiement;

    @Column(name = "delai_livraison_moyen")
    private Integer delaiLivraisonMoyen;

    @Column(name = "taux_remise", precision = 5, scale = 2)
    private BigDecimal tauxRemise;

    @Column(name = "evaluation_performance", precision = 3, scale = 2)
    private BigDecimal evaluationPerformance;

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

    public Supplier() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getNomEntreprise() { return nomEntreprise; }
    public void setNomEntreprise(String nomEntreprise) { this.nomEntreprise = nomEntreprise; }

    public String getAdresse() { return adresse; }
    public void setAdresse(String adresse) { this.adresse = adresse; }

    public String getCodePostal() { return codePostal; }
    public void setCodePostal(String codePostal) { this.codePostal = codePostal; }

    public String getVille() { return ville; }
    public void setVille(String ville) { this.ville = ville; }

    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getContactPrincipal() { return contactPrincipal; }
    public void setContactPrincipal(String contactPrincipal) { this.contactPrincipal = contactPrincipal; }

    public String getModalitePaiement() { return modalitePaiement; }
    public void setModalitePaiement(String modalitePaiement) { this.modalitePaiement = modalitePaiement; }

    public Integer getDelaiLivraisonMoyen() { return delaiLivraisonMoyen; }
    public void setDelaiLivraisonMoyen(Integer delaiLivraisonMoyen) { this.delaiLivraisonMoyen = delaiLivraisonMoyen; }

    public BigDecimal getTauxRemise() { return tauxRemise; }
    public void setTauxRemise(BigDecimal tauxRemise) { this.tauxRemise = tauxRemise; }

    public BigDecimal getEvaluationPerformance() { return evaluationPerformance; }
    public void setEvaluationPerformance(BigDecimal evaluationPerformance) { this.evaluationPerformance = evaluationPerformance; }

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
