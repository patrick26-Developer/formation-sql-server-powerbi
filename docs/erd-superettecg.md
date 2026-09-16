# ERD — SuperetteCG

Schéma OLTP en 3NF, 7 tables (voir `sql/01_creation_base_superettecg.sql` pour le DDL complet et les contraintes).

```mermaid
erDiagram
    MAGASINS ||--o{ EMPLOYES : emploie
    MAGASINS ||--o{ STOCKS : stocke
    PRODUITS ||--o{ STOCKS : est_stocke
    MAGASINS ||--o{ VENTES : realise
    CLIENTS |o--o{ VENTES : passe
    VENTES ||--o{ LIGNESVENTE : contient
    PRODUITS ||--o{ LIGNESVENTE : figure_dans

    MAGASINS {
        int Id PK
        nvarchar Nom
        nvarchar Ville
        nvarchar Adresse
    }

    PRODUITS {
        int Id PK
        nvarchar Nom
        nvarchar Categorie
        decimal PrixUnitaire
    }

    CLIENTS {
        int Id PK
        nvarchar Nom
        varchar Telephone
    }

    EMPLOYES {
        int Id PK
        int MagasinId FK
        nvarchar Nom
        nvarchar Poste
    }

    STOCKS {
        int MagasinId PK_FK
        int ProduitId PK_FK
        int Quantite
    }

    VENTES {
        int Id PK
        int MagasinId FK
        int ClientId FK "NULL = vente anonyme"
        datetime2 DateVente
    }

    LIGNESVENTE {
        int Id PK
        int VenteId FK
        int ProduitId FK
        int Quantite
        decimal PrixApplique
    }
```

## Notes de lecture
- `STOCKS` a une clé primaire composite `(MagasinId, ProduitId)` — une ligne par couple magasin/produit.
- `VENTES.ClientId` est nullable (achat anonyme en superette) ; toutes les autres FK du schéma sont obligatoires.
- La couche BI (`vw_FaitVentes`, `vw_DimProduit`, `vw_DimMagasin`, `vw_DimClient` — voir `sql/03_procedures_vues_superettecg.sql`) reprojette ce schéma OLTP en modèle étoile simplifié pour Power BI, sans dupliquer `LIGNESVENTE`/`VENTES` en table de faits séparée.
