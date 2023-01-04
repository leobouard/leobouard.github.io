---
layout: post
title: "Cours PowerShell #6 - EasyMode"
description: "On ajoute un paramètre qui permet de diminuer la difficulté du jeu en faisant en sorte que le nombre aléatoire soit toujours un mutliple de 5"
icon: 🎓
nextLink:
  name: "Partie 7"
  id: "/2022/12/01/cours-pratique-powershell-007"
prevLink:
  name: "Partie 5"
  id: "/2022/12/01/cours-pratique-powershell-005"
---

## Consigne

Ajouter un mode facile au script qui permet de modifier la génération du nombre aléatoire. En mode facile, le nombre aléatoire est forcément un multiple de 5 (par exemple : 145, 730 ou 855). Pour utiliser le mode facile du script, il faut simplement spécifier le paramètre `-EasyMode` lors de son exécution.

### Résultat attendu

> .\script.ps1 -EasyMode

---

## Etape par étape

1. Ajouter le paramètre au script
2. Générer un nombre aléatoire "facile" à deviner
3. Modifier la génération du nombre aléatoire en mode facile
4. Ajouter la difficulté dans l'objet de fin

### Ajouter le paramètre au script

Je vous recommande fortement de lire l'article [about_Parameters - PowerShell \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parameters) si vous n'êtes pas familier avec le passage de paramètres dans PowerShell. 

Notre besoin est relativement simple : si le paramètre `-EasyMode` du script est invoqué, alors on modifie la génération du nombre aléatoire, sinon on ne change rien. Il s'agit donc d'un paramètre du type `[switch]` (soit il est présent, soit il est absent).

```powershell
param([switch]$EasyMode)
```

### Générer un nombre aléatoire "facile" à deviner

Comme indiqué dans la consigne, le nombre aléatoire généré en mode facile sera obligatoirement un multiple de 5. Pour ça, le plus simple reste de générer un nombre aléatoire jusqu'à ce que celui-ci corresponde au critère. C'est pas très économique en ressource, mais c'est la façon la plus simple et compacte que j'ai trouvée.

Pour vérifier qu'un nombre est un multiple, on utilise le modulo `%` (à ne pas confondre avec l'alias de `ForEach-Object`). Si le résultat est égal à 0, alors le nombre est bien multiple de 5.

On génère alors le nombre aléatoire jusqu'à trouver un multiple de 5 en mettant le `Get-Random` dans une boucle du type `while`. L'avantage de la boucle `while` est que l'on entre dans celle-ci uniquement si la condition de départ est remplie. Si le nombre aléatoire est déjà un multiple de 5, pas besoin de faire de traitement supplémentaire.

```powershell
while ($random % 5 -ne 0) { $random = Get-Random -Min $min -Max $max }
```

### Modifier la génération du nombre aléatoire en mode facile

Pour savoir si le paramètre `-EasyMode` a été invoqué, il suffit de vérifier la valeur de la propriété `IsPresent` sur la variable associée :

- si la valeur est "vrai" : le paramètre a été invoqué
- si la valeur est "faux" : le paramètre est absent

```powershell
if ($EasyMode.IsPresent) {
    # Génération du nombre aléatoire "facile" à deviner
}
```

### Ajouter la difficulté dans l'objet de fin

Même chose dans l'affichage de l'information, on utilise simplement la propriété `IsPresent` :

```powershell
[PSCustomObject]@{
    "Mode facile" = $EasyMode.IsPresent
}
```

## Correction

```powershell
param(
    [switch]$EasyMode
)

$i          = 0
$min        = 1
$max        = 1000
$allAnswers = [System.Collections.Generic.List[int]]@()
$stopwatch  = [System.Diagnostics.Stopwatch]::New()
$random     = Get-Random -Minimum $min -Maximum $max

if ($EasyMode.IsPresent) {
    while ($random % 5 -ne 0) { $random = Get-Random -Min $min -Max $max }
}

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

$stopwatch.Stop()

if ($answer -ne $random) { 
    Write-Host "DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire"
}

[PSCustomObject]@{
    "Nombre aléatoire"          = $random
    "Réponses"                  = $allAnswers
    "Réponse moyenne"           = [int]($allAnswers | Measure-Object -Average).Average
    "Tentatives"                = $i
    "Temps de résolution (sec)" = [System.Math]::Round($stopwatch.Elapsed.TotalSeconds,3)
    "Temps moyen par tentative" = [System.Math]::Round(($stopwatch.Elapsed.TotalSeconds / $i),3)
    "Mode facile"               = $EasyMode.IsPresent
} | Format-List
```
