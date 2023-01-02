---
layout: post
title: "Partie 7 - Highscores"
description: "Le résultat de chaque victoire est maintenant conservé dans un fichier externe pour stocker toutes les tentatives du joueur"
icon: 🎓
nextLink:
  name: "Partie 8"
  id: "/2022/12/01/cours-pratique-powershell-008"
prevLink:
  name: "Partie 6"
  id: "/2022/12/01/cours-pratique-powershell-006"
---

## Consigne

### Résultat attendu

User           : leo.bouard
Date           : 02/01/2023 17:22:07
Random         : 20
Answers        : 500,250,125,75,50,25,15,20
Average answer : 132
Seconds        : 10,027
Count          : 8
Sec per try    : 1,253
EasyMode       : True

---

## Etape par étape

1. Modification et stockage dans une variable de l'objet de fin
2. Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores
3. Sauvegarder le score dans un fichier CSV
4. Demander à l'utilisateur si il veut voir le tableau
5. Afficher le tableau des meilleurs scores

### Modification et stockage dans une variable de l'objet de fin

On va maintenant vouloir stocker l'objet de fin dans une variable `$stats` pour pouvoir l'utiliser dans différents contextes. On prépare également le formatage des données pour pouvoir les stocker efficacement dans un fichier externe (CSV). Pour ça on doit modifier la propriété `Answers` afin de la transormer en une chaine de caractères sinon on risque de se retrouver avec le résultat suivant :

User | Date | Answers
---- | ---- | -------
john.smith | 31/12/2022 23:59:59 | System.Object[]

…au lieu de :

User | Date | Answers
---- | ---- | -------
john.smith | 31/12/2022 23:59:59 

On ajoute également deux nouvelles propriétés :

1. `User` qui contient le nom de l'utilisateur actuel Windows accessible avec la variable d'environnement $env:USERNAME
2. `Date` qui contient la date et l'heure de la partie. On utilise donc la commande `Get-Date` et on format l'affichage avec le paramètre `-Format` et la valeur de paramètre `G` qui permet d'obtenir une date au format "31/12/2022 23:59:59"

```powershell
$stats = [PSCustomObject]@{
    "User"    = $env:USERNAME
    "Date"    = Get-Date -Format G
    "Answers" = $allAnswers -join ','
}
```

### Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores

```powershell
param([IO.FileInfo]$HighscorePath = "$PSScriptRoot\highscore.csv")
```

### Sauvegarder le score dans un fichier CSV

```powershell

```

### Demander à l'utilisateur si il veut voir le tableau

```powershell

```

### Afficher le tableau des meilleurs scores

```powershell

```

### Conversion du format CSV au format JSON

```powershell

```

## Correction

```powershell


```
