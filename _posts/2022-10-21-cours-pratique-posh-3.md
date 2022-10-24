---
layout: post
title: "Partie 3"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

L'utilisateur possède maintenant jusqu'à 10 tentatives pour deviner le nombre aléatoire. Si l'utilisateur échoue à deviner le nombre, un message de défaite apparait. A la fin du script, le nombre de tentatives nécessaires est affiché avec les autres statistiques.

## Détails

### 1. Mettre le code dans une boucle

On va maintenant mettre le code qu'on a produit jusqu'ici dans une boucle pour pouvoir donner un peu plus qu'un seul essai. L'idée est de demande un nombre à l'utilisateur jusqu'à ce qu'il trouve le nombre aléatoire.

- Boucles possibles :
  - boucle "while(){}"
  - boucle "do{}while()"
  - **boucle "do{}until()"**

<details>
  <pre><code>
    while ($answer -ne $random) { <#[...]#> }

    do { <#[...]#> } while ($answer -ne $random)

    do { <#[...]#> } until ($answer -eq $random)
  </code></pre>
</details>

### 2. Ajouter un compteur de tentatives

Compter le nombre de tentatives. Vous pouvez partir de 0 ou de 1, c'est votre choix.

- Nom de variable : "i"
- Opérateur "++"

<details>
  <pre><code>
    $i = 1
    $i++
  </code></pre>
</details>

### Point bonus : utilisation de la boucle "for()"

On peut utiliser la boucle "for(){}" pour boucler et compter dans le même temps. Cette méthode ne sera pas conservée dans la correction.

- Boucle : "for(){}"

<details>
  <pre><code>
    for ($i = 1 ; $i++ ; $answer -ne $random) { <#[...]#> }
  </code></pre>
</details>

### 3. Sortir de la boucle après 10 tentatives

On augmente la difficulté pour le joueur : il dispose maintenant de 10 essais maximum pour trouver le nombre aléatoire. Si l'utilisateur dépasse 10 tentatives, on sort de la boucle.

- **Opérateur "-or"**
- Commande "break"

<details>
  <pre><code>
    do { <#[...]#> } until ($answer -eq $random -or $i -ge 10)
   
    if ($i -ge 10) { break }
  </code></pre>
</details>

### 4. Affichage d'un message de défaite

Si le joueur n'a pas trouvé le nombre aléatoire au bout de 10 tentatives, afficher un message de défaite.

<details>
  <pre><code>
    if ($answer -ne $random) { Write-Host "DEFAITE" }
  </code></pre>
</details>

### 5. Affichage du nombre de tentatives

Dans l'objet affiché à la fin, on ajoute le nombre de tentatives de l'utilisateur. 

- Objet "PSCustomObject"

<details>
  <pre><code>
    [PSCustomObject]@{
        "Random" = $random
        "Answer" = $answer
        "Count"  = $i
    } | Format-List
  </code></pre>
</details>

## Correction

```powershell

$i = 1
$random = Get-Random -Minimum 1 -Maximum 1000
do {
    $answer = Read-Host "Deviner le nombre"
    if ($random -gt $answer) { 
        Write-Host "??? est plus grand que $answer"
    } elseif ($random -lt $answer) {
        Write-Host "??? est plus petit que $answer"
    } else {
        Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
    }
    $i++
} until ($answer -eq $random -or $i -ge 10)

if ($answer -ne $random) { 
    Write-Host "DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire"
}

[PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
    "Count"  = $i
} | Format-List

```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/21/cours-pratique-posh-2">← Partie 2</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/21/cours-pratique-posh-4">Partie 4 →</a>
    </div>
</div>