-- ===============================================
-- DONNÉES DE TEST COMPLÈTES - ERP SYSTEM MADAGASCAR
-- Version corrigée avec données Madagascar (Ariary)
-- ===============================================
USE erp_db;

-- Nettoyage des données existantes
SET FOREIGN_KEY_CHECKS = 0;
TRUNCATE TABLE paiements;
TRUNCATE TABLE client_requests;
TRUNCATE TABLE inventaires_lignes;
TRUNCATE TABLE inventaires;
TRUNCATE TABLE receptions_lignes;
TRUNCATE TABLE receptions;
TRUNCATE TABLE livraisons_lignes;
TRUNCATE TABLE livraisons;
TRUNCATE TABLE factures_lignes;
TRUNCATE TABLE factures;
TRUNCATE TABLE commandes_ventes_lignes;
TRUNCATE TABLE commandes_ventes;
TRUNCATE TABLE commandes_achat_lignes;
TRUNCATE TABLE commandes_achat;
TRUNCATE TABLE proformas_lignes;
TRUNCATE TABLE proformas;
TRUNCATE TABLE proformas_ventes_lignes;
TRUNCATE TABLE proformas_ventes;
TRUNCATE TABLE demandes_achat_lignes;
TRUNCATE TABLE demandes_achat;
TRUNCATE TABLE mouvements_stock;
TRUNCATE TABLE niveaux_stock;
TRUNCATE TABLE habilitations_utilisateur;
TRUNCATE TABLE autorisations;
TRUNCATE TABLE audit_logs;
TRUNCATE TABLE articles;
TRUNCATE TABLE utilisateurs;
TRUNCATE TABLE roles;
TRUNCATE TABLE entrepots;
TRUNCATE TABLE fournisseurs;
TRUNCATE TABLE clients;
TRUNCATE TABLE taxes_vente;
TRUNCATE TABLE units;
TRUNCATE TABLE sites;
SET FOREIGN_KEY_CHECKS = 1;

-- ===============================================
-- 1. RÔLES
-- ===============================================
INSERT INTO roles (id, code, libelle, description) VALUES
(1, 'ADMIN', 'Administrateur', 'Accès complet au système'),
(2, 'ACHETEUR', 'Acheteur', 'Gestion des achats et fournisseurs'),
(3, 'COMMERCIAL', 'Commercial', 'Gestion des ventes et clients'),
(4, 'MAGASINIER', 'Magasinier', 'Gestion des stocks et entrepôts'),
(5, 'DIRECTION', 'Direction', 'Vue globale et reporting'),
(6, 'FINANCE', 'Finance', 'Gestion financière et comptable'),
(7, 'CLIENT', 'Client', 'Espace client');

-- ===============================================
-- 2. UTILISATEURS
-- ⚠️ IMPORTANT: Les utilisateurs sont créés par DataInitializer.java
-- Mot de passe pour tous: "password123" (BCrypt hash)
-- Hash BCrypt: $2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi
-- ===============================================
-- Les utilisateurs seront créés automatiquement par l'application

-- ===============================================
-- 3. AUTORISATIONS (Permissions)
-- ===============================================
INSERT INTO autorisations (id, code, libelle, ressource, action, description, role_id) VALUES
-- ADMIN
(1, 'ADMIN_ALL', 'Accès complet', '*', '*', 'Accès à toutes les ressources', 1),
-- ACHETEUR
(2, 'ACHAT_READ', 'Lecture achats', 'achats', 'READ', 'Consulter les achats', 2),
(3, 'ACHAT_WRITE', 'Écriture achats', 'achats', 'WRITE', 'Créer/modifier les achats', 2),
(4, 'FOURNISSEUR_MANAGE', 'Gestion fournisseurs', 'fournisseurs', '*', 'Gérer les fournisseurs', 2),
-- COMMERCIAL
(5, 'VENTE_READ', 'Lecture ventes', 'ventes', 'READ', 'Consulter les ventes', 3),
(6, 'VENTE_WRITE', 'Écriture ventes', 'ventes', 'WRITE', 'Créer/modifier les ventes', 3),
(7, 'CLIENT_MANAGE', 'Gestion clients', 'clients', '*', 'Gérer les clients', 3),
-- MAGASINIER
(8, 'STOCK_READ', 'Lecture stocks', 'stocks', 'READ', 'Consulter les stocks', 4),
(9, 'STOCK_WRITE', 'Écriture stocks', 'stocks', 'WRITE', 'Modifier les stocks', 4),
(10, 'INVENTAIRE_MANAGE', 'Gestion inventaires', 'inventaires', '*', 'Gérer les inventaires', 4),
-- DIRECTION
(11, 'REPORT_READ', 'Lecture rapports', 'rapports', 'READ', 'Consulter les rapports', 5),
(12, 'DASHBOARD_VIEW', 'Vue tableau de bord', 'dashboard', 'READ', 'Voir le tableau de bord', 5),
-- FINANCE
(13, 'FINANCE_READ', 'Lecture finances', 'finances', 'READ', 'Consulter les finances', 6),
(14, 'FINANCE_WRITE', 'Écriture finances', 'finances', 'WRITE', 'Gérer les finances', 6),
(15, 'FACTURE_MANAGE', 'Gestion factures', 'factures', '*', 'Gérer les factures', 6);

-- ===============================================
-- 4. ENTREPÔTS (RÉGIONS DE MADAGASCAR)
-- ===============================================
INSERT INTO entrepots (id, code, nom_depot, adresse, code_postal, ville, responsable_id, capacite_maximale, niveau_stock_securite, niveau_stock_alerte, type_depot, actif, date_creation, utilisateur_creation) VALUES
(1, 'DEP-ANA', 'Dépôt Central Analamanga', 'Lot IVG 123 Andraharo', '101', 'Antananarivo', NULL, 15000.00, 750.00, 1500.00, 'Principal', true, NOW(), 'admin'),
(2, 'DEP-ATS', 'Dépôt Atsinanana', 'Zone Portuaire Boulevard Joffre', '501', 'Toamasina', NULL, 8000.00, 400.00, 800.00, 'Secondaire', true, NOW(), 'admin'),
(3, 'DEP-FIA', 'Dépôt Haute Matsiatra', 'Route Nationale 7 Km 410', '301', 'Fianarantsoa', NULL, 5000.00, 250.00, 500.00, 'Secondaire', true, NOW(), 'admin'),
(4, 'DEP-MAJ', 'Dépôt Boeny', 'Zone Industrielle Amborovy', '401', 'Mahajanga', NULL, 6000.00, 300.00, 600.00, 'Secondaire', true, NOW(), 'admin'),
(5, 'DEP-TUL', 'Dépôt Atsimo Andrefana', 'Avenue de France', '601', 'Toliara', NULL, 4000.00, 200.00, 400.00, 'Tertiaire', true, NOW(), 'admin');

-- ===============================================
-- 5. SITES (PROVINCES DE MADAGASCAR)
-- ===============================================
INSERT INTO sites (id, code, name, address, city, zip_code, country, active, created_at) VALUES
(1, 'SITE-ANA', 'Site Analamanga', 'Quartier Ankorondrano', 'Antananarivo', '101', 'Madagascar', true, NOW()),
(2, 'SITE-ATS', 'Site Atsinanana', 'Boulevard Joffre', 'Toamasina', '501', 'Madagascar', true, NOW()),
(3, 'SITE-FIA', 'Site Haute Matsiatra', 'Centre-ville', 'Fianarantsoa', '301', 'Madagascar', true, NOW()),
(4, 'SITE-MAJ', 'Site Boeny', 'Quartier Amborovy', 'Mahajanga', '401', 'Madagascar', true, NOW()),
(5, 'SITE-TUL', 'Site Atsimo Andrefana', 'Avenue de France', 'Toliara', '601', 'Madagascar', true, NOW()),
(6, 'SITE-DIE', 'Site Diana', 'Rue Colbert', 'Antsiranana', '201', 'Madagascar', true, NOW());

-- ===============================================
-- 6. UNITÉS DE MESURE
-- ===============================================
INSERT INTO units (id, code, name, symbol, active, created_at) VALUES
(1, 'U', 'Unité', 'U', true, NOW()),
(2, 'KG', 'Kilogramme', 'kg', true, NOW()),
(3, 'L', 'Litre', 'L', true, NOW()),
(4, 'M', 'Mètre', 'm', true, NOW()),
(5, 'M2', 'Mètre carré', 'm²', true, NOW()),
(6, 'BOITE', 'Boîte', 'boîte', true, NOW()),
(7, 'PAQUET', 'Paquet', 'pqt', true, NOW()),
(8, 'KAPOAKA', 'Kapoaka', 'kpk', true, NOW()),
(9, 'VATA', 'Vata', 'vata', true, NOW());

