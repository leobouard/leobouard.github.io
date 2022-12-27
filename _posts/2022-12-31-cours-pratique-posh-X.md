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

### Modifier les couleurs

### Nettoyer l'affichage après chaque essai

### Sauvegarder les scores dans un CSV

### Sauvegarder dans un JSON

### Récupérer les high-scores avec une requête web

### Afficher une barre de progression