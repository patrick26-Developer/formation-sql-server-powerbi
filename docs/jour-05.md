# Jour 05 — Sauvegardes et SQL Server Agent

## Ce que j'ai fait
- Écriture de `sql/04_backup_strategie.sql` en deux parties :
  1. `BACKUP DATABASE SuperetteCG` vers `backups/SuperetteCG_full.bak` (compression, `STATS=10`), à exécuter manuellement d'abord pour valider le chemin.
  2. Un job SQL Server Agent `SuperetteCG_Backup_Quotidien` (créé via `sp_add_job`/`sp_add_jobstep`/`sp_add_schedule`/`sp_attach_schedule`/`sp_add_jobserver`) qui rejoue cette même sauvegarde tous les jours à 02h00.
- Création du dossier `backups/` (avec `.gitkeep`) et mise à jour de `.gitignore` : `*.bak`, `*.trn`, `backups/*` sont ignorés (seul `.gitkeep` est versionné) — aucun fichier de sauvegarde ne doit se retrouver dans Git.
- Vérification préalable : le service Windows `SQLSERVERAGENT` était **arrêté** (`Get-Service` → `Stopped`) avant toute action — cohérent avec une install Basic où l'Agent ne démarre pas automatiquement.
- Exécution de `sql/04_backup_strategie.sql` via `sqlcmd -S DESKTOP-3K8VBUM -E -i sql/04_backup_strategie.sql -f 65001 -b` :
  - Sauvegarde manuelle réussie : 681 pages, fichier `.bak` de 766 Ko confirmé sur disque.
  - Job créé sans erreur (message `SQLServerAgent is not currently running so it cannot be notified` = avertissement normal tant que le service est arrêté, pas un échec de création).
  - Vérifié via requêtes sur `msdb.dbo.sysjobs` / `sysjobschedules` / `sysjobsteps` : job activé, planification `Quotidien_02h00` (`freq_type=4` quotidien, `active_start_time=020000`), jobstep TSQL correct.

## Ce que j'ai appris
- `EXEC procedure @param = SUSER_SNAME();` lève `Msg 102 Incorrect syntax near ')'` — un appel de fonction ne peut pas être passé directement comme valeur d'un paramètre nommé dans un `EXEC`. Il faut d'abord l'affecter à une variable (`DECLARE @OwnerLogin sysname = SUSER_SNAME();`) puis passer la variable.
- Créer un job SQL Server Agent (`sp_add_job` etc.) ne nécessite **pas** que le service Agent soit démarré — ce sont de simples insertions de métadonnées dans `msdb`. En revanche, le job ne s'**exécutera** (planification, historique) que si le service est démarré.
- `sp_add_schedule @active_start_time` attend un entier au format `HHMMSS` (`20000` = 02:00:00, le zéro de tête ne change pas la valeur décimale).

## Blocages rencontrés
- Erreur de syntaxe `EXEC ... = SUSER_SNAME()` (voir ci-dessus), corrigée avec une variable intermédiaire.
- SQL Server Agent arrêté : le job est en place mais ne tournera pas tant que le service n'est pas démarré (action attendue de De Grâce dans SSMS, pas automatisable sans droits d'admin service Windows).

## Comment vérifier l'historique d'exécution du job dans SSMS
1. **Démarrer l'Agent si besoin** : Object Explorer → `SQL Server Agent` (icône avec flèche rouge si arrêté) → clic droit → **Start**.
2. Object Explorer → `SQL Server Agent` → `Jobs` → clic droit sur `SuperetteCG_Backup_Quotidien` → **Start Job at Step...** pour le tester immédiatement (ne pas attendre 02h00).
3. Toujours sur le job → clic droit → **View History** : la fenêtre **Log File Viewer** liste chaque exécution (date/heure, statut Succeeded/Failed, durée, message détaillé du step).
4. Alternative sans passer par le job en particulier : Object Explorer → `SQL Server Agent` → `Job Activity Monitor` — vue d'ensemble de tous les jobs, leur dernier statut et leur prochaine exécution planifiée.
5. Pour confirmer qu'une sauvegarde a bien eu lieu côté base (indépendamment du job) : `RESTORE HEADERONLY FROM DISK = N'F:\Projets\formation-sql-server-powerbi\backups\SuperetteCG_full.bak';` affiche les métadonnées du dernier `.bak` (date de sauvegarde, taille, type).

## À faire demain
- De Grâce : démarrer le service SQL Server Agent dans SSMS, lancer le job manuellement une fois (`Start Job at Step`) et confirmer dans `View History` que le statut est `Succeeded`.
- Jour 6 du plan : restauration de la sauvegarde (`RESTORE DATABASE`) pour valider que le `.bak` produit est effectivement exploitable — l'objectif de la checklist finale est une sauvegarde **restaurée avec succès**, pas seulement créée.
