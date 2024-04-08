---
layout: post
title: "PS101 #3 - Assembler les commandes entre-elles"
description: "Comprendre comment fonctionnent les commandes"
tableOfContent: "/2024/04/07/cours-powershell-from-scratch-introduction#table-des-matières"
nextLink:
  name: "Partie 4"
  id: "/2024/04/07/cours-powershell-from-scratch-004"
prevLink:
  name: "Partie 2"
  id: "/2024/04/07/cours-powershell-from-scratch-002"
---

## Pipeline

Le pipeline permet d'assembler des commandes entre-elles en envoyant le résultat d'une commande (ou autre chose) vers la suivante.

```powershell
Get-Content -Path '.\fichier.json' | ConvertFrom-Json
```

## Les commandes essentielles

Ces commandes là vont vous suivre dans tous vos scripts et pour toujours ! Il est important de les connaitre par coeur et de bien comprendre leur utilité.

- `Select-Object` : pour selectionner des propriétés
- `Sort-Object` : pour trier des données
- `Measure-Object` : pour mesurer une collection
- `Where-Object` : pour filtrer des données
- `ForEach-Object` : pour boucler sur chaque élément d'une collection

### Select-Object

`Select-Object` permet de manipuler une collection. La plupart du temps, on se servira de cette commande pour limiter la vue à ce qui nous intéresse.

```powershell
Get-ComputerInfo | Select-Object BiosSerialNumber, CsManufacturer, CsModel, CsProcessors
```

En utilisant un astérisque, on peut également afficher toutes les propriétés :

```powershell
Get-Service | Select-Object *
```

On peut également sélectionner uniquement les X premiers ou X derniers éléments d'une collection :

```powershell
Get-Service | Select-Object -First 10
# vs.
Get-Service | Select-Object -Last 10
```

### Exercice n°2A

A l'aide des commandes `Select-Object` et `Get-Service`, afficher les 25 premiers services avec les informations suivantes :

- Nom du service
- Type de démarrage
- Si le service peut être arrêté
- Si le service peut être éteint

### Sort-Object

`Sort-Object` pour trier des données, selon un ordre ascendant ou descendant

```powershell
Get-Process | Sort-Object -Property CPU
# vs.
Get-Process | Sort-Object -Property CPU -Descending
```

Il est également possible de dédupliquer une liste :

```powershell
Get-Process | Sort-Object -Property ProcessName -Unique
```

### Measure-Object

`Measure-Object` permet de mesurer une collection, en comptant le nombre d'élément, calculant la somme ou faisant une moyenne des valeurs numérique.

Pour compter le nombre d'objets :

```powershell
Get-ChildItem -Path 'C:\Windows' | Measure-Object
```

Pour calculer une somme et une moyenne :

```powershell
Get-ChildItem -Path 'C:\Windows' | Measure-Object -Property Length -Sum -Average
```

On observe que `Measure-Object` compte moins de résultats cette fois-ci, car il ne prend en compte que les éléments avec une propriété "Length".

### Exercice n°2B

A l'aide des commandes `Get-Process`, `Sort-Object` et `Measure-Object`, compter le nombre de processus unique sur votre ordinateur.

### Where-Object

`Where-Object` permet de filtrer pour ne garder que la donnée qui nous intéresse.

> `-eq` est un opérateur de comparaison pour savoir si un élément est égal à un autre

```powershell
Get-Service | Where-Object {$_.Status -eq 'Running'}
```

> `-like` est un opérateur qui permet de rechercher une chaine de caractère. En fonction de la position de l'astérisque, cela permet de trouver des résultats qui commencent par un mot, contiennent un mot ou finissent par un mot en particulier :

```powershell
Get-Service | Where-Object {$_.Name -like 'win*'}
# vs.
Get-Service | Where-Object {$_.Description -like '*xbox*'}
# vs.
Get-Service | Where-Object {$_.Name -like '*svc'}
```

### ForEach-Object

`ForEach-Object` permet d'appliquer un traitement *pour chaque* objet de la collection. C'est le type de boucle le plus répandu en PowerShell.

`$_` est ce qu'on appelle la "variable courante" : elle contient l'objet en cours de traitement.

```powershell
Get-LocalGroup | ForEach-Object {
    Write-Host $_.Name -ForegroundColor Yellow
    Get-LocalGroupMember -Group $_ | Format-List
}
```

Dans l'exemple ci-dessus, la variable courante va contenir le groupe "Administrateurs", puis "Administrateur Hyper-V", puis "Duplicateurs", etc.

### Exercice n°2C

A l'aide des commandes et des connaissances que vous avez vu précédemment, réaliser votre premier script en suivant le pseudo-code indiqué :

1. Récupérer les fichiers à la racine de C:\Windows
2. Filtrer pour n'obtenir que les fichiers .EXE
3. Obtenir les ACLs de chaque fichier (commande : `Get-Acl`)

Le script n'utilise que des commandes simples, avec des pipeline entre chaque.

```powershell
Get-ChildItem -Path 'C:\Windows' |
    Where-Object {$_.Extension -eq '.exe'} |
    ForEach-Object { Get-Acl -Path $_.FullName }
```

## Travaux pratiques n°1

Dans ces premiers travaux pratiques nous allons jouer à un "wargame". L'idée est simple : vous avez une connexion SSH avec un compte 1, et l'idée est de progresser en trouvant le mot de passe du compte 2 en résolvant une énigme.

Vous pouvez vous rendre sur <https://underthewire.tech/century> et lancer votre première connexion SSH avec la commande suivante :

```text
ssh century.underthewire.tech -l century1
```

Le mot de passe du premier compte "Century1" est `century1`.

Une fois que vous aurez trouvé le mot de passe du compte "Century2", vous pourrez quitter le SSH (commande `exit`) et lancer la même commande en modifiant le nom du compte.

### Conseils et informations

L'objectif pour cette session est d'arriver jusqu'au **niveau 10**. Avant de commencer, voici quelques conseils :

- Les mots de passe seront toujours en minuscule et sans espace
- Les connexions SSH se sont pas toujours stable, donc noter au moins le mot de passe de chaque compte pour éviter de retomber au niveau 1
- Il n'y a pas besoin de faire de scripts complexes pour le moment, donc restez sur des choses simples
- Google/Copilot est votre ami ! Savoir trouver de l'information est aussi important que savoir s'en servir

### Liste des commandes utiles

Commande | Description
-------- | -----------
Get-ADDomain | Donne les informations du domaine Active Directory
Get-Alias | Trouve l'alias d'une commande et inversement
Get-ChildItem | Liste les éléments d'un dossier
Get-Content | Récupère le contenu d'un fichier
