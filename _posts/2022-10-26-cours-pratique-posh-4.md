---
layout: post
title: "Partie 4 - Mais on est où là ?"
thumbnailColor: "#007acc"
icon: 🎓
---

## Consigne

Les paramètres "Minimum" et "Maximum" pour la commande "Get-Random" sont maintenant stockés dans des variables. Des bornes font leur apparition dans le texte du `Read-Host` pour aider le joueur à mieux situer le nombre aléatoire par rapport à ses précedentes tentatives. Ces bornes se resserent au fur et à mesure des réponses du joueur.

### Résultat attendu

Bornes classiques :

> Deviner le nombre (1 < ??? < 1000): 500\
> ??? est plus grand que 500\
> Deviner le nombre (500 < ??? < 1000): 750\
> ??? est plus petit que 750\
> Deviner le nombre (500 < ??? < 750):

Bornes intelligentes (donne toujours l'écart le plus serré) :

> Deviner le nombre (500 < ??? < 750): 800\
> ??? est plus petit que 800\
> Deviner le nombre (500 < ??? < 750):

C'est cette version qui sera conservée pour la correction. Elle a comme avantage de conserver la borne la plus proche en cas d'erreur du joueur.

---

## Etape par étape

1. Variabiliser les valeurs minimum et maximum pour la génération du nombre aléatoire
2. Modifier le texte affiché pour ajouter des bornes
3. Mettre à jour les bornes inférieure et supérieure
  - Point bonus : faire des bornes intelligentes

### Variabiliser les valeurs minimum et maximum pour la génération du nombre aléatoire

L'objectif est de créer deux variables `$min` et `$max` qui vont contenir et afficher les bornes inférieure et supérieure. Comme lors de la première tentative, les bornes sont définies à 1 et 1000 respectivement, on peut les utiliser pour la génération du nombre aléatoire par la commande `Get-Random`. De cette manière, on centralise l'information.

```powershell
$min = 1
$max = 1000
Get-Random -Minimum $min -Maximum $max
```

### Modifier le texte affiché pour ajouter des bornes

On va maintenant afficher la valeur des variables `$min` et `$max` dans le texte du `Read-Host` pour avoir un résultat qui ressemble à ça : "Deviner le nombre (1 < ??? < 1000):"

```powershell
Read-Host "Deviner le nombre ($min < ??? < $max)"
```

### Mettre à jour les bornes inférieure et supérieure

Après chaque tentative, les bornes se resserent pour afficher l'encadrement le plus proche de la valeur aléatoire. Dans les blocs `if` et `elseif`, on met donc à jour les variables `$min` ou `$max` en fonction du contexte :

- si le nombre proposé par le joueur est **plus élevé que le nombre aléatoire**, alors on met à jour la **borne supérieure**
- si le nombre proposé par le joueur est **plus bas que le nombre aléatoire**, alors on met à jour la **borne inférieure**.

Voici un exemple où le nombre aléatoire est 342 :

Nb joueur | Borne inf. | Borne sup. | Commentaire
--------- | ---------- | ---------- | -----------
500 | 1 | 1000 | 500 > 342, donc on met à jour la borne supérieure
250 | 1 | **500** | 250 < 342, donc on met à jour la borne inférieure
300 | **250** | 500 | 300 < 342, donc on met à jour la borne inférieure
350 | **300** | 500 | 350 > 342, donc on met à jour la borne supérieure
  | 300 | **350** | 

Affichage dans la console :

> Deviner le nombre (1 < ??? < 1000): 500\
> ??? est plus petit que 500\
> Deviner le nombre (1 < ??? < **500**): 250
> ??? est plus grand que 250\
> Deviner le nombre (**250** < ??? < 500): 300\
> ??? est plus grand que 300\
> Deviner le nombre (**300** < ??? < 500): 350\
> ??? est plus petit que 350\
> Deviner le nombre (300 < ??? < **350**):

```powershell
if ($random -gt $answer) { $min = $answer }
elseif ($random -lt $answer) { $max = $answer }
```

### Point bonus : faire des bornes intelligentes

```powershell
if ($random -gt $answer) { 
    $min = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object | Select-Object -Last 1
} elseif ($random -lt $answer) { 
    $max = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1
}
```

## Correction

```powershell
$i   = 0
$min = 1
$max = 1000
$allAnswers = [System.Collections.Generic.List[int]]@()
$random = Get-Random -Minimum $min -Maximum $max

do {
    $i++
    $answer = Read-Host "Deviner le nombre ($min < ??? < $max)"
    $allAnswers.Add($answer)
    if ($random -gt $answer) { 
        Write-Host "??? est plus grand que $answer"
        $min = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object | Select-Object -Last 1
    } elseif ($random -lt $answer) {
        Write-Host "??? est plus petit que $answer"
        $max = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1
    } else {
        Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
    }
} until ($answer -eq $random -or $i -ge 10)

if ($answer -ne $random) { 
    Write-Host "DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire"
}

[PSCustomObject]@{
    "Random"         = $random
    "Answers"        = $allAnswers
    "Average answer" = [int]($allAnswers | Measure-Object -Average).Average
    "Count"          = $i
} | Format-List
```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/26/cours-pratique-posh-3">← Partie 3</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/26/cours-pratique-posh-5">Partie 5 →</a>
    </div>
</div>