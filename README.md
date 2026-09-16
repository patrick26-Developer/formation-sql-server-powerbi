# formation-sql-server-powerbi
Formation intensive 14 jours SQL Server / Power BI / PowerShell — préparation candidature Analyste-Développeur Data

## État d'avancement (Semaine 1)

| Fait | Élément | Détail |
|---|---|---|
| ✅ | Schéma OLTP | 7 tables `SuperetteCG` en 3NF, contraintes PK/FK, `CHECK` (`sql/01_creation_base_superettecg.sql`) |
| ✅ | Données de test | 3 magasins, 20 produits, 10 clients, 6 employés, 60 stocks, 20 ventes / 46 lignes de vente (`sql/02_donnees_test_superettecg.sql`) |
| ✅ | Procédures stockées | `sp_VentesParMagasin`, `sp_ChiffreAffairesParPeriode`, `sp_ProduitsEnRupture` (`sql/03_procedures_vues_superettecg.sql`) |
| ✅ | Vues BI | `vw_FaitVentes` + 3 dimensions (`vw_DimProduit`, `vw_DimMagasin`, `vw_DimClient`) |
| ✅ | Sauvegarde | `BACKUP DATABASE` testé avec succès + job SQL Server Agent quotidien (`sql/04_backup_strategie.sql`) |
| ⚠️ | Job Agent actif | Job créé et planifié, mais nécessite le démarrage manuel du service `SQL Server Agent` |
| ✅ | Sécurité | Logins dédiés `dev_degrace` (db_owner limité à la base) et `lecteur_bi` (db_datareader, pour Power BI) — jamais `sa` au quotidien (`sql/05_securite_logins.sql`) |
| ⚠️ | Mode mixte | Logins SQL créés, mais le mode d'authentification mixte doit être activé manuellement côté serveur (voir `docs/jour-06.md`) |
| ✅ | ERD | Diagramme des 7 tables et relations (`docs/erd-superettecg.md`) |
| ⬜ | Restauration | Restaurer le `.bak` pour valider la chaîne de sauvegarde complète |
| ⬜ | Power BI | Rapport connecté à SQL Server (Import ou DirectQuery) |
| ⬜ | Rapport paginé | Power BI Report Builder |
| ⬜ | PowerShell | Script d'automatisation (`/powershell`) |
| ⬜ | Active Directory | Notions à maîtriser à l'oral |

Journal détaillé jour par jour : `docs/jour-01.md` à `docs/jour-07.md`.
