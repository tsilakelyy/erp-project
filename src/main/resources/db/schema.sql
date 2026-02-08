-- ERP Database Schema - MySQL 8.0 / MariaDB - CORRECTED VERSION
-- Create Database
drop database erp_db;
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



-- Ajouter les nouvelles colonnes à la table niveaux_stock
ALTER TABLE niveaux_stock
ADD COLUMN cout_moyen DECIMAL(10,2) AFTER quantite_reservee,
ADD COLUMN valeur_totale DECIMAL(15,2) AFTER cout_moyen,
ADD COLUMN quantite_disponible BIGINT DEFAULT 0 AFTER quantite_reservee,
ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP AFTER valeur_totale;

-- Vérifier la structure de la table
DESCRIBE niveaux_stock;

-- Mise à jour des valeurs existantes (optionnel)
-- Calculer le coût moyen basé sur le prix unitaire des articles
UPDATE niveaux_stock ns
JOIN articles a ON ns.article_id = a.id
SET 
    ns.cout_moyen = a.prix_unitaire,
    ns.valeur_totale = ns.quantite_actuelle * a.prix_unitaire;

-- Afficher un aperçu des données mises à jour
SELECT 
    a.code AS code_article,
    a.libelle AS article,
    e.nom_depot AS entrepot,
    ns.quantite_actuelle,
    ns.quantite_reservee,
    ns.cout_moyen,
    ns.valeur_totale
FROM niveaux_stock ns
JOIN articles a ON ns.article_id = a.id
JOIN entrepots e ON ns.entrepot_id = e.id
LIMIT 10;

SELECT '✅ Colonnes cout_moyen et valeur_totale ajoutées avec succès' AS status;

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

