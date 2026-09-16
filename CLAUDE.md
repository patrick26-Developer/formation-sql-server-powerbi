# CLAUDE.md — Contexte du projet pour Claude Code

## Qui tu assistes
De Grâce (patrick26-Developer), développeur fullstack (Next.js, NestJS, Django, React Native/Expo, PostgreSQL, Prisma, Supabase), basé à Brazzaville, Congo. Il connaît déjà PostgreSQL/MySQL/SQLite et suit une formation accélérée pour candidater à un poste **Analyste/Développeur Data (Power BI – SQL Server)** chez NetVirtSys (ESN à Pointe-Noire).

## Vision du projet
Ce repo est à la fois :
1. **Un outil de formation** : monter en compétence sur SQL Server, Power BI, PowerShell et des notions Active Directory en 14 jours, de façon 100% pratique.
2. **Un artefact de candidature** : l'historique de commits, le journal quotidien et le projet final sont des preuves concrètes à montrer en entretien.

L'objectif n'est **pas l'exhaustivité théorique**, mais l'éligibilité pratique au poste. Se référer en priorité aux missions réelles de l'offre (rapports Power BI, administration SQL Server, sauvegardes, jobs planifiés, migration SSRS→Paginated Reports, PowerShell en atout, AD en notion) plutôt qu'à des fonctionnalités avancées hors périmètre.

## Rôles
- **De Grâce** : décide des orientations, valide chaque étape, exécute les actions manuelles (installations, config Windows, comptes).
- **Claude Code (toi)** : exécutant technique dans ce repo — tu écris et organises les fichiers (scripts SQL, PowerShell, journaux, documentation), tu proposes le code correspondant au plan du jour, tu maintiens la structure et la cohérence du projet.
- **Claude (chat)** : architecte/pilote en amont — définit le plan, l'architecture cible, la méthodologie ; ce fichier en est la synthèse.

## Stack & environnement
- Windows 11, PowerShell (terminal principal)
- SQL Server 2025 Developer (édition Standard), installation Basic — mode d'authentification mixte **prévu mais non confirmé actif** : `SELECT SERVERPROPERTY('IsIntegratedSecurityOnly')` a renvoyé `1` (Windows uniquement) au Jour 6, voir `docs/jour-06.md` pour la procédure d'activation manuelle
- SSMS 22
- Power BI Desktop (+ Power BI Report Builder à partir du Jour 10)
- Base de travail : `SuperetteCG` (schéma métier connu de De Grâce, réutilisé depuis son projet Superette existant en NestJS/Prisma)

## Connexion
Le serveur SQL Server à utiliser dans **tous** les scripts, connexions (SSMS, PowerShell, Power BI) est :
```
DESKTOP-3K8VBUM
```
(instance par défaut, Developer Edition, SQL Server 2025). `.` ou `localhost` fonctionnent aussi (même instance par défaut).

**Ne jamais utiliser** `DESKTOP-3K8VBUM\SQLEXPRESS` — c'est une instance Express distincte, non utilisée dans ce projet. Une confusion ici entraînerait un débogage sur un faux problème (base introuvable, connexion refusée alors que l'instance visée n'est simplement pas la bonne).

**Encodage `sqlcmd`** : toujours ajouter `-f 65001` lors de l'exécution d'un script `.sql` contenant des caractères accentués via `sqlcmd` (ex. `sqlcmd -S DESKTOP-3K8VBUM -E -i sql/xxx.sql -f 65001 -b`). Sans ce flag, `sqlcmd` (ODBC Driver 17) lit les fichiers UTF-8 avec le mauvais codepage et corrompt silencieusement les caractères accentués **directement dans les données stockées** (pas seulement à l'affichage) — vécu au Jour 3 sur `sql/02_donnees_test_superettecg.sql`.

## Structure du repo — à respecter strictement
```
/sql          → scripts de création de tables, procédures stockées, vues (un fichier par objet ou par étape)
/powershell   → scripts d'automatisation (backup, health-check), jamais de mot de passe en clair
/powerbi      → fichiers .pbix et exports de mesures DAX documentées
/docs         → journal quotidien (jour-01.md à jour-14.md), ERD, guide de formation complet
README.md     → à tenir à jour au fil de l'avancement (statut, ce qui est fait)
```

## Architecture cible

```
Restitution      : Power BI (rapports interactifs + paginés)
Sémantique/BI     : vues SQL en modèle étoile (vw_FaitVentes, vw_DimProduit, vw_DimMagasin, vw_DimClient, vw_DimTemps)
Automatisation    : SQL Server Agent (jobs) + scripts PowerShell (sauvegardes, contrôles)
Données (OLTP)    : SQL Server, schéma normalisé 3NF — Magasins, Produits, Stocks, Clients, Ventes, LignesVente, Employes
Sécurité          : logins dédiés (jamais `sa` au quotidien), rôles limités, mode mixte
```

Le guide complet (méthodologie détaillée, bonnes pratiques par domaine, checklist d'audit) est dans `docs/guide-formation-sql-server-powerbi.md` — **le lire en entier avant toute action** si présent dans le repo.

## Règles d'exécution pour Claude Code

1. **Journal obligatoire** : à chaque session de travail, créer ou compléter `docs/jour-XX.md` avec le template :
   ```markdown
   # Jour XX — <titre de l'étape>
   ## Ce que j'ai fait
   ## Ce que j'ai appris
   ## Blocages rencontrés
   ## À faire demain
   ```
   Ne jamais sauter cette étape, même pour une session courte.

2. **Conventions de nommage SQL** : PascalCase pour les objets, préfixes `sp_` (procédures), `vw_` (vues), `fn_` (fonctions). Toujours des contraintes de clé primaire/étrangère explicites.

3. **Sécurité** : jamais de mot de passe ou de chaîne de connexion en clair dans un fichier versionné. Utiliser des placeholders (`<PASSWORD>`) et documenter où le vrai secret doit être renseigné localement (hors Git, via `.gitignore` déjà configuré).

4. **Portée** : rester strictement dans le périmètre des missions de l'offre NetVirtSys. Ne pas introduire de complexité (partitionnement avancé, Always On, features Enterprise) qui ne sert pas l'objectif d'éligibilité en 14 jours.

5. **Commits** : un commit par unité de travail logique, message au format `type(scope): description` (ex. `feat(sql): ajout table Ventes avec contraintes FK`, `docs(journal): jour 3`).

6. **Avant toute action destructive** (DROP, TRUNCATE, réécriture de fichier existant), demander confirmation explicite plutôt que d'exécuter directement.

7. **Alignement avec le plan 14 jours** : si un fichier `docs/plan-14-jours.md` existe, l'utiliser comme référence d'avancement et indiquer à chaque session à quel jour/étape on se situe.

## Checklist d'audit final (objectif de fin de formation)
- [ ] Base SuperetteCG : ≥ 6 tables liées, contraintes FK, index pertinents
- [ ] ≥ 3 procédures stockées + 2 vues fonctionnelles
- [ ] Sauvegarde configurée et restaurée avec succès au moins une fois
- [ ] Un job SQL Server Agent fonctionnel
- [ ] Rapport Power BI connecté à SQL Server (Import ou DirectQuery)
- [ ] Un rapport paginé (Power BI Report Builder)
- [ ] Un script PowerShell d'automatisation fonctionnel
- [ ] Notions Active Directory maîtrisées à l'oral
- [ ] Repo propre, historique de commits cohérent, README à jour
