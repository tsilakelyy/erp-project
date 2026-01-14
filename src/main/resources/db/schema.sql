-- ERP Database Schema - MySQL 8.0
-- Create Database
CREATE DATABASE IF NOT EXISTS erp_db DEFAULT CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE erp_db;

-- Articles Table
CREATE TABLE IF NOT EXISTS articles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    libelle VARCHAR(200) NOT NULL,
    description VARCHAR(500),
    unite_mesure VARCHAR(10),
    prix_unitaire DECIMAL(15,2),
    taux_tva DECIMAL(5,2) DEFAULT 20.00,
    quantite_minimale BIGINT DEFAULT 0,
    quantite_maximale BIGINT,
    actif BOOLEAN DEFAULT true,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    INDEX idx_code (code),
    INDEX idx_libelle (libelle),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Fournisseurs (Suppliers) Table
CREATE TABLE IF NOT EXISTS fournisseurs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    nom_entreprise VARCHAR(200) NOT NULL,
    adresse VARCHAR(255),
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    contact_principal VARCHAR(100),
    modalite_paiement VARCHAR(50),
    delai_livraison_moyen INT,
    taux_remise DECIMAL(5,2) DEFAULT 0,
    evaluation_performance DECIMAL(3,2),
    actif BOOLEAN DEFAULT true,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    INDEX idx_code (code),
    INDEX idx_email (email),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Clients (Customers) Table
CREATE TABLE IF NOT EXISTS clients (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    nom_entreprise VARCHAR(200) NOT NULL,
    adresse VARCHAR(255),
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    telephone VARCHAR(20),
    email VARCHAR(100) UNIQUE,
    contact_principal VARCHAR(100),
    limite_credit_initiale DECIMAL(15,2),
    limite_credit_actuelle DECIMAL(15,2),
    remise_pourcentage DECIMAL(5,2) DEFAULT 0,
    delai_paiement_jours INT DEFAULT 30,
    actif BOOLEAN DEFAULT true,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    INDEX idx_code (code),
    INDEX idx_email (email),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Entrepots/Depots (Warehouses) Table
CREATE TABLE IF NOT EXISTS entrepots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    nom_depot VARCHAR(100) NOT NULL,
    adresse VARCHAR(255),
    code_postal VARCHAR(10),
    ville VARCHAR(100),
    responsable_id BIGINT,
    capacite_maximale DECIMAL(15,2),
    niveau_stock_securite DECIMAL(15,2),
    niveau_stock_alerte DECIMAL(15,2),
    type_depot VARCHAR(50),
    actif BOOLEAN DEFAULT true,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    INDEX idx_code (code),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Utilisateurs (Users) Table
CREATE TABLE IF NOT EXISTS utilisateurs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    login VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) NOT NULL,
    nom VARCHAR(100),
    prenom VARCHAR(100),
    actif BOOLEAN DEFAULT true,
    verrouille BOOLEAN DEFAULT false,
    tentatives_connexion INT DEFAULT 0,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    date_last_login TIMESTAMP NULL,
    INDEX idx_login (login),
    INDEX idx_email (email),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Roles Table
CREATE TABLE IF NOT EXISTS roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL,
    description VARCHAR(500),
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Autorisations (Permissions) Table
CREATE TABLE IF NOT EXISTS autorisations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(100) NOT NULL UNIQUE,
    libelle VARCHAR(200) NOT NULL,
    ressource VARCHAR(100),
    action VARCHAR(50),
    description VARCHAR(500),
    role_id BIGINT,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Habilitations Utilisateur Table
