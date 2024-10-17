---
title: "Patch note Ping Castle 3.3.0.0"
description: "Quoi de neuf dans la dernière version de Ping Castle ?"
tags: active-directory
listed: true
---

## Introduction

### Définition

- <https://blog.improsec.com/tech-blog/the-fundamentals-of-ad-tiering>

### Principe de base

### Gestion de projet

## Remédiation de l'environnement

Avant d'attaquer le déploiement du modèle en tiers, il convient de faire le ménage votre domaine Active Directory. Pour cela, le plus simple est d'utiliser les bons outils, qui vous permettront de mettre en lumière les points faibles et les vulnérabilités.

### Outils d'audit

Voici une petite sélection d'outils d'audit (tous gratuit d'utilisation si vous n'êtes pas un auditeur profesionnel).

#### Ping Castle by NETWRIX

Ping Castle est un outil d’audit référence sur la partie configuration de l’Active Directory. Il se calque à 90% sur les recommandations de l’ANSSI et permet d’avoir une très bonne alternative à ORADAD pour les entreprises ne pouvant pas l’utiliser.

Le score va de 0 (le meilleur) à la limite de 100 (le pire). Le score "global" permet de se faire rapidement une idée du niveau d'exposition, mais n'est pas un bon moyen de suivre la progression de votre remédiation. Pour suivre l'évolution du score, il faut surtout regarder le score cumulé des quatre catégories (non limité à 100).

A titre personnel, c'est mon outil de travail principal lorsqu'il s'agit de faire une remédiation de Active Directory.

Source : <https://www.pingcastle.com/download/>

#### Purple Knight by SEMPERIS

Alternative à Ping Castle mais évalue certains éléments que Ping Castle ne mesure pas, donc c’est un bon complément.

Source : <https://www.semperis.com/fr/purple-knight/>

#### Forest Druid by SEMPERIS

Permet d'auditer les chemins d’attaque vers le Tier 0, alternative à Adalanche ou BloodHound.

Source : <https://www.semperis.com/fr/forest-druid/>

#### Adalanche

Permet d’auditer et de visualiser les permissions dans Active Directory. Alternative à Forest Druid ou BloodHound.

Source : <https://github.com/lkarlslund/Adalanche>

#### BloodHound

La référence pour auditer les chemins d’attaque vers des ressources critiques. Alternative à Adalanche et Forest Druid

Source : <https://github.com/SpecterOps/BloodHound>

#### PowerHuntShares

Source : <https://github.com/NetSPI/PowerHuntShares>

#### GPOZaurr

Outil d’audit de GPO, le plus complet disponible actuellement et très lisible. Ne fait pas directement de la sécurité mais permet de faire du ménage facilement.

Source : <https://github.com/EvotecIT/GPOZaurr>

#### Harden AD

Harden AD n’est pas un outil d’audit mais plutôt un framework pour déployer un environnement Active Directory renforcé rapidement, avec tout un ensemble de règles, de GPO et de délégations.

Source : <https://hardenad.net/>

### Bonnes pratiques

### Renforcement des DC

---

## Structure d'OU

### Simplifier les OU existantes

Une unité d'organisation ne sert techniquement qu'à deux choses : pouvoir déléguer des permissions sur les objets enfant ou appliquer une stratégie de groupe.

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

## Délégations Active Directory

### Choses à ne pas faire

Active Directory permet de déléguer beaucoup d'actions, mais 

- Délégation générale du DNS <https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/from-dnsadmins-to-system-to-domain-compromise>

### Modèle AGDLP

### Création des délégations

### Création des rôles

## Limiter les connexions

### GPO vs. Authentication Silos

### Création des GPO

- <https://techcommunity.microsoft.com/t5/core-infrastructure-and-security/initially-isolate-tier-0-assets-with-group-policy-to-start/ba-p/1184934>

### Priorisation des GPO

### Application des GPO

## PAW et serveurs de rebond

### PAW

### Serveurs de rebond

### Renforcement de l'OS

## Migration des ressources

### Cartographie des relations comptes & serveurs

### Identification des ressources

- <https://specterops.github.io/TierZeroTable/>

### Déplacement des ressources

### 