-- ===============================================
-- 7. FOURNISSEURS (MADAGASCAR - Prix en Ariary)
-- ===============================================
INSERT INTO fournisseurs (id, code, nom_entreprise, adresse, code_postal, ville, telephone, email, contact_principal, modalite_paiement, delai_livraison_moyen, taux_remise, evaluation_performance, actif, date_creation, utilisateur_creation) VALUES
(1, 'FOUR-001', 'TechSupply Madagascar SARL', 'Zone Industrielle Forello Tanjombato', '101', 'Antananarivo', '+261 20 22 123 45', 'contact@techsupply.mg', 'Randria Jean Claude', '30 jours fin de mois', 7, 5.00, 4.50, true, NOW(), 'admin'),
(2, 'FOUR-002', 'GlobalParts Toamasina SA', 'Boulevard Joffre Tanambao', '501', 'Toamasina', '+261 20 53 234 56', 'commercial@globalparts.mg', 'Rasoa Marie Michelle', '45 jours fin de mois', 10, 10.00, 4.20, true, NOW(), 'admin'),
(3, 'FOUR-003', 'EquipPro Fianarantsoa', 'Rue Rabearivelo Tsianolondroa', '301', 'Fianarantsoa', '+261 20 75 345 67', 'info@equippro.mg', 'Rakoto Paul Heriniaina', '60 jours', 14, 7.50, 4.80, true, NOW(), 'admin'),
(4, 'FOUR-004', 'ElectroDistrib Mahajanga', 'Zone Amborovy Mahabibo', '401', 'Mahajanga', '+261 20 62 456 78', 'vente@electrodistrib.mg', 'Rasoanaivo Sophie', '30 jours', 5, 3.00, 4.00, true, NOW(), 'admin'),
(5, 'FOUR-005', 'InfoTech Antsiranana', 'Rue Colbert Centre', '201', 'Antsiranana', '+261 20 82 567 89', 'contact@infotech.mg', 'Andrianina Luc', '45 jours', 8, 6.00, 4.30, true, NOW(), 'admin');

INSERT INTO fournisseurs (id, code, nom_entreprise, adresse, code_postal, ville, telephone, email, contact_principal, modalite_paiement, delai_livraison_moyen, taux_remise, evaluation_performance, actif, date_creation, utilisateur_creation) VALUES
(6, 'FOUR-006', 'MadIT Supplies', 'Lot VB 45 Ankorondrano', '101', 'Antananarivo', '+261 20 23 987 65', 'contact@madit.mg', 'Raherisoa Kanto', '30 jours', 6, 4.50, 4.10, true, NOW(), 'admin'),
(7, 'FOUR-007', 'Oceanic Components', 'Quai Nord Port', '501', 'Toamasina', '+261 20 53 777 12', 'sales@oceanic.mg', 'Raharimanana Joel', '45 jours fin de mois', 9, 6.50, 4.40, true, NOW(), 'admin'),
(8, 'FOUR-008', 'SmartOffice Antsirabe', 'Avenue de la Gare', '110', 'Antsirabe', '+261 20 44 221 00', 'contact@smartoffice.mg', 'Rabe Fara', '60 jours', 12, 5.00, 4.00, true, NOW(), 'admin');

-- ===============================================
-- 8. CLIENTS (MADAGASCAR - Ariary)
-- ===============================================
INSERT INTO clients (id, code, nom_entreprise, adresse, code_postal, ville, telephone, email, contact_principal, limite_credit_initiale, limite_credit_actuelle, remise_pourcentage, delai_paiement_jours, actif, date_creation, utilisateur_creation) VALUES
(1, 'CLI-001', 'ABC Industries Madagascar', 'Zone Industrielle Ivato', '105', 'Antananarivo', '+261 33 11 111 11', 'contact@abc-industries.mg', 'Rakotonirina Patrick', 50000000.00, 48000000.00, 5.00, 30, true, NOW(), 'admin'),
(2, 'CLI-002', 'XYZ Distribution Toamasina', 'Avenue de l Independence', '501', 'Toamasina', '+261 32 22 222 22', 'commercial@xyz-distrib.mg', 'Rasoarimalala Hanta', 30000000.00, 28500000.00, 3.00, 45, true, NOW(), 'admin'),
(3, 'CLI-003', 'TechSolutions Fianarantsoa', 'Boulevard de la Liberation', '301', 'Fianarantsoa', '+261 34 33 333 33', 'info@techsolutions.mg', 'Andriamampianina Nivo', 20000000.00, 20000000.00, 2.00, 60, true, NOW(), 'admin'),
(4, 'CLI-004', 'Digital Partners Mahajanga', 'Rue du Commerce Tsararano', '401', 'Mahajanga', '+261 33 44 444 44', 'contact@digitalpartners.mg', 'Razafindrakoto Malala', 40000000.00, 35000000.00, 4.00, 30, true, NOW(), 'admin'),
(5, 'CLI-005', 'Innovation Corp Toliara', 'Avenue Philibert Tsiranana', '601', 'Toliara', '+261 32 55 555 55', 'info@innovcorp.mg', 'Raharison Fidy', 25000000.00, 25000000.00, 2.50, 45, true, NOW(), 'admin'),
(6, 'CLI-006', 'Entreprise Ravinala', 'Lalana Rainandriamampandry', '101', 'Antananarivo', '+261 34 66 666 66', 'ravinala@enterprise.mg', 'Rasolofo Miora', 35000000.00, 33000000.00, 3.50, 30, true, NOW(), 'admin'),
(7, 'CLI-007', 'Baobab Trading', 'Route Circulaire Ambohimanarina', '101', 'Antananarivo', '+261 33 77 777 77', 'baobab@trading.mg', 'Randrianasolo Hery', 45000000.00, 42000000.00, 4.50, 60, true, NOW(), 'admin');

INSERT INTO clients (id, code, nom_entreprise, adresse, code_postal, ville, telephone, email, contact_principal, limite_credit_initiale, limite_credit_actuelle, remise_pourcentage, delai_paiement_jours, actif, date_creation, utilisateur_creation) VALUES
(8, 'CLI-008', 'Razana Telecom', 'Lot 12B Alarobia', '101', 'Antananarivo', '+261 34 88 888 88', 'contact@razana.mg', 'Rajaonarison Mamy', 60000000.00, 58000000.00, 4.00, 30, true, NOW(), 'admin'),
(9, 'CLI-009', 'GreenTech Mahajanga', 'Rue de la Plage', '401', 'Mahajanga', '+261 33 99 999 99', 'sales@greentech.mg', 'Rasoloarison Fanja', 22000000.00, 21000000.00, 2.00, 45, true, NOW(), 'admin'),
(10, 'CLI-010', 'Nexa Systems', 'Zone Galaxy Soarano', '101', 'Antananarivo', '+261 32 10 10 10', 'contact@nexa.mg', 'Rakotoarison Nivo', 32000000.00, 31000000.00, 3.00, 30, true, NOW(), 'admin'),
(11, 'CLI-011', 'LogistiKa', 'RN2 PK 12', '105', 'Antananarivo', '+261 33 11 22 33', 'logistika@mg.com', 'Ranaivoson Lova', 28000000.00, 27000000.00, 2.50, 30, true, NOW(), 'admin'),
(12, 'CLI-012', 'Nova Retail', 'Avenue Independence', '501', 'Toamasina', '+261 34 12 34 56', 'hello@novaretail.mg', 'Randrianarisoa Tiana', 26000000.00, 24500000.00, 3.50, 45, true, NOW(), 'admin');

-- ===============================================
-- 9. TAXES (TVA MADAGASCAR)
-- ===============================================
INSERT INTO taxes_vente (id, code, libelle, taux, actif, date_debut) VALUES
(1, 'TVA20', 'TVA 20%', 20.00, true, NOW()),
(2, 'TVA0', 'Exonéré TVA', 0.00, true, NOW()),
(3, 'TVA5', 'TVA Réduite 5%', 5.00, true, NOW());

