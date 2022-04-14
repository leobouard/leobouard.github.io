---
layout: post
title: "Elle est où la moulaga ?"
description: "<Titre un poil trompeur>"
tags: powershell challenges
author: "Léo"
thumbnailColor: "#519E8A"
icon: 💸
---

# #01 - Elle est où la moulaga ?

La situation initiale est la suivante : je dois rendre un document administratif tous les mois, au plus tard le 25e jour du mois en cours. Le problème, c'est que je dois faire ça sur des jours ouvrés (sinon ça compte pas).

Et comme c'est pas très parlant, on va se dire qu'au lieu de faire de l'administratif, c'est le jour où l'on reçoit notre paye. 

En bref : **elle est où la moulaga ?**

![le jour après la paye](https://media2.giphy.com/media/ZWiIwPxJ9JGW4/giphy.gif?cid=ecf05e47tztz1sa2magi8gsof2idlq05bmu1qvxiofkxia0q&rid=giphy.gif&ct=g)

## Règles

Les règles de base :
- le résultat doit être le jour ouvré le plus proche du 25e jour du mois (donc hors samedi & dimanche)
- les jours feriés ne sont pas à prendre en compte (pour simplifier le modèle)
- votre code doit afficher le résultat dans la console

Le défi est trop facile pour vous ? Essayez ça :
- de faire la version la plus courte possible (mon record : 63 caractères)
- de créer une version avec un [modulo](https://devblogs.microsoft.com/scripting/powertip-return-remainder-after-dividing-two-numbers/)
- utiliser les différents types de boucles :
  - version "ForEach-Object"
  - version "do{}until()" et/ou "do{}while()"
  - version "for()"

## Ressources utiles

- [Get-Date \| Microsoft Docs](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/get-date)
- [Boucles "do{}until()" et "do{}while()" \| IT-Connect](https://www.it-connect.fr/powershell-boucle-do-until-et-do-while/)
- [Opérateurs de comparaisons \| Microsoft Docs](https://docs.microsoft.com/powershell/module/microsoft.powershell.core/about/about_comparison_operators)

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

## Les solutions

Pour avoir les résultats sur toute l'année 2022 :

```powershell

1..12 | ForEach-Object {
  
  $i = 25
  do {
      $d = Get-Date -Year 2022 -Month $_ -Day $i
      $i--
  } until ($d.DayOfWeek -notlike "S*")
  
  $d
}

```

En version compressée (63 caractères de long) :

```powershell

$i=25;do{$d=date -Day $i;$i--}until($d.DayOfWeek-notlike"S*")$d

```
