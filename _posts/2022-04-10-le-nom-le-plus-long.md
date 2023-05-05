---
layout: post
title: "Défi - Qui a le nom le plus long ?"
description: "Saurez-vous retrouver la personne avec le nom complet (prénom et nom) le plus long de la liste ?"
background: "#F292A5"
tags: ['challenge','powershell']
listed: true
nextLink:
  name: "Voir la solution"
  id: "/2022/04/10/le-nom-le-plus-long-soluce"
---

PowerShell est un outil fantastique pour faire du reporting dans Active Directory : il permet de fournir des statistiques, épingler les comptes inactifs ou répondre à des questions que personne ne se pose !

La question du jour : **qui a le nom le plus long de l'annuaire ?** Si vous n'avez pas d'Active Directory (ou d'Azure AD) sous la main, pas d'inquiétude je vous fourni un fichier CSV qui vous permettra de réaliser l'exercice.

## Un peu plus de défi

Si vous souhaitez augmenter la difficulté, je vous proposer de faire une version qui n'utilise aucune forme de boucle "conventionnelle". Donc pas le droit au `foreach`, `ForEach-Object`, `for` ou n'importe quelle version de `while/until`.

Si vous ne savez pas comment faire, voici deux indices :

1. [La commande qui peut-être utilisée pour faire ça](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object)
2. [Comment l'utiliser dans ce contexte](https://docs.microsoft.com/fr-fr/powershell/scripting/samples/selecting-parts-of-objects--select-object-)

## Liste d'utilisateurs

Comme vous n'avez peut-être pas un tenant Microsoft 365 ou un annuaire Active Directory sous la main, je vous ai mis à disposition un tableau CSV avec un liste d'utilisateurs fictif. Vous pouvez récupérer le CSV avec cette commande :

```powershell
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'
```

…ou télécharger le fichier directement sur [GitHub](https://github.com/leobouard/leobouard.github.io/blob/main/assets/files/users.csv)
