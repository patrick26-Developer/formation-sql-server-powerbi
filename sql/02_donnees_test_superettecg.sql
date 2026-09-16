/*
    02_donnees_test_superettecg.sql
    Jeu de données de test pour SuperetteCG : 3 Magasins, 20 Produits (4 catégories),
    Stocks par magasin/produit, 10 Clients, 6 Employes, 20 Ventes (3 derniers mois)
    avec leurs LignesVente. Chaque bloc est gardé par IF NOT EXISTS pour rester
    ré-exécutable sans doublons (cf. convention IF NOT EXISTS/OBJECT_ID du script 01).
*/

USE SuperetteCG;
GO

-- Magasins
IF NOT EXISTS (SELECT 1 FROM dbo.Magasins)
BEGIN
    INSERT INTO dbo.Magasins (Nom, Ville, Adresse) VALUES
    (N'Superette Centre-Ville', N'Pointe-Noire', N'Avenue Charles de Gaulle, Pointe-Noire'),
    (N'Superette Poto-Poto',    N'Brazzaville',  N'Avenue de la Paix, Poto-Poto, Brazzaville'),
    (N'Superette Dolisie Gare', N'Dolisie',      N'Quartier Gare, Dolisie');
END
GO

-- Produits (4 catégories : Alimentaire, Boissons, Hygiène, Entretien)
IF NOT EXISTS (SELECT 1 FROM dbo.Produits)
BEGIN
    INSERT INTO dbo.Produits (Nom, Categorie, PrixUnitaire) VALUES
    (N'Riz parfumé 25kg',                     N'Alimentaire', 22000.00),
    (N'Farine de blé 1kg',                    N'Alimentaire',   800.00),
    (N'Sucre en poudre 1kg',                  N'Alimentaire',   900.00),
    (N'Huile de palme 1L',                    N'Alimentaire',  1500.00),
    (N'Sardines à l''huile (boîte)',          N'Alimentaire',   600.00),
    (N'Pâtes alimentaires 500g',              N'Alimentaire',   500.00),
    (N'Lait en poudre 400g',                  N'Alimentaire',  2800.00),
    (N'Concentré de tomate 400g',             N'Alimentaire',   400.00),
    (N'Eau minérale 1.5L',                    N'Boissons',      500.00),
    (N'Jus de fruit Tampico 1L',              N'Boissons',     1200.00),
    (N'Coca-Cola 33cl',                       N'Boissons',      500.00),
    (N'Bière Ngok 65cl',                      N'Boissons',      800.00),
    (N'Café soluble Nescafé 100g',            N'Boissons',     2200.00),
    (N'Savon de toilette Palmive',            N'Hygiène',       400.00),
    (N'Dentifrice Signal 100ml',              N'Hygiène',      1200.00),
    (N'Papier hygiénique (pack de 4)',        N'Hygiène',      1500.00),
    (N'Shampoing 400ml',                      N'Hygiène',      2000.00),
    (N'Savon de lessive Omo 1kg',             N'Entretien',    1800.00),
    (N'Eau de javel 1L',                      N'Entretien',     700.00),
    (N'Détergent liquide vaisselle 500ml',    N'Entretien',    1000.00);
END
GO

-- Clients
IF NOT EXISTS (SELECT 1 FROM dbo.Clients)
BEGIN
    INSERT INTO dbo.Clients (Nom, Telephone) VALUES
    (N'Jean-Pierre Moukala', N'+242 06 123 4567'),
    (N'Marie Loubota',       N'+242 05 234 5678'),
    (N'Serge Ngouabi',       N'+242 06 345 6789'),
    (N'Christelle Malonga',  N'+242 05 456 7890'),
    (N'Fabrice Bakekolo',    N'+242 06 567 8901'),
    (N'Grace Tchicaya',      N'+242 05 678 9012'),
    (N'Aristide Mbemba',     N'+242 06 789 0123'),
    (N'Nadège Kimbembe',     N'+242 05 890 1234'),
    (N'Rodrigue Samba',      N'+242 06 901 2345'),
    (N'Bénédicte Loko',      N'+242 05 012 3456');
