-- Categories Articles Data (NEW)
INSERT INTO categories_articles (code, libelle, description, actif, utilisateur_creation) VALUES
('CAT-001', 'Informatique', 'Equipements informatiques', true, 'admin'),
('CAT-002', 'Fournitures', 'Fournitures de bureau', true, 'admin'),
('CAT-003', 'Mobilier', 'Mobilier de bureau', true, 'admin'),
('CAT-004', 'Logiciels', 'Licences et logiciels', true, 'admin'),
('CAT-005', 'Services', 'Services informatiques', true, 'admin');

-- Pricing Lists Data (NEW)
-- VENTE (Sales) - Default
INSERT INTO listes_prix (code, libelle, description, type_liste, date_debut, devise, actif, par_defaut, utilisateur_creation) VALUES
('PL-VENTE-001', 'Liste Standard Vente', 'Prix de vente standard', 'VENTE', NOW(), 'Ar', true, true, 'admin'),
('PL-VENTE-002', 'Liste Premium', 'Prix premium clients VIP', 'VENTE', NOW(), 'Ar', true, false, 'admin');

-- ACHAT (Purchase) - Default
INSERT INTO listes_prix (code, libelle, description, type_liste, date_debut, devise, actif, par_defaut, utilisateur_creation) VALUES
('PL-ACHAT-001', 'Prix Fournisseur Standard', 'Prix d''achat standard', 'ACHAT', NOW(), 'Ar', true, true, 'admin');

-- Pricing List Lines (NEW)
-- Sales pricing for articles 1-9
INSERT INTO listes_prix_lignes (liste_prix_id, article_id, prix_unitaire, remise_pourcentage, remarque, actif) VALUES
(1, 1, 6000000.00, 0.00, 'Prix standard', true),
(1, 2, 45000.00, 0.00, 'Prix standard', true),
(1, 3, 35000.00, 0.00, 'Prix standard', true),
(1, 4, 1500000.00, 0.00, 'Prix standard', true),
(1, 5, 25000.00, 0.00, 'Prix standard', true),
(1, 6, 85000.00, 0.00, 'Prix standard', true),
(1, 7, 95000.00, 0.00, 'Prix standard', true),
(1, 8, 120000.00, 0.00, 'Prix standard', true),
(1, 9, 640000.00, 0.00, 'Prix standard', true);

-- VIP Pricing (Premium list) with discounts
INSERT INTO listes_prix_lignes (liste_prix_id, article_id, prix_unitaire, remise_pourcentage, remarque, actif) VALUES
(2, 1, 6000000.00, 10.00, 'Remise VIP 10%', true),
(2, 2, 45000.00, 5.00, 'Remise VIP 5%', true),
(2, 3, 35000.00, 5.00, 'Remise VIP 5%', true),
(2, 4, 1500000.00, 15.00, 'Remise VIP 15%', true);

-- Purchase pricing
INSERT INTO listes_prix_lignes (liste_prix_id, article_id, prix_unitaire, remise_pourcentage, remarque, actif) VALUES
(3, 1, 4500000.00, 0.00, 'Prix achat fournisseur', true),
(3, 2, 30000.00, 0.00, 'Prix achat fournisseur', true),
(3, 3, 25000.00, 0.00, 'Prix achat fournisseur', true),
(3, 4, 1200000.00, 0.00, 'Prix achat fournisseur', true),
(3, 5, 15000.00, 0.00, 'Prix achat fournisseur', true),
(3, 6, 60000.00, 0.00, 'Prix achat fournisseur', true),
(3, 7, 65000.00, 0.00, 'Prix achat fournisseur', true),
(3, 8, 80000.00, 0.00, 'Prix achat fournisseur', true),
(3, 9, 450000.00, 0.00, 'Prix achat fournisseur', true);
