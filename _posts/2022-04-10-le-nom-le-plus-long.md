---
title: "DÉFI #5 - Le nom le plus long"
description: "Saurez-vous retrouver la personne avec le nom le plus long de votre annuaire ?"
tags: ['challenge','powershell']
listed: true
nextLink:
  name: "Voir la solution"
  id: "le-nom-le-plus-long-soluce"
---

PowerShell est un outil fantastique pour faire du reporting dans Active Directory : il permet de fournir des statistiques, épingler les comptes inactifs ou répondre à des questions que personne ne se pose !

La question du jour : **qui a le nom le plus long de l'annuaire ?** Si vous n'avez pas d'Active Directory (ou d'Azure AD) sous la main, pas d'inquiétude je vous fourni un fichier CSV qui vous permettra de réaliser l'exercice.

![Willie le jardinier dans Les Simpson qui se demande pourquoi est-ce que c'est toujours les gamins avec les noms les plus long qui font des conneries](https://media0.giphy.com/media/3o6MbjqOVQNVwuaIx2/giphy.gif?cid=ecf05e47juiie0foc3cipfq12mxibd8fg6n88sn6wvuird8x&ep=v1_gifs_search&rid=giphy.gif&ct=g)

## Un peu plus de défi

Si vous souhaitez augmenter la difficulté, je vous proposer de faire une version qui n'utilise aucune forme de boucle "conventionnelle". Donc pas le droit au `foreach`, `ForEach-Object`, `for` ou n'importe quelle version de `while/until`.

Si vous n'avez pas d'idée sur la méthode à utiliser, voici deux indices :

1. [La commande qui peut-être utilisée pour faire ça](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/select-object)
2. [Et comment l'utiliser dans ce contexte](https://docs.microsoft.com/powershell/scripting/samples/selecting-parts-of-objects--select-object-)

## Liste d'utilisateurs

Comme vous n'avez peut-être pas un tenant Microsoft 365 ou un annuaire Active Directory sous la main, je vous ai mis à disposition un tableau CSV avec un liste d'utilisateurs fictif. Vous pouvez récupérer le CSV avec cette commande :

```powershell
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'
```

…ou télécharger le fichier directement sur [GitHub](https://github.com/leobouard/leobouard.github.io/blob/main/assets/files/users.csv)
