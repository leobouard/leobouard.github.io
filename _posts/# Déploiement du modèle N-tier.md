# RETEX - Mise en place du modèle en tier

## Définition et principes

Le modèle en tier (également appelé N-tier) consiste à segmenter les différentes ressources de l'Active Directory en fonction de leur niveau de criticité.

On utilise souvent 3 différents niveaux (tiers) :

Niveau | Cible | Permissions AD
------ | ----- | --------------
Tier 0 | Serveurs critiques | Admins du domaine
Tier 1 | Serveurs de production | Gestion des données
Tier 2 | RDS utilisateurs et postes de travail | Limitées / aucune

Les tiers sont **hermétiques entre-eux** : un administrateur du T1 ne peut pas se connecter sur un ordinateur/serveur du T0 ou du T2. Cela implique également qu'un administrateur qui doit intervenir sur les trois tiers devra utiliser trois comptes différents.

La seule exception est le tier 2, qui peut accueillir des utilisateurs standard sans privilège et des comptes administrateurs du tier 2.

Ce modèle permet en théorie de limiter le déplacement vertical vers des ressources critiques (*Golden Ticket*).

## Travail d'adaptation

Pour permettre l'application du modèle en tier, il faut veiller à adapter l'infrastructure existante pour permettre aux administrateur de pouvoir travailler correctement sans qu'ils soient limiter dans leurs tâches du quotidien. Dans l'idéal, plus de 80% du travail devrait pouvoir être fait dans le tier 1.

Seules les opérations critiques ou ponctuelles comme la création d'une nouvelle GPO, des changements au niveau du schéma Active Directory ou la création d'un nouveau compte administrateur doivent être réalisée en tier 0. Toute l'administration quotidienne doit restée dans les tiers inférieurs.

Pour cela, il convient donc de réaliser un travail d'adaptation :

- revue de l'arborescence Active Directory pour séparer les ressources de tiers différents
- revue des permissions Active Directory pour éviter les risques de sécurité
- mise en place de nouvelles délégations pour permettre aux administrateurs d'assurer leur travail quotidien

### Revue de l'arborescence

Principes à garder en mémoire :

- Réduire au maximum le nombre d'unité d'organisation (OU). Une OU est un objet Active Directory qui permet deux choses : l'application de stratégies de groupes (GPO) ou la mise en place de délégations, les OU ne sont donc pas un objet de rangement.
- Suivre le concept du privilège le moins élevé

```
🌐 corp.lbb.com
  📁 INFRA
    📁 Tier 0
      📁 Administrators
      📁 Groups
      📁 Servers
      📁 Service accounts
    📁 Tier 1
    📁 Tier 2
```

### Revue des permissions

Les permissions Active Directory sont assez rarement auditées, et la mise en place du modèle en tier est une bonne occasion de le faire. Dans l'idéal, vous devez auditer chaque permission actuellement en place et questionner son utilité et son niveau de permission. Il y a probablement moyen de supprimer ou réduire les permissions existantes.

Il faut également éviter au maximum les permissions données directement au compte. Si celles-ci ne sont pas correctement documentées, elles ne seront jamais mise à jour 

Passer via la méthode AGDLP