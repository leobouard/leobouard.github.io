---
layout: post
title: "Partie 4 - Mais on est où là ?"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

Les paramètres "Minimum" et "Maximum" pour la commande "Get-Random" sont maintenant variabilisés. Ils permettent de donner une indication au joueur avec une borne inférieure et supérieure affichée dans le "Read-Host". Ces bornes se resserent au fur et à mesure des réponses du joueur.

Exemple : 

> Deviner le nombre (1 < ??? < 1000): 500
> 
> ??? est plus grand que 500
> 
> Deviner le nombre (500 < ??? < 1000): 750
> 
> ??? est plus petit que 750
> 
> Deviner le nombre (500 < ??? < 750):

## Détails

### 1. Variabiliser les paramètres "Minimum" et "Maximum"

- Noms de variable :
  - "min"
  - "max"

<details>
  <pre><code>
    $min = 1
    $max = 1000
    Get-Random -Minimum $min -Maximum $max
  </code></pre>
</details>

### 2. Modifier le "Read-Host"

Modification du texte pour afficher les valeurs minimum et maximum possible

- Commande "Read-Host"
- Variables "min" et "max"

<details>
  <pre><code>
    Read-Host "Deviner le nombre ($min < ??? < $max)"
  </code></pre>
</details>

### 3. Mettre à jour les bornes supérieures et inférieures

Après chaque coup, les bornes se resserent pour afficher l'encadrement le plus proche de la valeur aléatoire.

- Dans les blocs "if" et "elseif"

<details>
  <pre><code>
    if ($random -gt $answer) { $min = $answer }
    elseif ($random -lt $answer) { $max = $answer }
  </code></pre>
</details>

### Point bonus : utiliser la variable "allAnswers" pour obtenir les bornes

Cette version sera conservée dans la correction, elle a comme avantage de conserver la borne la plus proche en cas d'erreur :

> Deviner le nombre (1 < ??? < 1000): 500
> 
> ??? est plus petit que 500
> 
> Deviner le nombre (1 < ??? < 500): 501
> 
> ??? est plus petit que 501
> 
> Deviner le nombre (1 < ??? < 500):

- Variable "allAnswers"
- Commandes "Where-Object", "Sort-Object" et "Select-Object"

<details>
  <pre><code>
    if ($random -gt $answer) { 
        $min = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object | Select-Object -Last 1
    } elseif ($random -lt $answer) { 
        $max = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1
    }
  </code></pre>
</details>

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