-- ===============================================
-- 10. ARTICLES (Prix en Ariary - 1 EUR ≈ 5000 Ar)
-- ===============================================
INSERT INTO articles (id, code, libelle, description, unite_mesure, prix_unitaire, taux_tva, quantite_minimale, quantite_maximale, actif, date_creation, utilisateur_creation) VALUES
(1, 'ART-001', 'Ordinateur Portable Dell Latitude', 'Ordinateur portable professionnel i5 8Go RAM', 'Unité', 6000000.00, 20.00, 5, 50, true, NOW(), 'admin'),
(2, 'ART-002', 'Clavier USB Standard', 'Clavier AZERTY USB filaire', 'Unité', 45000.00, 20.00, 10, 100, true, NOW(), 'admin'),
(3, 'ART-003', 'Souris Sans Fil Logitech', 'Souris optique sans fil 2.4GHz', 'Unité', 35000.00, 20.00, 20, 200, true, NOW(), 'admin'),
(4, 'ART-004', 'Écran LED 24 pouces HP', 'Moniteur Full HD HDMI VGA', 'Unité', 1500000.00, 20.00, 5, 30, true, NOW(), 'admin'),
(5, 'ART-005', 'Câble HDMI 2m', 'Câble haute définition plaqué or', 'Unité', 25000.00, 20.00, 50, 500, true, NOW(), 'admin'),
(6, 'ART-006', 'Hub USB 4 Ports', 'Multiplicateur USB 3.0 alimenté', 'Unité', 85000.00, 20.00, 30, 150, true, NOW(), 'admin'),
(7, 'ART-007', 'Casque Audio Bluetooth JBL', 'Casque sans fil réduction de bruit', 'Unité', 750000.00, 20.00, 10, 80, true, NOW(), 'admin'),
(8, 'ART-008', 'Webcam HD 1080p Logitech', 'Caméra visioconférence USB', 'Unité', 400000.00, 20.00, 15, 100, true, NOW(), 'admin'),
(9, 'ART-009', 'Disque Dur Externe 1To Seagate', 'Stockage portable USB 3.0', 'Unité', 450000.00, 20.00, 10, 60, true, NOW(), 'admin'),
(10, 'ART-010', 'Routeur WiFi TP-Link AC1200', 'Routeur dual band gigabit', 'Unité', 650000.00, 20.00, 5, 40, true, NOW(), 'admin'),
(11, 'ART-011', 'Imprimante Laser HP LaserJet', 'Imprimante réseau noir et blanc A4', 'Unité', 1500000.00, 20.00, 3, 20, true, NOW(), 'admin'),
(12, 'ART-012', 'Scanner Canon LiDE', 'Scanner à plat A4 USB', 'Unité', 950000.00, 20.00, 5, 25, true, NOW(), 'admin'),
(13, 'ART-013', 'Adaptateur USB-C Multiport', 'Hub USB-C HDMI VGA USB 3.0', 'Unité', 175000.00, 20.00, 25, 200, true, NOW(), 'admin'),
(14, 'ART-014', 'Tapis de Souris XXL', 'Mousepad gaming 80x40cm', 'Unité', 125000.00, 20.00, 30, 150, true, NOW(), 'admin'),
(15, 'ART-015', 'Support Laptop Aluminium', 'Support ergonomique réglable', 'Unité', 200000.00, 20.00, 15, 80, true, NOW(), 'admin'),
(16, 'ART-016', 'Clé USB 64Go Kingston', 'Clé USB 3.0 haute vitesse', 'Unité', 80000.00, 20.00, 40, 300, true, NOW(), 'admin'),
(17, 'ART-017', 'Onduleur 650VA APC', 'Onduleur protege 4 prises', 'Unité', 850000.00, 20.00, 8, 50, true, NOW(), 'admin'),
(18, 'ART-018', 'Carte Réseau WiFi USB', 'Adaptateur WiFi AC600 USB', 'Unité', 95000.00, 20.00, 20, 120, true, NOW(), 'admin');

INSERT INTO articles (id, code, libelle, description, unite_mesure, prix_unitaire, taux_tva, quantite_minimale, quantite_maximale, actif, date_creation, utilisateur_creation) VALUES
(19, 'ART-019', 'Serveur Dell PowerEdge', 'Serveur rack 2U Xeon 64Go RAM', 'Unité', 12000000.00, 20.00, 1, 10, true, NOW(), 'admin'),
(20, 'ART-020', 'Switch Cisco 24 ports', 'Switch manageable gigabit 24 ports', 'Unité', 1200000.00, 20.00, 2, 40, true, NOW(), 'admin'),
(21, 'ART-021', 'Projecteur Epson', 'Projecteur Full HD 4000 lumens', 'Unité', 2500000.00, 20.00, 2, 20, true, NOW(), 'admin'),
(22, 'ART-022', 'Onduleur 1500VA', 'Onduleur ligne interactive', 'Unité', 1600000.00, 20.00, 2, 30, true, NOW(), 'admin'),
(23, 'ART-023', 'Casque Micro Jabra', 'Casque USB antibruit', 'Unité', 180000.00, 20.00, 10, 120, true, NOW(), 'admin'),
(24, 'ART-024', 'Cable RJ45 Cat6 5m', 'Cable reseau haute vitesse', 'Unité', 15000.00, 20.00, 100, 1000, true, NOW(), 'admin');

-- ===============================================
-- 11. NIVEAUX DE STOCK
-- ===============================================
INSERT INTO niveaux_stock (article_id, entrepot_id, quantite_actuelle, quantite_reservee, cout_moyen, valeur_totale) VALUES
-- Dépôt Antananarivo
(1, 1, 25, 3, 5800000.00, 145000000.00),
(2, 1, 150, 10, 42000.00, 6300000.00),
(3, 1, 300, 15, 33000.00, 9900000.00),
(4, 1, 45, 5, 1450000.00, 65250000.00),
(5, 1, 500, 20, 23000.00, 11500000.00),
(6, 1, 120, 8, 82000.00, 9840000.00),
(7, 1, 65, 4, 730000.00, 47450000.00),
(8, 1, 85, 6, 385000.00, 32725000.00),
(9, 1, 50, 3, 440000.00, 22000000.00),
(10, 1, 35, 2, 630000.00, 22050000.00),
-- Dépôt Toamasina
(1, 2, 15, 2, 5900000.00, 88500000.00),
(2, 2, 80, 5, 43000.00, 3440000.00),
(3, 2, 200, 10, 34000.00, 6800000.00),
(6, 2, 100, 8, 83000.00, 8300000.00),
(7, 2, 50, 3, 740000.00, 37000000.00),
(11, 2, 18, 1, 1480000.00, 26640000.00),
(12, 2, 22, 2, 940000.00, 20680000.00),
(13, 2, 180, 12, 170000.00, 30600000.00),
-- Dépôt Fianarantsoa
(8, 3, 60, 4, 395000.00, 23700000.00),
(9, 3, 40, 2, 445000.00, 17800000.00),
(10, 3, 30, 1, 640000.00, 19200000.00),
(14, 3, 95, 7, 120000.00, 11400000.00),
(15, 3, 68, 5, 195000.00, 13260000.00),
-- Dépôt Mahajanga
(16, 4, 250, 15, 78000.00, 19500000.00),
(17, 4, 35, 3, 830000.00, 29050000.00),
(18, 4, 110, 8, 93000.00, 10230000.00);

INSERT INTO niveaux_stock (article_id, entrepot_id, quantite_actuelle, quantite_reservee, cout_moyen, valeur_totale) VALUES
-- Nouveaux articles
(19, 1, 10, 0, 12000000.00, 120000000.00),
(19, 2, 5, 0, 12000000.00, 60000000.00),
(20, 1, 50, 2, 1200000.00, 60000000.00),
(21, 2, 20, 1, 2500000.00, 50000000.00),
(22, 1, 15, 1, 1600000.00, 24000000.00),
(23, 3, 40, 4, 180000.00, 7200000.00),
(24, 1, 500, 20, 15000.00, 7500000.00);

-- ===============================================
-- 12. DEMANDES D'ACHAT
-- ===============================================
INSERT INTO demandes_achat (id, numero, statut, date_creation, date_soumission, date_validite, entrepot_id, montant_estime, utilisateur_creation, utilisateur_approbation) VALUES
(1, 'DA-2025-001', 'APPROUVEE', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_ADD(NOW(), INTERVAL 30 DAY), 1, 35000000.00, 'magasinier1', 'acheteur1'),
(2, 'DA-2025-002', 'EN_ATTENTE', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_ADD(NOW(), INTERVAL 45 DAY), 2, 15000000.00, 'magasinier1', NULL),
(3, 'DA-2025-003', 'APPROUVEE', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_ADD(NOW(), INTERVAL 40 DAY), 1, 45000000.00, 'magasinier1', 'acheteur1'),
(4, 'DA-2025-004', 'REJETEE', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 19 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), 3, 8000000.00, 'magasinier1', 'acheteur1');

-- ===============================================
-- 13. LIGNES DEMANDES D'ACHAT
-- ===============================================
INSERT INTO demandes_achat_lignes (demande_id, article_id, quantite, prix_unitaire, montant, notes) VALUES
(1, 1, 5, 5800000.00, 29000000.00, 'Renouvellement parc informatique bureau'),
(1, 4, 4, 1500000.00, 6000000.00, 'Écrans supplémentaires'),
(2, 2, 100, 45000.00, 4500000.00, 'Stock faible - commande urgente'),
(2, 3, 150, 35000.00, 5250000.00, 'Commande groupée périphériques'),
(2, 5, 250, 25000.00, 6250000.00, 'Câbles de connexion'),
(3, 7, 30, 750000.00, 22500000.00, 'Équipement téléconférence salles réunion'),
(3, 8, 25, 400000.00, 10000000.00, 'Webcams pour télétravail'),
(3, 11, 8, 1500000.00, 12000000.00, 'Imprimantes réseau nouveaux bureaux'),
(4, 16, 100, 80000.00, 8000000.00, 'Stock de sécurité clés USB');

