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

## Pagination

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

## Paramètres de requête

### Cas général

Pour éviter de demander de l'information qui ne nous est pas utile, on peut formater la donnée avant qu'elle nous soit envoyée. Pour cela on utilise donc les paramètres de requêtes. Ceux-ci vont nous permettre de trier, filtrer, compter ou formater de la donnée avant que celle-ci ne soit reçu. Cela permet donc d'améliorer grandement l'efficacité de nos requêtes.

### Microsoft Graph

Sur l'API Microsoft Graph, c'est la syntaxe OData qui est utilisé.

Les paramètres peuvent se combiner entre-eux et se placent directement à la fin de l'URI de la requête. Le début du bloc des paramètres doit être indiqué par un `?` et l'enchainement de paramètres se fait avec le caractère `&`.

#### Liste des paramètres

Nom | Description
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

URI | Description
--- | -----------
<https://graph.microsoft.com/v1.0/me/messages?$count=true> | Ajoute une propriété `@odata.count` pour indiquer le nombre total de messages
<https://graph.microsoft.com/v1.0/me/messages?$top=10&$skip=10> | Récupère les messages n°10 à 20
<https://graph.microsoft.com/v1.0/me/messages?$orderby=subject desc&$select=createdDateTime,subject,sender> | Tri des messages selon l'objet (par ordre décroissant) et limite la vue sur les propriétés `createdDateTime`, `subjet` et `sender`

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

## Sécurité

### Authentification

Je ne vais pas développer cette partie pour l'instant puisque l'authentification sur Microsoft Graph se fait de manière plutôt transparente à la fois sur Microsoft Graph Explorer (via une simple connexion avec votre compte) et en PowerShell via les modules dédiés et la commande `Connect-MgGraph`.

Sachez simplement que Microsoft Graph est une API web **protégée** et qui donc n'est pas accessible à n'importe qui. Si vous voulez accéder aux données de votre tenant, il faudra donc vous authentifier avec votre compte ou via une application en obtenant un jeton (token) via une requête API préliminaire. Vous ajouterez ensuite ce jeton dans l'entête (header) du reste de vos requêtes API.

#### Authentification "manuelle"

Si vous voulez faire les curieux et comprendre comment fonctionne l'authentification sur une API de manière générale, vous pouvez vous amuser avec [l'API de la NASA](https://api.nasa.gov/).

Pour Microsoft Graph, voici un exemple de code PowerShell pour s'authentifier sans utiliser le module Microsoft.Graph.Authentication :

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

### Permissions et étendues (scopes)

Microsoft suit le principe des privilèges minimum (principle of least privilege) pour son API. Cela signifie concrètement que vous ne possèdez aucun droit par défaut lorsque vous vous connectez pour la première fois à Microsoft Graph (même si vous avez le rôle *Global Administrator*).

Par exemple, pour pouvoir lister des utilisateurs de votre tenant, il vous faudra invoquer l'étendue *User.Read.All* à la connexion. Si vous voulez faire des modifications sur les utilisateurs, il vous faudra ajouter l'étendue *User.ReadWrite.All*.

Vous pouvez combiner les étendues entre-elles pour obtenir les permissions nécessaires pour votre travail.

La liste complète des étendues est disponible ici : [Permissions reference - Microsoft Graph \| Microsoft Learn](https://learn.microsoft.com/graph/permissions-reference)

### Approbation de l'administrateur

Pour la plupart des étendues, il vous faudra obtenir l'approbation de l'administrateur (admin consent) avant de pouvoir accéder aux données. Si vous êtes *Global Administrator* de votre tenant, vous pouvez alors vous autorisez vous-même.

Cependant, pour les étendues limitées à votre seule personne; il n'y a pas besoin de validation par l'administrateur (adminConsentRequired = FALSE). C'est le cas de *User.Read* pour consulter votre profil, ou *Files.Read* pour lire vos fichiers.

## Versions d'API

Microsoft travaille de manière continue pour ajouter des nouvelles API à Microsoft Graph. Pour permettre 

### Passage de l'un à l'autre

Microsoft.Graph.Beta*

### V1.0

### BETA
