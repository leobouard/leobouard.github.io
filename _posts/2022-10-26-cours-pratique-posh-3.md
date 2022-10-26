---
layout: post
title: "Partie 3 - En boucle en boucle en boucle"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

Tous les nombes essayés par l'utilisateur sont maintenant gardés en mémoire. Dans l'objet de fin :

- on remplace la dernière réponse de l'utilisateur par une liste contenant toutes ses réponses
- on affiche maintenant la valeur moyenne de toutes les réponses données par l'utilisateur (arrondie à l'entier)

## Détails

### 1. Garder en mémoire tous les nombres essayés par l'utilisateur

Toutes les tentatives de l'utilisateur doivent maintenant être stockées dans une variable.

- Objets utilisables :
  - "Array"
  - "ArrayList"
  - "Generic.List[T]"
  - **En natif PowerShell "$array = do{}until()"**
- Nom de variable : "allAnswers"

<details>
  <pre><code>
    # 3a. Avec "Array"
    $allAnswers = @()
    $allAnswers += $answer

    # 3b. Avec "ArrayList"
    $allAnswers = [System.Collections.ArrayList]@()
    $allAnswers.Add($answer)

    # 3c. Avec "Generic.List[T]"
    $allAnswers = [System.Collections.Generic.List[int]]@()
    $allAnswers.Add($answer)

    # 3d. En natif
    $allAnswers = do { <#...#> $answer } until (<#...#>) 
  </code></pre>
</details>

### 2. Affichage de tous les nombres essayés

On modifie l'objet de fin pour remplacer la propriété "Answer" par "Answers" qui contient tous les nombres essayés. 

- Objet "PSCustomObject"
- Propriété "answers"

<details>
  <pre><code>
    [PSCustomObject]@{
        "Random"  = $random
        "Answers" = $allAnswers
        "Count"   = $i
    }
  </code></pre>
</details>

### 3. Calcul de la réponse moyenne

Avec tous les nombres essayés par l'utilisateur, on va calculer la valeur moyenne de ses réponses. Par exemple : (500+750+875+800+850+862)/6 = 772,833

- Méthodes possibles :
  - **Commande "Measure-Object"**
  - Opérateur "-join" et commande "Invoke-Expression"

<details>
  <pre><code>
    ($allAnswers | Measure-Object -Average).Average

    (Invoke-Expression ($allAnswers -join "+")) / $i
  </code></pre>
</details>

### 4. Affichage de la réponse moyenne

Afficher la réponse moyenne arrondie à l'unité dans l'objet de fin.

- Propriété "Average answer"
- Type "[int]"

<details>
  <pre><code>
    [PSCustomObject]@{
        "Random"         = $random
        "Answers"        = $allAnswers
        "Average answer" = [int]($allAnswers | Measure-Object -Average).Average
        "Count"          = $i
    }
  </code></pre>
</details>

## Correction

```powershell

$i = 0
$random = Get-Random -Minimum 1 -Maximum 1000
$allAnswers = do {
    $i++
    $answer = Read-Host "Deviner le nombre"
    $answer
    if ($random -gt $answer) { 
        Write-Host "??? est plus grand que $answer"
    } elseif ($random -lt $answer) {
        Write-Host "??? est plus petit que $answer"
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
        <a href="/2022/10/21/cours-pratique-posh-2">← Partie 2</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/26/cours-pratique-posh-4">Partie 4 →</a>
    </div>
</div>