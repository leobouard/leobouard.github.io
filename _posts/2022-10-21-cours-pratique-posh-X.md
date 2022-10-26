---
layout: post
title: "Partie X"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

## Détails

### Vérification des données à l'entrée

```powershell

do {
    $validAnswer = try {
        [int]$answer = Read-Host "TEST"
        $true
    } catch {
        Write-Host "Answer is bad formating"
        $false
    }
} while ($validAnswer -ne $true)

```

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

### Définir les bornes supérieures et inférieures

```powershell

$limitLow  = 0
$limitHigh = 1000

# Borne inférieure
$limitLow  = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object -Descending | Select-Object -First 1

# Borne supérieure
$limitHigh = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1

```

### Modifier les couleurs

### Nettoyer l'affichage après chaque essai

### Sauvegarder les scores dans un CSV

### Sauvegarder dans un JSON

### Récupérer les high-scores avec une requête web

### Calcul de statistique

### Afficher une barre de progression

### Passage en interface graphique avec WPF

### Mode simplifié avec (Get-Random de 0 à 100)*100

### Mise en fonction (mise en bouate)
