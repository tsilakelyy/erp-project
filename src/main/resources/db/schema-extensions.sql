-- Categories Articles Table (NEW)
CREATE TABLE IF NOT EXISTS categories_articles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    libelle VARCHAR(200) NOT NULL,
    description VARCHAR(500),
    actif BOOLEAN DEFAULT true,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    INDEX idx_code (code),
    INDEX idx_libelle (libelle),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Pricing Lists Table (NEW)
CREATE TABLE IF NOT EXISTS listes_prix (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    libelle VARCHAR(200) NOT NULL,
    description VARCHAR(500),
    type_liste VARCHAR(50) NOT NULL COMMENT 'VENTE, ACHAT, GENERAL',
    date_debut TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_fin TIMESTAMP NULL,
    devise VARCHAR(10) DEFAULT 'Ar',
    actif BOOLEAN DEFAULT true,
    par_defaut BOOLEAN DEFAULT false,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    utilisateur_creation VARCHAR(100),
    utilisateur_modification VARCHAR(100),
    INDEX idx_code (code),
    INDEX idx_type (type_liste),
    INDEX idx_actif (actif),
    UNIQUE KEY unique_default_per_type (type_liste, par_defaut)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Pricing List Lines Table (NEW)
CREATE TABLE IF NOT EXISTS listes_prix_lignes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    liste_prix_id BIGINT NOT NULL,
    article_id BIGINT NOT NULL,
    prix_unitaire DECIMAL(15,2) NOT NULL,
    remise_pourcentage DECIMAL(5,2) DEFAULT 0.00,
    prix_net DECIMAL(15,2),
    remarque VARCHAR(500),
    actif BOOLEAN DEFAULT true,
    date_creation TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    date_modification TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (liste_prix_id) REFERENCES listes_prix(id) ON DELETE CASCADE,
    FOREIGN KEY (article_id) REFERENCES articles(id) ON DELETE CASCADE,
    UNIQUE KEY unique_article_per_list (liste_prix_id, article_id),
    INDEX idx_liste (liste_prix_id),
    INDEX idx_article (article_id),
    INDEX idx_actif (actif)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

-- ALTER TABLE articles to add category_id (NEW - Optional linking)
-- This is safe because it adds a new column without changing existing data
ALTER TABLE articles ADD COLUMN category_id BIGINT COMMENT 'Reference to category' AFTER taux_tva;
ALTER TABLE articles ADD FOREIGN KEY (category_id) REFERENCES categories_articles(id) ON DELETE SET NULL;
ALTER TABLE articles ADD INDEX idx_category (category_id);