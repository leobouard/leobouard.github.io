---
layout: post
title: "Partie 7 - Highscores"
description: "Le résultat de chaque victoire est maintenant conservé dans un fichier externe pour stocker toutes les tentatives du joueur"
icon: 🎓
nextLink:
  name: "Partie 8"
  id: "/2022/12/01/cours-pratique-powershell-008"
prevLink:
  name: "Partie 6"
  id: "/2022/12/01/cours-pratique-powershell-006"
---

## Consigne

### Résultat attendu

> Joueur                    : john.smith\
> Date                      : 01/12/2022 12:00:00\
> Nombre aléatoire          : 20\
> Réponses                  : 500,250,125,75,50,25,15,20\
> Réponse moyenne           : 132\
> Temps de résolution (sec) : 10,027\
> Temps moyen par tentative : 1,253\
> Tentatives                : 8\
> Mode facile               : True\
> \
> Voulez-vous voir les meilleurs scores?\
> [O] Oui  [N] Non  [?] Aide (la valeur par défaut est « N ») :

---

## Etape par étape

1. Modification et stockage dans une variable de l'objet de fin
2. Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores
3. Sauvegarder le score dans un fichier CSV
4. Demander au joueur si il veut voir le tableau
5. Afficher le tableau des meilleurs scores

### Modification et stockage dans une variable de l'objet de fin

On va maintenant vouloir stocker l'objet de fin dans une variable `$stats` pour pouvoir l'utiliser dans différents contextes. On prépare également le formatage des données pour pouvoir les stocker efficacement dans un fichier externe (CSV) :

1. Ajouter la propriété "Joueur" qui contient le nom de l'utilisateur actuel Windows accessible avec la variable d'environnement `$env:USERNAME`
2. Ajouter la propriété "Date" qui contient la date et l'heure de la partie. On utilise donc la commande `Get-Date` et on format l'affichage avec le paramètre `-Format` et la valeur de paramètre `G` qui permet d'obtenir une date au format "31/12/2022 23:59:59"
3. Modifier la propriété "Réponses" pour transformer l'objet en chaine de caractères avec l'opérateur `-join` pour mieux l'exporter en CSV

```powershell
$stats = [PSCustomObject]@{
    "Joueur"   = $env:USERNAME
    "Date"     = Get-Date -Format G
    "Réponses" = $allAnswers -join ','
}
```

### Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores

On ajoute un nouveau paramètre `-HighscorePath` du type `[IO.FileInfo]` qui contient le chemin vers le fichier CSV qui contiendra les highscores.

```powershell
param([IO.FileInfo]$HighscorePath = "$PSScriptRoot\highscore.csv")
```

### Sauvegarder le score dans un fichier CSV

Avec la commande `Export-Csv`, on va ajouter une nouvelle ligne au fichier qui contient les meilleurs scores. Détail des paramètres utilisés :

- `-Path` pour indiquer l'emplacement du fichier CSV
- `-Encoding` pour spécifier le type d'encodage (en l'occurence : "UTF8")
- `-Delimiter` pour indiquer quel caractère doit être utilisé pour séparer les valeurs entre-elles (dans notre cas, le point-virgule)
- `-NoTypeInformation` pour éviter d'avoir le type d'objet d'origine en première ligne du CSV (par exemple : `#TYPE System.Management.Automation.PSCustomObject`)
- `-Append` pour ne faire qu'ajouter une nouvelle ligne au fichier CSV au lieu d'écraser toutes les données
- `-Force` pour éviter les erreurs si jamais vous faites des modifications sur l'objet

```powershell
$stats | Export-Csv -Path $HighscorePath -Encoding UTF8 -Delimiter ';' -NoTypeInformation -Append -Force
```

### Demander au joueur si il veut voir le tableau

Pour demander au joueur si il veut voir le tableau des meilleurs score, on va utiliser `$Host.UI.PromptForChoice()` avec les paramètres suivants (dans l'ordre) :  

1. Le titre
2. La question à poser 
3. Les différents choix possibles sous forme d'un array où chaque option commence par `&`
4. L'option par défaut (commence à 0)

```powershell
$question = 'Voulez-vous voir les meilleurs scores?'
$choices  = '&Oui', '&Non'
$decision = $Host.UI.PromptForChoice($null, $question, $choices, 1)
```

### Afficher le tableau des meilleurs scores

Si le premier choix est selectionné par le joueur, alors on récupère le contenu du fichier CSV avec la commande `Import-Csv` pour l'afficher ensuite avec la commande `Out-GridView`.

```powershell
if ($decision -eq 0) {
    Import-Csv -Path $HighscorePath -Delimiter ';' -Encoding UTF8 | Out-GridView -Title "Meilleurs scores"
}
```

## Correction

```powershell
param(
    [switch]$EasyMode,
    [IO.FileInfo]$HighscorePath = "$PSScriptRoot\highscore.csv"
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

$stats = [PSCustomObject]@{
    "Joueur"                    = $env:USERNAME
    "Date"                      = Get-Date -Format G
    "Nombre aléatoire"          = $random
    "Réponses"                  = $allAnswers -join ','
    "Réponse moyenne"           = [int]($allAnswers | Measure-Object -Average).Average
    "Tentatives"                = $i
    "Temps de résolution (sec)" = [System.Math]::Round($stopwatch.Elapsed.TotalSeconds,3)
    "Temps moyen par tentative" = [System.Math]::Round(($stopwatch.Elapsed.TotalSeconds / $i),3)
    "Mode facile"               = $EasyMode.IsPresent
}
$stats | Write-Output

if ($answer -ne $random) { 
    Write-Host "DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire"
} else {
    $stats | Export-Csv -Path $HighscorePath -Encoding UTF8 -Delimiter ';' -NoTypeInformation -Append -Force
}

$question = 'Voulez-vous voir les meilleurs scores?'
$choices  = '&Oui', '&Non'
$decision = $Host.UI.PromptForChoice($null, $question, $choices, 1)

if ($decision -eq 0) {
    Import-Csv -Path $HighscorePath -Delimiter ';' -Encoding UTF8 | Out-GridView -Title "Meilleurs scores"
}
```
