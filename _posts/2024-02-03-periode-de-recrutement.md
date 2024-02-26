---
layout: post
title: "Période de recrutement"
description: "Trouver le mois avec le plus de création de comptes informatique"
tags: ['challenge','powershell']
thumbnail: null
listed: true
---

## Consigne

Trouver le mois avec le plus de création de compte dans l'année

## Ajout des dates de création

Si vous n'avez pas d'annuaire Active Directory ou de tenant Microsoft 365 sous la main, je vous propose d'utiliser un fichier CSV disponible sur mon GitHub et d'y ajouter une colonne "Created" avec une date aléatoire.

Pour récupérer mon fichier CSV, voici la ligne de commande :

```powershell
# Get the user list
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'
```

Si vous le souhaitez, vous pouvez ajouter vous-même la propriété "created" à l'ensemble des utilisateurs avec une date aléatoire. Sinon, vous pouvez utiliser ce code qui va ajouter une date comprise entre il y a cinq ans et aujourd'hui :

```powershell
# Add the random 'created' date
[int]$max = (New-TimeSpan -Start (Get-Date).AddYears(-5)).TotalDays
$users | ForEach-Object {
    $random = Get-Random -Minimum 1 -Maximum $max
    $date = (Get-Date -H 0 -Min 0 -S 0).AddDays(-$random)
    $_ | Add-Member -MemberType NoteProperty -Name 'Created' -Value $date -Force
}
```

## Découverte de la commande

Une commande déjà existante correspond exactement à notre besoin : `Group-Object`. Comme son nom l'indique, cette commande permet de regrouper les différents éléments en fonction de la valeur d'une propriété spécifiée. Le retour de commande se compose d'un tableau en trois colonnes :

1. **Count** : le nombre d'éléments avec la même valeur indiquée sur la propriété "Name"
2. **Name** : la propriété qui regroupe les différents objets entre-eux
3. **Group** : liste des éléments avec la valeur "Name"

Pour donner un cas pratique, voici une commande qui permet de lister le nombre de processus selon leur priorité (exemple issu de la documentation de Microsoft) :

```powershell
Get-Process | Group-Object PriorityClass | Sort-Object Count -D
```

Et voici le résultat obtenu :

Count | Name | Group
----- | ---- | -----
198 | Normal | {System.Diagnostics.Process…
18 |  | {System.Diagnostics.Process…
12 | Idle | {System.Diagnostics.Process…
6 | High | {System.Diagnostics.Process…
5 | AboveNormal | {System.Diagnostics.Process…

Lien vers la documentation complète : [Group Object - PowerShell \| Microsoft Learn](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/group-object)

## Application à notre problème

Avant d'utiliser la commande, on doit modifier notre objet pour inclure

```powershell
$users |
    Select-Object DisplayName,@{N='Month';E={Get-Date $_.Created -Format 'MM_MMMM'}} |
    Group-Object Month |
    Sort-Object Name
```

## Autres applications

Si vous avez un Active Directory ou un tenant Microsoft 365 sous la main, vous pouvez dresser des statistiques un peu plus pertinentes comme par exemple :

- anticiper la période de renouvellement de mot de passe via l'attribut `PasswordLastSet`
- connaitre le prénom ou le nom de famille le plus populaire de votre entreprise
