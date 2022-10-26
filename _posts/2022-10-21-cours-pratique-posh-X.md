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

### 1. Ajouter un chronomètre

Chronométrer le temps qu'il faut à l'utilisateur pour trouver le nombre aléatoire.

- Méthodes possibles :
  - **Classe .NET "System.Diagnostics.Stopwatch"**
  - Commande "Measure-Command"
  - Commande "New-TimeSpan"
- Nom de variable : "stopwatch" 

<details>
  <pre><code>
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $stopwatch.Stop()

    $stopwatch = Measure-Command { <#[...]#> }

    $startTime = Get-Date
    $stopWatch = New-TimeSpan -Start $startTime -End (Get-Date)
  </code></pre>
</details>

### 2. Formatage du temps de résolution

Arrondir le temps total de résolution en seconde à au millième de seconde (0.001 secondes).

- Classe .NET "System.Math"

<details>
  <pre><code>
    [System.Math]::Round($stopWatch.Elapsed.TotalSeconds,3)
  </code></pre>
</details>

### 3. Affichage du temps de résolution

Dans l'objet affiché à la fin, on ajoute le temps de résolution de la tentative. 

- Objet "PSCustomObject"
- Propriété "totalSeconds"

<details>
  <pre><code>
    [PSCustomObject]@{
        "Random"       = $random
        "Answer"       = $answer
        "Count"        = $i
        "TotalSeconds" = [System.Math]::Round($stopWatch.Elapsed.TotalSeconds,3)
    } | Format-List
  </code></pre>
</details>

