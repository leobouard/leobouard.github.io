---
title: "DÉFI #1 - Le jour de paie"
description: "Calculer le jour exact où vous recevrez votre salaire, en prenant en compte les jours ouvrés uniquement"
tags: ['challenge','powershell']
listed: true
nextLink:
  name: "Voir la solution"
  id: "jour-de-paie-soluce"
---

Admettons la situation suivante : votre salaire vous est versé sur votre compte en banque  **au plus tard** le 25 du mois. En sachant que vous ne pouvez pas recevoir votre virement un samedi ou un dimanche, vous devez donc déterminer le jour exact où l'argent arrivera sur votre compte en banque.

En bref : elle est où la moulaga ?

![Léonardo Di Caprio qui jette des billets dans Le Loup de Wallstreet](https://media2.giphy.com/media/ZWiIwPxJ9JGW4/giphy.gif?cid=ecf05e47tztz1sa2magi8gsof2idlq05bmu1qvxiofkxia0q&rid=giphy.gif&ct=g)

## Consignes

Les règles de ce défis sont très simple : on cherche à obtenir le jour ouvré (hors samedi et dimanche) le plus proche du 25e jour du mois. Exclure les jours fériés est facultatif et ne sera pas explicité dans les solutions proposées.

Pour les plus motivés d'entre-vous, voici plusieurs défis supplémentaires (du plus facile au plus dur) :

- faire la version la plus courte possible : tous les coups syntaxique sont permis. Vous serez probablement amené à tester tous les types de boucles (`for`, `ForEach-Object`, `while`, `do/until`, etc.) pour obtenir ou battre le record actuel : 54 caractères, espaces inclus.
- utiliser l'[API de l'Etat Français sur les jours fériés](https://api.gouv.fr/documentation/jours-feries) pour les exclure des résultats. Je n'ai pas eu le courage de le faire personnellement, mais ça peut être un bon moyen d'aborder les API en PowerShell.
- créer une version du script en utilisant le [modulo](https://devblogs.microsoft.com/scripting/powertip-return-remainder-after-dividing-two-numbers/)

## Ressources utiles

Voici quelques ressources qui pourraient vous être utiles :

- la documentation officielle de Microsoft sur la [commande `Get-Date`](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/get-date) qui permet d'obtenir une date
- la documentation officielle de Microsoft sur [les opérateurs de comparaisons](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators)
- un article de IT Connect sur les [les boucles `do/until` et `do/while`](https://www.it-connect.fr/powershell-boucle-do-until-et-do-while/)

## Résultats attendus pour l'année 2023

Les résultats ignorent les jours fériés

Mois | Jour attendu
---- | ------------
Janvier | mercredi 25 janvier
Février | vendredi 24 février
Mars | vendredi 24 mars
Avril | mardi 25 avril
Mai | jeudi 25 mai
Juin | vendredi 23 juin
Juillet | mardi 25 juillet
Août | vendredi 25 août
Septembre | lundi 25 septembre
Octobre | mercredi 25 octobre
Novembre | vendredi 24 novembre
Décembre | lundi 25 décembre

A vous de jouer !
