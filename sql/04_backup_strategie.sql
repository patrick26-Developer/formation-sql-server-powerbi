/*
    04_backup_strategie.sql
    Sauvegarde complète de SuperetteCG + job SQL Server Agent pour l'automatiser
    quotidiennement. Chemin de sauvegarde : backups/ à la racine du repo (ignoré
    par .gitignore — un .bak ne doit jamais être versionné).

    Pré-requis : le dossier backups/ doit exister et être accessible en écriture
    par le compte de service SQL Server (vérifié au Jour 5, cf. docs/jour-05.md).
    Le job planifié ne s'exécutera que si le service SQL Server Agent est démarré
    (Object Explorer > SQL Server Agent > Start si l'icône a une flèche rouge).
*/

-- =============================================
-- 1) Sauvegarde complète manuelle (à exécuter une première fois pour valider
--    le chemin et les droits d'écriture avant de créer le job).
-- =============================================
USE master;
GO

BACKUP DATABASE SuperetteCG
TO DISK = N'F:\Projets\formation-sql-server-powerbi\backups\SuperetteCG_full.bak'
WITH INIT, COMPRESSION, STATS = 10,
     NAME = N'SuperetteCG - Sauvegarde complète manuelle';
GO

-- =============================================
-- 2) Job SQL Server Agent : rejoue la même sauvegarde tous les jours à 02h00.
-- =============================================
USE msdb;
GO

IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'SuperetteCG_Backup_Quotidien')
BEGIN
    EXEC msdb.dbo.sp_delete_job @job_name = N'SuperetteCG_Backup_Quotidien';
END
GO

-- Propriétaire = login courant plutôt que 'sa' (cf. CLAUDE.md : jamais sa au quotidien).
-- Passe par une variable : EXEC n'accepte pas un appel de fonction directement
-- comme valeur d'un paramètre nommé (@p = SUSER_SNAME() lève une erreur de syntaxe).
DECLARE @OwnerLogin sysname = SUSER_SNAME();

EXEC msdb.dbo.sp_add_job
    @job_name        = N'SuperetteCG_Backup_Quotidien',
    @enabled         = 1,
    @description     = N'Sauvegarde complète quotidienne de la base SuperetteCG vers backups/SuperetteCG_full.bak.',
    @owner_login_name = @OwnerLogin;
GO

EXEC msdb.dbo.sp_add_jobstep
    @job_name        = N'SuperetteCG_Backup_Quotidien',
    @step_name       = N'Sauvegarde complete SuperetteCG',
    @subsystem       = N'TSQL',
    @database_name   = N'master',
    @command         = N'BACKUP DATABASE SuperetteCG
TO DISK = N''F:\Projets\formation-sql-server-powerbi\backups\SuperetteCG_full.bak''
WITH INIT, COMPRESSION, STATS = 10,
     NAME = N''SuperetteCG - Sauvegarde complète (job quotidien)'';',
    @retry_attempts  = 2,
    @retry_interval  = 5;
GO

EXEC msdb.dbo.sp_add_schedule
    @schedule_name     = N'Quotidien_02h00',
    @freq_type         = 4,      -- quotidien
    @freq_interval     = 1,      -- tous les jours
    @active_start_time = 20000;  -- 02:00:00
GO

EXEC msdb.dbo.sp_attach_schedule
    @job_name      = N'SuperetteCG_Backup_Quotidien',
    @schedule_name = N'Quotidien_02h00';
GO

EXEC msdb.dbo.sp_add_jobserver
    @job_name    = N'SuperetteCG_Backup_Quotidien',
    @server_name = N'(local)';
GO
