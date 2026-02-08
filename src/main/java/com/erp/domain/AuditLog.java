package com.erp.domain;

import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import javax.persistence.*;
import java.time.LocalDateTime;

@Entity
@Table(name = "audit_logs")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class AuditLog {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(name = "date_creation", nullable = false, updatable = false)
    @CreationTimestamp
    private LocalDateTime createdAt;

    @Column(name = "utilisateur", length = 100)
    private String userName;

    @Column(name = "nom_table", nullable = false, length = 100)
    private String entityName;

    @Column(name = "id_entity", nullable = false)
    private Long entityId;

    @Column(name = "action", nullable = false, length = 50)
    private String action;

    @Column(name = "attribut_modifie", length = 100)
    private String attributeModified;

    @Column(name = "ancienne_valeur", length = 1000)
    private String oldValues;

    @Column(name = "nouvelle_valeur", length = 1000)
    private String newValues;

    @Column(name = "adresse_ip", length = 45)
    private String ipAddress;

    @Column(name = "session_id", length = 255)
    private String sessionId;

    @Column(name = "reference_document", length = 255)
    private String reference;
}