CREATE TABLE IF NOT EXISTS habilitations_utilisateur (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    utilisateur_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    entrepot_id BIGINT,
    date_debut TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_fin TIMESTAMP NULL,
    actif BOOLEAN DEFAULT true,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    UNIQUE KEY unique_habilitation (utilisateur_id, role_id, entrepot_id),
    INDEX idx_utilisateur (utilisateur_id),
    INDEX idx_role (role_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Audit Log Table
CREATE TABLE IF NOT EXISTS audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    utilisateur VARCHAR(100),
    nom_table VARCHAR(100),
    id_entity BIGINT,
    action VARCHAR(50),
    attribut_modifie VARCHAR(100),
    ancienne_valeur TEXT,
    nouvelle_valeur TEXT,
    adresse_ip VARCHAR(45),
    session_id VARCHAR(255),
    reference_document VARCHAR(255),
    INDEX idx_table_entity (nom_table, id_entity),
    INDEX idx_utilisateur (utilisateur),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Taxes Vente Table
CREATE TABLE IF NOT EXISTS taxes_vente (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    libelle VARCHAR(100) NOT NULL,
    taux DECIMAL(5,2),
    actif BOOLEAN DEFAULT true,
    date_debut TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_fin TIMESTAMP NULL,
    INDEX idx_code (code),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Stock Levels Table
CREATE TABLE IF NOT EXISTS niveaux_stock (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    article_id BIGINT NOT NULL,
    entrepot_id BIGINT NOT NULL,
    quantite_actuelle BIGINT DEFAULT 0,
    quantite_reservee BIGINT DEFAULT 0,
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE,
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id) ON DELETE CASCADE,
    UNIQUE KEY unique_stock_article_warehouse (article_id, entrepot_id),
    INDEX idx_article (article_id),
    INDEX idx_entrepot (entrepot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Stock Movements Table
CREATE TABLE IF NOT EXISTS mouvements_stock (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    type_mouvement VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    article_id BIGINT NOT NULL,
    entrepot_id BIGINT NOT NULL,
    quantite BIGINT NOT NULL,
    prix_unitaire DECIMAL(15,2),
    montant DECIMAL(15,2),
    motif VARCHAR(255),
    utilisateur VARCHAR(100),
    reference_document VARCHAR(255),
    FOREIGN KEY (article_id) REFERENCES articles(id),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_type (type_mouvement),
    INDEX idx_date (date_creation),
    INDEX idx_article (article_id),
    INDEX idx_entrepot (entrepot_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Purchase Requests (Demandes d'achat) Table
CREATE TABLE IF NOT EXISTS demandes_achat (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_soumission TIMESTAMP NULL,
    date_validite TIMESTAMP NULL,
    entrepot_id BIGINT,
    montant_estime DECIMAL(15,2),
    utilisateur_creation VARCHAR(100),
    utilisateur_approbation VARCHAR(100),
    motif_rejet VARCHAR(500),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Purchase Orders (Commandes d'achat) Table
CREATE TABLE IF NOT EXISTS commandes_achat (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_commande TIMESTAMP NULL,
    date_echeance_estimee TIMESTAMP NULL,
    fournisseur_id BIGINT,
    entrepot_id BIGINT,
    montant_ht DECIMAL(15,2),
    montant_tva DECIMAL(15,2),
    montant_ttc DECIMAL(15,2),
    taux_tva DECIMAL(5,2),
    utilisateur_creation VARCHAR(100),
    utilisateur_approbation VARCHAR(100),
    FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_fournisseur (fournisseur_id),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Invoices (Factures) Table
CREATE TABLE IF NOT EXISTS factures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    type_facture VARCHAR(50),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_facture TIMESTAMP NULL,
    date_echeance TIMESTAMP NULL,
    tiers_id BIGINT,
    montant_ht DECIMAL(15,2),
    montant_tva DECIMAL(15,2),
    montant_ttc DECIMAL(15,2),
    taux_tva DECIMAL(5,2),
    type_tiers VARCHAR(50),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Delivery Table
CREATE TABLE IF NOT EXISTS livraisons (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_livraison TIMESTAMP NULL,
    commande_client_id BIGINT,
    entrepot_id BIGINT,
    utilisateur_picking VARCHAR(100),
    utilisateur_expedition VARCHAR(100),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Inventory Table
CREATE TABLE IF NOT EXISTS inventaires (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    type_inventaire VARCHAR(50) NOT NULL,
    statut VARCHAR(50) NOT NULL,
    date_debut TIMESTAMP NULL,
    date_fin TIMESTAMP NULL,
    entrepot_id BIGINT,
    montant_theorique DECIMAL(15,2),
    montant_compte DECIMAL(15,2),
    utilisateur_responsable VARCHAR(100),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_type (type_inventaire),
    INDEX idx_statut (statut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Payment Reconciliation View (Indexes for fast queries)
CREATE TABLE IF NOT EXISTS paiements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_paiement TIMESTAMP NULL,
    montant DECIMAL(15,2),
    moyen_paiement VARCHAR(50),
    reference_transaction VARCHAR(255),
    facture_id BIGINT,
    fournisseur_id BIGINT,
    INDEX idx_statut (statut),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
