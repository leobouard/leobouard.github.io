---
layout: post
title: "Partie 2 - En boucle en boucle en boucle"
description: "Mise en boucle du script pour permettre au joueur d'avoir 10 tentatives pour trouver un nombre aléatoire"
icon: 🎓
---

## Consigne

Le script est maintenant pourvu d'une boucle qui permet au joueur d'avoir 10 tentatives maximum pour deviner le nombre aléatoire. Le script se termine si l'une des deux conditions est remplie :

- le joueur a trouvé le nombre aléatoire (victoire)
- le joueur n'a pas réussi à trouver le nombre aléatoire en 10 tentatives (défaite)

A la fin du script, le nombre de tentatives est affiché avec les autres statistiques.

### Résultats attendus

Exemple de victoire :

> Deviner le nombre: 500\
> ??? est plus grand que 500\
> [...]\
> Deviner le nombre: 560\
> VICTOIRE ! Vous avez deviné le nombre aléatoire\
> \
> Random : 560\
> Answer : 560\
> Count  : 6

Exemple de défaite :

> Deviner le nombre: 500\
> ??? est plus grand que 500\
> [...]\
> Deviner le nombre: 608\
> ??? est plus petit que 608\
> DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire\
> \
> Random : 606\
> Answer : 608\
> Count  : 10

---

## Etape par étape

1. Mettre le code dans une boucle
2. Ajouter un compteur de tentatives
3. Sortir de la boucle au bout de 10 tentatives
4. Affichage d'un message de défaite
5. Affichage du nombre de tentatives

### Mettre le code dans une boucle

Pour permettre au joueur d'avoir plusieurs tentatives, le plus simple est de mettre le code dans une boucle. Plusieurs types de boucles sont utilisables dans notre exemple, suivant notre condition de sortie.

- boucle `while` : tant que le joueur n'a pas trouvé le nombre aléatoire, on reste dans la boucle
- boucle `do/while` : on reste dans la boucle tant que le joueur n'a pas trouvé le nombre aléatoire
- **boucle `do/until`** : on reste dans la boucle jusqu'à ce que le joueur trouve le nombre aléatoire

Pour le script exemple, j'ai choisi la boucle `do/until`.

```powershell
while ($answer -ne $random) { <#[...]#> }
do { <#[...]#> } while ($answer -ne $random)
do { <#[...]#> } until ($answer -eq $random)
```

### Ajouter un compteur de tentatives

Cette étape se décompose en deux parties : 

1. hors de la boucle : initier le compteur en créant une nouvelle variable `$i` dont la valeur initiale est 0 (par exemple)
2. dans la boucle : incrémenter la variable à chaque nouvelle tentative avec l'opérateur `++`

```powershell
$i = 0
do { 
    $i++
} until ($answer -eq $random)
```

<!--
### Point bonus : utilisation de la boucle "for()"

On peut utiliser la boucle `for` pour boucler et compter dans le même temps. Cette méthode ne sera pas conservée dans la correction.

- Boucle : "for(){}"

```powershell
for ($i = 1 ; $i++ ; $answer -ne $random) { <#[...]#> }
```
-->

### Sortir de la boucle après 10 tentatives

On se base sur notre variable `$i` qui compte le nombre de tentatives et on ajoute une condition de sortie dans notre boucle `do/until` avec l'opérateur `-or` qui permet de joindre deux condition entre-elle : on reste dans la boucle jusqu'à ce que le joueur trouve le nombre aléatoire **ou** que le nombre de tentatives soit égal ou supérieur à 10.

```powershell
do {

} until ($answer -eq $random -or $i -ge 10)
```

### Affichage d'un message de défaite

A la fin de la boucle, si le joueur n'a pas trouvé le nombre aléatoire au bout de 10 tentatives, on affiche un message de défaite dans la console avec la commande `Write-Host`.

```powershell
if ($answer -ne $random) { Write-Host "DEFAITE" }
```

### Affichage du nombre de tentatives

Dans le `PSCustomObject` affiché à la fin, on ajoute une nouvelle propriété `Count` pour montrer le nombre de tentatives (variable `$i`) utilisées par le joueur.

```powershell
[PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
    "Count"  = $i
} | Format-List
```

## Correction

```powershell
$i = 0
$random = Get-Random -Minimum 1 -Maximum 1000
do {
    $i++
    $answer = Read-Host "Deviner le nombre"
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
    "Random" = $random
    "Answer" = $answer
    "Count"  = $i
} | Format-List
```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/21/cours-pratique-posh-1">← Partie 1</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/26/cours-pratique-posh-3">Partie 3 →</a>
    </div>
</div>