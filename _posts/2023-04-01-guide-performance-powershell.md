---
layout: post
title: "Petit guide sur la performance en PowerShell"
description: "Tout savoir sur l'optimisation des performances sur vos scripts PowerShell"
tags: powershell
listed: true
---

## Bien choisir ses tableaux

Je le connais, vous le connaissez, tout le monde le connait et l'utilise. Et pourtant, c'est la méthode la moins performante que l'on puisse choisir !

```powershell
$array = @()
1..10 | % { $array += $_ }
```

Comment ça marche ? Et bien la syntaxe très simple cache en fait un fonctionnement assez complexe.

Avec `@()`, vous allez créer une collection de taille fixe avec une capacité maximum de 0 élément. Comment agrandir la collection alors ? Grâce à l'opérateur `+=`, on ne va pas ajouter un élément à la collection existante (puisque ce n'est pas possible) mais plutôt :

- créer une nouvelle collection de taille fixe avec une capacité suffisante pour accueillir tous les éléments de l'ancienne collection + 1
- peupler la nouvelle collection en additionnant entre eux les éléments de l'ancienne collection et le nouvel élément à ajouter
- supprimer l'ancienne collection

En bref : un processus bien plus complexe que la syntaxe ne peut le laisser deviner. Pour résumé, le `+=` pourrait être expliqué avec la syntaxe suivante :

```powershell
$array = @()
1..10 | % { $array = $array + @($_)}
```

Si vous voulez tout comprendre, voici l'article original : [Building Arrays and Collections in PowerShell \| Clear-Script](https://vexx32.github.io/2020/02/15/Building-Arrays-Collections/)

Lorsque vous créer un array avec cette méthode, vous allez générer un tableau d'une taille fixe qui peut contenir un maximum de 0 élément. Impossible donc d'y ajouter un membre avec la méthode `.Add()` qui donne l'erreur suivante : *Exception lors de l'appel de «Add» avec «1» argument(s): «La collection était d'une taille fixe.»*.

Comment faire pour ajouter un nouvel élément ? Avec l'opérateur `+=` voyons ! Et comment est-ce que cet opérateur fonctionne ? De la manière la plus simple possible.

Comme il n'est pas possible d'agrandir l'array existant (qui est d'une taille fixe), la solution est donc de créer un nouvel array 

PowerShell's + and += operators are designed to work with arrays in a relatively unusual way. When you try to add items to an array like this, what actually happens goes something like this:

PowerShell checks the size of the collection in $array and the number of items being added to it (in this case, just one each time).
PowerShell creates a completely different array of the correct size.
The original array is copied into this new array, along with the new item(s).
This is also why it's perfectly possible to join two arrays together with the + or += operators.


## Création d'objet

New-Object -TypeName 'psobject' ... vs [PSCustomObject]@{}

## Bien comprendre le pipeline

On lit souvent que `foreach` est plus performant que `ForEach-Object`, ce n'est pas tout à fait vrai : il s'agit simplement d'une utilisation différente.

La boucle `foreach` est en effet plus performante si toutes les données à traiter ont déjà été récupérées.

L'avantage et l'inconvénient du `ForEach-Object`, c'est qu'il s'utilise avec un pipeline. Le pipeline (qui pourrait être traduit grossièrement en *tuyau*) permet d'envoyer de la donnée dès qu'elle est disponible. Donc si vous faites une requête avec 10000 objets en résultat, le traitement via le pipeline permettra de commencer le travail dès que le premier objet est reçu.

Vous pouvez visualiser la différence avec les scripts suivants :

```powershell
function Test-Pipeline {
    1..100 | ForEach-Object { $_ ; Start-Sleep -Milliseconds 100 }
}

Test-Pipeline | ForEach-Object { 
    Write-Progress -Activity "Using 'ForEach-Object'" -PercentComplete $_
}

foreach ($_ in (Test-Pipeline)) { 
    Write-Progress -Activity "Using 'foreach()'" -PercentComplete $_
}
```

En résumé : si vous la liste de données à traiter est instantanément disponible (genre un fichier CSV), alors préférez l'utilisation de `foreach`. Si les données arrivent au fur et à mesure (comme pour une requête API par exemple), alors préférez le pipeline et `ForEach-Object`.

