# Jour 06 — Sécurité (logins, rôles)

## Ce que j'ai fait
- Écriture de `sql/05_securite_logins.sql` :
  - Vérification du mode d'authentification via `SERVERPROPERTY('IsIntegratedSecurityOnly')` (pas de commande T-SQL pour l'activer, c'est un réglage serveur).
  - Login `dev_degrace` (usage quotidien) + utilisateur associé dans `SuperetteCG`, membre du rôle `db_owner` **limité à cette base** (pas `sysadmin`).
  - Login `lecteur_bi` (lecture seule) + utilisateur associé, membre de `db_datareader` — c'est celui que Power BI utilisera plus tard pour se connecter sans droit d'écriture.
  - Aucun mot de passe en clair dans le script : les deux mots de passe passent par des variables `sqlcmd` (`$(DevPassword)`, `$(BiPassword)`), fournies uniquement en ligne de commande au moment de l'exécution.
- Exécution : `sqlcmd -S DESKTOP-3K8VBUM -E -f 65001 -b -i sql/05_securite_logins.sql -v DevPassword="..." BiPassword="..."`.
- Vérification en base : `dev_degrace` et `lecteur_bi` existent bien comme `SQL_LOGIN` (non désactivés), et sont respectivement membres de `db_owner` et `db_datareader` sur `SuperetteCG`.

## ⚠️ Point bloquant découvert — mode d'authentification
La requête de vérification a renvoyé :
```
SELECT SERVERPROPERTY('IsIntegratedSecurityOnly');
-- 1 = Windows uniquement (PAS le mode mixte)
```
Malgré la note initiale dans `CLAUDE.md` ("mode mixte activé" pendant l'installation), l'instance est en réalité configurée en **authentification Windows uniquement**. Les logins SQL (`dev_degrace`, `lecteur_bi`) ont bien été créés — `CREATE LOGIN` fonctionne indépendamment du mode — mais **la connexion via ces logins échouera** tant que le mode mixte n'est pas réellement activé (erreur attendue : *"Login failed for user 'dev_degrace'. (Microsoft SQL Server, Error: 18456)"* ou message explicite sur le mode d'authentification).

### Procédure manuelle pour activer le mode mixte (à faire dans SSMS, action serveur — pas de T-SQL)
1. Object Explorer → clic droit sur le serveur `DESKTOP-3K8VBUM` → **Properties**.
2. Page **Security** → sous "Server authentication", sélectionner **SQL Server and Windows Authentication mode**.
3. OK, puis **redémarrer le service SQL Server** (Object Explorer → clic droit sur le serveur → **Restart**, ou via `services.msc` sur le service `SQL Server (MSSQLSERVER)`) — le changement ne prend effet qu'après redémarrage.
4. Ensuite seulement, tester la reconnexion avec `dev_degrace` (nouvelle connexion SSMS → Authentification SQL Server → login `dev_degrace` / mot de passe communiqué en dehors de ce fichier, jamais commité).

## Ce que j'ai appris
- `CREATE LOGIN ... WITH PASSWORD = ...` réussit même si le serveur est en mode Windows uniquement — la vérification du mode d'authentification a lieu **à la connexion**, pas à la création du login. Un script qui "s'exécute sans erreur" ne garantit donc pas que le login fonctionnera : d'où l'intérêt de la vérification croisée (`SERVERPROPERTY`) avant de déclarer l'étape terminée.
- Les mots de passe passés via variables `sqlcmd` (`-v Var="valeur"`) évitent tout mot de passe en clair dans un fichier versionné, tout en gardant le script exécutable tel quel.
- `IS_ROLEMEMBER('role', 'user')` permet de garder les scripts de sécurité ré-exécutables sans erreur (`ALTER ROLE ... ADD MEMBER` échoue si déjà membre, sans ce garde-fou).

## Blocages rencontrés
- Mode d'authentification réellement en Windows uniquement, contrairement à ce qui était noté dans `CLAUDE.md` — corrigé dans `CLAUDE.md` (note mise à jour) et procédure manuelle documentée ci-dessus. Le test de reconnexion `dev_degrace` en SSMS ne pourra réussir qu'une fois cette activation manuelle faite par De Grâce.

## À faire demain
- De Grâce : activer le mode mixte (procédure ci-dessus), redémarrer le service, puis tester la reconnexion SSMS avec `dev_degrace`.
- Jour 7 du plan : ERD + documentation de clôture semaine 1.
