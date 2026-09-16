# Jour 02 — Création du schéma SuperetteCG

## Ce que j'ai fait
- Écriture de `sql/01_creation_base_superettecg.sql` : création de la base `SuperetteCG` (si absente) et des 7 tables du schéma OLTP en 3NF — `Magasins`, `Produits`, `Clients`, `Employes`, `Stocks`, `Ventes`, `LignesVente`.
- Contraintes PK explicites sur chaque table (PK composite `(MagasinId, ProduitId)` pour `Stocks`), contraintes FK entre toutes les tables liées, et quelques `CHECK` pour interdire les quantités/prix négatifs.
- Types SQL Server natifs utilisés (`NVARCHAR`, `DECIMAL(10,2)`, `DATETIME2(0)`, `INT IDENTITY`) plutôt que des équivalents MySQL/PostgreSQL.
- Exécution du script validée via `sqlcmd -S DESKTOP-3K8VBUM` : les 7 tables et les 7 contraintes FK attendues sont bien présentes dans `SuperetteCG`.
- Ajout d'une section "Connexion" dans `CLAUDE.md` : le serveur à utiliser partout est `DESKTOP-3K8VBUM` (instance par défaut), jamais `DESKTOP-3K8VBUM\SQLEXPRESS`.

## Ce que j'ai appris
- `DB_ID()` / `OBJECT_ID()` sont les façons idiomatiques en T-SQL de sécuriser un script en le rendant ré-exécutable sans erreur (équivalent de `IF NOT EXISTS` côté objets serveur).
- `Ventes.ClientId` est nullable pour permettre une vente sans client identifié (achat anonyme en superette), contrairement à `Ventes.MagasinId` qui reste obligatoire.
- Confirmation : DESKTOP-3K8VBUM (instance par défaut, SQL Server 2025 Developer) est l'instance à cibler ; `\SQLEXPRESS` sur la même machine est une instance Express distincte, non utilisée.

## Blocages rencontrés
- Aucun. Script exécuté sans erreur et vérifié (tables + FK) via `sqlcmd`.

## À faire demain
- Insérer un jeu de données de test réaliste (Jour 4 du plan) pour permettre de pratiquer les requêtes T-SQL et brancher Power BI ensuite.
