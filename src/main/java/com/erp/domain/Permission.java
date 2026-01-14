package com.erp.domain;

import javax.persistence.*;

@Entity
@Table(name = "autorisations")
public class Permission {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "code", unique = true, nullable = false, length = 100)
    private String code;

    @Column(name = "libelle", length = 200)
    private String libelle;

    @Column(name = "ressource", length = 100)
    private String ressource;

    @Column(name = "action", length = 50)
    private String action;

    @Column(name = "description", length = 500)
    private String description;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "role_id")
    private Role role;

    public Permission() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getCode() { return code; }
    public void setCode(String code) { this.code = code; }

    public String getLibelle() { return libelle; }
    public void setLibelle(String libelle) { this.libelle = libelle; }

    public String getRessource() { return ressource; }
    public void setRessource(String ressource) { this.ressource = ressource; }

    public String getAction() { return action; }
    public void setAction(String action) { this.action = action; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Role getRole() { return role; }
    public void setRole(Role role) { this.role = role; }
}
