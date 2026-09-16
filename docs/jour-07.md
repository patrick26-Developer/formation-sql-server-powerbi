# Jour 07 — Clôture Semaine 1 : ERD + documentation

## Ce que j'ai fait
- Création de `docs/erd-superettecg.md` : diagramme Mermaid (`erDiagram`) des 7 tables de `SuperetteCG` avec attributs, PK/FK et relations (dont la nullabilité de `Ventes.ClientId`).
- Mise à jour de `README.md` avec une section "État d'avancement (Semaine 1)" : tableau récapitulant ce qui est fait (✅), partiel/à finaliser (⚠️) et pas encore commencé (⬜), avec pointeurs vers les fichiers concernés.
- Ce fichier, récapitulatif de la semaine 1.

## Récapitulatif Semaine 1
| Jour | Sujet | Livrable |
|---|---|---|
| 1 | Mise en place | Repo, `CLAUDE.md` |
| 2 | Schéma OLTP | `sql/01_creation_base_superettecg.sql` — 7 tables, contraintes FK |
| 3 | Données de test | `sql/02_donnees_test_superettecg.sql` — 3 magasins, 20 produits, 20 ventes/46 lignes |
| 4 | Procédures & vues | `sql/03_procedures_vues_superettecg.sql` — 3 procédures, 4 vues (modèle étoile simplifié) |
| 5 | Sauvegarde & Agent | `sql/04_backup_strategie.sql` — backup testé, job quotidien créé |
| 6 | Sécurité | `sql/05_securite_logins.sql` — logins `dev_degrace`/`lecteur_bi`, rôles limités |
| 7 | ERD & doc | `docs/erd-superettecg.md`, `README.md` mis à jour |

## Ce que j'ai appris (transversal semaine 1)
- Un script "techniquement correct" (pas d'erreur SQL) ne garantit pas un résultat correct côté métier ou côté environnement : le bug d'encodage `sqlcmd` (Jour 3) et le mode d'authentification réellement Windows-only malgré la note initiale (Jour 6) ont été détectés par des vérifications croisées, pas par l'absence d'erreur.
- Les deux points ⚠️ du tableau d'avancement (Agent à démarrer, mode mixte à activer) sont des réglages **serveur/service**, pas du T-SQL — un rappel utile pour la distinction entre "objet de base de données" et "configuration d'instance" qu'on retrouvera en entretien.

## Blocages rencontrés
- Aucun nouveau ce jour — les deux points en suspens (Agent arrêté, mode mixte) sont déjà documentés respectivement dans `docs/jour-05.md` et `docs/jour-06.md`, avec la procédure manuelle pour les lever.

## À faire demain (Semaine 2)
- Lever les deux ⚠️ (démarrer l'Agent, activer le mode mixte + tester `dev_degrace`).
- Restauration du `.bak` (`RESTORE DATABASE`) pour clore l'item "sauvegarde restaurée avec succès" de la checklist finale.
- Démarrer la Semaine 2 : Power BI (connexion, premier rapport), en gardant à l'esprit que cette partie demande un temps d'assimilation différent de la Semaine 1 (concepts nouveaux, pas seulement exécution de scripts) — pas de précipitation.
