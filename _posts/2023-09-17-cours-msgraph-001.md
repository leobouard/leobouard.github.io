---
layout: post
title: "Cours Microsoft Graph #1 - Qu'est-ce qu'une API ?"
description: "???"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 2"
  id: "/2023/09/17/cours-msgraph-002"
prevLink:
  name: "Sommaire"
  id: "/2023/09/17/cours-msgraph-sommaire"
---

## Définition d'une API

Définition de la CNIL :

  *Une API (application programming interface ou « interface de programmation d’application ») est une interface logicielle qui permet de « connecter » un logiciel ou un service à un autre logiciel ou service afin d’échanger des données et des fonctionnalités.*

Dans la plupart des cas, une API est positionnée comme un intermédiaire permettant de faciliter les échanges entre clients et serveurs. Les clients savent comment récupérer l'information et le serveur sait comment la formater correctement. Les deux peuvent donc communiquer de manière standardisée, sans nécessiter plus d'information sur le contexte de l'un ou de l'autre.

### Standard REST

Il existe différents types d'API, mais le standard le plus répandu pour les API web est le REST (*Representational State Transfer*). Chaque API RESTful est différente puisqu'il ne s'agit que de lignes directrices, mais elles s'articulent obligatoirement autour de ces deux élements :

1. La méthode : comment voulez-vous interragir avec la donnée
2. L'URI : pour identifier la ressource que vous voulez requêter

On peut également retrouver un Body (corps de message) et un Header (entête) pour envoyer de la donnée et s'authentifier.

Groso modo : on envoie une re

#### Méthode

Il existe quatres méthodes principales :

- `GET` pour récupérer de la donnée
- `POST` pour ajouter de la donnée
- `PATCH` pour mettre à jour de la donnée
- `DELETE` pour supprimer de la donnée

Il en existe d'autre, mais les quatres cités précédemment représentent plus de 90% des requêtes.

#### URI

Une URI (*Uniform Ressource Identifier*), elle se compose en général de trois parties :

Partie | Description | Exemple
------ | ----------- | -------
FQDN | *Fully Qualified Domain Name* du site web | `http://www.reddit.com/`
Ressource |
Paramètres de requête | 

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