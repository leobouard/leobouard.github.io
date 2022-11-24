---
layout: post
title: "Bégaiement"
description: "Faire bégailler une longue tirade en faisant attention à la longueur des mots et aux syllabes"
tags: DÉFI
thumbnailColor: "#074A46"
icon: 🗨️
listed: true
---

Un grand classique de la programmation appliqué au PowerShell : faire bégayer un texte !
L'idée c'est de répéter la première syllabe d'un mot deux fois de temps à autre.

Et quoi de mieux pour ça que la réplique d'Edouard Baer dans Asterix :

![edouard baer le boss](https://c.tenor.com/3J9KbV6Gt1sAAAAC/asterix-obelix.gif)

<div style="text-align: center">
  <i> Mais vous sa… sa… savez, moi je ne crois pas qu’il y ait de bonnes ou de ma… ma… mauvaises situations</i>
</div>

## Conseils

Et si vous voulez faire ça propre, je vous conseille de faire ça dans une fonction avec les paramètres suivants :
  - la probabilité de bégaiement (par défaut : 50%)
  - la longueur minimale des mots à faire bégayer (par défaut : 5)

## Petite aide

Si besoin, voici la tirade au complet : 

```powershell

$text = "Vous savez, moi je ne crois pas qu’il y ait de bonne ou de mauvaise situation. Moi, si je devais résumer ma vie aujourd’hui avec vous, je dirais que c’est d’abord des rencontres. Des gens qui m’ont tendu la main, peut-être à un moment où je ne pouvais pas, où j’étais seul chez moi. Et c’est assez curieux de se dire que les hasards, les rencontres forgent une destinée… Parce que quand on a le goût de la chose, quand on a le goût de la chose bien faite, le beau geste, parfois on ne trouve pas l’interlocuteur en face je dirais, le miroir qui vous aide à avancer. Alors ça n’est pas mon cas, comme je disais là, puisque moi au contraire, j’ai pu : et je dis merci à la vie, je lui dis merci, je chante la vie, je danse la vie… je ne suis qu’amour ! Et finalement, quand beaucoup de gens aujourd’hui me disent « Mais comment fais-tu pour avoir cette humanité ? », et bien je leur réponds très simplement, je leur dis que c’est ce goût de l’amour ce goût donc qui m’a poussé aujourd’hui à entreprendre une construction mécanique, mais demain qui sait ? Peut-être simplement à me mettre au service de la communauté, à faire le don, le don de soi…"

```

A vos claviers ! 😄