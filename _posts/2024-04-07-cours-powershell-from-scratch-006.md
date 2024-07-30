---
layout: post
title: "PS101 #6 - Les conditions en bref"
description: "Troisième élément essentiel du scripting"
tableOfContent: "/2024/04/07/cours-powershell-from-scratch-introduction#table-des-matières"
nextLink:
  name: "Partie 7"
  id: "/2024/04/07/cours-powershell-from-scratch-007"
prevLink:
  name: "Partie 5"
  id: "/2024/04/07/cours-powershell-from-scratch-005"
---

## Conditions

En PowerShell, les conditions sont représentées par trois structures :

- IF/ELSEIF/ELSE
- SWITCH
- TERNAIRE (à partir de PowerShell 7+), ne sera pas abordé ici

### IF/ELSEIF/ELSE

La structure du IF/ELSEIF/ELSE est la plus courante en PowerShell et permet de traiter des conditions simples rapidement. Cette structure est très modulable et se décline le plus souvent de trois manières :

1. IF : pour faire un traitement si la condition est remplie
2. IF/ELSE : pour faire un traitement si la condition est remplie et un autre si elle n'est pas remplie
3. IF/ELSEIF/ELSE : pour faire un traitement suivant la condition qui sera remplie et un autre pour le reste

~~~powershell
if (condition) {
    # Traitement si la condition est remplie
}
elseif (condition) {
    # Traitement si la condition secondaire est remplie
}
else {
    # Traitement si aucune condition n'a été remplie
}
~~~

### Exercice n°6A

Avec les commandes `Read-Host`, `Write-Host` et des conditions, réaliser un script qui donne une appréciation selon l'âge de la personne :

- Moins de 18 ans : "Rien à faire ici !
- Entre 18 et 25 ans : "Le bel âge !"
- Entre 25 et 45 ans : "Salut les d'jeuns"
- Entre entre 45 et 65 : "J'adore Nostalgie !"
- Entre 65 et 80 ans : "Il serait temps de partir en retraite"
- Plus de 80 ans : "Ça sent le sapin"

### SWITCH

Le SWITCH permet de traiter un grand nombre de comparaison différentes dans une syntaxe très compacte.

~~~powershell
switch ($num) {
    22 { Write-Host 'Finistère' }
    31 { Write-Host 'Haute-Garonne' }
    33 { Write-Host 'Gironde' }
    35 { Write-Host 'Ille-et-Vilaine' }
    44 { Write-Host 'Loire-Altantique' }
    default { Write-Host "Numéro incorrect" -ForegroundColor Red }
}
~~~

### Exercice n°6B

Ecrivez un script PowerShell qui permet de transformer une phrase en alphabet militaire.

Vous aurez besoin d'utiliser des variables, une condition, une boucle, un opérateur de manipulation de texte et les commandes `Write-Host` et `Read-Host`.

Le résultat attendu est le suivant :

~~~plainttext
Entrer la phrase à convertir: HELLO WORLD

H - Hotel
E - Echo
L - Lima
L - Lima
O - Oscar

W - Whiskey
O - Oscar
R - Romeo
L - Lima
D - Delta
~~~
