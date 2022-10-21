---
layout: post
title: "Partie 2 - En boucle en boucle en boucle"
---

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
