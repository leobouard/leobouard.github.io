---
layout: post
title: "Bégaiement"
description: "C’est une bonne situation ça scribe ?"
tags: challenges
thumbnailColor: "#EDAE49"
icon: 🗨️
---

Un grand classique de la programmation appliqué au PowerShell : faire bégayer un texte !
L'idée c'est de répéter la première syllabe d'un mot deux fois de temps à autre.

Et quoi de mieux pour ça que la réplique d'Edouard Baer dans Asterix :

![edouard baer le boss](https://c.tenor.com/3J9KbV6Gt1sAAAAC/asterix-obelix.gif)

>  Mais vous sa… sa… savez, moi je ne crois pas qu’il y ait de bonnes ou de ma… ma… mauvaises situations.

## Conseils

- Pour plus de lisibilité, éviter de faire bégayer les mots de moins de 5 caractères de long	
- Ajouter une probabilité de bégayement pour pouvoir faire vos tests

Et si vous voulez faire ça propre, je vous conseille de faire ça dans une fonction avec les paramètres suivants :
  - la probabilité de bégayement (par défaut : 50%)
  - la longueur minimale des mots à faire bégayer (par défaut : 5)
  - si le texte doit être lu à haute-voix avec [SpeechSynthesizer](https://learn-powershell.net/2013/12/04/give-powershell-a-voice-using-the-speechsynthesizer-class/)

A vos claviers ! 😄