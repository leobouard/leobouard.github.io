---
layout: post
title: "Elle est où la moulaga ?"
description: "C'est quand qu'on est payé..."
tags: powershell challenges
author: "Léo"
thumbnailColor: "#519E8A"
icon: 💸
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
