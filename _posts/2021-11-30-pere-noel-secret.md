---
layout: post
title: "Secret santa"
description: "Créer un tirage au sort qui permet de savoir à qui doit-on offrir son cadeau"
tags: ['challenge','powershell']
listed: true
thumbnail:  "/assets/thumbnail/secret-santa.png"
nextLink:
  name: "Voir la solution"
  id: "/2021/11/30/pere-noel-secret-soluce"
---

Ce défi peut paraitre facile au premier abord, mais attention : il y a assez peu de chances que vous l'ayez résolu en moins de cinq minutes. Le but du jeu est simple, vous avez une liste de partipants qui doivent s'offrir des cadeaux mutuellement et vous êtes chargés de dire qui offre à qui.

![Jake Peralta dans Brooklyn 99](https://media3.giphy.com/media/l4JyXxZuYlt6BUUaA/giphy.gif?cid=790b7611db9865c6b3ca30b2ffd967b5c86700f85dbd799a&rid=giphy.gif&ct=g)

## Consignes

Faire une fonction ou un script qui prend en paramètre le nom de chaque participant et donne en résultat un affichage progressif qui affiche dans la console "*A offre son cadeau à B*". La ligne suivante n'est affichée qu'après une action de l'utilisateur (comme l'appui sur une touche par exemple). Le résultat doit être complétement aléatoire.

Pour votre liste de participants, vous pouvez utiliser l'équipe de Brooklyn 99 : Jake, Terry, Holt, Amy, Rosa et Charles.

### Contraintes

On considère que le nombre minimum de participants est de trois. Les situations suivantes ne doivent alors pas se produire :

- une personne ne peut pas s'offrir de cadeau à elle-même. Exemple : *A offre son cadeau à A*.
- deux personnes ne peuvent pas s'offrir de cadeau mutuellement. Exemple : *A offre son cadeau à B et B offre son cadeau à A*.

## Résultat attendu

> #0 Jake offre son cadeau à Terry\
> #1 Terry offre son cadeau à Holt\
> #2 Holt offre son cadeau à Amy\
> #3 Amy offre son cadeau à Rosa\
> #4 Rosa offre son cadeau à Charles\
> #5 Charles offre son cadeau à Jake
