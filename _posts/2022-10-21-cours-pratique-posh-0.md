---
layout: post
title: "Cours pratique PowerShell"
description: "Promis on va s'amuser !"
tags: howto
thumbnailColor: "#007acc"
icon: 🎓
---

## PARTIE 1 - Simple, basique.

1. Générer un nombre aléatoire (commande "Get-Random")
`Get-Random -Minimum 1 -Maximum 1000`
2. Stocker le nombre aléatoire dans une variable
`$random = Get-Random -Minimum 1 -Maximum 1000`
3. Demander à l'utilisateur de deviner le nombre (commande "Read-Host")
`$answer = Read-Host "Deviner le nombre"`

4. Vérifier si le nombre aléatoire est strictement supérieur ou inférieur au nombre de l'utilisateur (opérateurs de comparaison "-gt" et "-lt")
$random -gt $answer ; $answer -lt $random
$random -lt $answer ; $answer -gt $random

5. Comparaison 1 : afficher un message pour dire que le nombre aléatoire est plus grand que le nombre de l'utilisateur (commande "Write-Host" et condition "if(){}")
if ($random -gt $answer) { Write-Host "??? est plus grand que $answer" }

6. Comparaison 2 : afficher un message pour dire que le nombre aléatoire est plus petit que le nombre de l'utilisateur (commande "Write-Host" et condition "elseif(){}")
elseif ($random -lt $answer) { Write-Host "??? est plus petit que $answer" }

7. Comparaison 3 : afficher un message de victoire si le nombre aléatoire est égal au nombre de l'utilisateur (commande "Write-Host" et condition "else{}")
else { Write-Host "VICTOIRE ! Vous avez devinez le nombre aléatoire" }

8. Vérifier vos conditions en affichant un objet avec les membres "Random" et "Answer" (objet "PSCustomObject")
$result = [PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
}

9. Formater la vue de l'objet en mode liste (commande "Format-List")
$result | Format-List

## CORRECTION 

```powershell

$random = Get-Random -Minimum 1 -Maximum 1000
$answer = Read-Host "Deviner le nombre"
if ($random -gt $answer) { 
    Write-Host "??? est plus grand que $answer"
} elseif ($random -lt $answer) {
    Write-Host "??? est plus petit que $answer"
} else {
    Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
}
[PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
} | Format-List

```

# ---

# PARTIE 2 - En boucle en boucle en boucle...

# 1. Mettre le code dans une boucle pour demander le nombre jusqu'à ce que l'utilisateur trouve
    # 1a. Avec une boucle "while(){}"
    while ($answer -ne $random) { }
    # 1b. Avec une boucle "do{}while()"
    do { } while ($answer -ne $random)
    # 1c. Avec une boucle "do{}until()"
    do { } until ($answer -eq $random)

# 2. Ajouter un compteur de tentatives qui s'incrémente à chaque essai (opérateur "++")
$i = 0
$i++

# Point bonus : utiliser la boucle "for()" pour faire la boucle et le compteur en même temps
for ($i = 0 ; $i++ ; $answer -ne $random) { }

# 4. Sortir de la boucle si l'utilisateur dépasse 10 tentatives (commande "break" ou opérateur "-or")
    # 4a. Avec la commande "break"

    # 4b. Avec l'opérateur "-or"


# . Afficher le nombre de tentatives en même temps que le nombre aléatoire (objet "PSCustomObject")
[PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
    "Count"  = $i
} | Format-List

# Modifier l'objet final pour 


# CORRECTION
$i = 0
$random = Get-Random -Minimum 1 -Maximum 1000
$allAnswers = do {
    $answer = Read-Host "Deviner le nombre"
    if ($random -gt $answer) { 
        Write-Host "??? est plus grand que $answer"
    } elseif ($random -lt $answer) {
        Write-Host "??? est plus petit que $answer"
    } else {
        Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
    }
    $answer
    $i++
} until ($answer -eq $random)
[PSCustomObject]@{
    "Random"  = $random
    "Answer" = $allAnswer
    "Count"   = $i
} | Format-List


# ---

# Garder en mémoire tous les nombres essayés par l'utilisateurs (objets "Array", "ArrayList", "Generic.List<T>" ou en natif)
    # 3a. Avec "Array"
    $allAnswers = @()
    $allAnswers += $answer
    # 3b. Avec "ArrayList"
    $allAnswers = [System.Collections.ArrayList]@()
    $allAnswers.Add($answer)
    # 3c. Avec "Generic.List<T>"
    $allAnswers = [System.Collections.Generic.List[int]]@()
    $allAnswers.Add($answer)
    # 3d. En natif
    $allAnswers = while ($answer -ne $random) { <#...#> $answer }

# Remplacer le compteur de tentative "$i" par avec la variable "$allAnswers"

# Modifier les couleurs

# Définir les bornes supérieures et inférieures

# Nettoyer l'affichage après chaque essai

# Sauvegarder les scores dans un CSV

# Chronometrer le temps de résolution

# Afficher une barre de progression

