/*
    01_creation_base_superettecg.sql
    Création de la base SuperetteCG et du schéma OLTP (3NF) :
    Magasins, Produits, Stocks, Clients, Ventes, LignesVente, Employes.
    Conventions : PascalCase, contraintes PK/FK explicites (voir CLAUDE.md).
*/

IF DB_ID(N'SuperetteCG') IS NULL
BEGIN
    CREATE DATABASE SuperetteCG;
END
GO

USE SuperetteCG;
GO

-- Magasins : chaque point de vente de la chaîne.
IF OBJECT_ID(N'dbo.Magasins', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Magasins
    (
        Id      INT IDENTITY(1,1) NOT NULL,
        Nom     NVARCHAR(100)     NOT NULL,
        Ville   NVARCHAR(100)     NOT NULL,
        Adresse NVARCHAR(255)     NULL,
        CONSTRAINT PK_Magasins PRIMARY KEY (Id)
    );
END
GO

-- Produits : catalogue produit, indépendant des magasins.
IF OBJECT_ID(N'dbo.Produits', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Produits
    (
        Id            INT IDENTITY(1,1) NOT NULL,
        Nom           NVARCHAR(150)     NOT NULL,
        Categorie     NVARCHAR(100)     NULL,
        PrixUnitaire  DECIMAL(10,2)     NOT NULL,
        CONSTRAINT PK_Produits PRIMARY KEY (Id),
        CONSTRAINT CK_Produits_PrixUnitaire CHECK (PrixUnitaire >= 0)
    );
END
GO

-- Clients : clientèle identifiée (vente peut aussi rester anonyme, cf. Ventes.ClientId nullable).
IF OBJECT_ID(N'dbo.Clients', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Clients
    (
        Id        INT IDENTITY(1,1) NOT NULL,
        Nom       NVARCHAR(150)     NOT NULL,
        Telephone VARCHAR(20)       NULL,
        CONSTRAINT PK_Clients PRIMARY KEY (Id)
    );
END
GO

-- Employes : personnel rattaché à un magasin.
IF OBJECT_ID(N'dbo.Employes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Employes
    (
        Id        INT IDENTITY(1,1) NOT NULL,
        MagasinId INT               NOT NULL,
        Nom       NVARCHAR(150)     NOT NULL,
        Poste     NVARCHAR(100)     NULL,
        CONSTRAINT PK_Employes PRIMARY KEY (Id),
        CONSTRAINT FK_Employes_Magasins FOREIGN KEY (MagasinId)
            REFERENCES dbo.Magasins (Id)
    );
END
GO

-- Stocks : quantité d'un produit disponible dans un magasin (1 ligne par couple Magasin/Produit).
IF OBJECT_ID(N'dbo.Stocks', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Stocks
    (
        MagasinId INT           NOT NULL,
        ProduitId INT           NOT NULL,
        Quantite  INT           NOT NULL CONSTRAINT DF_Stocks_Quantite DEFAULT (0),
        CONSTRAINT PK_Stocks PRIMARY KEY (MagasinId, ProduitId),
        CONSTRAINT FK_Stocks_Magasins FOREIGN KEY (MagasinId)
            REFERENCES dbo.Magasins (Id),
        CONSTRAINT FK_Stocks_Produits FOREIGN KEY (ProduitId)
            REFERENCES dbo.Produits (Id),
        CONSTRAINT CK_Stocks_Quantite CHECK (Quantite >= 0)
    );
END
GO

-- Ventes : en-tête d'une transaction (un client, un magasin, une date).
IF OBJECT_ID(N'dbo.Ventes', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.Ventes
    (
        Id        INT IDENTITY(1,1) NOT NULL,
        MagasinId INT               NOT NULL,
        ClientId  INT               NULL,
        DateVente DATETIME2(0)      NOT NULL CONSTRAINT DF_Ventes_DateVente DEFAULT (SYSDATETIME()),
        CONSTRAINT PK_Ventes PRIMARY KEY (Id),
        CONSTRAINT FK_Ventes_Magasins FOREIGN KEY (MagasinId)
            REFERENCES dbo.Magasins (Id),
        CONSTRAINT FK_Ventes_Clients FOREIGN KEY (ClientId)
            REFERENCES dbo.Clients (Id)
    );
END
GO

-- LignesVente : détail des produits vendus pour chaque vente, au prix pratiqué ce jour-là.
IF OBJECT_ID(N'dbo.LignesVente', N'U') IS NULL
BEGIN
    CREATE TABLE dbo.LignesVente
    (
        Id            INT IDENTITY(1,1) NOT NULL,
        VenteId       INT               NOT NULL,
        ProduitId     INT               NOT NULL,
        Quantite      INT               NOT NULL,
        PrixApplique  DECIMAL(10,2)     NOT NULL,
        CONSTRAINT PK_LignesVente PRIMARY KEY (Id),
        CONSTRAINT FK_LignesVente_Ventes FOREIGN KEY (VenteId)
            REFERENCES dbo.Ventes (Id),
        CONSTRAINT FK_LignesVente_Produits FOREIGN KEY (ProduitId)
            REFERENCES dbo.Produits (Id),
        CONSTRAINT CK_LignesVente_Quantite CHECK (Quantite > 0),
        CONSTRAINT CK_LignesVente_PrixApplique CHECK (PrixApplique >= 0)
    );
END
GO
