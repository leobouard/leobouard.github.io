---
title: "TIERING #3"
description: ""
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 4"
  id: "/2024/11/01/tiering-model-004"
prevLink:
  name: "Partie 2"
  id: "/2024/11/01/tiering-model-002"
---

## Structure d'OU

### Simplifier les OU existantes

Une unité d'organisation ne sert techniquement qu'à deux choses : 

1. Déléguer des permissions sur les objets enfants
2. Appliquer une stratégie de groupe

Si une OU ne fait aucune de ces deux choses, elle est donc 

> Attention : changer l'emplacement d'objets Active Directory peut avoir un impact sur les applications qui se basent sur le chemin LDAP (*DistinguishedName*) de certains objets (souvent les groupes).

```plaintext
🌐 contoso.com
  📁 CONTOSO
    📁 Canada
    📁 France
      📁 Bretagne
        📁 Brest
        📁 Rennes
        📁 Saint-Malo
    📁 Germany
    📁 India
    📁 Italy
```

```plaintext
🌐 contoso.com
  📁 CONTOSO
    📁 Canada
    📁 France
      📁 Bretagne
        🧑‍💼 Martin DUPOND        Brest
        🧑‍💼 Jeanne ROUSSEAU      Rennes
        🧑‍💼 Charles DUMAT        Saint-Malo
    📁 Germany
    📁 India
    📁 Italy
```


### Tier 0 / Tier 1 / Tier 2

Voici un exemple de structure qui fonctionne très bien, à positionner directement à la racine du domaine :

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
