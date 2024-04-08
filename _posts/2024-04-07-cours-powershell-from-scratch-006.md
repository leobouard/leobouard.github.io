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
