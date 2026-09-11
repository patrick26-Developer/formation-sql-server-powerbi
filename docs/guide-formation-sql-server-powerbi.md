# Guide de formation — SQL Server / Power BI / PowerShell (14 jours)

> Référence de méthodologie pour ce repo. Complète `CLAUDE.md` (contexte projet) — ce document détaille le **comment** : plan jour par jour, bonnes pratiques par domaine, checklist d'audit.
> Objectif : éligibilité pratique au poste Analyste/Développeur Data (Power BI – SQL Server) chez NetVirtSys, pas l'exhaustivité théorique.

## Méthodologie générale

- **Chaque jour = un livrable concret** versionné dans le repo (script SQL, script PowerShell, export Power BI, page de doc), jamais une simple lecture passive.
- **Journal obligatoire** : `docs/jour-XX.md` rempli à chaque session (voir template dans `CLAUDE.md`), même pour une session courte — c'est la trace d'apprentissage montrable en entretien.
- **Un commit par unité de travail logique**, message `type(scope): description`.
- **Priorité aux missions réelles de l'offre** : rapports Power BI, administration SQL Server (sauvegardes, jobs), migration SSRS → Paginated Reports, PowerShell en atout, notions AD à l'oral. Pas de fonctionnalités Enterprise/avancées hors périmètre (Always On, partitionnement, etc.).
- **Base de travail unique** : `SuperetteCG`, réutilisant le schéma métier déjà connu (projet Superette NestJS/Prisma) pour aller vite sur le métier et se concentrer sur SQL Server/Power BI.

## Plan jour par jour

### Jour 1 — Cadrage du projet
- Repo Git initialisé (README, LICENSE, .gitignore, structure `/sql /powershell /powerbi /docs`).
- `CLAUDE.md` en place à la racine (contexte pour Claude Code).
- Premier `docs/jour-01.md`.

### Jour 2 — Installation & sécurisation de l'instance
- Installation SQL Server 2025 Developer (édition Standard, installation Basic).
- Activation du mode d'authentification mixte.
- SSMS 22 installé, connexion vérifiée.
- Création d'un **login dédié** (pas `sa` au quotidien) avec rôle limité sur la base de travail.
- Création de la base `SuperetteCG` (script dans `/sql`).

### Jour 3 — Modélisation OLTP (3NF)
- Conception du schéma normalisé : `Magasins`, `Produits`, `Stocks`, `Clients`, `Ventes`, `LignesVente`, `Employes`.
- Script(s) de création de tables avec **contraintes PK/FK explicites** dans `/sql`.
- Schéma ERD documenté dans `/docs` (image ou description texte).

### Jour 4 — Contraintes, index et données de test
- Revue des contraintes (NOT NULL, UNIQUE, CHECK pertinents).
- Index sur les colonnes de jointure/recherche fréquentes.
- Jeu de données de test (script d'insertion ou génération) pour pouvoir requêter et brancher Power BI ensuite.

### Jour 5 — T-SQL fondamentaux
- Pratique : SELECT, jointures (INNER/LEFT), agrégations (GROUP BY, HAVING), sous-requêtes, CTE.
- Quelques requêtes métier utiles documentées (ex. CA par magasin, top produits).

### Jour 6 — Procédures stockées
- **≥ 3 procédures stockées** (`sp_...`) couvrant des cas métier réels (ex. enregistrer une vente, réapprovisionner un stock, calculer un CA sur une période).
- Gestion basique des erreurs (TRY/CATCH) et paramètres.

### Jour 7 — Vues et modèle en étoile
- **≥ 2 vues fonctionnelles** (`vw_...`) pour des besoins de reporting simples.
- Vues du modèle étoile pour la BI : `vw_FaitVentes`, `vw_DimProduit`, `vw_DimMagasin`, `vw_DimClient`, `vw_DimTemps`.

### Jour 8 — Sauvegarde et restauration
- Stratégie de sauvegarde (Full, éventuellement Differential/Log selon le temps disponible).
- Sauvegarde exécutée et **restauration testée avec succès au moins une fois** (sur un nom de base différent pour valider sans écraser la base de travail).
- Script(s) documentés dans `/sql` ou `/powershell`.

### Jour 9 — Automatisation : SQL Server Agent
- Un **job SQL Server Agent fonctionnel** (ex. sauvegarde planifiée quotidienne).
- Vérification de l'historique d'exécution du job.

### Jour 10 — PowerShell + intro Power BI Report Builder
- **Script PowerShell d'automatisation** fonctionnel (ex. health-check de l'instance, ou déclenchement/vérification de sauvegarde) — jamais de mot de passe en clair, `<PASSWORD>` en placeholder.
- Installation de Power BI Report Builder pour préparer les jours suivants.

