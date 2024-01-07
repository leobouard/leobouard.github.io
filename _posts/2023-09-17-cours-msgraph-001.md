---
layout: post
title: "MSGRAPH #1 - Les bases d'une API web"
description: "Concepts et principes de base pour l'utilisation d'une API RESTful"
tableOfContent: "/2023/09/17/cours-msgraph-introduction#table-des-matières"
nextLink:
  name: "Partie 2"
  id: "/2023/09/17/cours-msgraph-002"
prevLink:
  name: "Introduction"
  id: "/2023/09/17/cours-msgraph-introduction"
---

## Définition d'une API

Définition de la CNIL :

  *Une API (application programming interface ou « interface de programmation d’application ») est une interface logicielle qui permet de « connecter » un logiciel ou un service à un autre logiciel ou service afin d’échanger des données et des fonctionnalités.*

Dans la plupart des cas, une API est positionnée comme un intermédiaire permettant de faciliter les échanges entre clients et serveurs. Les clients savent comment récupérer l'information et le serveur sait comment la formater correctement. Les deux peuvent donc communiquer de manière standardisée, sans nécessiter plus d'information sur le contexte de l'un ou de l'autre.

## Standard REST

Il existe différents types d'API, mais le standard le plus répandu pour les API web est le REST (*Representational State Transfer*). Chaque API RESTful est différente puisqu'il ne s'agit que de lignes directrices, mais elles s'articulent obligatoirement autour de ces deux élements :

1. La méthode : comment voulez-vous interragir avec la donnée
2. L'URI : pour identifier la ressource que vous voulez requêter

On peut également retrouver un Body (corps de message) et un Header (entête) pour envoyer de la donnée et s'authentifier.

Ces éléments vont permettre de construire une **requête HTTP** pour pouvoir interagir avec une donnée précise.

### Méthode

Il existe quatres méthodes principales :

- `GET` pour récupérer de la donnée
- `POST` pour ajouter de la donnée
- `PATCH` pour mettre à jour de la donnée
- `DELETE` pour supprimer de la donnée

Il en existe d'autre, mais les quatres cités précédemment représentent plus de 90% des requêtes.

### URI

Une URI (*Uniform Ressource Identifier*), elle se compose en général de trois parties :

1. Le **FQDN** du site web que l'on veut requêter : `http://www.reddit.com/`
2. La **chemin vers la ressource** qui nous intéresse : `r/midjourney`
3. Les **paramètres de requête** pour filtrer, sélectionner ou trier : `/top.json?t=month`

On obtient alors notre URI complète : `http://www.reddit.com/r/midjourney/top.json?t=month`

### Clients REST

Le client API REST le plus connu est [Postman](https://www.postman.com/downloads/?utm_source=postman-home), qui permet d'avoir une interface utilisateur simple et de requêter sans avoir besoin de coder

Si vous souhaitez coder, quasiment tous les languages de programmation modernes proposent une méthode pour envoyer des requêtes HTTP vers une API. Pour PowerShell, vous pouvez utiliser les commandes `Invoke-RestMethod` et/ou `Invoke-WebRequest`.

Pour de la récupération de données (méthode `GET`) sur une API ouverte à tous, vous pouvez même utiliser simplement votre navigateur et aller à l'URL indiquée pour consulter le résultat.

### Résultat

Le résultat d'une requête sera fourni dans un language structuré. Le plus souvent, les résultats seront donnés en JSON (avec souvent une indication sur le format de réponse utilisé).

### Faire une requête HTTP

Pour faire une requête via PowerShell, vous pouvez utiliser la commande `Invoke-RestMethod` puis indiquer votre méthode et l'URI :

```powershell
$uri = 'https://restcountries.com/v3.1/alpha/FR'
Invoke-RestMethod -Method 'GET' -Uri $uri
```

Vous pouvez également utiliser Postman pour effectuer votre requête :

![Exemple de requête via Postman](/assets/images/postman-001.png)

## Exercice pratique

Nous allons mettre en pratique les différents éléments abordés dans un exercice utilisant une API RESTful très simple à utiliser. L'idée de cet exercice est de faire des requêtes `GET` depuis PowerShell ou un client (comme Postman) sur une API simple et ouverte à tous.

A l'aide de [l'API Découpage Administratif (api.gouv.fr)](https://api.gouv.fr/documentation/api-geo), vous devez répondre aux questions suivantes :

- Combien y'a-t'il de communes dans le département 75 ?
- Combien y'a-t'il d'habitants à Louvemont-Côte-du-Poivre (code : 55307) ?
- Récupérer la liste des départements d'une des régions française
- *(BONUS) Lister les cinq plus grandes villes de votre département de naissance*
- *(SUPER BONUS) Quelle est la région la moins peuplée ?*

Vous pouvez utiliser PowerShell avec la commande `Invoke-RestMethod`, Postman ou encore l'outil intégré à la documentation de l'API.

<a class="solution" href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-msgraph-001.ps1" target="_blank">Voir la solution</a>