-- ===============================================
-- 13b. PROFORMAS (Factures proforma achat)
-- ===============================================
INSERT INTO proformas (
    id, numero, statut, date_creation, date_proforma, date_validite,
    demande_id, fournisseur_id, entrepot_id,
    importance, validation_mode,
    validation_finance_requise, validation_direction_requise,
    valide_finance, valide_direction,
    date_validation_finance, utilisateur_validation_finance,
    montant_ht, montant_tva, montant_ttc, taux_tva,
    utilisateur_creation
) VALUES
(1, 'PF-2025-001', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY),
 2, 2, 2,
 'MOYENNE', 'AUTO',
 true, false,
 true, false,
 DATE_SUB(NOW(), INTERVAL 5 DAY), 'finance1',
 16000000.00, 3200000.00, 19200000.00, 20.00,
 'acheteur1'),
(2, 'PF-2025-002', 'EN_ATTENTE', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 15 DAY),
 1, 1, 1,
 'ELEVEE', 'FINANCE_DIRECTION',
 true, true,
 true, false,
 DATE_SUB(NOW(), INTERVAL 1 DAY), 'finance1',
 35000000.00, 7000000.00, 42000000.00, 20.00,
 'acheteur1');

-- ===============================================
-- 13c. LIGNES PROFORMAS
-- ===============================================
INSERT INTO proformas_lignes (proforma_id, article_id, quantite, prix_unitaire, montant, notes) VALUES
(1, 2, 100, 42000.00, 4200000.00, 'Claviers'),
(1, 3, 150, 33000.00, 4950000.00, 'Souris'),
(1, 5, 250, 23000.00, 5750000.00, 'Cables HDMI'),
(1, 6, 15, 82000.00, 1230000.00, 'Hubs USB'),
(2, 1, 5, 5800000.00, 29000000.00, 'Ordinateurs'),
(2, 4, 4, 1500000.00, 6000000.00, 'Ecrans');

-- ===============================================
-- 14. COMMANDES D'ACHAT
-- ===============================================
INSERT INTO commandes_achat (id, numero, statut, date_creation, date_commande, date_echeance_estimee, fournisseur_id, entrepot_id, montant_ht, montant_tva, montant_ttc, taux_tva, utilisateur_creation, utilisateur_approbation) VALUES
(1, 'CA-2025-001', 'RECUE', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 1, 1, 35000000.00, 7000000.00, 42000000.00, 20.00, 'acheteur1', 'direction1'),
(2, 'CA-2025-002', 'EN_COURS', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_ADD(NOW(), INTERVAL 7 DAY), 2, 2, 16000000.00, 3200000.00, 19200000.00, 20.00, 'acheteur1', 'direction1'),
(3, 'CA-2025-003', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 12 DAY), 1, 1, 44500000.00, 8900000.00, 53400000.00, 20.00, 'acheteur1', 'direction1'),
(4, 'CA-2025-004', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_ADD(NOW(), INTERVAL 10 DAY), 3, 3, 12500000.00, 2500000.00, 15000000.00, 20.00, 'acheteur1', 'direction1');

-- Lier certaines commandes aux proformas pour le suivi
UPDATE commandes_achat SET proforma_id = 1 WHERE id = 1;
UPDATE commandes_achat SET proforma_id = 2 WHERE id = 2;

-- ===============================================
-- 15. LIGNES COMMANDES D'ACHAT
-- ===============================================
INSERT INTO commandes_achat_lignes (commande_id, article_id, quantite, prix_unitaire, montant) VALUES
(1, 1, 5, 5800000.00, 29000000.00),
(1, 4, 4, 1500000.00, 6000000.00),
(2, 2, 100, 42000.00, 4200000.00),
(2, 3, 150, 33000.00, 4950000.00),
(2, 5, 250, 23000.00, 5750000.00),
(2, 6, 15, 82000.00, 1230000.00),
(3, 7, 30, 730000.00, 21900000.00),
(3, 8, 25, 385000.00, 9625000.00),
(3, 11, 8, 1480000.00, 11840000.00),
(3, 13, 50, 170000.00, 8500000.00),
(4, 9, 30, 440000.00, 13200000.00);

-- ===============================================
-- 16. RÉCEPTIONS
-- ===============================================
INSERT INTO receptions (id, numero, statut, date_creation, date_reception, commande_id, entrepot_id, utilisateur_reception, utilisateur_validation, notes) VALUES
(1, 'REC-2025-001', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 1, 1, 'magasinier1', 'acheteur1', 'Réception complète conforme - Bon état'),
(2, 'REC-2025-002', 'EN_COURS', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 2, 2, 'magasinier1', NULL, 'Réception partielle - Vérification en cours'),
(3, 'REC-2025-003', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY), 4, 3, 'magasinier1', 'acheteur1', 'Conforme - Stock mis à jour');

-- ===============================================
-- 17. LIGNES RÉCEPTIONS
-- ===============================================
INSERT INTO receptions_lignes (reception_id, article_id, quantite, batch_number, serial_number, location, notes) VALUES
(1, 1, 5, 'BATCH-2025-001', NULL, 'A-01-15', 'Cartons scellés - Bon état'),
(1, 4, 4, 'BATCH-2025-002', NULL, 'A-01-16', 'Emballages intacts'),
(2, 2, 80, 'BATCH-2025-003', NULL, 'B-02-10', 'Réception partielle - manque 20 unités'),
(2, 3, 150, 'BATCH-2025-004', NULL, 'B-02-11', 'Conforme à la commande'),
(3, 9, 30, 'BATCH-2025-005', NULL, 'C-03-08', 'Tous testés - Fonctionnels');

-- ===============================================
-- 18. COMMANDES DE VENTE
-- ===============================================
INSERT INTO commandes_ventes (id, numero, statut, date_creation, date_commande, client_id, entrepot_id, montant_ht, montant_tva, montant_ttc, taux_tva, utilisateur_creation, utilisateur_approbation) VALUES
(1, 'CV-2025-001', 'LIVREE', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), 1, 1, 18000000.00, 3600000.00, 21600000.00, 20.00, 'commercial1', 'direction1'),
(2, 'CV-2025-002', 'EN_COURS', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 2, 1, 22500000.00, 4500000.00, 27000000.00, 20.00, 'commercial1', 'direction1'),
(3, 'CV-2025-003', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 3, 2, 11000000.00, 2200000.00, 13200000.00, 20.00, 'commercial1', 'direction1'),
(4, 'CV-2025-004', 'LIVREE', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY), 4, 1, 9000000.00, 1800000.00, 10800000.00, 20.00, 'commercial1', 'direction1'),
(5, 'CV-2025-005', 'EN_COURS', DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), 5, 3, 14500000.00, 2900000.00, 17400000.00, 20.00, 'commercial1', 'direction1');

INSERT INTO commandes_ventes (id, numero, statut, date_creation, date_commande, client_id, entrepot_id, client_request_id, proforma_id, montant_ht, montant_tva, montant_ttc, taux_tva, utilisateur_creation, utilisateur_approbation) VALUES
(6, 'CV-2025-006', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), 6, 1, 7, NULL, 6050000.00, 1210000.00, 7260000.00, 20.00, 'commercial1', 'direction1'),
(7, 'CV-2025-007', 'EN_COURS', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), 7, 2, 12, NULL, 12000000.00, 2400000.00, 14400000.00, 20.00, 'commercial1', 'direction1'),
(8, 'CV-2025-008', 'LIVREE', DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 9 DAY), 2, 1, NULL, NULL, 2950000.00, 590000.00, 3540000.00, 20.00, 'commercial1', 'direction1'),
(9, 'CV-2025-009', 'PAYEE', DATE_SUB(NOW(), INTERVAL 14 DAY), DATE_SUB(NOW(), INTERVAL 14 DAY), 3, 2, NULL, NULL, 6400000.00, 1280000.00, 7680000.00, 20.00, 'commercial1', 'direction1'),
(10, 'CV-2025-010', 'BROUILLON', DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 8, 3, NULL, NULL, 5000000.00, 1000000.00, 6000000.00, 20.00, 'commercial1', NULL);

