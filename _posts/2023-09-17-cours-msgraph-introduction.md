---
layout: post
title: "Cours Microsoft Graph"
description: "Bien commencer et progresser rapidement sur la nouvelle méthode d'administration via PowerShell des services cloud Microsoft"
tags: microsoft-graph
background: "#bd93d8"
listed: true
nextLink:
  name: "Sommaire"
  id: "/2022/09/17/cours-msgraph-sommaire"
---

## Table des matières

- [Table des matières](#table-des-matières)
- [Introduction](#introduction)
  - [Définition d'une API](#définition-dune-api)
  - [Standard REST](#standard-rest)
    - [Méthode](#méthode)
    - [URI](#uri)
  - [Clients REST](#clients-rest)
  - [Exercice pratique n°1](#exercice-pratique-n1)
  - [Pour aller plus loin](#pour-aller-plus-loin)
    - [Pagination](#pagination)
    - [Paramètres de requête](#paramètres-de-requête)
    - [Authentification](#authentification)
- [Présentation de Microsoft Graph](#présentation-de-microsoft-graph)
  - [Produits supportés](#produits-supportés)
  - [Méthodes de requêtage](#méthodes-de-requêtage)
  - [Historique (AzureAD \& MSOnline)](#historique-azuread--msonline)
  - [Contexte et intérêts pour Microsoft](#contexte-et-intérêts-pour-microsoft)
    - [Les modules PowerShell : le parent pauvre](#les-modules-powershell--le-parent-pauvre)
- [Liens utiles](#liens-utiles)

## Introduction

### Définition d'une API

Définition de la CNIL :

> Une API (application programming interface ou « interface de programmation d’application ») est une interface logicielle qui permet de « connecter » un logiciel ou un service à un autre logiciel ou service afin d’échanger des données et des fonctionnalités.

Dans la plupart des cas, une API est positionnée comme un intermédiaire permettant de faciliter les échanges entre clients et serveurs. Les clients savent comment récupérer l'information et le serveur sait comment la formater correctement. Les deux peuvent donc communiquer de manière standardisée et sans avoir plus d'information sur le contexte de l'un ou de l'autre.

### Standard REST

> Representational State Transfer : REST

Il existe différent type d'API, mais le standard le plus répandu pour les API web est le REST (API REST). Chaque API REST est différente puisqu'il ne s'agit que de lignes directrices, mais elles s'articulent souvent autour de ces deux élements :

1. La méthode : comment voulez-vous interragir avec l'information
1. L'URI : quelle ressource voulez-vous interroger

On peut également retrouver un Body (corps de message) et un Header (entête) pour envoyer de l'information et s'authentifier.

#### Méthode

Il existe quatres méthodes principales :

- `GET` pour consulter de l'information
- `POST` pour ajouter de l'information
- `PATCH` pour mettre à jour de l'information
- `DELETE` pour supprimer de l'information

Il en existe d'autre, mais les quatres cités précédemment représentent plus de 90% des requêtes.

#### URI

> Uniform Ressource Identifier

Pour l'URI, elle se compose en général de trois parties :

1. Le FQDN du site web que l'on veut requêter : `http://www.reddit.com/`
1. La ressource qui nous intéresse : `r/midjourney`
1. Les paramètres de requête pour filtrer, sélectionner ou trier : `/top.json?t=month`

On obtient alors notre URI complète : `http://www.reddit.com/r/midjourney/top.json?t=month`

### Clients REST

Le client API REST le plus connu est [Postman](https://www.postman.com/downloads/?utm_source=postman-home), mais vous pouvez aussi requêter des API depuis PowerShell avec les commandes `Invoke-RestMethod` et `Invoke-WebRequest`.

### Exercice pratique n°1

A l'aide de [l'API Découpage Administratif](https://api.gouv.fr/documentation/api-geo), vous devez répondre aux questions suivantes :

- Combien y'a-t'il de communes dans le département 75 ?
- Combien y'a-t'il d'habitants à Louvemont-Côte-du-Poivre (code : 55307) ?
- Récupérer la liste des départements de votre région de naissance
- BONUS :
  - Lister les cinq plus grandes villes de votre département de naissance
  - Quelle est la région la moins peuplée ?

Vous pouvez utiliser PowerShell avec la commande `Invoke-RestMethod`, POSTMAN ou encore l'outil intégré à la documentation de l'API.

```powershell
# Combien y'a-t'il de communes dans le département 75 ?
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/departements/75/communes'

# Combien y'a-t'il d'habitants à Louvemont-Côte-du-Poivre ?
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/communes/55307'

# Récupérer la liste des départements de votre région de naissance
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/regions'
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/regions/52/departements'

# BONUS : Lister les cinq plus grandes villes de votre département de naissance
$result = Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/departements/85/communes'
$result | Sort-Object population -Descending | Select-Object nom,code,population -First 5

# BONUS : Quelle est la région la moins peuplée ?
$regions = Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/regions'
$regions | ForEach-Object { 
    $dpts = Invoke-RestMethod -Method GET -Uri "https://geo.api.gouv.fr/regions/$($_.code)/departements"
    $villes = $dpts | ForEach-Object {
        Invoke-RestMethod -Method GET -Uri "https://geo.api.gouv.fr/departements/$($_.code)/communes"
    }
    $pop = $villes.population | Measure-Object -Sum
    $_ | Add-Member -MemberType NoteProperty -Name 'population' -Value $pop.Sum
}
$regions | Sort-Object population | Select-Object nom,code,population
```

### Pour aller plus loin

Cette API reste relativement simple et est idéale pour débuter. Cependant, la plupart des APIs (Microsoft Graph en tête) sont souvent plus complexes. Pour aller plus loin, on va donc intégrer des nouveaux éléments :

- les paramètres de requêtes
- la pagination

#### Pagination

L'un des objectifs de n'importe quelle API est de pouvoir interagir avec de la donnée le plus rapidement possible. Pour cela, la plupart des API REST utilisent un principe de pagination : toutes les données ne sont pas disponibles dès la première requête : il va falloir défiler les pages.

Chaque page peut contenir un nombre maximum de données. Cela varie suivant l'API et il n'y a pas de règles strictes. Dans tous les cas, lorsqu'une API utilise de la pagination, l'une des propriétés retournée servira à indiquer l'adresse de la prochaine page, que l'on devra inclure dans notre prochaine requête.

#### Paramètres de requête

Pour éviter de demander de l'information qui ne nous est pas utile, on peut formater la donnée avant qu'elle nous soit envoyée. Pour cela on utilise donc les paramètres de requêtes. Ceux-ci vont nous permettre de trier, filtrer, compter ou formater de la donnée avant que celle-ci ne soit reçu. Cela permet donc d'améliorer grandement l'efficacité de nos requêtes.

Ce sont également les paramètres de requêtes qui vont nous permettre de tourner les pages.

#### Authentification

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