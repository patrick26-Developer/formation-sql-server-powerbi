# Jour 01 — Mise en place du projet et du contexte pour Claude Code

## Ce que j'ai fait
- Création du repo `formation-sql-server-powerbi` (README, LICENSE, .gitignore, structure `/sql`, `/powershell`, `/powerbi`, `/docs`).
- Ajout de `CLAUDE.md` à la racine : brief de contexte (rôles, stack, architecture cible, conventions de nommage, règles d'exécution, checklist d'audit final) pour que Claude Code garde le bon cadre à chaque session.

## Ce que j'ai appris
- Claude Code lit automatiquement `CLAUDE.md` à la racine au démarrage d'une session dans le dossier — c'est le point d'ancrage du contexte projet.

## Blocages rencontrés
- `docs/guide-formation-sql-server-powerbi.md` référencé dans `CLAUDE.md` n'est pas encore présent dans le repo (à fournir/générer).

## À faire demain
- Ajouter `docs/guide-formation-sql-server-powerbi.md` (et/ou `docs/plan-14-jours.md`).
- Démarrer le Jour 2 : installation/vérification SQL Server 2025 Developer + SSMS 22, création de la base `SuperetteCG`.