Pour tout savoir sur le pipeline : [Understanding PowerShell Pipeline \| PowerShell One](https://powershell.one/powershell-internals/scriptblocks/powershell-pipeline)

## Connaître son ennemi

Pour optimiser votre code, le plus important est d'identifier le goulot d'étranglement. Pour ça, vous pouvez utiliser la commande `Measure-Object` qui va mesurer le temps d'execution du code qui va se trouver entre les deux accolades. Certaines commandes sont plus gourmandes que d'autres (notamment les requêtes API, les cmdlet Exchange et Microsoft Graph) et le `Measure-Object` peut vous permettre de calculer précisément le temps d'execution global, pour faire ensuite une belle barre de progression avec `Write-Progress` (notamment via le paramètre `-SecondsRemaining`).

Voici un petit script qui permet de mesurer la durée moyenne d'exécution d'une commande ou d'un script PowerShell sur 100 itérations :

```powershell
$stats = foreach ($_ in 1..100) {
    Measure-Command -Expression { Get-LocalGroup }
}
$stats | Measure-Object -Property 'TotalSeconds' -Average
```

## Filtrer correctement

Tous les filtres ne se valent pas ! Une règle de base peut être facilement utilisée : faire les filtres les plus stricts (ceux qui éliminerons le plus d'objets) en amont. Moins votre collection sera grande, plus votre script sera performant.

Point bonus : si votre collection est composée de PSCustomObject, évitez de garder des propriétés inutile. L'idée c'est de raisonner en terme de poids total de votre collection, ce qui importe c'est le nombre d'objets et le nombre de propriétés par objet.

## Utiliser la parallélisation à bon escient

Avec l'arrivée de PowerShell v7, la commande `ForEach-Object` récupère un nouveau paramètre : `-Parallel`. Ce paramètre permet (comme son nom l'indique) de paralléliser et donc de diviser le temps de traitement par le nombre d'instances (en général : le nombre de CPU +1).

Si vous pouvez avoir accès à ce paramètre, vous pouvez l'utilisez pour diminuer le temps d'exécution de vos boucles `ForEach-Object`. Attention cependant : la parallélisation n'est pas "gratuite", et initier une nouvelle instance pour traiter un objet a un coût.

Ainsi, sur certaines boucles très rapides, vous ne verrez pas d'amélioration voir pire : une dégradation des performances. Si vous voulez vous amusez, vous pouvez tester la différence entre `ForEach-Object` et `ForEach-Object -Parallel` sur des commandes simples avec la fonction suivante :

```powershell
function Test-Parallel {
    param(
        [string]$Command = '$PSItem',
        [int]$Iteration = 100
    )

    $scriptA = "(Measure-Command { 1..$Iteration | ForEach-Object { $Command } }).TotalMilliseconds"
    $scriptB = $scriptA -replace 'ForEach-Object','ForEach-Object -Parallel'

    $statRef = Invoke-Expression $scriptA
    $statDif = Invoke-Expression $scriptB
    $dif = $statRef/$statDif
    if ($statRef -lt $statDif) {
        [int]$dif = (1-$dif)*100
        $slowerOrFaster = 'rapide'
    } else {
        [int]$dif = ($dif-1)*100
        $slowerOrFaster = 'lente'
    }
    Write-Host "La boucle sans parallélisation est $dif`% plus $slowerOrFaster que la boucle avec parallélisation"
}
```

## Utiliser les bons outils

Vous aurez beau optimiser votre code comme jamais et suivre toutes les bonnes pratiques possibles, un script exécuté avec Windows PowerShell 2.0 sera toujours moins performant qu'un même script exécuté en PowerShell v7. Les versions les plus récentes embarquent toujours leurs lot d'améliorations, autant au niveau des performances qu'au niveau des fonctionnalités.

Voici un comparatif de temps de traitement sur plusieurs scripts différents, exécutés sur la même machine, sur des données locales uniquement (moyenne sur 100 exécutions) :

Version | Script n°1 | Script n°2 | Script n°3
------- | ---------- | ---------- | ----------
PowerShell 2.0 | 65ms | 70ms | 85ms
PowerShell 5.1 | 49ms | 49ms | 70ms
PowerShell 7.3 | 15ms | 10ms | 14ms

On observe PowerShell 7.3 fonctionne en moyenne **4x plus rapidement** que son ancêtre PowerShell 2.0, avec un script identique (donc sans utiliser la parallélisation).

Pour suivre les dernières nouveautés de PowerShell : [Overview of what's new in PowerShell \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/overview?view=powershell-7.3)

## Se méfier de l'affichage dans la console

null = ... plutôt que Out-Null

N'importe quel type d'affichage dans une console va vous coûter du temps de traitement ! Que ce soit du `Format-Table`, du `Write-Progress` ou du `Write-Output` : rien à faire, vous perdrez en performance.

Cependant, avant de tomber dans le dogmatisme je tiens à préciser quelque chose d'important : la perte en temps vaut probablement le coup, et ça pour plusieurs raisons :

1. L'affichage dans la console est utile pour la journalisation et le débuggage d'un script. Un script qui s'exécute vite, c'est bien. Un script qui fonctionne et qui est facile à maintenir, c'est mieux !
2. Il ne faut pas sous-estimer la puissance d'une barre de progression pour le cerveau humain : le temps vous semblera infiniment moins long avec une barre qui se remplie petit à petit, plutôt qu'une console vierge qui ne montre pas le moindre signe de progression.
3. Priorisez l'optimisation de vos performances : supprimer tout affichage dans votre script ne le rendra probablement pas deux fois plus performant. Essayer de trouver la cause du ralentissement avant de dégommer tous les `Write-Output` de votre script, car il y a de grandes chances pour ça ne soit pas la cause principale.

## Manger ~~bio~~ local

Une requête AD pour obtenir 10000 utilisateurs est moins coûteuse que 10000 requêtes d'un seul utilisateur.

Morale de l'histoire : faire une grosse requête pour requêter ensuite à l'intérieur du résultat plutôt que de faire une requête à chaque fois.

Pour MSGraph : des rapports CSV sont disponibles (notamment pour les statistiques emails) qui permettent de gagner beaucoup de temps par rapport à des requêtes individuelles.

## Conclusion
