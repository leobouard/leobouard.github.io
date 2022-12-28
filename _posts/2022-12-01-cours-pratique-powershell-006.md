---
layout: post
title: "Partie 6 - Trois étoiles"
description: "Ajout d'une évaluation de la performance du joueur sur 5 étoiles, qui se base sur la difficulté, la méthode et la rapidité"
icon: 🎓
nextLink:
  name: "Partie 7"
  id: "/2022/12/01/cours-pratique-powershell-007"
prevLink:
  name: "Partie 5"
  id: "/2022/12/01/cours-pratique-powershell-005"
---

## Consigne

L'objectif est de donner une apréciation sur 5 étoiles de la performance et la chance du joueur, en prennant en compte différents facteurs :

- la réponse moyenne par rapport au nombre aléatoire (dans un écart de 5% : OK par exemple)
- le temps moyen par coup (via une échelle)
- le facteur de difficulté du nombre aléatoire (si le nombre aléatoire est un multiple de 5)

### Résultat attendu

---

## Etape par étape

### Calcul du score pour le temps de réponse

10 points à gagner maximum

1 seconde et moins : 10 points
2 secondes : 8 points
3 secondes : 6 points
4 secondes : 4 points
5 secondes : 2 points
+5 secondes : 0 point

### Calcul du score pour l'écart avec le temps de réponse moyen

+/- 5%  : 10 points
+/- 10% : 8 points
+/- 15% : 6 points
+/- 20% : 4 points
+/- 25% : 2 points
+/- 30% : 0 point

### Calcul du score pour la difficulté du nombre aléatoire

x1  : 10 points
x2  : 8 points
x5  : 6 points
x10 : 4 points
x25 : 2 points
x50 : 0 point

### Calcul de la prise de risque du joueur



## Correction

```powershell
function Get-Evaluation {

    param(
        [PSObject]$
    )

}

```
