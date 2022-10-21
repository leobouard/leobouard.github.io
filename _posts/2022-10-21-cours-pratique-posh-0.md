---
layout: post
title: "Cours pratique PowerShell"
description: "Promis on va s'amuser !"
tags: howto
thumbnailColor: "#007acc"
icon: 🎓
---




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

<div class="buttonNext">
    <a href="/2022/10/21/cours-pratique-posh-1">Suivant : Partie 1</a>
</div>