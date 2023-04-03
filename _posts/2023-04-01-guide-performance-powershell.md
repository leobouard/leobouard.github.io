---
layout: post
title: "Petit guide sur la performance en PowerShell"
description: "Tout savoir sur l'optimisation des performances sur vos scripts PowerShell"
tags: COURS
icon: 💪
listed: true
---

## Bien choisir ses tableaux

différence entre Array, ArrayList et GenericList

Pour tout savoir sur les Array et les collections : [Building Arrays and Collections in PowerShell \| Clear-Script](https://vexx32.github.io/2020/02/15/Building-Arrays-Collections/)

## Création d'objet

New-Object -TypeName 'psobject' ... vs [PSCustomObject]@{}

## Bien comprendre le pipeline

On lit souvent que `foreach` est plus performant que `ForEach-Object`, ce n'est pas tout à fait vrai : il s'agit simplement d'une utilisation différente.

La boucle `foreach` est en effet plus performante si toutes les données à traiter ont déjà été récupérées.

L'avantage et l'inconvénient du `ForEach-Object`, c'est qu'il s'utilise avec un pipeline. Le pipeline (qui pourrait être traduit grossièrement en *tuyau*) permet d'envoyer de la donnée dès qu'elle est disponible. Donc si vous faites une requête avec 10000 objets en résultat, le traitement via le pipeline permettra de commencer le travail dès que le premier objet est reçu.

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

Pour suivre les dernières nouveautés de PowerShell : [Overview of what's new in PowerShell \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/scripting/whats-new/overview?view=powershell-7.3)

## Se méfier de l'affichage dans la console

null = ... plutôt que Out-Null

N'importe quel type d'affichage dans une console va vous coûter du temps de traitement ! Que ce soit du `Format-Table`, du `Write-Progress` ou du `Write-Output` : rien à faire, vous perdrez en performance.

Cependant, avant de tomber dans le dogmatisme je tiens à préciser quelque chose d'important : la perte en temps vaut probablement le coup, et ça pour plusieurs raisons :

1. L'affichage dans la console est utile pour la journalisation et le débuggage d'un script. Un script qui s'exécute vite, c'est bien. Un script qui fonctionne et qui est facile à maintenir, c'est mieux !
2. Il ne faut pas sous-estimer la puissance d'une barre de progression pour le cerveau humain : le temps vous semblera infiniment moins long avec une barre qui se remplie petit à petit, plutôt qu'une console vierge qui ne montre pas le moindre signe de progression.
3. Priorisez l'optimisation de vos performances : supprimer tout affichage dans votre script ne le rendra probablement pas deux fois plus performant. Essayer de trouver la cause du ralentissement avant de dégommer tous les `Write-Output` de votre script, car il y a de grandes chances pour ça ne soit pas la cause principale.

## Conclusion
