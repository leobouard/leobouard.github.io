---
layout: post
title: "PS101 #2 - Commandes et paramètres"
description: "Comprendre comment fonctionnent les commandes"
tableOfContent: "/2024/04/07/cours-powershell-from-scratch-introduction#table-des-matières"
nextLink:
  name: "Partie 3"
  id: "/2024/04/07/cours-powershell-from-scratch-003"
prevLink:
  name: "Partie 1"
  id: "/2024/04/07/cours-powershell-from-scratch-001"
---

## Syntaxe des commandes

Les commandes PowerShell se décomposent en trois parties distinctes :

1. Le verbe
2. Le préfixe (optionnel)
3. Le nom

Le verbe est séparé du reste par un tiret, ce qui nous donne la structure suivante : `Verbe-PrefixeNom`

### Verbe

Voici quelques exemples :

- **Get** : récupérer un truc
- **Set** : modifier un truc
- **New** : créer un truc
- **Add** : ajouter un truc
- **Remove** : supprimer un truc
- **Convert** : convertir un truc

Il existe une liste de verbes approuvés par Microsoft.\
On peut obtenir cette liste avec la commande `Get-Verb`.

### Préfixe (optionnel)

Indique la provenance de la commande et permet d'éviter les conflits entre des commandes provenant de différents modules.
Certaines commandes *de base* de PowerShell n'ont pas de préfixe, mais la plupart des modules fournissent des commandes avec préfixes :

- `Mg` pour les commandes Microsoft Graph
- `AD` pour les commandes Active Directory
- `PnP` pour le module SharePoint

### Nom

Le nom donne une description brève de la commande.\
Ce nom est **toujours au singulier** et n'a pas de limite de longueur.

### En résumé

Type | Description | Exemples
---- | ----------- | --------
Verbe | Indique la méthode | Get, Set, New...
Préfixe | Indique la provenance de la commande | EXO, AD, MG...
Nom | Indique l'utilité de la commande | User, Group, Service

Quelques exemples de commandes :

- `Add-LocalGroupMember`
- `Get-Date`
- `New-ADUser`
- `Remove-MgGroup`
- `Start-Service`
- `Write-Host`

## Les alias

Certaines commandes possèdent des "alias" qui permette d'utiliser une commande avec un nom alternatif, souvent plus court et/ou issu de la syntaxe UNIX.

Voici quelques exemples :

Alias | Commande | Description
----- | -------- | -----------
`cd` | `Set-Location` | Se déplacer dans un répertoire
`ls` | `Get-ChildItem` | Lister le contenu d'un dossier
`mkdir` | `New-Item` | Créer un dossier
`cls` | `Clear-Host` | Nettoyer l'affichage dans la console

Les alias ne doivent pas être utilisé dans un script pour des raisons d'accessibilité. Ceux-ci ne doivent être utilisés que lorsque vous faites des requêtes dans la console.

La liste des alias est disponible avec la commande `Get-Alias` (ou `gal` pour les intimes).

## Les paramètres

Certaines commandes peuvent donner un résultat juste en entrant le nom de la commande. C'est le cas de la commande `Get-Date`, que l'on va utiliser en exemple sur les éléments suivants.

Les paramètres servent à modifier ou affiner le résultat d'une commande, pour obtenir un résultat au plus proche de vos attentes.

Le résultat par défaut :

```powershell
Get-Date
```

Avec l'utilisation du paramètre `-Year`, on indique l'année qui nous intéresse :

```powershell
Get-Date -Year 2010
```

Il est possible d'utiliser plusieurs paramètres en combinaison, pour obtenir la date au 1 janvier 2010 par exemple :

```powershell
Get-Date -Year 2010 -Month 01 -Day 01
```

Si on veut indiquer une valeur plus complexe que de simple chiffres, il est souvent nécessaire d'utiliser des *double-quotes* pour encadrer la valeur à passer en paramètre, exemple :

```powershell
Get-Date -Date "15/12/1997"
```

Certains paramètres n'ont pas besoin d'avoir une valeur définie pour être utilisé, c'est ce qu'on appelle un *switch* :

```powershell
Get-Date -AsUTC
```

D'autres paramètres peuvent s'exclure entre-eux car ils ne peuvent pas être utilisé en combinaison, exemple :

```powershell
Get-Date -Format "dd/MM/yyyy"
# vs.
Get-Date -UFormat "%d/%m/%Y"
```

Pour consulter la liste des paramètres disponibles, le plus simple est de tapper votre commande, ajouter un tiret et appuyer sur `Ctrl`+`Espace`.

```text
PS C:\> Get-Date -
Date                 Hour                 UFormat              ErrorAction          WarningVariable
UnixTimeSeconds      Minute               Format               WarningAction        InformationVariable
Year                 Second               AsUTC                InformationAction    OutVariable
Month                Millisecond          Verbose              ProgressAction       OutBuffer
Day                  DisplayHint          Debug                ErrorVariable        PipelineVariable
```

Certains paramètres sont des paramètres "par défaut" que vous retrouverez sur quasiment toutes les commandes PowerShell, c'est le cas des paramètres suivants :

- `-Verbose` : permet d'afficher toutes les actions de la commande dans la console
- `-ErrorAction` : indique le comportement que la commande doit suivre en cas d'erreur
- `-WhatIf` : permet de simuler l'action de la commande sans jamais faire l'action

### Astuces de pro

Vous n'avez pas besoin de spécifier le nom complet du paramètre. Dès lors qu'il n'y a plus qu'un choix possible, PowerShell comprendra implicitement le paramètre utilisé.

```powershell
Get-Date -H 12 -Min 59 -Sec 00
# vs.
Get-Date -Hour 12 -Minute 59 -Second 00
```

Egalement, certains paramètres sont utilisés par défaut si une valeur est spécifiée après une commande. Exemple :

```powershell
Write-Host 'Hello world!'
```

## Trouver une commande

Il y a une commande PowerShell qui permet de trouver toutes les autres : `Get-Command`

Pour trouver toutes les commandes qui contiennent le mot "culture" :

```powershell
Get-Command -Name "*culture*"
```

> Suivant la présence ou la position des `*`, cela permet de modifier la requête pour demander les commandes qui commencent par un texte, finissent par un texte ou simplement contiennent un texte.

## Exercice n°1

1. Expérimenter les commandes suivantes et trouver leur utilité :
   - `Get-Process`
   - `Get-Service`
   - `Get-ChildItem`
   - `Get-LocalGroup`
   - `Get-ComputerInfo`
2. Trouver la commande pour générer un nombre aléatoire grâce à `Get-Command`
3. Générer un nombre aléatoire
4. Générer un nombre aléatoire entre 1 et 10
