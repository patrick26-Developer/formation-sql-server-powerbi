/*
    05_securite_logins.sql
    Sécurité : vérification du mode d'authentification, création de deux logins
    dédiés (jamais sa au quotidien) :
    - dev_degrace : db_owner sur SuperetteCG UNIQUEMENT (pas sysadmin)
    - lecteur_bi  : db_datareader sur SuperetteCG (lecture seule, pour Power BI)

    Sécurité mots de passe : ce script ne contient AUCUN mot de passe en clair.
    Les mots de passe sont passés en variables sqlcmd au moment de l'exécution :

        sqlcmd -S DESKTOP-3K8VBUM -E -f 65001 -b -i sql/05_securite_logins.sql ^
            -v DevPassword="<mot de passe fort ici>" -v BiPassword="<autre mot de passe fort>"

    Ne jamais committer un mot de passe réel, y compris dans l'historique de commandes.
*/

-- =============================================
-- 1) Mode d'authentification : vérification uniquement.
--    C'est un réglage serveur (registre / Server Properties > Security dans SSMS),
--    pas une commande T-SQL — voir docs/jour-06.md pour la procédure manuelle
--    si le résultat ci-dessous n'indique pas le mode mixte.
-- =============================================
SELECT
    CASE SERVERPROPERTY('IsIntegratedSecurityOnly')
        WHEN 0 THEN N'Mode mixte (SQL Server + Windows) — OK, les logins SQL ci-dessous fonctionneront.'
        WHEN 1 THEN N'Windows uniquement — mode mixte à activer manuellement (voir docs/jour-06.md) avant de continuer.'
    END AS ModeAuthentification;
GO

-- =============================================
-- 2) Login dev_degrace : usage quotidien sur SuperetteCG, db_owner limité à cette base.
-- =============================================
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'dev_degrace')
BEGIN
    CREATE LOGIN dev_degrace
        WITH PASSWORD = N'$(DevPassword)',
             CHECK_POLICY = ON,
             DEFAULT_DATABASE = SuperetteCG;
END
GO

USE SuperetteCG;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'dev_degrace')
BEGIN
    CREATE USER dev_degrace FOR LOGIN dev_degrace;
END
GO

IF IS_ROLEMEMBER('db_owner', 'dev_degrace') = 0
BEGIN
    ALTER ROLE db_owner ADD MEMBER dev_degrace;
END
GO

-- =============================================
-- 3) Login lecteur_bi : lecture seule, prévu pour la connexion Power BI.
-- =============================================
USE master;
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'lecteur_bi')
BEGIN
    CREATE LOGIN lecteur_bi
        WITH PASSWORD = N'$(BiPassword)',
             CHECK_POLICY = ON,
             DEFAULT_DATABASE = SuperetteCG;
END
GO

USE SuperetteCG;
GO

IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = N'lecteur_bi')
BEGIN
    CREATE USER lecteur_bi FOR LOGIN lecteur_bi;
END
GO

IF IS_ROLEMEMBER('db_datareader', 'lecteur_bi') = 0
BEGIN
    ALTER ROLE db_datareader ADD MEMBER lecteur_bi;
END
GO
