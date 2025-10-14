---
title: "La plupart de vos OU ne servent à rien"
description: "Y'a deux types d'unités d'organisations : celles qui sont utiles et les autres"
tags: activedirectory
listed: true
---

## Utilité d'une unité d'organisation

Les unités d'organisation (OU) dans Active Directory (AD) servent à structurer et à gérer les objets (utilisateurs, groupes, ordinateurs, etc.) de manière logique et hiérarchique. Voici leurs principaux rôles :

- Structuration logique de l'annuaire
- Délégation de l'administration
- Application de stratégie de groupe (GPO)
- Séparation des rôles et des responsabilités

### Structuration logique de l'annuaire

### Délégation de l'administration

### Application de stratégie de groupe (GPO)

### Séparation des rôles et des responsabilités

🎯 Objectifs des unités d'organisation

Structuration logique de l’annuaire

Permet de refléter l’organisation réelle de l’entreprise (par département, site géographique, fonction, etc.).
Facilite la navigation et la recherche dans l’annuaire.

Délégation de l’administration

On peut attribuer des droits d’administration spécifiques à une OU sans donner un accès global à tout l’AD.
Exemple : un responsable IT local peut gérer les comptes utilisateurs de son site sans toucher aux autres.

Application de stratégies de groupe (GPO)

Les GPO peuvent être appliquées à des OU spécifiques pour contrôler les paramètres des utilisateurs et des ordinateurs.
Cela permet une gestion fine des politiques de sécurité, des configurations système, etc.

Séparation des rôles et des responsabilités

Utile pour les grandes entreprises avec plusieurs équipes IT ou des environnements multi-tenant.

📌 Exemple concret
Imaginons une entreprise avec deux sites : Rennes et Nantes. On pourrait avoir :

- Entreprise
   ├── Rennes
   │    ├── Utilisateurs
   │    └── Ordinateurs
   └── Nantes
        ├── Utilisateurs
        └── Ordinateurs

Chaque site peut avoir ses propres GPO et ses propres administrateurs locaux.

###

```
🌐 contoso.com
  📁 CONTOSO
    📁 
```
