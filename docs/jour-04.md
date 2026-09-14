# Jour 04 — Procédures stockées et vues

## Ce que j'ai fait
- Écriture de `sql/03_procedures_vues_superettecg.sql` :
  - **Procédures** : `sp_VentesParMagasin(@MagasinId)`, `sp_ChiffreAffairesParPeriode(@DateDebut, @DateFin)`, `sp_ProduitsEnRupture(@SeuilAlerte)`
  - **Vues** : `vw_FaitVentes` (grain = ligne de vente, clés de dimensions + `MontantLigne` calculé), `vw_DimProduit`, `vw_DimMagasin`, `vw_DimClient`
  - `CREATE OR ALTER` partout pour rester ré-exécutable sans erreur.
- Exécution : `sqlcmd -S DESKTOP-3K8VBUM -E -i sql/03_procedures_vues_superettecg.sql -f 65001 -b` — aucune erreur.
- Vérification des 3 procédures et des 4 vues via `sqlcmd` avant passage en revue dans SSMS :
  - `sp_VentesParMagasin @MagasinId = 1` : 16 lignes, cohérentes avec les ventes du magasin Centre-Ville.
  - `sp_ChiffreAffairesParPeriode` sur juin-septembre 2026 : 20 ventes, CA = 193 100 FCFA.
  - `sp_ProduitsEnRupture @SeuilAlerte = 30` : 10 couples magasin/produit sous le seuil, cohérent avec la formule de génération des stocks.
  - `vw_FaitVentes` : 46 lignes = 46 `LignesVente`, `SUM(MontantLigne)` = 193 100 FCFA (identique au résultat de `sp_ChiffreAffairesParPeriode` — cohérence croisée validée).
  - `vw_DimProduit` / `vw_DimMagasin` / `vw_DimClient` : 20 / 3 / 10 lignes, conformes au jeu de données.

## Ce que j'ai appris
- `CREATE OR ALTER` évite la ceinture `IF OBJECT_ID(...) DROP ... CREATE` utilisée pour les tables — plus direct pour les procédures/vues, supporté depuis SQL Server 2016.
- Croiser deux objets censés donner le même résultat par des chemins différents (`vw_FaitVentes` agrégée vs `sp_ChiffreAffairesParPeriode`) est un bon réflexe de validation avant de brancher Power BI dessus — ça aurait détecté une jointure dupliquée ou un filtre oublié.

## Blocages rencontrés
- Aucun. Le flag `-f 65001` appris au Jour 3 a évité tout problème d'encodage cette fois (noms de produits/magasins accentués corrects dans les résultats).

## À faire demain
- Vérification visuelle dans SSMS par De Grâce (`EXEC sp_VentesParMagasin @MagasinId = 1;`, `SELECT * FROM vw_FaitVentes;`).
- Jour 5 du plan : sécurité (login dédié hors `sa`, rôle limité) puis sauvegarde/restauration.
