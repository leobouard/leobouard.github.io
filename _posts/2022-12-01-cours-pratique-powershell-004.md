---
layout: post
title: "Cours PowerShell #4 - Mais on est où là ?"
description: "Ajout de bornes inférieure et supérieure pour aider le joueur à deviner le nombre aléatoire"
icon: 🎓
nextLink:
  name: "Partie 5"
  id: "/2022/12/01/cours-pratique-powershell-005"
prevLink:
  name: "Partie 3"
  id: "/2022/12/01/cours-pratique-powershell-003"
---

## Consigne

Les paramètres "Minimum" et "Maximum" pour la commande "Get-Random" sont maintenant stockés dans des variables. Des bornes font leur apparition dans le texte du `Read-Host` pour aider le joueur à mieux situer le nombre aléatoire par rapport à ses précédentes tentatives. Ces bornes se rapprochent au fur et à mesure des réponses du joueur.

### Résultat attendu

Bornes classiques :

> Deviner le nombre (1 < ??? < 1000): 500\
> ??? est plus grand que 500\
> Deviner le nombre (500 < ??? < 1000): 750\
> ??? est plus petit que 750\
> Deviner le nombre (500 < ??? < 750):

Bornes intelligentes (donne toujours l'écart le plus serré) :

> Deviner le nombre (500 < ??? < 750): 800\
> ??? est plus petit que 800\
> Deviner le nombre (500 < ??? < 750):

C'est cette version qui sera conservée pour la correction. Elle a comme avantage de conserver la borne la plus proche en cas d'erreur du joueur.

---

## Etape par étape

1. Stocker les valeurs minimum et maximum dans des variables pour la génération du nombre aléatoire
2. Modifier le texte affiché pour ajouter des bornes
3. Mettre à jour les bornes inférieure et supérieure
  - Point bonus : faire des bornes intelligentes

### Stocker les valeurs minimum et maximum dans des variables pour la génération du nombre aléatoire

L'objectif est de créer deux variables `$min` et `$max` qui vont contenir et afficher les bornes inférieure et supérieure. Comme lors de la première tentative, les bornes sont définies à 1 et 1000 respectivement, on peut les utiliser pour la génération du nombre aléatoire par la commande `Get-Random`. De cette manière, on centralise l'information.

```powershell
$min = 1
$max = 1000
Get-Random -Minimum $min -Maximum $max
```

### Modifier le texte affiché pour ajouter des bornes

On va maintenant afficher la valeur des variables `$min` et `$max` dans le texte du `Read-Host` avec comme résultat : "Deviner le nombre (1 < ??? < 1000)"

```powershell
Read-Host "Deviner le nombre ($min < ??? < $max)"
```

### Mettre à jour les bornes inférieure et supérieure

Après chaque tentative, les bornes se rapprochent pour afficher l'encadrement le plus proche de la valeur aléatoire. Dans les blocs `if` et `elseif`, on met donc à jour les variables `$min` ou `$max` en fonction du contexte :

- si le nombre proposé par le joueur est **plus élevé que le nombre aléatoire**, alors on met à jour la **borne supérieure**
- si le nombre proposé par le joueur est **plus bas que le nombre aléatoire**, alors on met à jour la **borne inférieure**.

Voici un exemple où le nombre aléatoire est 342 :

Nb joueur | Borne inf. | Borne sup. | Commentaire
--------- | ---------- | ---------- | -----------
500 | 1 | 1000 | 500 > 342, donc on met à jour la borne supérieure
250 | 1 | **500** | 250 < 342, donc on met à jour la borne inférieure
300 | **250** | 500 | 300 < 342, donc on met à jour la borne inférieure
350 | **300** | 500 | 350 > 342, donc on met à jour la borne supérieure
325 | 300 | **350** | etc...

Affichage dans la console :

> Deviner le nombre (1 < ??? < 1000): 500\
> ??? est plus petit que 500\
> Deviner le nombre (1 < ??? < **500**): 250
> ??? est plus grand que 250\
> Deviner le nombre (**250** < ??? < 500): 300\
> ??? est plus grand que 300\
> Deviner le nombre (**300** < ??? < 500): 350\
> ??? est plus petit que 350\
> Deviner le nombre (300 < ??? < **350**):

```powershell
if ($random -gt $answer) { $min = $answer }
elseif ($random -lt $answer) { $max = $answer }
```

### Point bonus : faire des bornes intelligentes

Le point faible des bornes "classiques", c'est que si le joueur commet une erreur, celles-ci vont s'agrandir au lieu de rester sur l'encadrement le plus proche du nombre aléatoire. Pour éviter ce genre de problème, on peut utiliser la variable `$allAnswers` qui contient toutes les tentatives précédentes.

- si le nombre proposé par le joueur est **plus bas que le nombre aléatoire**, alors :
  1. on récupère toutes les tentatives qui sont inférieures au nombre aléatoire avec `Where-Object`
  2. on trie les réponses par ordre croissant avec `Sort-Object` pour faire descendre la valeur la plus élevée (et donc la plus proche du nombre aléatoire) en dernière position
  3. on récupère la dernière valeur du tableau avec la commande `Select-Object` et le paramètre `-Last`
- si le nombre proposé par le joueur est **plus élevé que le nombre aléatoire**, alors :
  1. on récupère toutes les tentatives qui sont supérieures au nombre aléatoire avec `Where-Object`
  2. on trie les réponses par ordre croissant avec `Sort-Object` pour faire remonter la valeur la plus faible (et donc la plus proche du nombre aléatoire) en première position
  3. on récupère la première valeur du tableau avec la commande `Select-Object` et le paramètre `-First`

On joint le tout avec des `|` (pipeline) pour envoyer le résultat de la commande vers la prochaine et on obtient un bloc assez compact et qui n'est pas impacté par les erreurs potentielles du joueur :

```powershell
if ($random -gt $answer) { 
    $min = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object | Select-Object -Last 1
} elseif ($random -lt $answer) { 
    $max = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1
}
```

## Correction

<a class="solution" href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-004.ps1" target="_blank">Voir le script complet</a>