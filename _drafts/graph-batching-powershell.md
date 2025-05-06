---
title: "Microsoft Graph JSON batching avec PowerShell"
description: "Diviser par 20 les temps de réponse pour vos appels API vers Microsoft Graph"
tags: ["powershell", "msgraph"]
listed: true
---

## JSON batching

Lorsque vous travaillez avec Microsoft Graph, l'optimisation des performances est très importante. Microsoft rappelle fréquemment l’importance d’optimiser les performances, notamment pour les appels gourmands en ressources, à travers différents conseils :

- utilisation de filtres plus restrictifs avec le paramètre `$filter`
- réduction des propriétés retournées avec le paramètre `$select`
- combiner plusieurs requêtes en une seule avec `$batch`

C'est sur ce troisième point que nous allons nous concentrer, puisqu'il permet de réunir jusqu'à 20 appels API différents en une seule requête. Ces 20 appels seront alors exécutés en parallèle ou en séquence (selon vos besoins).

La documentation officielle de Microsoft est disponible ici : [Combiner plusieurs requêtes HTTP à l’aide du traitement par lot JSON - Microsoft Graph \| Microsoft Learn](https://learn.microsoft.com/fr-fr/graph/json-batching?tabs=http), mais celle-ci n'inclut pas d'exemple d'utilisation avec PowerShell.

### Appel API parent

L'appel API pour faire du batching se fait sur l'URL <https://graph.microsoft.com/beta/$batch> avec la méthode POST :

```powershell
'https://graph.microsoft.com/beta/$batch'
Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
```

> Le batching est disponible sur la v1.0 et la version beta de Microsoft Graph. La version que vous choisissez ici sera utilisée pour toutes les requêtes "enfants".

### Corps de la requête

Le corps de la requête (body) va contenir nos 20 requêtes à exécuter, au format JSON. Toutes les requêtes sont contenues dans une propriété racine "requests" qui contient un tableau regroupant tous les appels que vous souhaitez effectuer.

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
            "body": "..."
        },
        {
            "id": "2",
            "method": "GET",
            "url": "/groups/..."
        }
    ]
}
```

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

## Exemple avec PowerShell

### Requête BATCH

L'une de mes utilisations principales pour le batching est la récupération d'informations supplémentaires sur des comptes utilisateurs.

Voici un exemple pour récupérer les appartenances aux groupes de tous les utilisateurs du tenant :

```powershell
# Récupération de tous les utilisateurs du tenant
$users = Get-MgUser -All -Filter "userType eq 'Member'"

# Variables pour le découpage par lot
$first = 20
$skip = 0
$count = ($users | Measure-Object).Count

# Traitement pour récupérer les résultats
$results = do {
    # Création du corps JSON
    $array = $users | Select-Object -First $first -Skip $skip | ForEach-Object {
        [PSCustomObject]@{
            id = $_.Id
            method = 'GET'
            url = "/users/$($_.Id)/memberof"
        }
    }

    # Appel API $batch
    $uri = 'https://graph.microsoft.com/beta/$batch'
    $body = [PSCustomObject]@{ request = $array } | ConvertTo-Json
    Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body -OutputType 'PSObject' -ContentType 'application/json'

    $skip = $skip + $first
} until ($skip -ge $count)
```

### Récupération des résultats