-- Units Table (Unités de mesure)
CREATE TABLE IF NOT EXISTS units (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10) NOT NULL UNIQUE,
    name VARCHAR(50) NOT NULL,
    symbol VARCHAR(10),
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Sites Table
CREATE TABLE IF NOT EXISTS sites (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(10),
    name VARCHAR(100),
    address VARCHAR(255),
    city VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(100),
    active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_code (code)
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
    importance VARCHAR(20),
    validation_mode VARCHAR(30),
    validation_finance_requise BOOLEAN,
    validation_direction_requise BOOLEAN,
    valide_finance BOOLEAN,
    valide_direction BOOLEAN,
    date_validation_finance TIMESTAMP NULL,
    date_validation_direction TIMESTAMP NULL,
    utilisateur_validation_finance VARCHAR(100),
    utilisateur_validation_direction VARCHAR(100),
    utilisateur_creation VARCHAR(100),
    utilisateur_approbation VARCHAR(100),
    motif_rejet VARCHAR(500),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Proformas (Factures proforma achat) Table
CREATE TABLE IF NOT EXISTS proformas (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_proforma TIMESTAMP NULL,
    date_validite TIMESTAMP NULL,
    demande_id BIGINT NULL,
    fournisseur_id BIGINT NULL,
    entrepot_id BIGINT NULL,
    importance VARCHAR(20),
    validation_mode VARCHAR(30),
    validation_finance_requise BOOLEAN,
    validation_direction_requise BOOLEAN,
    valide_finance BOOLEAN,
    valide_direction BOOLEAN,
    date_validation_finance TIMESTAMP NULL,
    date_validation_direction TIMESTAMP NULL,
    utilisateur_validation_finance VARCHAR(100),
    utilisateur_validation_direction VARCHAR(100),
    motif_rejet VARCHAR(500),
    montant_ht DECIMAL(15,2),
    montant_tva DECIMAL(15,2),
    montant_ttc DECIMAL(15,2),
    taux_tva DECIMAL(5,2),
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (demande_id) REFERENCES demandes_achat(id),
    FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_demande (demande_id),
    INDEX idx_fournisseur (fournisseur_id),
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
    proforma_id BIGINT NULL,
    fournisseur_id BIGINT,
    entrepot_id BIGINT,
    montant_ht DECIMAL(15,2),
    montant_tva DECIMAL(15,2),
    montant_ttc DECIMAL(15,2),
    taux_tva DECIMAL(5,2),
    utilisateur_creation VARCHAR(100),
    utilisateur_approbation VARCHAR(100),
    FOREIGN KEY (proforma_id) REFERENCES proformas(id),
    FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_proforma (proforma_id),
    INDEX idx_fournisseur (fournisseur_id),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Sales Orders (Commandes de vente) Table - MOVED HERE BEFORE commandes_ventes_lignes
CREATE TABLE IF NOT EXISTS proformas_ventes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_proforma TIMESTAMP NULL,
    date_validation_client TIMESTAMP NULL,
    client_id BIGINT,
    request_id BIGINT NULL,
    entrepot_id BIGINT NULL,
    montant_ht DECIMAL(15,2),
    montant_tva DECIMAL(15,2),
    montant_ttc DECIMAL(15,2),
    taux_tva DECIMAL(5,2),
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_client (client_id),
    INDEX idx_request (request_id),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS proformas_ventes_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    proforma_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(15,2),
    montant DECIMAL(15,2),
    notes VARCHAR(255),
    FOREIGN KEY (proforma_id) REFERENCES proformas_ventes(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_proforma (proforma_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS commandes_ventes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_commande TIMESTAMP NULL,
    client_id BIGINT,
    entrepot_id BIGINT,
    client_request_id BIGINT,
    proforma_id BIGINT,
    montant_ht DECIMAL(15,2),
    montant_tva DECIMAL(15,2),
    montant_ttc DECIMAL(15,2),
    taux_tva DECIMAL(5,2),
    utilisateur_creation VARCHAR(100),
    utilisateur_approbation VARCHAR(100),
    FOREIGN KEY (client_id) REFERENCES clients(id),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    FOREIGN KEY (proforma_id) REFERENCES proformas_ventes(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_client (client_id),
    INDEX idx_client_request (client_request_id),
    INDEX idx_proforma_vente (proforma_id),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Invoices (Factures) Table - MOVED HERE BEFORE factures_lignes
CREATE TABLE IF NOT EXISTS factures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    type_facture VARCHAR(50),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_facture TIMESTAMP NULL,
    date_echeance TIMESTAMP NULL,
    tiers_id BIGINT,
    commande_achat_id BIGINT NULL,
    commande_client_id BIGINT NULL,
    montant_ht DECIMAL(15,2),
    montant_tva DECIMAL(15,2),
    montant_ttc DECIMAL(15,2),
    taux_tva DECIMAL(5,2),
    type_tiers VARCHAR(50),
    FOREIGN KEY (commande_achat_id) REFERENCES commandes_achat(id),
    FOREIGN KEY (commande_client_id) REFERENCES commandes_ventes(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_commande_achat (commande_achat_id),
    INDEX idx_commande_client (commande_client_id),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Delivery Table - MOVED HERE BEFORE livraisons_lignes
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

-- Good Receipts (Réceptions) Table - MOVED HERE BEFORE receptions_lignes
CREATE TABLE IF NOT EXISTS receptions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    numero VARCHAR(50) NOT NULL UNIQUE,
    statut VARCHAR(50) NOT NULL,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_reception TIMESTAMP NULL,
    commande_id BIGINT,
    entrepot_id BIGINT,
    utilisateur_reception VARCHAR(100),
    utilisateur_validation VARCHAR(100),
    notes VARCHAR(500),
    FOREIGN KEY (commande_id) REFERENCES commandes_achat(id),
    FOREIGN KEY (entrepot_id) REFERENCES entrepots(id),
    INDEX idx_numero (numero),
    INDEX idx_statut (statut),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Inventory Table - MOVED HERE BEFORE inventaires_lignes
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

-- Purchase Request Lines Table
CREATE TABLE IF NOT EXISTS demandes_achat_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    demande_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(15,2),
    montant DECIMAL(15,2),
    notes VARCHAR(500),
    FOREIGN KEY (demande_id) REFERENCES demandes_achat(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_demande (demande_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Proforma Lines Table
CREATE TABLE IF NOT EXISTS proformas_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    proforma_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(15,2),
    montant DECIMAL(15,2),
    notes VARCHAR(500),
    FOREIGN KEY (proforma_id) REFERENCES proformas(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_proforma (proforma_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Purchase Order Lines Table
CREATE TABLE IF NOT EXISTS commandes_achat_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    commande_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(15,2),
    montant DECIMAL(15,2),
    FOREIGN KEY (commande_id) REFERENCES commandes_achat(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_commande (commande_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Sales Order Lines Table - NOW AFTER commandes_ventes
CREATE TABLE IF NOT EXISTS commandes_ventes_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    commande_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite_commandee INT NOT NULL,
    quantite_reservee INT DEFAULT 0,
    prix_unitaire DECIMAL(15,2),
    montant DECIMAL(15,2),
    FOREIGN KEY (commande_id) REFERENCES commandes_ventes(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_commande (commande_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Invoice Lines Table - NOW AFTER factures
CREATE TABLE IF NOT EXISTS factures_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    facture_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite INT NOT NULL,
    prix_unitaire DECIMAL(15,2),
    montant DECIMAL(15,2),
    FOREIGN KEY (facture_id) REFERENCES factures(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_facture (facture_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Delivery Lines Table - NOW AFTER livraisons
CREATE TABLE IF NOT EXISTS livraisons_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    livraison_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite INT NOT NULL,
    batch_number VARCHAR(100),
    serial_number VARCHAR(100),
    FOREIGN KEY (livraison_id) REFERENCES livraisons(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_livraison (livraison_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Good Receipt Lines Table - NOW AFTER receptions
CREATE TABLE IF NOT EXISTS receptions_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    reception_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite INT NOT NULL,
    batch_number VARCHAR(100),
    serial_number VARCHAR(100),
    location VARCHAR(50),
    notes VARCHAR(500),
    FOREIGN KEY (reception_id) REFERENCES receptions(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_reception (reception_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Inventory Lines Table - NOW AFTER inventaires
CREATE TABLE IF NOT EXISTS inventaires_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    inventaire_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    quantite_theorique INT,
    quantite_comptee INT,
    variance INT,
    notes VARCHAR(500),
    FOREIGN KEY (inventaire_id) REFERENCES inventaires(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_inventaire (inventaire_id),
    INDEX idx_article (article_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Payment Reconciliation Table
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
    FOREIGN KEY (facture_id) REFERENCES factures(id),
    FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id),
    INDEX idx_statut (statut),
    INDEX idx_date (date_creation)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Client Requests Table (Front office demandes)
CREATE TABLE IF NOT EXISTS client_requests (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id BIGINT NOT NULL,
    request_type VARCHAR(50) NOT NULL,
    statut VARCHAR(50) NOT NULL DEFAULT 'EN_ATTENTE',
    titre VARCHAR(150),
    description VARCHAR(500),
    article_id BIGINT,
    quantite DECIMAL(12,2),
    montant_estime DECIMAL(15,2),
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES clients(id),
    FOREIGN KEY (article_id) REFERENCES articles(id),
    INDEX idx_client (customer_id),
    INDEX idx_type (request_type),
    INDEX idx_statut (statut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
