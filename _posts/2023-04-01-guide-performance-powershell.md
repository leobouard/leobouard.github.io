---
layout: post
title: "Petit guide sur la performance en PowerShell"
description: "Tout savoir sur l'optimisation des performances sur vos scripts PowerShell"
background: "#9bd3d3"
tags: powershell
listed: true
---

## Bien choisir ses tableaux

### Le cas du `+=`

Je le connais, vous le connaissez, tout le monde le connait et l'utilise. Et pourtant, c'est la méthode la moins performante que l'on puisse choisir !

```powershell
$array = @()
1..10 | % { $array += $_ }
```

Comment ça marche ? Et bien la syntaxe très simple cache en fait un fonctionnement assez complexe.

Avec `@()`, vous allez créer une collection de taille fixe avec une capacité maximum de 0 élément. Comment agrandir la collection alors ? En tout cas on ne peut pas y ajouter d'éléments aevc la méthode `.Add()` puisque celle-ci nous donne l'erreur : *Exception lors de l'appel de «Add» avec «1» argument(s): «La collection était d'une taille fixe.»*.

On va donc utiliser l'opérateur `+=`, qui ne va pas ajouter un élément à la collection existante (puisque ce n'est pas possible) mais plutôt :

1. Créer une nouvelle collection de taille fixe avec une capacité suffisante pour accueillir tous les éléments de l'ancienne collection + 1
1. Peupler la nouvelle collection en additionnant entre eux les éléments de l'ancienne collection et le nouvel élément à ajouter
1. Supprimer l'ancienne collection

En bref : un processus bien plus complexe que la syntaxe ne peut le laisser deviner. Pour résumer, le `+=` pourrait être expliqué avec la syntaxe suivante :

```powershell
$array = @()
1..10 | % { $array = $array + @($_)}
```

### Par quoi le remplacer ?

La solution est donnée dans l'article de blog cité plus haut, mais pour faire une version rapide, on peut retenir deux options :

1. Les tableaux `List<T>`
1. L'aspiration via pipeline

Voici un exemple rapide d'utilisation pour les deux méthodes :

```powershell
# List<T>
$list = [System.Collections.Generic.List[int]]@{}
1..100 | ForEach-Object { $list.Add($_) }

# Aspiration via pipeline
$list = 1..100 | ForEach-Object { $_ }
```

### Tableau comparatif

Voici un tableau qui récapitule vos options pour la création d'un tableau :

Méthode | Compatibilité | Performance | Simplicité | Fonctionnalités
------- | ------------- | ----------- | ---------- | ---------------
`@()` | 🟢 Bonne | 🔴 Mauvaise | 🟡 Moyenne | 🟡 Moyenne
`List<T>` | 🔴 Mauvaise | 🟢 Bonne | 🔴 Mauvaise | 🟢 Bonne
Aspiration via pipeline | 🟢 Bonne | 🟡 Moyenne | 🟢 Bonne | 🟡 Moyenne

Et si ça vous intéresse, je ne peux que vous recommander de lire l'article original : [Building Arrays and Collections in PowerShell \| Clear-Script](https://vexx32.github.io/2020/02/15/Building-Arrays-Collections/)

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

En résumé : si la liste de données à traiter est instantanément disponible (un fichier CSV par exemple), alors préférez l'utilisation de `foreach`. Si les données arrivent au fur et à mesure (comme pour une requête API par exemple), alors préférez le pipeline et `ForEach-Object`.

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

Point bonus : si votre collection est composée de PSCustomObject, évitez de garder des propriétés inutiles. L'idée c'est de raisonner en terme de "poids total" de votre collection : ce qui importe c'est le nombre d'objets et le nombre de propriétés par objet.

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

Pour suivre les dernières nouveautés de PowerShell : [Overview of what's new in PowerShell \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/overview)

## Se méfier de l'affichage dans la console

N'importe quel type d'affichage dans une console va vous coûter du temps de traitement ! Que ce soit du `Format-Table`, du `Write-Progress` ou du `Write-Output` : rien à faire, vous perdrez en performance.

Cependant, avant de tomber dans le dogmatisme je tiens à préciser quelque chose d'important : la perte en temps vaut probablement le coup, et ça pour plusieurs raisons :

1. L'affichage dans la console est utile pour la journalisation et le débuggage d'un script. Un script qui s'exécute vite, c'est bien. Un script qui fonctionne et qui est facile à maintenir, c'est mieux !
2. Il ne faut pas sous-estimer la puissance d'une barre de progression pour le cerveau humain : le temps vous semblera infiniment moins long avec une barre qui se remplie petit à petit, plutôt qu'une console vierge qui ne montre pas le moindre signe de progression.
3. Priorisez l'optimisation de vos performances : supprimer tout affichage dans votre script ne le rendra probablement pas deux fois plus performant. Essayer de trouver la cause du ralentissement avant de dégommer tous les `Write-Output` de votre script, car il y a de grandes chances pour ça ne soit pas la cause principale.

## Manger ~~bio et~~ local

De manière générale, une requête pour obtenir 10 000 utilisateurs est moins coûteuse que 10 000 requêtes d'un seul utilisateur.

> ~~On peut tromper mille fois mille personnes~~
> ~~On peut tromper une fois mille personnes, mais on ne peut pas tromper mille fois mille personnes~~
> ~~On peut tromper une fois mille personne mais on peut pas tromper mille fois une personne~~

Morale de l'histoire : faire une grosse requête pour requêter ensuite à l'intérieur du résultat plutôt que de faire une requête à chaque fois.

Pour Microsoft Graph : des rapports CSV sont disponibles (notamment pour les statistiques d'usage des boîtes aux lettres) et permettent de gagner beaucoup de temps par rapport à des requêtes individuelles, beaucoup plus coûteuses.

## Quelques tests en vrac

### `Out-Null` est moins performant que `$null =`

```powershell
Get-Command | Out-Null
# vs.
$null = Get-Command
```

**✅ VRAI** : La commande `Out-Null` permet de *mettre à la poubelle/ne pas afficher* le résultat d'une commande. Son utilisation reste relativement rare, mais si vous l'utilisez vous pouvez gagner 25% de performance en le remplaçant par `$null =`.

### `New-Object` est moins performant que `[PSCustomObject]@{}`

```powershell
New-Object -TypeName 'PSCustomObject' -Property @{}
# vs.
[PSCustomObject]@{}
```

**❌ PLUTÔT FAUX** : Lorsqu'il s'agit de créer un nouveau PSCustomObject, je n'ai trouvé aucune différence de temps de traitement entre les deux syntaxes. Je conseillerai tout de même d'adopter la syntaxe la plus moderne qui reste plus simple à comprendre et à lire.

## Conclusion