-- ===============================================
-- 19. LIGNES COMMANDES DE VENTE
-- ===============================================
INSERT INTO commandes_ventes_lignes (commande_id, article_id, quantite_commandee, quantite_reservee, prix_unitaire, montant) VALUES
(1, 1, 2, 2, 6000000.00, 12000000.00),
(1, 4, 4, 4, 1500000.00, 6000000.00),
(2, 2, 50, 10, 45000.00, 2250000.00),
(2, 3, 100, 15, 35000.00, 3500000.00),
(2, 7, 10, 4, 750000.00, 7500000.00),
(2, 8, 12, 6, 400000.00, 4800000.00),
(2, 16, 50, 0, 80000.00, 4000000.00),
(3, 9, 10, 3, 450000.00, 4500000.00),
(3, 10, 10, 2, 650000.00, 6500000.00),
(4, 6, 30, 0, 85000.00, 2550000.00),
(4, 5, 100, 0, 25000.00, 2500000.00),
(4, 13, 25, 0, 175000.00, 4375000.00),
(5, 11, 5, 1, 1500000.00, 7500000.00),
(5, 12, 4, 2, 950000.00, 3800000.00),
(5, 17, 3, 3, 850000.00, 2550000.00);

INSERT INTO commandes_ventes_lignes (commande_id, article_id, quantite_commandee, quantite_reservee, prix_unitaire, montant) VALUES
(6, 2, 80, 20, 45000.00, 3600000.00),
(6, 3, 70, 15, 35000.00, 2450000.00),
(7, 1, 2, 2, 6000000.00, 12000000.00),
(8, 6, 20, 0, 85000.00, 1700000.00),
(8, 5, 50, 0, 25000.00, 1250000.00),
(9, 11, 3, 1, 1500000.00, 4500000.00),
(9, 12, 2, 1, 950000.00, 1900000.00);

-- ===============================================
-- 20. LIVRAISONS
-- ===============================================
INSERT INTO livraisons (id, numero, statut, date_creation, date_livraison, commande_client_id, entrepot_id, utilisateur_picking, utilisateur_expedition) VALUES
(1, 'LIV-2025-001', 'EXPEDIEE', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), 1, 1, 'magasinier1', 'magasinier1'),
(2, 'LIV-2025-002', 'EN_PREPARATION', DATE_SUB(NOW(), INTERVAL 3 DAY), NULL, 2, 1, 'magasinier1', NULL),
(3, 'LIV-2025-003', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 3, 2, NULL, NULL),
(4, 'LIV-2025-004', 'EXPEDIEE', DATE_SUB(NOW(), INTERVAL 13 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY), 4, 1, 'magasinier1', 'magasinier1');

INSERT INTO livraisons (id, numero, statut, date_creation, date_livraison, commande_client_id, entrepot_id, utilisateur_picking, utilisateur_expedition) VALUES
(5, 'LIV-2025-005', 'EN_PREPARATION', DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 6, 1, 'magasinier1', NULL),
(6, 'LIV-2025-006', 'EXPEDIEE', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY), 7, 2, 'magasinier1', 'magasinier1'),
(7, 'LIV-2025-007', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY), 8, 1, 'magasinier1', 'magasinier1'),
(8, 'LIV-2025-008', 'VALIDEE', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 11 DAY), 9, 2, 'magasinier1', 'magasinier1');

-- ===============================================
-- 21. LIGNES LIVRAISONS
-- ===============================================
INSERT INTO livraisons_lignes (livraison_id, article_id, quantite, batch_number, serial_number) VALUES
(1, 1, 2, 'BATCH-2025-001', 'SN-DELL-001-002'),
(1, 4, 4, 'BATCH-2024-045', NULL),
(2, 2, 10, 'BATCH-2025-003', NULL),
(2, 3, 15, 'BATCH-2025-004', NULL),
(4, 6, 30, 'BATCH-2024-088', NULL),
(4, 5, 100, 'BATCH-2025-006', NULL);

INSERT INTO livraisons_lignes (livraison_id, article_id, quantite, batch_number, serial_number) VALUES
(5, 2, 80, 'BATCH-2025-010', NULL),
(5, 3, 70, 'BATCH-2025-011', NULL),
(6, 1, 2, 'BATCH-2025-012', 'SN-DELL-003-004'),
(7, 6, 20, 'BATCH-2025-013', NULL),
(7, 5, 50, 'BATCH-2025-014', NULL),
(8, 11, 3, 'BATCH-2025-015', NULL),
(8, 12, 2, 'BATCH-2025-016', NULL);

-- ===============================================
-- 22. FACTURES
-- ===============================================
INSERT INTO factures (id, numero, statut, type_facture, date_creation, date_facture, date_echeance, tiers_id, montant_ht, montant_tva, montant_ttc, taux_tva, type_tiers) VALUES
-- Factures Vente
(1, 'FV-2025-001', 'PAYEE', 'VENTE', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 1, 18000000.00, 3600000.00, 21600000.00, 20.00, 'CLIENT'),
(2, 'FV-2025-002', 'EN_ATTENTE', 'VENTE', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_ADD(NOW(), INTERVAL 25 DAY), 2, 22500000.00, 4500000.00, 27000000.00, 20.00, 'CLIENT'),
(3, 'FV-2025-003', 'EN_ATTENTE', 'VENTE', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_ADD(NOW(), INTERVAL 58 DAY), 3, 11000000.00, 2200000.00, 13200000.00, 20.00, 'CLIENT'),
(4, 'FV-2025-004', 'PAYEE', 'VENTE', DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 15 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), 4, 9000000.00, 1800000.00, 10800000.00, 20.00, 'CLIENT'),
-- Factures Achat
(5, 'FA-2025-001', 'PAYEE', 'ACHAT', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), 1, 35000000.00, 7000000.00, 42000000.00, 20.00, 'FOURNISSEUR'),
(6, 'FA-2025-002', 'EN_ATTENTE', 'ACHAT', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_ADD(NOW(), INTERVAL 37 DAY), 2, 16000000.00, 3200000.00, 19200000.00, 20.00, 'FOURNISSEUR'),
(7, 'FA-2025-003', 'PAYEE', 'ACHAT', DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 20 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 3, 12500000.00, 2500000.00, 15000000.00, 20.00, 'FOURNISSEUR');

INSERT INTO factures (id, numero, statut, type_facture, date_creation, date_facture, date_echeance, tiers_id, commande_client_id, montant_ht, montant_tva, montant_ttc, taux_tva, type_tiers) VALUES
(8, 'FV-2025-006', 'EN_ATTENTE', 'VENTE', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_ADD(NOW(), INTERVAL 22 DAY), 2, 8, 2950000.00, 590000.00, 3540000.00, 20.00, 'CLIENT'),
(9, 'FV-2025-007', 'PAYEE', 'VENTE', DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 12 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 3, 9, 6400000.00, 1280000.00, 7680000.00, 20.00, 'CLIENT'),
(10, 'FV-2025-008', 'EN_ATTENTE', 'VENTE', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_ADD(NOW(), INTERVAL 27 DAY), 6, 6, 6050000.00, 1210000.00, 7260000.00, 20.00, 'CLIENT');

-- Lier certaines factures aux commandes d'achat pour le suivi
UPDATE factures SET commande_achat_id = 1 WHERE id = 5;
UPDATE factures SET commande_achat_id = 2 WHERE id = 6;
UPDATE factures SET commande_achat_id = 4 WHERE id = 7;

-- Lier certaines factures de vente aux commandes clients
UPDATE factures SET commande_client_id = 1 WHERE id = 1;
UPDATE factures SET commande_client_id = 2 WHERE id = 2;
UPDATE factures SET commande_client_id = 3 WHERE id = 3;
UPDATE factures SET commande_client_id = 4 WHERE id = 4;

-- ===============================================
-- 23. LIGNES FACTURES
-- ===============================================
INSERT INTO factures_lignes (facture_id, article_id, quantite, prix_unitaire, montant) VALUES
-- Facture Vente 1
(1, 1, 2, 6000000.00, 12000000.00),
(1, 4, 4, 1500000.00, 6000000.00),
-- Facture Vente 2
(2, 2, 50, 45000.00, 2250000.00),
(2, 3, 100, 35000.00, 3500000.00),
(2, 7, 10, 750000.00, 7500000.00),
(2, 8, 12, 400000.00, 4800000.00),
(2, 16, 50, 80000.00, 4000000.00),
-- Facture Vente 3
(3, 9, 10, 450000.00, 4500000.00),
(3, 10, 10, 650000.00, 6500000.00),
-- Facture Vente 4
(4, 6, 30, 85000.00, 2550000.00),
(4, 5, 100, 25000.00, 2500000.00),
(4, 13, 25, 175000.00, 4375000.00),
-- Facture Achat 1
(5, 1, 5, 5800000.00, 29000000.00),
(5, 4, 4, 1500000.00, 6000000.00),
-- Facture Achat 2
(6, 2, 100, 42000.00, 4200000.00),
(6, 3, 150, 33000.00, 4950000.00),
(6, 5, 250, 23000.00, 5750000.00),
(6, 6, 15, 82000.00, 1230000.00),
-- Facture Achat 3
(7, 9, 30, 440000.00, 13200000.00);

