---
title: "Microsoft Graph JSON batching avec PowerShell"
description: "Diviser par 20 les temps de réponse pour vos appels API vers Microsoft Graph"
tags: ["powershell", "msgraph"]
listed: true
---

## JSON batching

Lorsque vous travaillez avec Microsoft Graph, l'optimisation des performances est très importante. Microsoft rappelle fréquemment l’importance d’optimiser les performances, notamment pour les appels gourmands en ressources, en donnant plusieurs conseils :

- Utilisation de filtres plus restrictifs avec le paramètre `$filter`
- Réduction des propriétés retournées avec le paramètre `$select`
- Combinaison de plusieurs requêtes en une seule avec `$batch`

C'est sur ce troisième point que nous allons nous concentrer, puisqu'il permet de regrouper jusqu'à 20 appels API différents en une seule requête. Ces 20 appels seront alors exécutés en parallèle ou en séquence (selon vos besoins)

La documentation officielle de Microsoft est disponible ici : [Combiner plusieurs requêtes HTTP à l’aide du traitement par lot JSON - Microsoft Graph \| Microsoft Learn](https://learn.microsoft.com/fr-fr/graph/json-batching?tabs=http), mais elle n'inclut pas d'exemple d'utilisation avec PowerShell..

### Appel API

L'idée est simple : vous allez effectuer une requête "parente" qui va contenir les 20 requêtes "enfants" à exécuter. Au lieu de faire 20 appels, vous n'en faite donc plus qu'un seul. Les requêtes enfants sont stockées dans le corps (*body*) de la requête parente

> Le batching est disponible sur la v1.0 et la version beta de Microsoft Graph. La version que vous choisissez ici sera utilisée pour toutes les requêtes "enfants".

Voici un exemple avec PowerShell :

```powershell
$body = '{...}'
$uri = 'https://graph.microsoft.com/beta/$batch'
Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
```

### Corps de la requête

Le corps de la requête (*body*) va contenir nos 20 requêtes à exécuter, au format JSON. Toutes les requêtes sont contenues dans une propriété racine "requests" qui contient un tableau regroupant tous les appels que vous souhaitez effectuer.

Chaque appel est indiqué avec les propriétés suivantes :

Propriété | Obligatoire | Description
--------- | ----------- | -----------
`id` | ✓ | Chaîne de caractères unique au sein du corps JSON, permet d'associer la demande à la réponse
`method` | ✓ | Méthode API pour la requête (exemples : GET, POST, PATCH, DELETE...)
`url` | ✓ | URL de ressource relative (exemple : "/users/"), vous pouvez utiliser les paramètres de requête
`body` | | Corps de la requête
`headers` | | En-têtes

Voici à quoi devrait ressembler notre corps de requête (body) :

```json
{
    "requests": [
        {
            "id": "1",
            "method": "POST",
            "url": "/users/...",
            "body": "{...}"
        },
        {
            "id": "2",
            "method": "GET",
            "url": "/groups/..."
        }
    ]
}
```

## Exemple avec PowerShell

### Découpage par lot

Si vous avez plus de 20 appels API à faire, vous allez devoir faire votre découpage par lot. Dans ce cas, le plus simple est de recourir à une boucle `do { } until ()` et à la commande `Select-Object` avec les paramètres `-First` et `-Skip`.

Exemple de traitement pour un lot de 100 objets :

```powershell
# Tous les objets à traiter
$all = 1..100

# Variables pour le découpage par lot
$first = 20
$skip = 0
$count = ($all | Measure-Object).Count

# Boucle de traitement
do {
    $batch = $all | Select-Object -First $first -Skip $skip
    Write-Host "Traitement de $($batch[0]) à $($batch[-1])"
    Start-Sleep 2
    $skip = $skip + $first
} until ($skip -ge $count)
```

Le script va donc découper les 100 objets à traiter en cinq lots de 20 :

```plaintext
Traitement de 1 à 20
Traitement de 21 à 40
Traitement de 41 à 60
Traitement de 61 à 80
Traitement de 81 à 100
```

### Création du body JSON

Le coeur du batching repose sur le *body* de votre requête. Voici donc un morceau de code qui permet de générer un corps de requête JSON au format attendu par Microsoft Graph :

```powershell
$array = 1,2 | ForEach-Object {
    [PSCustomObject]@{
        ID     = $_
        Method = 'GET'
        URL    = "/users/$_"
    }
}
[PSCustomObject]@{requests = $array } | ConvertTo-Json
```

### Requête BATCH

L'une de mes utilisations principales pour le batching est la récupération d'informations supplémentaires sur des comptes utilisateurs. L'utilisation du batching sur ce genre de requête permet un gain de performance énorme.

Voici un exemple pour récupérer les appartenances aux groupes de tous les utilisateurs du tenant :

```powershell
# Récupération de tous les utilisateurs du tenant
$users = Get-MgUser -All -Filter "userType eq 'Member'"

# Variables pour le découpage par lot
$first = 20
$skip = 0
$count = ($users | Measure-Object).Count

$results = do {
    # Création du body
    $array = $users | Select-Object -First $first -Skip $skip | ForEach-Object {
        [PSCustomObject]@{
            ID     = $_.Id
            Method = 'GET'
            URL    = "/users/$($_.Id)/memberOf"
        }
    }
    $body = [PSCustomObject]@{requests = $array } | ConvertTo-Json

    # Requête HTTP batching
    Invoke-MgGraphRequest -Method POST -Uri 'https://graph.microsoft.com/beta/$batch' -Body $body -ContentType 'application/json' -OutputType PSObject

    $skip = $skip + $first
    Clear-Variable body
} until ($skip -ge $count)
```

### Récupération des résultats

Tous les résultats sont disponibles dans la variable `$results.responses.body.value`. Pour faire la corrélation entre nos comptes utilisateurs contenus dans la variable `$users` et le résultat du batching, on peut faire une corrélation en utilisant l'Id.

Comme l'Id de l'utilisateur a été utilisé pour créer l'Id des requêtes dans le batching, il n'y a plus qu'à faire un assemblage. Ma méthode préférée consiste à ajouter une nouvelle propriété à chaque objet utilisateur, puis à la remplir avec les données issues du batching. Cela nous donne ce code :

```powershell
# Création de la nouvelle propriété "memberOf"
$users | Add-Member -MemberType 'NoteProperty' -Name 'memberOf' -Value $null -Force

# Ajout de l'information issue du batching dans la nouvelle propriété
$users | ForEach-Object {
    $id = $_.Id
    $_.memberOf = ($results.responses | Where-Object {$_.Id -eq $id}).body.value.id }
}

# Affichage du résultat
$users | Select-Object DisplayName, UserPrincipalName, MemberOf
```
