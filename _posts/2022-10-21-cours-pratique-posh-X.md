---
layout: post
title: "Partie X"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

## Détails

### Garder en mémoire tous les nombres essayés par l'utilisateurs

- Objets utilisables :
  - "Array"
  - "ArrayList"
  - "Generic.List<T>"
  - Via pipeline

```powershell

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
    
```

### Remplacer le compteur de tentative "$i" par avec la variable "$allAnswers"

### Modifier les couleurs

### Définir les bornes supérieures et inférieures

### Nettoyer l'affichage après chaque essai

### Sauvegarder les scores dans un CSV

### Sauvegarder dans un JSON

### Récupérer les high-scores avec une requête web

### Chronometrer le temps de résolution

### Calcul de statistique

### Afficher une barre de progression

### Passage en interface graphique avec WPF

### Mode simplifié avec (Get-Random de 0 à 100)*100

### Mise en fonction (mise en bouate)
