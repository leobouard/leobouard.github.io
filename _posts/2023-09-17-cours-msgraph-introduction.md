---
layout: post
title: "Cours Microsoft Graph"
description: "Bien commencer et progresser rapidement sur la nouvelle méthode d'administration via PowerShell des services cloud Microsoft"
tags: microsoft-graph
background: "#bd93d8"
listed: true
nextLink:
  name: "Sommaire"
  id: "/2023/09/17/cours-msgraph-sommaire"
---

## Introduction

Ce cours est dédié aux administrateurs systèmes en charge de l'administration des services cloud de Microsoft (Entra, Microsoft 365, etc...).

Microsoft Graph est la nouvelle plateforme de programmation qui connecte la plupart des services et des données de Microsoft 365. Cette nouvelle plateforme incarne **un changement de paradigme pour l'administration système** : si auparavant nous bénéficions de modules PowerShell dédiés à nos tâches, nous devons maintenant utiliser une API REST plus généralistes et avec un fonctionnement qui convient mieux au travail d'un développeur.

Avec [la fin de vie des modules PowerShell AzureAD et MSOnline](https://techcommunity.microsoft.com/t5/microsoft-entra-azure-ad-blog/important-azure-ad-graph-retirement-and-powershell-module/ba-p/3848270), il est donc important de mettre à jour ses connaissances et d'en développer de nouvelles, pour pouvoir commencer ou continuer à automatiser votre travail d'administration sur les services cloud de Microsoft.

Pour ce cours, je considère que vous maitrisez les bases du scripting PowerShell et l'administration de Microsoft 365, sans avoir pour autant de connaissances sur les anciens modules.

Egalement, si vous pouvez avoir accès à un tenant Microsoft 365 de test (via [https://demo.microsoft.com](https://cdx.transform.microsoft.com/)) en tant qu'administrateur global, cela vous permettra de mieux prendre en main et pratiquer sur Microsoft Graph.

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

Cependant, ces modules sont de plutôt mauvaise qualité car ils ont été générés automatiquement par Microsoft en se basant sur l'API.

- les commandes peuvent changer de nom d'une version à l'autre (voir même disparaitre) : quatre sous-modules ont été supprimés entre la version 1.28.0 et la version 2.2.0
- la documentation associée aux commandes PowerShell est de bien moins bonne qualité de la documentation de l'API
- les commandes PowerShell ne retournent pas toujours le même résultat qu'une requête sur l'API correspondante
- les paramètres de commandes sont génériques et n'ont pas été pensés pour la praticité

Exemple de la commande la plus longue en version 2.2.0 : `Get-MgDeviceManagementUserExperienceAnalyticAppHealthApplicationPerformanceByAppVersionDeviceIdCount`

## Liens utiles

- [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
- [Paramètres de requêtes](https://learn.microsoft.com/fr-fr/graph/query-parameters?tabs=http)
- [Correspondance MSOnline/AzureAD vers MSGraph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0)
- [Liste complète de toutes les API v1.0](https://learn.microsoft.com/fr-fr/graph/api/overview?view=graph-rest-1.0)
- [Parcours de formation Microsoft Graph Fundamentals](https://learn.microsoft.com/en-us/training/paths/m365-msgraph-fundamentals/)
- [Extension Edge/Chrome pour récupérer des requêtes Graph](https://microsoftedge.microsoft.com/addons/detail/graph-xray/oplgganppgjhpihgciiifejplnnpodak)

-->