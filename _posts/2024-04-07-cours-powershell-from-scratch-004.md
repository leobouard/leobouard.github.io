---
layout: post
title: "PS101 #4 - Variables, opérateurs et conditions"
description: "Découvrir les éléments essentiels du scripting"
tableOfContent: "/2024/04/07/cours-powershell-from-scratch-introduction#table-des-matières"
nextLink:
  name: "Partie 5"
  id: "/2024/04/07/cours-powershell-from-scratch-005"
prevLink:
  name: "Partie 3"
  id: "/2024/04/07/cours-powershell-from-scratch-003"
---

## Variables

Les variables sont un composant majeur de n'importe quel language de programmation/scripting. Dans le cas de PowerShell, les variables sont très flexibles et simple à utiliser. On les déclare à n'importe quel moment avec un `$` et on peut y stocker n'importe quoi en utilisant `=` (résultat de commande, texte, collection, nombre...)

```powershell
$users = Get-LocalUser
$text = 'Voici un texte court'
$number = 1032
```

Pour consulter leur contenu, il suffit simplement de tapper la commande dans la console.

### Conseils sur le nommage

Vous pouvez utiliser n'importe quel nom pour votre variable (lettres, chiffres et tirets & underscore), mais voici quelques conseils :

- Garder des noms simples et explicite sur leur contenu
- Utiliser des majuscules régulières : `$disabledUsers` par exemple
- Privilégier l'anglais

### Variables par défaut

Certaines variables sont utilisé par PowerShell pour stocker des informations importantes et nécessaires à son bon fonctionnement. Evitez de marcher sur les plate-bandes de PowerShell pour éviter les soucis.

## Opérateurs

### Opérateurs de comparaison

Il existe une multitude

Opérateur | Description
--------- | -----------
`-eq` | Egal à
`-ne` | N'est pas égal à
`-gt` | Strictement supérieur à
`-ge` | Supérieur ou égal à
`-lt` | Strictement inférieur à
`-le` | Inférieur ou égal à

## Exercice n°4

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

```powershell
if (condition) {
    # Traitement si la condition est remplie
}
elseif (condition) {
    # Traitement si la condition secondaire est remplie
}
else {
    # Traitement si aucune condition n'a été remplie
}
```

### Exercice n°5 (partie A)

### SWITCH

Le SWITCH permet de traiter un grand nombre de comparaison différentes dans une syntaxe très compacte.

```powershell
switch ($lettre) {
    'A' { Write-Host 'Alpha' }
    'B' { Write-Host 'Bravo' }
    'C' { Write-Host 'Charlie' }
    'D' { Write-Host 'Delta' }
    default { Write-Host "`n" }
}
```

### Exercice n°5 (partie B)

```powershell

```
