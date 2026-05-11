---
title: "SOLUCE #1 - Le jour de paie"
hidden: true
prevLink:
  name: "Retour au défi"
  id: "jour-de-paie"
---

## Différentes boucles

Comme indiqué dans la consigne, différentes boucles sont possibles pour obtenir le résultat demandé.

Voici un tableau récapitulatif des méthodes les plus courtes :

Boucle | Longueur
------ | --------
`for` | 66 caractères
`while` | 65 caractères
`do/until` | 63 caractères
`do/while` | 60 caractères
`ForEach-Object` | 54 caractères

### Version `for`

Cette boucle est assez peu répandue en PowerShell, si bien qu'on a tendance à l'oublier. Elle permet de faire en une seule ligne :

- une situation de départ : `$i = 25`
- la condition pour rester dans la boucle : `$null -eq $d`
- l'action a effectuer pour chaque traitement : `$i--`

Le reste de la boucle est alors assez simple : on ajoute la date du jour à la variable `$d` si celle-ci n'est pas un samedi ou un dimanche.

```powershell
for ($i = 25; $null -eq $d ; $i--) {
    $d = Get-Date -Day $i | Where-Object {$_.DayOfWeek -notlike "S*"}
}
$d
```

Version courte à 66 caractères : `for($i=25;!$d;$i--){$d=date -day $i|?{$_.DayOfWeek-notlike"s*"}}$d`

### Version `while`

C'est une boucle assez commune, mais qui peut être cause de boucles infinies si la condition n'est jamais remplie. Elle a donné son nom à un album : [while(1<2) par deadmau5](https://open.spotify.com/album/4NQRw9HthpcLg4vYQ6yJFu), qui est un bon exemple de boucle infinie.

Le traitement est donc simple : on récupère la date du 25e jour du mois en cours, et si celle-ci est un samedi ou un dimanche, alors on remonte un jour en arrière via la méthode `.AddDays(-1)` jusqu'à ce que le jour soit ouvré.

```powershell
$d = Get-Date -Day 25
while ($d.DayOfWeek -like "S*") {
    $d = $d.AddDays(-1)
}
$d
```

Version courte à 65 caractères : `$d=date -Day 25;while($d.DayOfWeek-like"s*"){$d=$d.AddDays(-1)}$d`

### Version `do/until` et `do/while`

Le fonctionnement est relativement proche de la boucle `while`, mais cette fois-ci on tombe obligatoirement dans la boucle de traitement (il n'y a pas de condition en entrée, uniquement en sortie). La différence entre le `do/until` (faire X jusqu'à ce que Y) et le `do/while` (faire X tant que Z) réside simplement dans la différence de la comparaison :

- `until ($d.DayOfWeek -notlike "S*")`
- `while ($d.DayOfWeek -like "S*")`

Dans l'objectif de faire le script le plus court possible, c'est `do/while` qui est plus intéressant.

```powershell
$i = 25
do {
    $d = Get-Date -Day $i
    $i--
} while ($d.DayOfWeek -like "S*")
$d
```

Version courte à 60 caractères : `$i=25;do{$d=date -Day $i;$i--}while($d.DayOfWeek-like"S*")$d`

### Version `ForEach-Object`

La boucle la plus répandue en PowerShell : on a une liste et on applique un traitement pour chaque élément de la liste. Ce script a très clairement été réalisé pour obtenir la commande la plus courte possible, donc la logique est particulière.

L'objectif est d'avoir un tableau de tous les jours ouvrés du mois en cours, pour ensuite afficher le premier résultat. Le fait d'avoir une liste inversée (`25..1`) nous permet d'éviter d'avoir à recourir au paramètre `-Last` de la commande `Select-Object` (sur laquelle il n'y a pas de syntaxe courte).

Ici pas besoin de variable `$d`, on utilise le pipeline au maximum (pour économiser de précieux caractères).

```powershell
25..1 | ForEach-Object { 
    Get-Date -Day $_ | Where-Object {$_.DayOfWeek -notlike "S*"}
} | Select-Object -First 1
```

Version courte à 54 caractères : `(25..1|%{date -Day $_|?{$_.DayOfWeek-notlike"S*"}})[0]`

## Utilisation du modulo

*Trouvé par [@Ludovic Morin](https://www.linkedin.com/in/ludovic-morin-193a44144/).*

On se base sur la version avec la boucle `do/until`, mais on modifie la condition de sortie pour quelque chose de plus exotique :

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
Dimanche | 0 | 6 | 6

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