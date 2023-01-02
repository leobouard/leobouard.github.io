---
layout: post
title: "Partie 7 - Highscore"
description: "Le résultat de chaque victoire est maintenant conservé dans un fichier externe pour stocker toutes les tentatives du joueur"
icon: 🎓
nextLink:
  name: "Partie 8"
  id: "/2022/12/01/cours-pratique-powershell-008"
prevLink:
  name: "Partie 5"
  id: "/2022/12/01/cours-pratique-powershell-006"
---

## Consigne

### Résultat attendu

---

## Etape par étape

1. Stocker l'objet de fin dans une variable
2. Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores
3. Sauvegarder le score dans un fichier CSV
4. Demander à l'utilisateur si il veut voir le tableau
5. Afficher le tableau des meilleurs scores
6. Conversion du format CSV au format JSON

### Stocker l'objet de fin dans une variable

### Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores

```powershell
param([FileInfo]$)
```

### Sauvegarder le score dans un fichier CSV

```powershell

```

### Demander à l'utilisateur si il veut voir le tableau

```powershell

```

### Afficher le tableau des meilleurs scores

```powershell

```

### Conversion du format CSV au format JSON

```powershell

```

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
