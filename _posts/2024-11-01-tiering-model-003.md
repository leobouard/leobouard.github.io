---
title: "TIERING #3 - Unités d'organisation"
description: ""
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 4"
  id: "/2024/11/01/tiering-model-004"
prevLink:
  name: "Partie 2"
  id: "/2024/11/01/tiering-model-002"
---

## Structure existante

### Unités d'organisation

Normalement, votre Active Directory possède déjà une arborescence d'unités d'organisation complexe, installée depuis quelques dizaines d'années dans certains cas et sur laquelle un grand nombre de processus se reposent. Cette structure est propre à chaque entreprise et est souvent très sensible aux changements, puisque changer l'emplacement d'objets Active Directory peut avoir un impact sur les applications qui se basent sur le chemin LDAP (*DistinguishedName*) de certains objets (souvent les groupes).

L'idée est donc de toucher le moins possible à la structure existante, et de travailler autour. Certains objets doivent être déplacés pour être catégoriser dans le Tier 1 ou Tier 0, mais la grande majorité des objets peut rester dans la structure existante qui sera assimilée au Tier 2.

### Containers par défaut

La racine du domaine, les containers par défaut (Users, BuiltIn, Domain Controllers, etc...) doivent être considérés comme du Tier 0. Vous n'avez donc pas à déplacer les membres.

## Nouvelle structure

Pour simplifier l'administration, il est vital de déployer de nouvelles unités d'organisation qui serviront à catégoriser les ressources (groupes, utilisateurs, serveurs) dans les différents niveaux d'administration. Ces unités d'organisation vont recevoir des délégations et des stratégies de groupes qui seront la base du tiering model.

Voici un exemple simple de structure, à positionner directement à la racine du domaine :

```plaintext
🌐 contoso.com
  📁 TIER0
    📁 Administrators
    📁 Groups
    📁 Servers
    📁 Service accounts
  📁 TIER1
    📁 Administrators
    📁 Groups
    📁 Servers
    📁 Service accounts
  📁 TIER2
    📁 Administrators
    📁 Groups
    📁 Servers
    📁 Service accounts
```

> Certains administrateurs préfèrent ajouter un suffixe ou un préfixe sur chaque unité d'organisation de deuxième niveau, pour éviter d'avoir trois objets "OU=Administrators" avec un nom identique (par exemple).

### Objets qui seront déplacés

Comme indiqué précédemment, seul une minorité d'objets seront déplacés vers la nouvelle structure. Parmi ces objets à déplacer, on va retrouver :

- tous les comptes administrateurs
- tous les comptes de service
- tous les serveurs du Tier 0 et du Tier 1
- les groupes d'accès à des ressources du Tier 0 et du Tier 1

Vous ne devriez ne garder que des ressources du Tier 2 dans votre structure existante, comme des utilisateurs ou des groupes sans privilèges, des objets de messagerie, des ordinateurs, des serveurs sur lesquels les utilisateurs se connectent...