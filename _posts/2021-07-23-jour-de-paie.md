---
layout: post
title: "Le jour de paie"
description: "Calculer le jour exact où vous recevrez votre salaire, en prennant en compte les jours ouvrés uniquement"
tags: DÉFI
icon: 💸
listed: true
---

Admettons la situation suivante : votre salaire vous est versé au plus tard le 25 du mois en cours. Comme vous êtes très dépensier, vous voulez savoir précisement quand est-ce que vous allez pouvoir manger autre chose que des pâtes !

Du coup la question est simple : c'est quand votre jour de paie ?

![le jour après la paye](https://media2.giphy.com/media/ZWiIwPxJ9JGW4/giphy.gif?cid=ecf05e47tztz1sa2magi8gsof2idlq05bmu1qvxiofkxia0q&rid=giphy.gif&ct=g)

<div style="text-align: center">
  <i>Environ 5 min après avoir reçu votre salaire</i>
</div>

## Règles

Les règles de base :
- le résultat doit être le jour ouvré le plus proche du 25e jour du mois (donc hors samedi & dimanche)
- les jours feriés ne sont pas à prendre en compte (pour simplifier le modèle)
- votre code doit afficher le résultat dans la console

## Trop facile pour vous ?

Pas de problème ! Pour corser un peu l'exercice, on peut ajouter quelques défis bonus

- Faire la version la plus courte possible, mon record personnel étant 63 caractères
- Créer une version en utilisant un [modulo](https://devblogs.microsoft.com/scripting/powertip-return-remainder-after-dividing-two-numbers/)
- Utiliser 3 différents types de boucles :
  - version ForEach-Object ou foreach
  - version Do/Until et/ou Do/While
  - version For

## Ressources utiles

Voici quelques ressources qui pourraient vous être utiles :

1. La documentation Microsoft sur la commande [Get-Date](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/get-date)
2. Un article sympa et complet de IT Connect sur [les boucles Do/Until et Do/While](https://www.it-connect.fr/powershell-boucle-do-until-et-do-while/)
3. Un petit rappel sur [les opérateurs de comparaisons](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators) sur Microsoft Docs

## Résultats attendus pour l'année 2022

Mois | Jour attendu
---- | ------------
Janvier 2022 | mardi 25 janvier
Février 2022 | vendredi 25 février
Mars 2022 | vendredi 25 mars
Avril 2022 | lundi 25 avril
Mai 2022 | mercredi 25 mai
Juin 2022 | vendredi 24 juin
Juillet 2022 | lundi 25 juillet
Août 2022 | jeudi 25 août
Septembre 2022 | vendredi 23 septembre
Octobre 2022 | mardi 25 octobre
Novembre 2022 | vendredi 25 novembre
Décembre 2022 | vendredi 23 décembre

A vos claviers ! 🙂
