---
layout: post
image: "https://media3.giphy.com/media/14SAx6S02Io1ThOlOY/giphy.gif?cid=ecf05e47vjsfts2omq85p4ohnx4u9nc18cpd4mbwclbn2a9b&rid=giphy.gif&ct=g"
title: "Elle est où la moulaga ?"
description: "Simple et efficace : vous devez trouver quand est-ce que votre salaire va tomber"
tags: powershell challenges
author: "Léo"
---

# Défi PowerShell n°1 : le jour de paie

Ce défi m'est venu en rendant mon "compte rendu d'activité", une tâche administrative à faire avant le 25e jour du mois en cours.

## Règles du défi

Les règles de base :
- le résultat doit être le jour ouvré le plus proche du 25e jour du mois (hors samedi & dimanche)
- les jours feriés ne sont pas à prendre en compte (pour simplifier le modèle)

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

## Ma solution

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