INSERT INTO factures_lignes (facture_id, article_id, quantite, prix_unitaire, montant) VALUES
-- Facture Vente 6
(8, 6, 20, 85000.00, 1700000.00),
(8, 5, 50, 25000.00, 1250000.00),
-- Facture Vente 7
(9, 11, 3, 1500000.00, 4500000.00),
(9, 12, 2, 950000.00, 1900000.00),
-- Facture Vente 8
(10, 2, 80, 45000.00, 3600000.00),
(10, 3, 70, 35000.00, 2450000.00);

-- ===============================================
-- 24. PAIEMENTS (En Ariary)
-- ===============================================
INSERT INTO paiements (id, numero, statut, date_creation, date_paiement, montant, moyen_paiement, reference_transaction, facture_id, fournisseur_id) VALUES
(1, 'PAY-2025-001', 'COMPLETE', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 21600000.00, 'VIREMENT', 'VIR-BNI-2025-001', 1, NULL),
(2, 'PAY-2025-002', 'COMPLETE', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), 42000000.00, 'VIREMENT', 'VIR-BOA-2025-002', 5, 1),
(3, 'PAY-2025-003', 'EN_ATTENTE', NOW(), NULL, 27000000.00, 'VIREMENT', NULL, 2, NULL),
(4, 'PAY-2025-004', 'EN_ATTENTE', NOW(), NULL, 19200000.00, 'CHEQUE', 'CHQ-456789', 6, 2),
(5, 'PAY-2025-005', 'COMPLETE', DATE_SUB(NOW(), INTERVAL 10 DAY), DATE_SUB(NOW(), INTERVAL 10 DAY), 10800000.00, 'VIREMENT', 'VIR-BFV-2025-003', 4, NULL),
(6, 'PAY-2025-006', 'COMPLETE', DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 5 DAY), 15000000.00, 'VIREMENT', 'VIR-BMOI-2025-004', 7, 3);

INSERT INTO paiements (id, numero, statut, date_creation, date_paiement, montant, moyen_paiement, reference_transaction, facture_id, fournisseur_id) VALUES
(7, 'PAY-2025-007', 'COMPLETE', DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY), 7680000.00, 'VIREMENT', 'VIR-BNI-2025-007', 9, NULL),
(8, 'PAY-2025-008', 'EN_ATTENTE', DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 3540000.00, 'CHEQUE', NULL, 8, NULL),
(9, 'PAY-2025-009', 'EN_ATTENTE', DATE_SUB(NOW(), INTERVAL 1 DAY), NULL, 7260000.00, 'VIREMENT', NULL, 10, NULL);

-- ===============================================
-- 24b. DEMANDES CLIENTS (FRONT OFFICE)
-- ===============================================
INSERT INTO client_requests (id, customer_id, request_type, statut, titre, description, article_id, quantite, montant_estime, date_creation, date_modification) VALUES
(1, 1, 'ORDER_REQUEST', 'EN_ATTENTE', 'Commande urgente laptops', 'Besoin de 3 laptops pour projet Q1', 1, 3, 18000000.00, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
(2, 1, 'DELIVERY_REQUEST', 'EN_COURS', 'Demande livraison partielle', 'Livrer en 2 lots selon disponibilite', NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(3, 2, 'DISCOUNT_REQUEST', 'EN_ATTENTE', 'Bon de reduction', 'Demande remise pour volume trimestriel', NULL, NULL, 1500000.00, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 6 DAY)),
(4, 3, 'PURCHASE_VOUCHER', 'VALIDEE', 'Bon d achats', 'Bon d achats fidelite', NULL, NULL, 500000.00, DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(5, 4, 'PRODUCT_REQUEST', 'EN_ATTENTE', 'Demande produit', 'Besoin d ecran 27 pouces', 4, 6, 9000000.00, DATE_SUB(NOW(), INTERVAL 1 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY));

INSERT INTO client_requests (id, customer_id, request_type, statut, titre, description, article_id, quantite, montant_estime, date_creation, date_modification) VALUES
(6, 5, 'DEVIS', 'EN_ATTENTE', 'Devis infrastructure WiFi', 'Besoin de switches et bornes', 20, 10, 12000000.00, DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(7, 6, 'COMMANDE', 'TRANSFORMEE', 'Commande accessoires bureautique', 'Claviers et souris pour nouveaux postes', 2, 80, 3600000.00, DATE_SUB(NOW(), INTERVAL 5 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY)),
(8, 2, 'BON_REDUCTION', 'EN_ATTENTE', 'Bon de reduction Q2', 'Remise sur achats > 10M Ar', NULL, NULL, 2000000.00, DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY)),
(9, 3, 'BON_ACHAT', 'VALIDEE', 'Bon achat fidelite', 'Bon d achat valable 6 mois', NULL, NULL, 1500000.00, DATE_SUB(NOW(), INTERVAL 6 DAY), DATE_SUB(NOW(), INTERVAL 2 DAY)),
(10, 1, 'LIVRAISON', 'EN_COURS', 'Livraison bureau Ivato', 'Livraison avant fin de semaine', NULL, NULL, NULL, DATE_SUB(NOW(), INTERVAL 2 DAY), DATE_SUB(NOW(), INTERVAL 1 DAY)),
(11, 4, 'PRODUIT', 'EN_ATTENTE', 'Serveur additionnel', 'Serveur pour nouvelle salle', 19, 2, 24000000.00, DATE_SUB(NOW(), INTERVAL 7 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY)),
(12, 7, 'DEVIS', 'TRANSFORMEE', 'Renouvellement parc', 'Deux laptops pour equipe direction', 1, 2, 12000000.00, DATE_SUB(NOW(), INTERVAL 9 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY));

-- ===============================================
-- 24c. PROFORMAS VENTES (Devis clients)
-- ===============================================
INSERT INTO proformas_ventes (
    id, numero, statut, date_creation, date_proforma, date_validation_client,
    client_id, request_id, entrepot_id,
    montant_ht, montant_tva, montant_ttc, taux_tva,
    utilisateur_creation, utilisateur_modification
) VALUES
(1, 'PFV-2025-001', 'VALIDEE_CLIENT', DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 4 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY),
 6, 7, 1,
 6050000.00, 1210000.00, 7260000.00, 20.00,
 'commercial1', 'commercial1'),
(2, 'PFV-2025-002', 'EN_ATTENTE', DATE_SUB(NOW(), INTERVAL 3 DAY), DATE_SUB(NOW(), INTERVAL 3 DAY), NULL,
 7, 12, 2,
 12000000.00, 2400000.00, 14400000.00, 20.00,
 'commercial1', 'commercial1'),
(3, 'PFV-2025-003', 'VALIDEE_CLIENT', DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 8 DAY), DATE_SUB(NOW(), INTERVAL 7 DAY),
 2, NULL, 1,
 2950000.00, 590000.00, 3540000.00, 20.00,
 'commercial1', 'commercial1');

INSERT INTO proformas_ventes_lignes (proforma_id, article_id, quantite, prix_unitaire, montant, notes) VALUES
(1, 2, 80, 45000.00, 3600000.00, 'Claviers'),
(1, 3, 70, 35000.00, 2450000.00, 'Souris'),
(2, 1, 2, 6000000.00, 12000000.00, 'Laptops'),
(3, 6, 20, 85000.00, 1700000.00, 'Hubs USB'),
(3, 5, 50, 25000.00, 1250000.00, 'Cables HDMI');

UPDATE commandes_ventes SET proforma_id = 1 WHERE id = 6;
UPDATE commandes_ventes SET proforma_id = 2 WHERE id = 7;
UPDATE commandes_ventes SET proforma_id = 3 WHERE id = 8;

-- ===============================================
-- 25. INVENTAIRES
-- ===============================================
INSERT INTO inventaires (id, numero, type_inventaire, statut, date_debut, date_fin, entrepot_id, montant_theorique, montant_compte, utilisateur_responsable) VALUES
(1, 'INV-2025-001', 'COMPLET', 'CLOTURE', DATE_SUB(NOW(), INTERVAL 30 DAY), DATE_SUB(NOW(), INTERVAL 28 DAY), 1, 625000000.00, 624250000.00, 'magasinier1'),
(2, 'INV-2025-002', 'PARTIEL', 'EN_COURS', DATE_SUB(NOW(), INTERVAL 2 DAY), NULL, 2, 225000000.00, NULL, 'magasinier1'),
(3, 'INV-2025-003', 'COMPLET', 'PLANIFIE', NULL, NULL, 3, NULL, NULL, 'magasinier1'),
(4, 'INV-2025-004', 'TOURNANT', 'EN_COURS', DATE_SUB(NOW(), INTERVAL 5 DAY), NULL, 4, 85000000.00, NULL, 'magasinier1');

