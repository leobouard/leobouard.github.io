---
layout: post
title: "Défi - Bégaiement"
description: "Faire bégailler une longue tirade en faisant attention à la longueur des mots et aux syllabes"
background: "#69a9e9"
tags: ['challenge','powershell']
listed: true
nextLink:
  name: "Voir la solution"
  id: "/2021/09/28/begaiement-soluce"
---

Un classique des exercices de programmation : **faire bégayer un texte**, c'est-à-dire répéter deux à trois fois les premières lettres d'un mot. On doit alors fournir les informations à notre code pour qu'il puisse fonctionner : le texte à traiter et la probabilité du bégaiement (car on veut éviter que le bégaillement soit systématique). Un autre élément à prendre en compte est la longueur des mots minimum pour être "eligible" au bégaillement : pour être crédible, il faudra éviter de faire bégayer des mots trop courts en moins de cinq lettres par exemple.

Avec tous ces éléments, on peut distinguer une structure qui pourrait convenir parfaitement à notre code : une fonction avec plusieurs paramètres. Et pour tester cette fonction, quoi de mieux qu'une réplique culte ?

![Edouard Baer dans Astérix Mission Cléopatre avec la réplique culte "Vous savez, moi je ne crois pas qu'il y ait de bonnes ou de mauvaises situations"](https://c.tenor.com/3J9KbV6Gt1sAAAAC/asterix-obelix.gif)

## Consignes

Vous devrez créer une fonction PowerShell pour appliquer un bégaiement sur un texte de plusieurs phrases. Cette fonction prendra plusieurs paramètres :

- le texte à traiter (qui doit pouvoir être envoyé dans la fonction via un pipeline)
- la probabilité de bégaiement, avec une valeur par défaut définie à 50%
- la longueur minimale des mots à faire bégayer (par défaut : 5 caractères)

Si vous souhaitez corser un peu le défi, vous pouvez faire en sorte que PowerShell *identifie* les syllabes pour obtenir un résultat plus naturel. Par exemple :

- avancer → a…a…avancer
- mauvaise → mau…mau…mauvaise
- beaucoup → beau…beau…beaucoup

## Résultats attendus

Avant traitement | Après traitement
---------------- | ----------------
Vous savez, moi je ne crois pas qu'il y ait de bonne ou de mauvaise situation | Vous sa…sa…savez, moi je ne crois pas qu’il y ait de bo…bo…bonnes ou de mau…mau…mauvaises situations

## Texte de référence

> Vous savez, moi je ne crois pas qu’il y ait de bonne ou de mauvaise situation. Moi, si je devais résumer ma vie aujourd’hui avec vous, je dirais que c’est d’abord des rencontres. Des gens qui m’ont tendu la main, peut-être à un moment où je ne pouvais pas, où j’étais seul chez moi. Et c’est assez curieux de se dire que les hasards, les rencontres forgent une destinée… Parce que quand on a le goût de la chose, quand on a le goût de la chose bien faite, le beau geste, parfois on ne trouve pas l’interlocuteur en face je dirais, le miroir qui vous aide à avancer. Alors ça n’est pas mon cas, comme je disais là, puisque moi au contraire, j’ai pu : et je dis merci à la vie, je lui dis merci, je chante la vie, je danse la vie… je ne suis qu’amour ! Et finalement, quand beaucoup de gens aujourd’hui me disent « Mais comment fais-tu pour avoir cette humanité ? », et bien je leur réponds très simplement, je leur dis que c’est ce goût de l’amour ce goût donc qui m’a poussé aujourd’hui à entreprendre une construction mécanique, mais demain qui sait ? Peut-être simplement à me mettre au service de la communauté, à faire le don, le don de soi…
