---
layout: post
title: "Cours pratique PowerShell"
description: "Création d'un jeu en PowerShell en utilisant un maximum de commandes et de techniques différentes"
tags: COURS
icon: 🎓
listed: true
nextLink:
  name: "Sommaire"
  id: "/2022/12/01/cours-pratique-powershell-sommaire"
---

## Introduction

L'idée est simple : **créer un petit jeu avec PowerShell** mais qu'on va emmener loin, très loin ! Le jeu que j'ai choisi pour ce cours pratique est le suivant : un nombre aléatoire est généré et vous devez le trouver.

Simple non ? Normalement vous aurez fini la base en moins de 10 minutes, mais c'est la suite qui va être intéressante. On va explorer un maximum de chose avec PowerShell via ce jeu : les différents types de boucle, les conditions, les collections d'objets et on finira en beauté par l'ajout d'une interface graphique avec WPF.

![Interface graphique finale en WPF](/assets/images/final-results.gif)

Quelques précisions avant de commencer :

- Dans ce cours, je considère que vous êtes familier avec les concepts de base de PowerShell, ainsi que sa syntaxe. Si ce n'est pas le cas, il y a plein de ressources à votre disposition sur Internet pour monter en compétence sur cette partie
- Je ne mettrais pas les liens directs pour les documentations sur les commandes utilisées. L'idée est de faire vos propres recherches (c'est comme ça qu'on apprend le mieux)
- Une *correction* sera disponible à la fin de chaque partie. Celle-ci n'est qu'une réponse parmi d'autre. Si votre script fonctionne mais ne ressemble pas au mien, ce n'est pas grave !

## Structure

Chaque partie sera similaire dans son organisation :

- Un résumé du résultat à obtenir qui contient toutes les informations nécessaires pour réaliser l'exercice
- Le détail pas-à-pas pour vous aider en cas de blocage
- La fameuse *correction* en fin de page pour suivre le rythme en cas de problème
