---
layout: post
title: "La formule magique"
description: "Une petite énigme a résoudre avant d'essayer de faire le script le plus court possible pour la résoudre"
tags: ['challenge','powershell']
listed: true
capsule: "👍 Le plus facile"
nextLink:
  name: "Voir la solution"
  id: "/2021/11/02/la-formule-magique-soluce"
---

Pour ce défi, vous allez devoir résoudre une petite énigme avant de passer à la partie PowerShell. Je vous donne quelques exemples pour que vous puissiez essayer de deviner la fameuse formule magique :

- 2568 en entrée donne 21 en sortie
- 5143 en entrée donne 13 en sortie
- 8543 en entrée donne 20 en sortie

![Il faut un peu cogiter](https://media.giphy.com/media/d3mlE7uhX8KFgEmY/giphy.gif)

L'énigme n'est pas très complexe, donc pas besoin d'aller chercher bien loin. Si vous rencontrez des difficultés pour résoudre l'énigme, la solution est disponible ici :

<details>
  <summary>Voir la solution</summary>
  <p>Il suffit d'additionner les chiffres qui composent le nombre entre eux. Pour reprendre le premier exemple : <b>2568 devient 21</b> parce que 2+5+6+8 = 21</p>
</details>

## Consigne

La consigne est très simple : réaliser une fonction qui permet de résoudre cette énigme. Avec le paramètre en entrée, vous allez récupérer le nombre entier pour donner le résultat en sortie. Si vous le souhaitez, vous pouvez essayer de faire le code le plus court possible, mon record étant à 31 caractères (uniquement pour le cœur de la fonction).

## Modèle

Si vous souhaitez l'utiliser, voici une structure de fonction :

```powershell
# Version à compléter
function LaFormuleMagique {
    param([Int64]$i)

    # <votre code ici>

    return 
}
```
