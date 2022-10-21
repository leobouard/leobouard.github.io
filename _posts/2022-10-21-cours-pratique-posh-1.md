---
layout: post
title: "Partie 1 - Simple. Basique."
---

## Résumé

Un nombre aléatoire est généré et l'utilisateur doit entrer son estimation. L'utilisateur n'a qu'un seul essai. Si le nombre de l'utilisateur est plus petit ou plus grand que le nombre aléatoire, alors un message est affiché pour situer la comparaison entre les deux nombres (X plus grand que Y ou inversement). Si le nombre aléatoire est égal à l'estimation de l'utilisateur, alors on déclare la victoire. A la fin du script, le nombre aléatoire et l'estimation de l'utilisateur sont affichées sous la forme d'un objet au format liste.

![Vidéo du script à l'issue de la première partie](cours-pratique-partie-1.gif)

## Détails

### 1. Générer un nombre aléatoire

La première pierre est posée : la génération du nombre aléatoire qui doit être deviné par le joueur !

- Commande utilisée : "Get-Random"
- Valeur obtenue : nombre entier en 1 et 1000

<details>
  <pre><code>
    Get-Random -Minimum 1 -Maximum 1000
  </code></pre>
</details>

### 2. Stocker le nombre aléatoire dans une variable

- Nom de variable : "random"

<details>
  <pre><code>
    $random = Get-Random -Minimum 1 -Maximum 1000
  </code></pre>
</details>

### 3. Demander à l'utilisateur de deviner le nombre

On va maintenant inviter le joueur / l'utilisateur a entrer son estimation.

- Commande utilisée : "Read-Host"
- Nom de variable : "answer"

<details>
  <pre><code>
    $answer = Read-Host "Deviner le nombre"
  </code></pre>
</details>

### 4. Comparer le nombre aléatoire au nombre de l'utilisateur

Vérifier si le nombre aléatoire est strictement supérieur ou inférieur au nombre de l'utilisateur.

- Opérateurs de comparaison "-gt" et "-lt"

<details>
  <pre><code>
    # Aléatoire est supérieur au nb utilisateur
    $random -gt $answer
    $answer -lt $random
    # Aléatoire est plus petit que nb utilisateur
    $random -lt $answer
    $answer -gt $random
  </code></pre>
</details>

### 5. Comparaison 1 

Afficher un message pour dire que le nombre aléatoire est plus grand que le nombre de l'utilisateur 

- Commande "Write-Host"
- Condition "if(){}"

<details>
  <pre><code>
    if ($random -gt $answer) { Write-Host "??? est plus grand que $answer" }
  </code></pre>
</details>

### 6. Comparaison 2

Afficher un message pour dire que le nombre aléatoire est plus petit que le nombre de l'utilisateur

- Commande "Write-Host"
- Condition "elseif(){}"

<details>
  <pre><code>
    elseif ($random -lt $answer) { Write-Host "??? est plus petit que $answer" }
  </code></pre>
</details>

### 7. Comparaison 3

Afficher un message de victoire si le nombre aléatoire est égal au nombre de l'utilisateur

- Commande "Write-Host"
- Condition "else{}"

<details>
  <pre><code>
    else { Write-Host "VICTOIRE ! Vous avez devinez le nombre aléatoire" }
  </code></pre>
</details>

### Vérification des conditions

A la fin de votre script, afficher un objet avec les membres "Random" et "Answer"

- Objet "PSCustomObject"

<details>
  <pre><code>
    $result = [PSCustomObject]@{
        "Random" = $random
        "Answer" = $answer
    }
  </code></pre>
</details>

### Formater la vue en mode liste

Par défaut, l'objet va s'afficher sous forme de tableau (puisqu'il n'y a que deux valeurs). Il faut donc forcer un affichage sous forme de liste.

- Commande "Format-List"

<details>
  <pre><code>
    $result | Format-List
  </code></pre>
</details>

## Correction 

Encore une fois un petit rappel : il n'y a pas une seule bonne méthode donc si votre script ne ressemble pas au mien mais qu'il fonctionne, tant-mieux !

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