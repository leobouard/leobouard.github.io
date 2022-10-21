---
layout: post
title: "Partie 1 - Simple. Basique."
---

1. Générer un nombre entier aléatoire entre 1 et 1000 (commande "Get-Random")

<details>
    <summary>Réponse</summary>
`Get-Random -Minimum 1 -Maximum 1000`
</details>

2. Stocker le nombre aléatoire dans une variable

<details>
`$random = Get-Random -Minimum 1 -Maximum 1000`
</details>

1. Demander à l'utilisateur de deviner le nombre (commande "Read-Host")

`$answer = Read-Host "Deviner le nombre"`

1. Vérifier si le nombre aléatoire est strictement supérieur ou inférieur au nombre de l'utilisateur (opérateurs de comparaison "-gt" et "-lt")
$random -gt $answer ; $answer -lt $random
$random -lt $answer ; $answer -gt $random

5. Comparaison 1 : afficher un message pour dire que le nombre aléatoire est plus grand que le nombre de l'utilisateur (commande "Write-Host" et condition "if(){}")
if ($random -gt $answer) { Write-Host "??? est plus grand que $answer" }

6. Comparaison 2 : afficher un message pour dire que le nombre aléatoire est plus petit que le nombre de l'utilisateur (commande "Write-Host" et condition "elseif(){}")
elseif ($random -lt $answer) { Write-Host "??? est plus petit que $answer" }

7. Comparaison 3 : afficher un message de victoire si le nombre aléatoire est égal au nombre de l'utilisateur (commande "Write-Host" et condition "else{}")
else { Write-Host "VICTOIRE ! Vous avez devinez le nombre aléatoire" }

8. Vérifier vos conditions en affichant un objet avec les membres "Random" et "Answer" (objet "PSCustomObject")
$result = [PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
}

9. Formater la vue de l'objet en mode liste (commande "Format-List")
$result | Format-List

## CORRECTION 

```powershell

$random = Get-Random -Minimum 1 -Maximum 1000
$answer = Read-Host "Deviner le nombre"
if ($random -gt $answer) { 
    Write-Host "??? est plus grand que $answer"
} elseif ($random -lt $answer) {
    Write-Host "??? est plus petit que $answer"
} else {
    Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
}
[PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
} | Format-List

```