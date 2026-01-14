INSERT IGNORE INTO utilisateurs (
    login, 
    mot_de_passe, 
    email, 
    nom, 
    prenom, 
    actif,
    created_by
) VALUES (
    'admin',
    '$2a$10$8.UnVuG9HHgffUDAlk8qfOuVGkqRzgVymGe07xd00Xxs8EqkICwXa',
    'admin@localhost',
    'Admin',
    'System',
    true,
    'system'
);

-- Insertion rôles par défaut
INSERT IGNORE INTO roles (code, libelle, description) VALUES 
('ADMIN', 'Administrateur', 'Rôle administrateur - tous les droits'),
('DIRECTION', 'Direction', 'Rôle direction stratégique'),
('ACHATS', 'Acheteur', 'Rôle gestion des achats'),
('VENTES', 'Commercial', 'Rôle gestion des ventes'),
('FINANCE', 'Comptable', 'Rôle gestion financière'),
('MAGASINIER', 'Magasinier', 'Rôle gestion de stock');

-- Lien utilisateur ADMIN - rôle ADMIN
INSERT IGNORE INTO habilitations_utilisateur (utilisateur_id, role_id)
SELECT u.id, r.id 
FROM utilisateurs u, roles r 
WHERE u.login = 'admin' AND r.code = 'ADMIN';