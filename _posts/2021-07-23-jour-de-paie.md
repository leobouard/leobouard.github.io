---
layout: post
title: "Le jour de paie"
description: "Calculer le jour exact où vous recevrez votre salaire, en prenant en compte les jours ouvrés uniquement"
tags: DÉFI
icon: 💸
listed: true
nextLink:
  name: "Voir la solution"
  id: "/2021/07/23/jour-de-paie-soluce"
---

Admettons la situation suivante : votre salaire vous est versé sur votre compte en banque  **au plus tard** le 25 du mois. En sachant que vous ne pouvez pas recevoir votre virement un samedi ou un dimanche, vous devez donc déterminer le jour exact où l'argent arrivera sur votre compte en banque.

En bref : elle est où la moulaga ?

![le jour après la paye](https://media2.giphy.com/media/ZWiIwPxJ9JGW4/giphy.gif?cid=ecf05e47tztz1sa2magi8gsof2idlq05bmu1qvxiofkxia0q&rid=giphy.gif&ct=g)

<div style="text-align: center">
  <i>Environ 5 min après avoir reçu votre salaire</i>
</div>

## Consignes

Les règles de ce défis sont très simple : on cherche à obtenir le jour ouvré (hors samedi et dimanche) le plus proche du 25e jour du mois. Exclure les jours fériés est facultatif et ne sera pas explicité dans les solutions proposées.

Pour les plus motivés d'entre-vous, voici plusieurs défis supplémentaires (du plus facile au plus dur) :

- faire la version la plus courte possible : tous les coups syntaxique sont permis. Vous serez probablement amené à tester tous les types de boucles (`for`, `ForEach-Object`, `while`, `do/until`, etc.) pour obtenir ou battre le record actuel : 63 caractères, espaces inclus.
- utiliser l'[API de l'Etat Français sur les jours fériés](https://api.gouv.fr/documentation/jours-feries) pour les exclure des résultats. Je n'ai pas eu le courage de le faire personnellement, mais ça peut être un bon moyen d'aborder les API en PowerShell.
- créer une version du script en utilisant le [modulo](https://devblogs.microsoft.com/scripting/powertip-return-remainder-after-dividing-two-numbers/)

## Ressources utiles

Voici quelques ressources qui pourraient vous être utiles :

- la documentation officielle de Microsoft sur la [commande `Get-Date`](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/get-date) qui permet d'obtenir une date
- la documentation officielle de Microsoft sur [les opérateurs de comparaisons](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators)
- un article de IT Connect sur les [les boucles `do/until` et `do/while`](https://www.it-connect.fr/powershell-boucle-do-until-et-do-while/)

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

A vous de jouer !