END
GO

-- Employes (2 par magasin)
IF NOT EXISTS (SELECT 1 FROM dbo.Employes)
BEGIN
    INSERT INTO dbo.Employes (MagasinId, Nom, Poste)
    SELECT m.Id, e.Nom, e.Poste
    FROM (VALUES
        (N'Superette Centre-Ville', N'Patricia Ondongo',  N'Gérante'),
        (N'Superette Centre-Ville', N'Yannick Batantou',  N'Caissier'),
        (N'Superette Poto-Poto',    N'Sylvie Ngoma',      N'Gérante'),
        (N'Superette Poto-Poto',    N'Hervé Moussounda',  N'Vendeur'),
        (N'Superette Dolisie Gare', N'Chancel Ibara',     N'Gérant'),
        (N'Superette Dolisie Gare', N'Reine Pambou',      N'Caissière')
    ) AS e (MagasinNom, Nom, Poste)
    JOIN dbo.Magasins m ON m.Nom = e.MagasinNom;
END
GO

-- Stocks : une ligne par couple Magasin/Produit, quantité déterministe (pas de hasard non reproductible)
IF NOT EXISTS (SELECT 1 FROM dbo.Stocks)
BEGIN
    INSERT INTO dbo.Stocks (MagasinId, ProduitId, Quantite)
    SELECT m.Id, p.Id, 20 + ((p.Id * 3 + m.Id * 11) % 60)
    FROM dbo.Magasins m
    CROSS JOIN dbo.Produits p;
END
GO

