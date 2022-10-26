---
layout: post
title: "Partie 4 - Top chrono"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

Ajouter un chronomètre

## Détails

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

### 4. Affichage du temps par essai

Dans l'objet affiché à la fin, on calcul le temps moyen par essai.

- Object "PSCustomObject"

## Correction

```powershell


```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/21/cours-pratique-posh-3">← Partie 3</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/21/cours-pratique-posh-5">Partie 5 →</a>
    </div>
</div>