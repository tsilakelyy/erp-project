package com.erp.domain;

import javax.persistence.*;
import java.time.LocalDateTime;
import java.util.Set;

@Entity
@Table(name = "utilisateurs")
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "login", unique = true, nullable = false)
    private String login;

    @Column(name = "mot_de_passe", nullable = false)
    private String password;

    @Column(name = "email")
    private String email;

    @Column(name = "nom")
    private String nom;

    @Column(name = "prenom")
    private String prenom;

    @Column(name = "actif")
    private Boolean active = true;

    @Column(name = "verrouille")
    private Boolean locked = false;

    @Column(name = "tentatives_connexion")
    private Integer loginAttempts = 0;

    @Column(name = "date_creation")
    private LocalDateTime dateCreation;

    @Column(name = "date_modification")
    private LocalDateTime dateModification;

    @Column(name = "date_last_login")
    private LocalDateTime dateLastLogin;

    @ManyToMany(fetch = FetchType.EAGER)
    @JoinTable(
        name = "habilitations_utilisateur",
        joinColumns = @JoinColumn(name = "utilisateur_id"),
        inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private Set<Role> roles;

    @Transient
    private Set<Warehouse> allowedWarehouses;

    @Transient
    private Set<String> allowedSites;

    public User() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getLogin() { return login; }
    public void setLogin(String login) { this.login = login; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getNom() { return nom; }
    public void setNom(String nom) { this.nom = nom; }

    public String getPrenom() { return prenom; }
    public void setPrenom(String prenom) { this.prenom = prenom; }

    public Boolean getActive() { return active; }
    public void setActive(Boolean active) { this.active = active; }

    public Boolean getLocked() { return locked; }
    public void setLocked(Boolean locked) { this.locked = locked; }

    public Integer getLoginAttempts() { return loginAttempts; }
    public void setLoginAttempts(Integer loginAttempts) { this.loginAttempts = loginAttempts; }

    public LocalDateTime getDateCreation() { return dateCreation; }
    public void setDateCreation(LocalDateTime dateCreation) { this.dateCreation = dateCreation; }

    public LocalDateTime getDateModification() { return dateModification; }
    public void setDateModification(LocalDateTime dateModification) { this.dateModification = dateModification; }

    public LocalDateTime getDateLastLogin() { return dateLastLogin; }
    public void setDateLastLogin(LocalDateTime dateLastLogin) { this.dateLastLogin = dateLastLogin; }

    public Set<Role> getRoles() { return roles; }
    public void setRoles(Set<Role> roles) { this.roles = roles; }

    public Set<Warehouse> getAllowedWarehouses() { return allowedWarehouses; }
    public void setAllowedWarehouses(Set<Warehouse> allowedWarehouses) { this.allowedWarehouses = allowedWarehouses; }

    public Set<String> getAllowedSites() { return allowedSites; }
    public void setAllowedSites(Set<String> allowedSites) { this.allowedSites = allowedSites; }

    // Méthode alias pour Spring Security
    public String getUsername() {
        return this.login;
    }
}
