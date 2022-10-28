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
  - Commandes "Get-Date" & "New-TimeSpan"
  - Classe .NET "System.Diagnostics.Stopwatch"

<details>
  <pre><code>
    # Pour "Get-Date" & "New-TimeSpan"
    if (!$startTime) { $startTime = Get-Date }
    
    # Pour "System.Diagnostics.Stopwatch"
    $stopwatch  = [System.Diagnostics.Stopwatch]::New()
    if ($stopwatch.IsRunning -eq $false) { $stopwatch.Start() }
  </code></pre>
</details>

### . Stopper le chronomètre

- Méthodes possibles :
  - Commandes "Get-Date" & "New-TimeSpan"
  - Classe .NET "System.Diagnostics.Stopwatch"

<details>
  <pre><code>
    # Pour "Get-Date" & "New-TimeSpan"
    $stopwatch = New-TimeSpan -Start $startTime -End (Get-Date)
    
    # Pour "System.Diagnostics.Stopwatch"
    $stopwatch.Stop()
  </code></pre>
</details>

### 3. Afficher le temps de résolution

- Propriété "TotalSeconds"

<details>
  <pre><code>
    # Pour "Get-Date" & "New-TimeSpan"
    $stopwatch.TotalSeconds
    
    # Pour "System.Diagnostics.Stopwatch"
    $stopwatch.Elapsed.TotalSeconds
  </code></pre>
</details>

### 4. Formatage du temps de résolution

Arrondir le temps total de résolution au millième de seconde (0.001 secondes).

- Classe .NET "System.Math"

<details>
  <pre><code>
    [System.Math]::Round($stopwatch.Elapsed.TotalSeconds,3)
  </code></pre>
</details>

### 5. Calculer et afficher le temps par coup

<details>
  <pre><code>
    $stopwatch.Elapsed.TotalSeconds / $i
  </code></pre>
</details>


## Correction

```powershell

$i          = 0
$min        = 1
$max        = 1000
$allAnswers = [System.Collections.Generic.List[int]]@()
$stopwatch  = [System.Diagnostics.Stopwatch]::New()
$random     = Get-Random -Minimum $min -Maximum $max

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
    "Sec per try"    = [System.Math]::Round(($stopwatch.Elapsed.TotalSeconds / $i),3)
} | Format-List

```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/26/cours-pratique-posh-4">← Partie 4</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/26/cours-pratique-posh-6">Partie 6 →</a>
    </div>
</div>