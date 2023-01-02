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

> Joueur                    : john.smith\
> Date                      : 01/12/2022 12:00:00\
> Nombre aléatoire          : 20\
> Réponses                  : 500,250,125,75,50,25,15,20\
> Réponse moyenne           : 132\
> Temps de résolution (sec) : 10,027\
> Temps moyen par tentative : 1,253\
> Tentatives                : 8\
> Mode facile               : True\
> \
> Voulez-vous voir les meilleurs scores?\
> [O] Oui  [N] Non  [?] Aide (la valeur par défaut est « N ») :

---

## Etape par étape

1. Modification et stockage dans une variable de l'objet de fin
2. Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores
3. Sauvegarder le score dans un fichier CSV
4. Demander à l'utilisateur si il veut voir le tableau
5. Afficher le tableau des meilleurs scores

### Modification et stockage dans une variable de l'objet de fin

On va maintenant vouloir stocker l'objet de fin dans une variable `$stats` pour pouvoir l'utiliser dans différents contextes. On prépare également le formatage des données pour pouvoir les stocker efficacement dans un fichier externe (CSV) :

1. Ajouter la propriété `Joueur` qui contient le nom de l'utilisateur actuel Windows accessible avec la variable d'environnement $env:USERNAME
2. Ajouter la propriété `Date` qui contient la date et l'heure de la partie. On utilise donc la commande `Get-Date` et on format l'affichage avec le paramètre `-Format` et la valeur de paramètre `G` qui permet d'obtenir une date au format "31/12/2022 23:59:59"
3. Modifier la propriété `Réponses` pour transformer l'objet en chaine de caractères avec l'opérateur `-join` pour mieux l'exporter en CSV

```powershell
$stats = [PSCustomObject]@{
    "Joueur"   = $env:USERNAME
    "Date"     = Get-Date -Format G
    "Réponses" = $allAnswers -join ','
}
```

### Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores

```powershell
param([IO.FileInfo]$HighscorePath = "$PSScriptRoot\highscore.csv")
```

### Sauvegarder le score dans un fichier CSV

```powershell
$stats | Export-Csv -Path $HighscorePath -Encoding UTF8 -Delimiter ';' -NoTypeInformation -Append -Force
```

### Demander à l'utilisateur si il veut voir le tableau

```powershell
$question = 'Voulez-vous voir les meilleurs scores?'
$choices  = '&Oui', '&Non'
$decision = $Host.UI.PromptForChoice($null, $question, $choices, 1)
```

### Afficher le tableau des meilleurs scores

```powershell
if ($decision -eq 0) {
    Import-Csv -Path $HighscorePath -Delimiter ';' -Encoding UTF8 | Out-GridView -Title "Meilleurs scores"
}
```

## Correction

```powershell


```
