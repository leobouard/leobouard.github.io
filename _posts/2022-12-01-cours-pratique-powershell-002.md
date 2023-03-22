---
layout: post
title: "Cours PowerShell #2 - En boucle en boucle en boucle"
description: "Mise en boucle du script pour permettre au joueur d'avoir 10 tentatives pour trouver un nombre aléatoire"
icon: 🎓
nextLink:
  name: "Partie 3"
  id: "/2022/12/01/cours-pratique-powershell-003"
prevLink:
  name: "Partie 1"
  id: "/2022/12/01/cours-pratique-powershell-001"
---

## Consigne

Le script est maintenant pourvu d'une boucle qui permet au joueur d'avoir 10 tentatives maximum pour deviner le nombre aléatoire. Le script se termine si l'une des deux conditions est remplie :

- le joueur a trouvé le nombre aléatoire (victoire)
- le joueur n'a pas réussi à trouver le nombre aléatoire en 10 tentatives (défaite)

À la fin du script, le nombre de tentatives est affiché avec les autres statistiques.

### Résultats attendus

Exemple de victoire :

> Deviner le nombre: 500\
> ??? est plus grand que 500\
> [...]\
> Deviner le nombre: 560\
> VICTOIRE ! Vous avez deviné le nombre aléatoire\
> \
> Nombre aléatoire : 560\
> Dernière réponse : 560\
> Tentatives       : 6

Exemple de défaite :

> Deviner le nombre: 500\
> ??? est plus grand que 500\
> [...]\
> Deviner le nombre: 608\
> ??? est plus petit que 608\
> DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire\
> \
> Nombre aléatoire : 606\
> Dernière réponse : 608\
> Tentative        : 10

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

### Sortir de la boucle après 10 tentatives

Le plus simple est d'ajouter une deuxième condition de sortie à notre boucle `do/until`. Pour créer et ajouter cette deuxième condition, on peut se baser sur :

- la variable `$i` qui contient le nombre de tentatives du joueur
- les opérateurs de comparaison `-eq` (*equals*, est égal à) ou `-ge` (*greater or equals*, supérieur ou égal à)
- l'opérateur logique `-or` qui permet de joindre deux conditions entre-elles

On arrive à la double condition suivante : "on reste dans la boucle jusqu'à ce que le joueur trouve le nombre aléatoire **ou** que le nombre de tentatives soit égal ou supérieur à 10", que l'on peut ensuite ajouter à notre boucle `do/until`.

```powershell
do {

} until ($answer -eq $random -or $i -ge 10)
```

<div class="information">
    <span>Autre possibilité : la boucle For</span>
    <p>Pour réaliser la boucle, le compteur et la condition de sortie en une seule commande, il est possible d'utiliser la boucle <code>for</code>. Celle-ci peut s'avérer très utile dans certains cas (comme celui-ci) mais reste très rare en PowerShell.<br>Si cela vous intéresse, vous pouvez consulter la documentation disponible ici : <a href="https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_for" target="_blank">à propos de For - PowerShell | Microsoft Learn →</a></p>
</div>

### Affichage d'un message de défaite

A la fin de la boucle, si le joueur n'a pas trouvé le nombre aléatoire, on affiche un message de défaite dans la console avec la commande `Write-Host`. La condition avant l'affichage du message permet d'éviter le double message "VICTOIRE" puis "DEFAITE".

```powershell
if ($answer -ne $random) { Write-Host "DEFAITE" }
```

### Affichage du nombre de tentatives

Dans le `PSCustomObject` affiché à la fin, on ajoute une nouvelle propriété `Count` pour montrer le nombre de tentatives (variable `$i`) utilisées par le joueur.

```powershell
[PSCustomObject]@{
    "Tentatives" = $i
} | Format-List
```

## Correction

<details>
    <summary>Voir la solution</summary>
    <a href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-002.ps1">cours-pratique-powershell-002.ps1</a>
</details>