-- ===============================================
-- 26. LIGNES INVENTAIRES
-- ===============================================
INSERT INTO inventaires_lignes (inventaire_id, article_id, quantite_theorique, quantite_comptee, variance, notes) VALUES
-- Inventaire 1 (Complet - Clôturé)
(1, 1, 25, 25, 0, 'Conforme - Tous scannés'),
(1, 2, 150, 148, -2, 'Manque 2 unités - Enquête en cours'),
(1, 3, 300, 301, 1, 'Excédent - Erreur de saisie corrigée'),
(1, 4, 45, 45, 0, 'Conforme - Emballages OK'),
(1, 5, 500, 500, 0, 'Conforme'),
(1, 6, 120, 120, 0, 'Conforme'),
(1, 7, 65, 65, 0, 'Conforme - Testés fonctionnels'),
(1, 8, 85, 85, 0, 'Conforme'),
(1, 9, 50, 49, -1, 'Unité défectueuse retirée'),
(1, 10, 35, 35, 0, 'Conforme'),
-- Inventaire 2 (Partiel - En cours)
(2, 1, 15, 15, 0, 'Vérifié et validé'),
(2, 2, 80, NULL, NULL, 'En attente de comptage'),
(2, 3, 200, 200, 0, 'Vérifié'),
(2, 6, 100, NULL, NULL, 'Programmé demain'),
-- Inventaire 4 (Tournant)
(4, 16, 250, 248, -2, 'Petit écart normal'),
(4, 17, 35, 35, 0, 'Conforme'),
(4, 18, 110, 111, 1, 'Excédent mineur');

-- ===============================================
-- 27. MOUVEMENTS DE STOCK
-- ===============================================
INSERT INTO mouvements_stock (type_mouvement, date_creation, article_id, entrepot_id, quantite, prix_unitaire, montant, motif, utilisateur, reference_document) VALUES
-- Entrées (Réceptions)
('ENTREE', DATE_SUB(NOW(), INTERVAL 2 DAY), 1, 1, 5, 5800000.00, 29000000.00, 'Réception commande CA-2025-001', 'magasinier1', 'REC-2025-001'),
('ENTREE', DATE_SUB(NOW(), INTERVAL 2 DAY), 4, 1, 4, 1500000.00, 6000000.00, 'Réception commande CA-2025-001', 'magasinier1', 'REC-2025-001'),
('ENTREE', DATE_SUB(NOW(), INTERVAL 1 DAY), 2, 2, 80, 42000.00, 3360000.00, 'Réception partielle CA-2025-002', 'magasinier1', 'REC-2025-002'),
('ENTREE', DATE_SUB(NOW(), INTERVAL 1 DAY), 3, 2, 150, 33000.00, 4950000.00, 'Réception CA-2025-002', 'magasinier1', 'REC-2025-002'),
('ENTREE', DATE_SUB(NOW(), INTERVAL 15 DAY), 9, 3, 30, 440000.00, 13200000.00, 'Réception CA-2025-004', 'magasinier1', 'REC-2025-003'),
-- Sorties (Livraisons)
('SORTIE', DATE_SUB(NOW(), INTERVAL 7 DAY), 1, 1, -2, 6000000.00, -12000000.00, 'Livraison client CV-2025-001', 'magasinier1', 'LIV-2025-001'),
('SORTIE', DATE_SUB(NOW(), INTERVAL 7 DAY), 4, 1, -4, 1500000.00, -6000000.00, 'Livraison client CV-2025-001', 'magasinier1', 'LIV-2025-001'),
('SORTIE', DATE_SUB(NOW(), INTERVAL 12 DAY), 6, 1, -30, 85000.00, -2550000.00, 'Livraison client CV-2025-004', 'magasinier1', 'LIV-2025-004'),
('SORTIE', DATE_SUB(NOW(), INTERVAL 12 DAY), 5, 1, -100, 25000.00, -2500000.00, 'Livraison client CV-2025-004', 'magasinier1', 'LIV-2025-004'),
-- Ajustements
('AJUSTEMENT', DATE_SUB(NOW(), INTERVAL 28 DAY), 2, 1, -2, 45000.00, -90000.00, 'Ajustement inventaire INV-2025-001 - manquant', 'magasinier1', 'INV-2025-001'),
('AJUSTEMENT', DATE_SUB(NOW(), INTERVAL 28 DAY), 3, 1, 1, 35000.00, 35000.00, 'Ajustement inventaire INV-2025-001 - excédent', 'magasinier1', 'INV-2025-001'),
('AJUSTEMENT', DATE_SUB(NOW(), INTERVAL 28 DAY), 9, 1, -1, 450000.00, -450000.00, 'Retrait unité défectueuse', 'magasinier1', 'INV-2025-001'),
-- Transferts
('TRANSFERT', DATE_SUB(NOW(), INTERVAL 20 DAY), 16, 1, -50, 80000.00, -4000000.00, 'Transfert vers Toamasina', 'magasinier1', 'TRF-2025-001'),
('TRANSFERT', DATE_SUB(NOW(), INTERVAL 20 DAY), 16, 2, 50, 80000.00, 4000000.00, 'Réception transfert Antananarivo', 'magasinier1', 'TRF-2025-001');

-- ===============================================
-- 28. AUDIT LOGS
-- ===============================================
INSERT INTO audit_logs (date_creation, utilisateur, nom_table, id_entity, action, attribut_modifie, ancienne_valeur, nouvelle_valeur, adresse_ip, session_id, reference_document) VALUES
-- Création entités
(DATE_SUB(NOW(), INTERVAL 30 DAY), 'admin', 'articles', 1, 'CREATE', NULL, NULL, 'Article ART-001 créé', '192.168.1.10', 'SESSION-001', NULL),
(DATE_SUB(NOW(), INTERVAL 30 DAY), 'admin', 'entrepots', 1, 'CREATE', NULL, NULL, 'Dépôt DEP-ANA créé', '192.168.1.10', 'SESSION-001', NULL),
(DATE_SUB(NOW(), INTERVAL 29 DAY), 'admin', 'fournisseurs', 1, 'CREATE', NULL, NULL, 'Fournisseur FOUR-001 créé', '192.168.1.10', 'SESSION-002', NULL),
(DATE_SUB(NOW(), INTERVAL 29 DAY), 'admin', 'clients', 1, 'CREATE', NULL, NULL, 'Client CLI-001 créé', '192.168.1.10', 'SESSION-003', NULL),
-- Modifications
(DATE_SUB(NOW(), INTERVAL 25 DAY), 'acheteur1', 'fournisseurs', 1, 'UPDATE', 'taux_remise', '0', '5.00', '192.168.1.15', 'SESSION-010', NULL),
(DATE_SUB(NOW(), INTERVAL 20 DAY), 'commercial1', 'clients', 2, 'UPDATE', 'limite_credit_actuelle', '30000000.00', '28500000.00', '192.168.1.20', 'SESSION-015', 'CV-2025-002'),
(DATE_SUB(NOW(), INTERVAL 18 DAY), 'finance1', 'clients', 4, 'UPDATE', 'limite_credit_actuelle', '40000000.00', '35000000.00', '192.168.1.22', 'SESSION-017', NULL),
-- Désactivations
(DATE_SUB(NOW(), INTERVAL 15 DAY), 'admin', 'articles', 99, 'DELETE', 'actif', 'true', 'false', '192.168.1.10', 'SESSION-020', NULL),
-- Connexions
(DATE_SUB(NOW(), INTERVAL 1 HOUR), 'admin', 'utilisateurs', 1, 'LOGIN', 'date_last_login', NULL, NOW(), '192.168.1.10', 'SESSION-100', NULL),
(DATE_SUB(NOW(), INTERVAL 2 HOUR), 'commercial1', 'utilisateurs', 3, 'LOGIN', 'date_last_login', NULL, NOW(), '192.168.1.20', 'SESSION-099', NULL),
(DATE_SUB(NOW(), INTERVAL 3 HOUR), 'acheteur1', 'utilisateurs', 2, 'LOGIN', 'date_last_login', NULL, NOW(), '192.168.1.15', 'SESSION-098', NULL),
(DATE_SUB(NOW(), INTERVAL 4 HOUR), 'magasinier1', 'utilisateurs', 4, 'LOGIN', 'date_last_login', NULL, NOW(), '192.168.1.25', 'SESSION-097', NULL),
-- Opérations stock
(DATE_SUB(NOW(), INTERVAL 2 DAY), 'magasinier1', 'niveaux_stock', 1, 'UPDATE', 'quantite_actuelle', '20', '25', '192.168.1.25', 'SESSION-090', 'REC-2025-001'),
(DATE_SUB(NOW(), INTERVAL 7 DAY), 'magasinier1', 'niveaux_stock', 1, 'UPDATE', 'quantite_actuelle', '27', '25', '192.168.1.25', 'SESSION-085', 'LIV-2025-001'),
(DATE_SUB(NOW(), INTERVAL 1 DAY), 'magasinier1', 'niveaux_stock', 2, 'UPDATE', 'quantite_actuelle', '70', '150', '192.168.1.25', 'SESSION-092', 'REC-2025-002'),
-- Commandes
(DATE_SUB(NOW(), INTERVAL 12 DAY), 'acheteur1', 'commandes_achat', 1, 'CREATE', NULL, NULL, 'Commande CA-2025-001 créée', '192.168.1.15', 'SESSION-075', NULL),
(DATE_SUB(NOW(), INTERVAL 10 DAY), 'commercial1', 'commandes_ventes', 1, 'CREATE', NULL, NULL, 'Commande CV-2025-001 créée', '192.168.1.20', 'SESSION-070', NULL),
(DATE_SUB(NOW(), INTERVAL 5 DAY), 'direction1', 'commandes_ventes', 2, 'UPDATE', 'statut', 'BROUILLON', 'VALIDEE', '192.168.1.30', 'SESSION-065', NULL),
-- Factures
(DATE_SUB(NOW(), INTERVAL 10 DAY), 'finance1', 'factures', 1, 'CREATE', NULL, NULL, 'Facture FV-2025-001 créée', '192.168.1.22', 'SESSION-080', NULL),
(DATE_SUB(NOW(), INTERVAL 5 DAY), 'finance1', 'factures', 1, 'UPDATE', 'statut', 'EN_ATTENTE', 'PAYEE', '192.168.1.22', 'SESSION-082', 'PAY-2025-001');

