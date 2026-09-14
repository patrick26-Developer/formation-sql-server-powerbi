/*
    03_procedures_vues_superettecg.sql
    Procédures stockées (sp_) et vues (vw_) sur SuperetteCG :
    - sp_VentesParMagasin, sp_ChiffreAffairesParPeriode, sp_ProduitsEnRupture
    - vw_FaitVentes (grain = ligne de vente) + vw_DimProduit, vw_DimMagasin, vw_DimClient
    CREATE OR ALTER : script ré-exécutable sans erreur, conventions PascalCase (cf. CLAUDE.md).
*/

USE SuperetteCG;
GO

-- =============================================
-- sp_VentesParMagasin
-- Détail des ventes (une ligne par produit vendu) pour un magasin donné.
-- @MagasinId : Id du magasin (dbo.Magasins.Id) à consulter.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_VentesParMagasin
    @MagasinId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        v.Id                                    AS VenteId,
        v.DateVente,
        ISNULL(c.Nom, N'Client anonyme')        AS Client,
        p.Nom                                    AS Produit,
        lv.Quantite,
        lv.PrixApplique,
        lv.Quantite * lv.PrixApplique            AS TotalLigne
    FROM dbo.Ventes v
    JOIN dbo.LignesVente lv ON lv.VenteId = v.Id
    JOIN dbo.Produits p     ON p.Id = lv.ProduitId
    LEFT JOIN dbo.Clients c ON c.Id = v.ClientId
    WHERE v.MagasinId = @MagasinId
    ORDER BY v.DateVente, v.Id;
END
GO

-- =============================================
-- sp_ChiffreAffairesParPeriode
-- Chiffre d'affaires total (toutes ventes/magasins confondus) sur une période donnée.
-- @DateDebut, @DateFin : bornes incluses de la période (DATE).
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_ChiffreAffairesParPeriode
    @DateDebut DATE,
    @DateFin   DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        @DateDebut                               AS DateDebut,
        @DateFin                                 AS DateFin,
        COUNT(DISTINCT v.Id)                     AS NbVentes,
        SUM(lv.Quantite * lv.PrixApplique)       AS ChiffreAffaires
    FROM dbo.Ventes v
    JOIN dbo.LignesVente lv ON lv.VenteId = v.Id
    WHERE CAST(v.DateVente AS DATE) BETWEEN @DateDebut AND @DateFin;
END
GO

-- =============================================
-- sp_ProduitsEnRupture
-- Liste des couples Magasin/Produit dont le stock est sous un seuil d'alerte.
-- @SeuilAlerte : quantité en-dessous de laquelle un produit est considéré en rupture.
-- =============================================
CREATE OR ALTER PROCEDURE dbo.sp_ProduitsEnRupture
    @SeuilAlerte INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        m.Nom       AS Magasin,
        p.Nom       AS Produit,
        p.Categorie,
        s.Quantite  AS StockActuel,
        @SeuilAlerte AS SeuilAlerte
    FROM dbo.Stocks s
    JOIN dbo.Magasins m ON m.Id = s.MagasinId
    JOIN dbo.Produits p ON p.Id = s.ProduitId
    WHERE s.Quantite < @SeuilAlerte
    ORDER BY s.Quantite ASC;
END
GO

-- =============================================
-- vw_FaitVentes
-- Table de faits (grain = une ligne de vente) pour la couche BI / modèle étoile.
-- Une ligne = un produit vendu dans une vente, avec les clés de dimensions et le montant.
-- =============================================
CREATE OR ALTER VIEW dbo.vw_FaitVentes
AS
SELECT
    lv.Id           AS LigneVenteId,
    v.Id            AS VenteId,
    v.DateVente,
    v.MagasinId,
    v.ClientId,
    lv.ProduitId,
    lv.Quantite,
    lv.PrixApplique,
    lv.Quantite * lv.PrixApplique AS MontantLigne
FROM dbo.LignesVente lv
JOIN dbo.Ventes v ON v.Id = lv.VenteId;
GO

-- =============================================
-- vw_DimProduit
-- Dimension Produit simplifiée pour la couche BI.
-- =============================================
CREATE OR ALTER VIEW dbo.vw_DimProduit
AS
SELECT
    Id            AS ProduitId,
    Nom           AS Produit,
    Categorie,
    PrixUnitaire
FROM dbo.Produits;
GO

-- =============================================
-- vw_DimMagasin
-- Dimension Magasin simplifiée pour la couche BI.
-- =============================================
CREATE OR ALTER VIEW dbo.vw_DimMagasin
AS
SELECT
    Id      AS MagasinId,
    Nom     AS Magasin,
    Ville,
    Adresse
FROM dbo.Magasins;
GO

-- =============================================
-- vw_DimClient
-- Dimension Client simplifiée pour la couche BI.
-- =============================================
CREATE OR ALTER VIEW dbo.vw_DimClient
AS
SELECT
    Id        AS ClientId,
    Nom       AS Client,
    Telephone
FROM dbo.Clients;
GO
