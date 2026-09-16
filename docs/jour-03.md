# Jour 03 — Jeu de données de test

## Ce que j'ai fait
- Écriture de `sql/02_donnees_test_superettecg.sql` : jeu de données de test cohérent pour les 7 tables de `SuperetteCG`.
  - 3 `Magasins` (Pointe-Noire, Brazzaville, Dolisie)
  - 20 `Produits` sur 4 `Categorie` (Alimentaire, Boissons, Hygiène, Entretien), prix réalistes en FCFA
  - 60 `Stocks` (3 magasins × 20 produits)
  - 10 `Clients`, 6 `Employes` (2 par magasin)
  - 20 `Ventes` réparties sur les 3 derniers mois (dont 4 ventes anonymes, `ClientId` NULL) et 46 `LignesVente`
- Chaque bloc d'insertion est gardé par `IF NOT EXISTS (SELECT 1 FROM dbo.X)` pour rester ré-exécutable sans doublon.
- Mapping `VenteKey → VenteId` fait via `MERGE ... OUTPUT` (un simple `INSERT ... OUTPUT` ne peut pas exposer une colonne de la source, seulement `inserted`/`deleted` — il a fallu passer par `MERGE` pour que l'`OUTPUT` renvoie `src.VenteKey` en plus de l'`Id` généré).
- Exécution via `sqlcmd -S DESKTOP-3K8VBUM -E -i sql/02_donnees_test_superettecg.sql -f 65001 -b`.

## Ce que j'ai appris
- **Bug d'encodage important** : `sqlcmd` (ODBC Driver 17) lit par défaut les fichiers `.sql` avec le codepage de la console, pas en UTF-8. Un premier chargement sans `-f 65001` a corrompu tous les caractères accentués **dans les données stockées** (`Hygiène` → `HygiÃ¨ne`, 8 caractères au lieu de 7 — vérifié avec `LEN()`, pas juste un artefact d'affichage). Correction : ajouter systématiquement `-f 65001` (UTF-8) aux appels `sqlcmd`. Consigne ajoutée dans `CLAUDE.md`.
- `OUTPUT` sur un `INSERT ... SELECT` ne peut référencer que `inserted`/`deleted`, pas les colonnes de la table source du `SELECT` — pour ça il faut un `MERGE`, dont l'`OUTPUT` peut lire à la fois la source et la cible.
- Nettoyage de données corrompues : `DELETE` (ordre inverse des FK) + `DBCC CHECKIDENT (table, RESEED, 0)` pour repartir sur des `IDENTITY` propres avant de recharger.

## Blocages rencontrés
- Corruption d'encodage détectée après un premier chargement (voir ci-dessus) — corrigée en vidant les tables et en rechargeant avec `-f 65001`.
- Le classifieur auto mode a bloqué les `DELETE` de nettoyage lancés via l'outil Bash (action jugée destructive, comme prévu par les règles du projet) ; exécutés à la place via PowerShell après confirmation explicite de De Grâce.

## À faire demain
- Vérification visuelle dans SSMS par De Grâce (Object Explorer → `Ventes` → Select Top 1000 Rows) pour confirmer cohérence des données.
- Jour 4 du plan : premières requêtes T-SQL d'exploration sur ce jeu de données, puis procédures stockées et vues (modèle étoile).