-- Ventes : 20 transactions réparties sur les 3 derniers mois (ClientNom NULL = vente anonyme)
IF NOT EXISTS (SELECT 1 FROM dbo.Ventes)
BEGIN
    DECLARE @VentesSeed TABLE (VenteKey INT, MagasinNom NVARCHAR(100), ClientNom NVARCHAR(150) NULL, JoursAvant INT);
    INSERT INTO @VentesSeed (VenteKey, MagasinNom, ClientNom, JoursAvant) VALUES
    (1,  N'Superette Centre-Ville', N'Jean-Pierre Moukala', 88),
    (2,  N'Superette Poto-Poto',    N'Marie Loubota',       85),
    (3,  N'Superette Dolisie Gare', NULL,                   81),
    (4,  N'Superette Centre-Ville', N'Serge Ngouabi',       76),
    (5,  N'Superette Poto-Poto',    N'Christelle Malonga',  72),
    (6,  N'Superette Centre-Ville', NULL,                   68),
    (7,  N'Superette Dolisie Gare', N'Fabrice Bakekolo',    63),
    (8,  N'Superette Poto-Poto',    N'Grace Tchicaya',      59),
    (9,  N'Superette Centre-Ville', N'Aristide Mbemba',     54),
    (10, N'Superette Dolisie Gare', N'Nadège Kimbembe',     50),
    (11, N'Superette Poto-Poto',    NULL,                   45),
    (12, N'Superette Centre-Ville', N'Rodrigue Samba',      41),
    (13, N'Superette Dolisie Gare', N'Bénédicte Loko',      37),
    (14, N'Superette Poto-Poto',    N'Jean-Pierre Moukala', 32),
    (15, N'Superette Centre-Ville', N'Marie Loubota',       28),
    (16, N'Superette Dolisie Gare', NULL,                   24),
    (17, N'Superette Poto-Poto',    N'Serge Ngouabi',       19),
    (18, N'Superette Centre-Ville', N'Christelle Malonga',  14),
    (19, N'Superette Dolisie Gare', N'Fabrice Bakekolo',     8),
    (20, N'Superette Poto-Poto',    N'Grace Tchicaya',       3);

    DECLARE @VenteIdMap TABLE (VenteKey INT, VenteId INT);

    -- MERGE (et non INSERT...SELECT) car OUTPUT doit renvoyer VenteKey, une colonne
    -- de la source qu'un simple OUTPUT sur INSERT ne peut pas exposer.
    MERGE INTO dbo.Ventes AS tgt
    USING (
        SELECT src.VenteKey, m.Id AS MagasinId, c.Id AS ClientId,
               DATEADD(DAY, -src.JoursAvant, SYSDATETIME()) AS DateVente
        FROM @VentesSeed AS src
        JOIN dbo.Magasins m ON m.Nom = src.MagasinNom
        LEFT JOIN dbo.Clients c ON c.Nom = src.ClientNom
    ) AS src
    ON 1 = 0
    WHEN NOT MATCHED THEN
        INSERT (MagasinId, ClientId, DateVente)
        VALUES (src.MagasinId, src.ClientId, src.DateVente)
    OUTPUT src.VenteKey, inserted.Id INTO @VenteIdMap (VenteKey, VenteId);

    -- LignesVente : 1 à 4 lignes par vente
    DECLARE @LignesSeed TABLE (VenteKey INT, ProduitNom NVARCHAR(150), Quantite INT);
    INSERT INTO @LignesSeed (VenteKey, ProduitNom, Quantite) VALUES
    (1,  N'Riz parfumé 25kg', 1),               (1,  N'Huile de palme 1L', 2),                (1,  N'Sucre en poudre 1kg', 1),
    (2,  N'Eau minérale 1.5L', 6),               (2,  N'Coca-Cola 33cl', 4),
    (3,  N'Pâtes alimentaires 500g', 3),         (3,  N'Concentré de tomate 400g', 2),
    (4,  N'Savon de toilette Palmive', 2),       (4,  N'Dentifrice Signal 100ml', 1),          (4,  N'Papier hygiénique (pack de 4)', 1),
    (5,  N'Bière Ngok 65cl', 6),                 (5,  N'Jus de fruit Tampico 1L', 2),
    (6,  N'Lait en poudre 400g', 1),             (6,  N'Café soluble Nescafé 100g', 1),
    (7,  N'Savon de lessive Omo 1kg', 2),        (7,  N'Eau de javel 1L', 1),                  (7,  N'Détergent liquide vaisselle 500ml', 1),
    (8,  N'Riz parfumé 25kg', 1),                (8,  N'Sardines à l''huile (boîte)', 4),
    (9,  N'Shampoing 400ml', 1),                 (9,  N'Dentifrice Signal 100ml', 1),          (9,  N'Savon de toilette Palmive', 3),
    (10, N'Eau minérale 1.5L', 10),              (10, N'Jus de fruit Tampico 1L', 3),          (10, N'Coca-Cola 33cl', 6),
    (11, N'Farine de blé 1kg', 2),               (11, N'Sucre en poudre 1kg', 2),
    (12, N'Bière Ngok 65cl', 12),
    (13, N'Concentré de tomate 400g', 3),        (13, N'Pâtes alimentaires 500g', 4),          (13, N'Huile de palme 1L', 1),
    (14, N'Café soluble Nescafé 100g', 2),       (14, N'Lait en poudre 400g', 1),
    (15, N'Papier hygiénique (pack de 4)', 2),   (15, N'Détergent liquide vaisselle 500ml', 2),
    (16, N'Riz parfumé 25kg', 2),                (16, N'Huile de palme 1L', 3),
    (17, N'Eau de javel 1L', 2),                 (17, N'Savon de lessive Omo 1kg', 1),
    (18, N'Sardines à l''huile (boîte)', 6),     (18, N'Concentré de tomate 400g', 2),
    (19, N'Coca-Cola 33cl', 8),                  (19, N'Eau minérale 1.5L', 5),
    (20, N'Shampoing 400ml', 2),                 (20, N'Savon de toilette Palmive', 2),        (20, N'Dentifrice Signal 100ml', 1);

    INSERT INTO dbo.LignesVente (VenteId, ProduitId, Quantite, PrixApplique)
    SELECT vim.VenteId, p.Id, ls.Quantite, p.PrixUnitaire
    FROM @LignesSeed ls
    JOIN @VenteIdMap vim ON vim.VenteKey = ls.VenteKey
    JOIN dbo.Produits p ON p.Nom = ls.ProduitNom;
END
GO
