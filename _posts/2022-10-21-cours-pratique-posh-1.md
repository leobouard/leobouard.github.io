---
layout: post
title: "Partie 1 - Simple. Basique."
---

## 1. Générer un nombre entier aléatoire entre 1 et 1000

La première pierre est posée : la génération du nombre aléatoire qui doit être deviné par le joueur !

- Commande utilisée : "Get-Random"

<details>

`Get-Random -Minimum 1 -Maximum 1000`

</details>

## 2. Stocker le nombre aléatoire dans une variable

- Nom de variable : "random"

<details>

`$random = Get-Random -Minimum 1 -Maximum 1000`

</details>

## 3. Demander à l'utilisateur de deviner le nombre (commande "Read-Host")

On va maintenant inviter le joueur / l'utilisateur a entrer son estimation.

- Commande utilisée : "Read-Host"
- Nom de variable : "answer"

<details>

`$answer = Read-Host "Deviner le nombre"`

</details>

## 4. Comparer le nombre aléatoire au nombre de l'utilisateur

Vérifier si le nombre aléatoire est strictement supérieur ou inférieur au nombre de l'utilisateur.

- Opérateurs de comparaison "-gt" et "-lt"

<details>

```powershell

# Aléatoire est supérieur au nb utilisateur
$random -gt $answer
$answer -lt $random
# Aléatoire est plus petit que nb utilisateur
$random -lt $answer
$answer -gt $random

```

</details>

## 5. Comparaison 1 : afficher un message pour dire que le nombre aléatoire est plus grand que le nombre de l'utilisateur 

- Commande "Write-Host"
- Condition "if(){}"

<details>

```powershell

if ($random -gt $answer) { Write-Host "??? est plus grand que $answer" }

```

</details>

## 6. Comparaison 2 : afficher un message pour dire que le nombre aléatoire est plus petit que le nombre de l'utilisateur

- Commande "Write-Host"
- Condition "elseif(){}"

<details>

```powershell

elseif ($random -lt $answer) { Write-Host "??? est plus petit que $answer" }

```

</details>

1. Comparaison 3 : afficher un message de victoire si le nombre aléatoire est égal au nombre de l'utilisateur (commande "Write-Host" et condition "else{}")
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


<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/21/cours-pratique-posh-0">Précédent : Introduction</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/21/cours-pratique-posh-2">Suivant : Partie 2</a>
    </div>
</div>