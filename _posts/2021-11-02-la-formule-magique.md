---
layout: post
title: "La formule magique"
description: "Une petite énigme a résoudre avant d'essayer de faire le script le plus court possible pour la résoudre"
tags: DÉFI
icon: 🎩
listed: true
nextLink:
  name: "Voir la solution"
  id: "/2021/11/02/la-formule-magique-soluce"
---

On part sur quelque-chose de plus simple pour cette fois-ci ! 😋

Il faut simplement faire une fonction pour que :

- 2568 en entrée donne 21 en sortie
- 5143 en entrée donne 13 en sortie
- 8543 en entrée donne 20 en sortie
- etc…

Vous voyez, c'est L-I-M-P-I-D-E !

![Il faut un peu cogiter](https://media.giphy.com/media/d3mlE7uhX8KFgEmY/giphy.gif)

<div style="text-align: center">
  <i>Simple comme bonjour</i>
</div>

## Règles

Rien de spécifique, mais si vous voulez faire le script le plus court possible :

- le script doit être fonctionnel en PowerShell 5.1
- le script doit être fonctionnel sans connexion Internet
- le script doit être autonome (pas de fichiers externes)
- tous les coups sont permis sur la syntaxe

## Modèle

Comme je suis sympa, je vous laisse la structure de ma fonction :

```powershell
# Version à compléter
function LaFormuleMagique {
    param([Int64]$i)

    # <votre code ici>

    return 
}
```

A vos claviers ! 😃