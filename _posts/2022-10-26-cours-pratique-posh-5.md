---
layout: post
title: "Partie 5 - Top chrono !"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

Ajouter un chronomètre

Le chronomètre se lance après la première réponse du joueur.

## Détails

### 1. Créer et lancer un chronomètre

- Méthodes possibles :
  - Commandes "Get-Date" et "New-TimeSpan"
  - Classe .NET "System.Diagnostics.Stopwatch"

### 2. Stopper le chronomètre

### 3. Afficher le temps de résolution

### 4. Formatage du temps de résolution

Arrondir le temps total de résolution en seconde à au millième de seconde (0.001 secondes).

- Classe .NET "System.Math"

## Correction

```powershell

$i   = 0
$min = 1
$max = 1000
$allAnswers = [System.Collections.Generic.List[int]]@()
$stopwatch  = [System.Diagnostics.Stopwatch]::New()
$random = Get-Random -Minimum $min -Maximum $max

do {
    $i++
    $answer = Read-Host "Deviner le nombre ($min < ??? < $max)"
    if ($stopwatch.IsRunning -eq $false) { $stopwatch.Start() }
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

$stopwatch.Stop()

[PSCustomObject]@{
    "Random"         = $random
    "Answers"        = $allAnswers
    "Average answer" = [int]($allAnswers | Measure-Object -Average).Average
    "Seconds"        = [System.Math]::Round($stopwatch.Elapsed.TotalSeconds,3)
    "Count"          = $i
} | Format-List

$stopwatch.Stop()

```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/26/cours-pratique-posh-4">← Partie 4</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/26/cours-pratique-posh-6">Partie 6 →</a>
    </div>
</div>