### Jour 11 — Power BI Desktop : modèle de données
- Connexion Power BI Desktop → SQL Server (Import ou DirectQuery, choix documenté et justifié).
- Construction du modèle (relations entre vues étoile).
- Premières mesures DAX (CA total, nombre de ventes, panier moyen), exportées/documentées dans `/powerbi`.

### Jour 12 — Power BI Desktop : rapport interactif
- Rapport interactif avec visuels pertinents (CA par magasin/période, top produits, évolution des ventes).
- Filtres et interactions entre visuels.
- Fichier `.pbix` versionné dans `/powerbi` (sans données sensibles).

### Jour 13 — Rapport paginé (Power BI Report Builder)
- Un **rapport paginé** connecté à `SuperetteCG` (logique proche SSRS → utile pour la mission de migration SSRS/Paginated Reports de l'offre).
- Export/documentation du rapport dans `/powerbi`.

### Jour 14 — Active Directory (notions) + finalisation
- Notions AD à maîtriser à l'oral : utilisateurs, groupes, OU, authentification Windows vs SQL, lien avec les logins SQL Server (authentification intégrée).
- Relecture et mise à jour du `README.md` (statut, ce qui est fait).
- Revue de la checklist d'audit final (ci-dessous) et nettoyage du repo (historique de commits cohérent).

## Bonnes pratiques par domaine

### Administration SQL Server
- Authentification mixte activée, mais **logins dédiés** avec rôles limités pour le travail quotidien — `sa` réservé aux cas exceptionnels.
- Sauvegardes régulières testées par une restauration réelle, pas seulement lancées.
- Jobs SQL Server Agent avec notification/historique vérifiable.

### Développement T-SQL
- Convention de nommage : PascalCase pour les objets, préfixes `sp_` (procédures), `vw_` (vues), `fn_` (fonctions).
- Contraintes PK/FK toujours explicites, jamais de clé implicite.
- Procédures stockées paramétrées, avec gestion d'erreur minimale (TRY/CATCH) plutôt que des scripts ad hoc.

### Power BI
- Modèle en étoile (faits/dimensions) plutôt qu'un modèle plat — plus lisible et plus proche des attentes d'un poste BI.
- Mesures DAX nommées clairement et documentées (à quoi elles servent, pas juste la formule).
- Choix Import vs DirectQuery toujours justifié en fonction du volume et du besoin de fraîcheur des données.

### PowerShell
- Scripts idempotents autant que possible (relançables sans effet de bord destructeur).
- Jamais de secret en clair — placeholders + variables d'environnement ou fichier local hors Git.
- Scripts commentés sur le *pourquoi*, pas sur l'évidence du *quoi*.

### Sécurité générale
- `.gitignore` déjà configuré pour exclure les fichiers sensibles (chaînes de connexion, credentials).
- Toute action destructive (DROP, TRUNCATE) confirmée explicitement avant exécution.
- Principe du moindre privilège appliqué aux logins/rôles SQL Server créés pendant la formation.

### Active Directory (notions, pas d'implémentation complète)
- Comprendre la différence authentification Windows (intégrée, via AD) vs authentification SQL Server.
- Savoir expliquer à l'oral : utilisateur, groupe, unité d'organisation (OU), et comment un login SQL Server peut être mappé à un compte/groupe AD.

## Checklist d'audit final

- [ ] Base `SuperetteCG` : ≥ 6 tables liées, contraintes FK, index pertinents
- [ ] ≥ 3 procédures stockées + 2 vues fonctionnelles
- [ ] Sauvegarde configurée et restaurée avec succès au moins une fois
- [ ] Un job SQL Server Agent fonctionnel
- [ ] Rapport Power BI connecté à SQL Server (Import ou DirectQuery)
- [ ] Un rapport paginé (Power BI Report Builder)
- [ ] Un script PowerShell d'automatisation fonctionnel
- [ ] Notions Active Directory maîtrisées à l'oral
- [ ] Repo propre, historique de commits cohérent, README à jour
