---
layout: post
title: "Partie 4 - Mais on est où là ?"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

## Détails

## Correction

```powershell

$i   = 0
    $min = 1
    $max = 1000
    $allAnswers = [System.Collections.Generic.List[int]]@()

    $random = Get-Random -Minimum $min -Maximum $max

    do {
        $i++
        $answer = Read-Host "Deviner le nombre ($min < ??? < $max)"
        $allAnswers.Add($answer)
        if ($random -gt $answer) { 
            Write-Host "??? est plus grand que $answer"
            $min = ($allAnswers | Where-Object {$_ -lt $random} | Sort-Object -Descending)[0]
        } elseif ($random -lt $answer) {
            Write-Host "??? est plus petit que $answer"
            $max = ($allAnswers | Where-Object {$_ -gt $random} | Sort-Object)[0]
        } else {
            Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
        }
    } until ($answer -eq $random -or $i -ge 10)

    if ($answer -ne $random) { 
        Write-Host "DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire"
    }

    [PSCustomObject]@{
        "Random"         = $random
        "Answers"        = $allAnswers
        "Average answer" = [int]($allAnswers | Measure-Object -Average).Average
        "Count"          = $i
    } | Format-List

```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/26/cours-pratique-posh-3">← Partie 3</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/26/cours-pratique-posh-5">Partie 5 →</a>
    </div>
</div>