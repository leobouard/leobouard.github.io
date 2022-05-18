---
layout: post
title: "[SOLUTION] Le jour de paie"
---



## Version Do/Until

```powershell

$i = 25
do {
    $d = Get-Date -Day $i
    $i--
} until ($d.DayOfWeek -notlike "S*")
$d

```

En version compressée on obtient :

```powershell

# 63 caractères de long
$i=25;do{$d=date -Day $i;$i--}until($d.DayOfWeek-notlike"S*")$d

```

## Version Foreach-Object

```powershell

$d = @()
1..25 | ForEach-Object { 
    $d += Get-Date -Day $_ | Where-Object {$_.DayOfWeek -notlike "S*"} 
}
$d | Select-Object -Last 1

```

## Version For

```powershell

for ($i = 25; $null -eq $d ; $i--) {
    $d = Get-Date -Day $i | Where-Object {$_.DayOfWeek -notlike "S*"}
}
$d

```

## Version While

```powershell

$d = Get-Date -Day 25
while ($d.DayOfWeek -like "S*") {
    $d = $d.AddDays(-1)
}
$d

```

## Version avec modulo

Trouvé par [@Ludovic]()

On se base sur la version avec la boucle Do/Until, mais on modifie la condition de sortie pour quelque chose de plus exotique !

```powershell

$i = 25
do {
    $d = Get-Date -Day $i
    $i--
} until (([int]$d.DayOfWeek+6)%7 -le 4)
$d

```

### Explications

`([int]$d.DayOfWeek+6)%7 -le 4`

`[int]$d.DayOfWeek` : permet de convertir le jour de la semaine en nombre entier. Même si ça parait un peu bizarre, c'est assez simple.

- Dimanche devient 0
- Lundi devient 1
- Mardi devient 2
- ...et samedi devient 6

Mais on se rend compte d'un problème : dimanche (0) et samedi (6) ne suivent pas, donc ça va être difficile de les exclure avec une seule condition (inférieur à 6 par exemple). C'est là que rentre en compte les mathématiques !

`+ 6` : on ajoute 6 au nombre entier pour pouvoir mieux le diviser par 7 (l'étape suivante). L'idée c'est de déplacer la valeur minimale (dimanche) de 0 à 6 et la maximale (samedi) de 6 à 12. Vous allez comprendre plus tard.

`% 7` : le fameux modulo ! on divise le résultat par 7 et on retourne l'entier restant. L'utilité ? Ça nous permet de passer le dimanche de la valeur la plus faible à la plus élevée.

Petit récapitulatif :

Jour de la semaine | Valeur | Valeur après addition | Valeur après modulo
------------------ | ------ | --------------------- | -------------------
Lundi | 1 | 7 | 0
Mardi | 2 | 8 | 1
Mercredi | 3 | 9 | 2
Jeudi | 4 | 10 | 3
Vendredi | 5 | 11 | 4
Samedi | 6 | 12 | 5
Dimanche | 7 | 13 | 6

`-le 4` : suite à toutes nos opérations mathématiques, samedi = 5 et dimanche = 6. Il ne nous reste donc plus qu'à les exclure des résultats avec un opérateur de comparaison "Lower or equal".

Au final, on si on n'avait utilisé le + 6) % 7, on aurait dû choisir la deuxième condition de sortie :

```powershell

$i = 25
do {
    $d = Get-Date -Day $i
    $i--
} until (([int]$d.DayOfWeek) -in 1..5)
$d

```

...soit littéralement : si le jour de la semaine est compris en 1 et 5, alors on peut sortir. Mais avouez que c'est quand même moins fun que la première option !