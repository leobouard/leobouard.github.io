---
layout: post
title: "MSGRAPH #2 - Plus d'informations sur les API"
description: "Comprendre les spécificités d'une API web"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 3"
  id: "/2023/09/17/cours-msgraph-003"
prevLink:
  name: "Partie 1"
  id: "/2023/09/17/cours-msgraph-001"
---

## Pour aller plus loin

Cette API reste relativement simple et est idéale pour débuter. Cependant, la plupart des APIs (Microsoft Graph en tête) sont souvent plus complexes. Pour aller plus loin, on va donc intégrer des nouveaux éléments :

- les paramètres de requêtes
- la pagination
- l'authentification

**Vous pouvez à partir de maintenant faire vos tests directement sur le [Microsoft Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)** sur le tenant fictif par défaut ou votre tenant de test.

### Pagination

L'un des objectifs de n'importe quelle API est de pouvoir interagir avec de la donnée le plus rapidement possible. Pour cela, la plupart des API REST utilisent un principe de pagination : toutes les données ne sont pas disponibles dès la première requête : il va falloir faire défiler les pages.

Chaque page peut contenir un nombre maximum de données. Cela varie suivant l'API et il n'y a pas de règles strictes. Dans tous les cas, lorsqu'une API utilise de la pagination, l'une des propriétés retournée servira à indiquer l'adresse de la prochaine page (sous forme d'URI le plus souvent), que l'on devra inclure dans notre prochaine requête.

Voici un exemple de réponse de Microsoft Graph avec une indication sur l'adresse de la page suivante avec la propriété `@odata.nextLink`.

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/...",
    "value": [{...}],
    "@odata.nextLink": "https://graph.microsoft.com/v1.0/..."
}
```

### Paramètres de requête

Pour éviter de demander de l'information qui ne nous est pas utile, on peut formater la donnée avant qu'elle nous soit envoyée. Pour cela on utilise donc les paramètres de requêtes. Ceux-ci vont nous permettre de trier, filtrer, compter ou formater de la donnée avant que celle-ci ne soit reçu. Cela permet donc d'améliorer grandement l'efficacité de nos requêtes.

Sur l'API Microsoft Graph, c'est la syntaxe OData qui est utilisé.

Les paramètres peuvent se combiner entre-eux et se placent directement à la fin de l'URI de la requête. Le début du bloc des paramètres doit être indiqué par un `?` et l'enchainement de paramètres se fait avec le caractère `&`.

#### Liste des paramètres de Microsoft Graph

Nom |	Description
--- | -----------
$count | Compte le nombre de résultat
$expand	| Récupère les ressources connexes
$filter	| Filtre les résultats (lignes)
$format	| Renvoie les résultats dans le format de média spécifié
$orderby | Classe les résultats, ajouter "desc" pour trier dans l'ordre décroissant
$search | Renvoie les résultats en fonction des critères de recherche
$select | Filtre les propriétés (colonnes)
$skip | Indexe dans un jeu de résultats. Également utilisé par certaines API pour implémenter la pagination et peut être utilisé avec $top pour pager manuellement les résultats
$top | Définit la taille de la page de résultats

#### Exemples

- <https://graph.microsoft.com/v1.0/me/messages?$count=true>
- <https://graph.microsoft.com/v1.0/me/messages?$top=10&$skip=10>
- <https://graph.microsoft.com/v1.0/me/messages?$orderby=subject desc&$select=createdDateTime,subject,sender>

#### Note sur les paramètres avec Microsoft Graph

Petit point d'attention sur les paramètres : tous les paramètres ne sont pas disponibles sur toutes les APIs. Il n'est pas rare qu'un filtre ou qu'un tri ne soit pas possible. Dans ce cas, vous aurez un retour en erreur du type "Bad Request (400)".

Voici par exemple le résultat pour la requête suivante : <https://graph.microsoft.com/v1.0/me/messages?$orderby=id>

```json
{
    "error": {
        "code": "ErrorInvalidProperty",
        "message": "The property 'id' does not support filtering."
    }
}
```

#### Plus d'informations

Toutes les informations sur les paramètres de requêtes généraux pour Microsoft Graph sont disponibles ici : [Utilisation de paramètres de requête pour personnaliser des réponses](https://learn.microsoft.com/graph/query-parameters).

### Authentification

Je ne vais pas développer cette partie pour l'instant puisque l'authentification sur Microsoft Graph se fait de manière plutôt transparente à la fois sur Microsoft Graph Explorer (via une simple connexion avec votre compte) et en PowerShell via les modules dédiés et la commande `Connect-MgGraph`.

Sachez simplement que Microsoft Graph est une API web **protégée** et qui donc n'est pas accessible à n'importe qui. Si vous voulez accéder aux données de votre tenant, il faudra donc vous authentifier avec votre compte ou via une application en obtenant un jeton (token)) que vous ajouterez dans l'entête (header) de vos requêtes API. Si vous voulez faire les curieux et comprendre comment fonctionne l'authentification sur une API de manière générale, vous pouvez vous amuser avec [l'API de la NASA](https://api.nasa.gov/).

Sinon, voici un exemple de code PowerShell pour s'authentifier et faire une requête sans utiliser le module Microsoft Graph :

```powershell
# Get token
$tenantID       = '************'
$clientID       = '************'
$clientSecret   = '************' | ConvertTo-SecureString

# Create a hashtable for the body, the data needed for the token request
$body = @{
    'tenant'        = $tenantID
    'client_id'     = $clientID
    'scope'         = "https://graph.microsoft.com/.default"
    'client_secret' = $clientSecret
    'grant_type'    = "client_credentials"
}
# Assemble a hashtable for splatting parameters, for readability
$params = @{
    'Uri'           = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
    'Method'        = 'Post'
    'Body'          = $body
    'ContentType'   = 'application/x-www-form-urlencoded'
}
$authResponse = Invoke-RestMethod @params
$headers = @{'Authorization' = "Bearer $($authResponse.access_token)"}

# Make an API request
Invoke-RestMethod -Method GET -Headers $headers -Uri 'https://graph.microsoft.com/v1.0/...'
```
