---
layout: post
title: "Cours PowerShell #3 - Historique de navigation"
description: "Toutes les tentatives du joueur sont gardées en mémoire pour pouvoir afficher plus d'informations sur la partie"
icon: 🎓
nextLink:
  name: "Partie 4"
  id: "/2022/12/01/cours-pratique-powershell-004"
prevLink:
  name: "Partie 2"
  id: "/2022/12/01/cours-pratique-powershell-002"
---

## Consigne

Toutes les tentatives du joueur sont maintenant gardées en mémoire et l'objet de fin est modifié en conséquence :

- on remplace la dernière tentative par une liste contenant toutes les tentatives
- on affiche maintenant la valeur moyenne de toutes les tentatives du joueur (arrondie à l'entier)

### Résultat attendu

> Deviner le nombre: 500\
> ??? est plus grand que 500\
> [...]\
> VICTOIRE ! Vous avez deviné le nombre aléatoire\
> \
> Nombre aléatoire : 939\
> Réponses         : {500, 750, 900, 950...}\
> Réponse moyenne  : 864\
> Tentatives       : 9

---

## Etape par étape

1. Garder en mémoire toutes les estimations du joueur
2. Afficher toutes les tentatives
3. Calculer l'estimation moyenne
4. Afficher l'estimation moyenne

### Garder en mémoire toutes les estimations du joueur

Cette étape se décompose en deux parties :

1. hors de la boucle : créer la variable `$allAnswers` de type tableau ou liste qui va permettre de contenir toutes les estimations du joueur
2. dans la boucle : l'ajout de l'estimation du joueur dans cette variable

Pour créer une variable de type tableau ou liste (c'est-à-dire qui contient plusieurs valeurs homogènes), plusieurs choix s'offrent à vous :

- Array : `$array = @()`
- ArrayList : `$array = [System.Collections.ArrayList]@()`
- Pipeline : `$array = 1..10 | % { $_ }`
- **List\<T\>** : `$list = [System.Collections.Generic.List[int]]@()`

Pour vous aider à faire votre choix, je vous recommande vivement de lire l'article suivant : [Building Arrays and Collections in PowerShell \| Clear-Script](https://vexx32.github.io/2020/02/15/Building-Arrays-Collections/) qui fait un comparatif entre les différentes méthodes et qui explique le fonctionnement de chacune.

En résumé, il est recommandé d'utiliser les List\<T\> pour les performances et le pipeline pour la simplicité d'utilisation et la compatibilité. Pour ma part, j'ai choisi une List\<T\>.

Une fois dans la boucle, il ne reste plus qu'à ajouter des valeurs dans notre variable. Dans ce cas, la méthode varie suivant votre choix :

- Array : `$array += 1`
- ArrayList : `$null = $array.Add(1)`
- Pipeline : `$array = 1..10 | % { $_ }`
- **List\<T\>** : `$list.Add(1)`

```powershell
# a. Avec "Array"
$allAnswers = @()
do {
    $allAnswers += $answer
} until ()

# b. Avec "ArrayList"
$allAnswers = [System.Collections.ArrayList]@()
do {
    $allAnswers.Add($answer)
} until ()

# c. Avec le pipeline
$allAnswers = do {
    $answer
} until ()

# d. Avec "List<T>"
$allAnswers = [System.Collections.Generic.List[int]]@()
do {
    $allAnswers.Add($answer)
}
until ()
```

### Afficher toutes les tentatives

Dans le `PSCustomObject` affiché à la fin, on modifie la propriété `Réponse` en `Réponses` qui contient toutes les réponses (variable `$allAnswers`) du joueur.

```powershell
[PSCustomObject]@{
    "Nombre aléatoire"  = $random
    "Réponses" = $allAnswers
    "Tentatives"   = $i
}
```

### Calculer l'estimation moyenne

Avec toutes les réponses du joueur stockées dans une variable, on va maintenant calculer la valeur moyenne de toutes ses réponses. Par exemple : (500+750+875+800+850+862)/6 = 772,833. On peut le faire facilement en PowerShell avec la commande `Measure-Object` et le paramètre `-Average`.

```powershell
($allAnswers | Measure-Object -Average).Average
```

### Afficher l'estimation moyenne

Dans le `PSCustomObject` affiché à la fin, on ajoute une nouvelle propriété `Réponse moyenne` pour montrer la valeur moyenne des tentatives du joueur arrondie à l'entier.

Pour arrondir un nombre décimal en PowerShell, le plus simple est de le convertir en utilisant le type `[int]`. Il est également possible d'utiliser la méthode `[math]:Round()`, que l'on utilisera plus tard.

```powershell
[PSCustomObject]@{
    "Réponse moyenne" = [int]($allAnswers | Measure-Object -Average).Average
}
```

## Correction

<details>
    <summary>Voir la solution</summary>
    <a href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-003.ps1">cours-pratique-powershell-003.ps1</a>
</details>