---
layout: post
title: "Cours MSGraph"
description: "Bien commencer sur Microsoft Graph pour les administrateurs systèmes"
tags: microsoft-graph
thumbnail: "/assets/thumbnail/cours-msgraph.png"
listed: true
nextLink:
  name: "Sommaire"
  id: "/2023/09/17/cours-msgraph-sommaire"
---

## Introduction

Ce cours est dédié aux administrateurs systèmes en charge de l'administration des services cloud de Microsoft (Entra, Microsoft 365, etc...).

Microsoft Graph est la nouvelle plateforme de programmation qui connecte la plupart des services et des données de Microsoft 365. Cette nouvelle plateforme incarne **un changement de paradigme pour l'administration système** : si auparavant nous bénéficions de modules PowerShell dédiés à nos tâches, nous devons maintenant utiliser une API REST plus généraliste et avec un fonctionnement qui convient mieux au travail d'un développeur.

Avec [la fin de vie des modules PowerShell AzureAD et MSOnline](https://techcommunity.microsoft.com/t5/microsoft-entra-azure-ad-blog/important-azure-ad-graph-retirement-and-powershell-module/ba-p/3848270), il est donc important de mettre à jour ses connaissances et en développer de nouvelles, pour pouvoir commencer (ou continuer) à automatiser votre travail.

### Prérequis

Pour ce cours, je considère que vous maitrisez les bases du scripting PowerShell et l'administration de Microsoft 365, sans avoir pour autant de connaissances sur les anciens modules.

Pour réaliser les exercices pratiques, vous devrez avoir accès à un tenant Microsoft 365 (de test de préférence). Si vous n'en avez pas, vous pouvez en obtenir avec :

- [Microsoft 365 Developer Program](https://developer.microsoft.com/en-us/microsoft-365/dev-program), disponible pour tout le monde
- [Microsoft Customer Digital Experiences](https://cdx.transform.microsoft.com/), disponible si votre entreprise est un partenaire Microsoft

## Liens utiles

- [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
- [Paramètres de requêtes](https://learn.microsoft.com/fr-fr/graph/query-parameters?tabs=http)
- [Correspondance MSOnline/AzureAD vers MSGraph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0)
- [Liste complète de toutes les API v1.0](https://learn.microsoft.com/fr-fr/graph/api/overview?view=graph-rest-1.0)
- [Parcours de formation Microsoft Graph Fundamentals](https://learn.microsoft.com/en-us/training/paths/m365-msgraph-fundamentals/)
- [Extension Edge/Chrome pour récupérer des requêtes Graph](https://microsoftedge.microsoft.com/addons/detail/graph-xray/oplgganppgjhpihgciiifejplnnpodak)

<!--

## Présentation de Microsoft Graph

### Produits supportés

### Méthodes de requêtage

### Historique (AzureAD & MSOnline)

### Contexte et intérêts pour Microsoft

Microsoft doit gérer et maintenir de très nombreux produits cloud et a une volonté de rationnaliser et automatiser au maximum, réduire les coûts et améliorer la sécurité/qualité/maintenance de ses produits. La solution qui a été choisie par Microsoft est de faire reposer l'intégralité des interfaces (console web et ligne de commande) sur une API REST : Microsoft Graph.

Microsoft Graph est donc un point de terminaison unique pour administrer la plupart des produits cloud de Microsoft. Il reste encore quelques produits qui reposent sur des API différentes, mais l'idée de Microsoft est de tout centraliser à terme sur cette interface.

Dernier exemple en date : les modules PowerShell MSOnline et AzureAD qui reposaient sur d'anciennes API seront [abandonnés définitivement en mars 2024](https://techcommunity.microsoft.com/t5/microsoft-entra-azure-ad-blog/important-azure-ad-graph-retirement-and-powershell-module/ba-p/3848270) par Microsoft. Des commandes équivalentes sont disponibles sur Microsoft Graph.

#### Les modules PowerShell : le parent pauvre

Il est possible de continuer à utiliser Microsoft Graph via des modules PowerShell :

```powershell
Install-Module -Name 'Microsoft.Graph'
Get-InstalledModule 
```

-->