---
layout: post
title: "Qui a le nom le plus long ?"
description: "Et non ce n'est pas Bernard de la Villardière"
tags: challenges
thumbnailColor: "#334195"
icon: 🆔
---

## Liste d'utilisateurs

Comme vous n'avez peut-être pas un tenant Microsoft 365 ou un annuaire Active Directory sous la main, je vous ai mis à disposition un tableau CSV avec un liste d'utilisateurs fictif. Vous pouvez récupérer le CSV avec cette commande :

```powershell

$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'

```

...ou télécharger le fichier directement sur [GitHub](https://github.com/leobouard/leobouard.github.io/blob/main/assets/files/users.csv)