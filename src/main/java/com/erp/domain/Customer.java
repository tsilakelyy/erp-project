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
@Table(name = "clients")
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class Customer {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", nullable = false, unique = true, length = 50)
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

    @Column(name = "limite_credit_initiale", precision = 15, scale = 2)
    private BigDecimal limiteCreditInitiale;

    @Column(name = "limite_credit_actuelle", precision = 15, scale = 2)
    private BigDecimal limiteCreditActuelle;

    @Column(name = "remise_pourcentage", precision = 5, scale = 2)
    @Default
    private BigDecimal remisePourcentage = BigDecimal.ZERO;

    @Column(name = "delai_paiement_jours")
    @Default
    private Integer delaiPaiementJours = 30;

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

    // Méthodes alias pour compatibilité avec CustomerService/Controller
    public String getName() {
        return this.nomEntreprise;
    }

    public void setName(String name) {
        this.nomEntreprise = name;
    }

    public String getAddress() {
        return this.adresse;
    }

    public void setAddress(String address) {
        this.adresse = address;
    }

    public String getCity() {
        return this.ville;
    }

    public void setCity(String city) {
        this.ville = city;
    }

    public String getZipCode() {
        return this.codePostal;
    }

    public void setZipCode(String zipCode) {
        this.codePostal = zipCode;
    }

    public String getPhone() {
        return this.telephone;
    }

    public void setPhone(String phone) {
        this.telephone = phone;
    }

    public String getContactPerson() {
        return this.contactPrincipal;
    }

    public void setContactPerson(String contactPerson) {
        this.contactPrincipal = contactPerson;
    }

    public Integer getPaymentTermsDays() {
        return this.delaiPaiementJours;
    }

    public void setPaymentTermsDays(Integer paymentTermsDays) {
        this.delaiPaiementJours = paymentTermsDays;
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
        if (this.delaiPaiementJours == null) {
            this.delaiPaiementJours = 30;
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.dateModification = LocalDateTime.now();
    }
}