-- ===============================================
-- AFFICHAGE DES DONNÉES CRÉÉES
-- ===============================================
SELECT '✅ Données de test Madagascar insérées avec succès (Ariary)' AS status;

SELECT CHAR(10) AS separator;
SELECT '🏢 ENTREPÔTS MADAGASCAR:' AS info;
SELECT code, nom_depot, ville, type_depot, actif FROM entrepots;

SELECT CHAR(10) AS separator;
SELECT '📦 ARTICLES (10 premiers) - Prix en Ariary:' AS info;
SELECT code, libelle, FORMAT(prix_unitaire, 0) AS prix_ar, unite_mesure, actif FROM articles LIMIT 10;

SELECT CHAR(10) AS separator;
SELECT '📊 STOCK DISPONIBLE (10 premiers):' AS info;
SELECT 
    a.code AS article_code,
    a.libelle AS article_nom,
    e.nom_depot AS entrepot,
    ns.quantite_actuelle AS quantite,
    ns.quantite_reservee AS reserve,
    FORMAT(ns.valeur_totale, 0) AS valeur_ar
FROM niveaux_stock ns
JOIN articles a ON ns.article_id = a.id
JOIN entrepots e ON ns.entrepot_id = e.id
LIMIT 10;

SELECT CHAR(10) AS separator;
SELECT '🛒 COMMANDES ACHAT:' AS info;
SELECT numero, statut, DATE_FORMAT(date_commande, '%Y-%m-%d') AS date, FORMAT(montant_ttc, 0) AS montant_ar FROM commandes_achat;

SELECT CHAR(10) AS separator;
SELECT '💰 COMMANDES VENTE:' AS info;
SELECT numero, statut, DATE_FORMAT(date_commande, '%Y-%m-%d') AS date, FORMAT(montant_ttc, 0) AS montant_ar FROM commandes_ventes;

SELECT CHAR(10) AS separator;
SELECT '📄 FACTURES:' AS info;
SELECT numero, type_facture, statut, FORMAT(montant_ttc, 0) AS montant_ar FROM factures;

SELECT CHAR(10) AS separator;
SELECT '📊 STATISTIQUES GLOBALES:' AS info;
SELECT 
    (SELECT COUNT(*) FROM articles WHERE actif = true) AS total_articles,
    (SELECT COUNT(*) FROM clients WHERE actif = true) AS total_clients,
    (SELECT COUNT(*) FROM fournisseurs WHERE actif = true) AS total_fournisseurs,
    (SELECT COUNT(*) FROM commandes_achat) AS total_cmd_achat,
    (SELECT COUNT(*) FROM commandes_ventes) AS total_cmd_vente,
    (SELECT COUNT(*) FROM factures) AS total_factures,
    (SELECT COUNT(*) FROM livraisons) AS total_livraisons,
    FORMAT((SELECT SUM(valeur_totale) FROM niveaux_stock), 0) AS valeur_stock_ar;

SELECT CHAR(10) AS separator;
SELECT '💵 Taux de change: 1 EUR ≈ 5000 Ar' AS info;
SELECT '🏦 Banques: BNI, BOA, BFV, BMOI, Banky Fampandrosoana' AS info2;




1°[INFO] /E:/S5/web/TOVO/erp/erp/src/main/java/com/erp/controller/ReportsApiController.java: Some input files use or override a deprecated API. 
[INFO] /E:/S5/web/TOVO/erp/erp/src/main/java/com/erp/controller/ReportsApiController.java: Recompile with -Xlint:deprecation for details.
[INFO] /E:/S5/web/TOVO/erp/erp/src/main/java/com/erp/controller/DashboardApiController.java: E:\S5\web\TOVO\erp\erp\src\main\java\com\erp\controller\DashboardApiController.java uses unchecked or unsafe operations.
2)[INFO] /E:/S5/web/TOVO/erp/erp/src/main/java/com/erp/controller/DashboardApiController.java: Recompile with -Xlint:unchecked for details                                                                                                                                                                                                                                                                                                 3) echec generation ici http://localhost:9091/erp-system/reports/, ici http://localhost:9091/erp-system/reports/purchases                                                                                                                                                                                                                                                                                    4) dans les rapports je ne veux pas de graph mais PLUSIEUR GRANDES ET LONGUES barres verticales d'avancement(globalité,specificité) EN % http://localhost:9091/erp-system/reports/                                                                                                                                                                          5)le filp retourne tout de suite l'autre login et vice ver ca ,meme carte et meme taille mais pas de filp qui montre le login a l'envers                                                                                                                                                                                                                                                                6)les boutons "voir"devrait marcher ,bref dans les tableaux dnas les pages il devrait y avoir du edit et delete ,quand on clique sur voir,la ligne coresspondante s'afficheen carte et la page se floute en arriere plan ,on peut editer alors le contenu selons les elements ou suprrimer la ligne,tu vas tous les modifier pour que ce soit comme ça                                                                                                                                                                                                                                                                                                                                                                                                            7) le site bugue un peu ,tu vas relativiser un peu les performances                                                                                                                                                                                                                                                                                                                                                                           8) tu dois mettre dans le front office le lien pour faire les differentes inssertions que les clients font  dans la side bar en haut a cote de tableau ,liste deroulante "Purchase" :faire une commande ,demander une livraison , mettre bon de reduction ,bon d'achats" Je ne sais pas mais tout en place ps)EVITER LA REDONDANCE CHAQUE PAGE A SA SPECIFICITE VEUILLEZ ETRE AUTHENTIQUE?AJOUTEZ DE LA DISTINCTIONS ,N'OUBLIE PAS LES BONS , LES LIENS ET TOUS LES ELEMENTS DES FORMULAIRES (âs de lien de back office dans front office)                                                                      9)LE FRONT OFFICE EST LA PARTIE CLEINTELLE PAS UN SECOND DOMAINE DE GESTION DE VENTES ,TU VAS MODIFIER LE FRONT OFFICE TOUT MODIFIER POUR QUE CE SOIT COMME LA PARTIE E COMMERCE OU LE CLIENT PEUT VOIR LA LISTE DES PRODUIT, SON PROFIL ,SES ACTIONS ,SES COMMANDES ,SES PAYEMENTS ,SES LIVRAISONS , OU IL PEUUUUUT COMMANDER OU IL PEUT REMPLIR DES FORMULAIRES POUR DEMANDER DES PRODUITS ET LE RESTE ......J'INSISTE SUR "LE RESTE" CAR J' AI PEUT ETRE OUBLIER CERTAINS POINTS CORRIGE LE FRONT OFFICE, IL DOIT ETRE LIE ET MIS EN RELATION AVEC LE BACK tu peux creer tous les fichiers que tu veux   10)On doit aussi avoir une liste client et liste facture et l'export pdf ne marche âs CREER TOUS LES FICHIERS NECESSAIRES
