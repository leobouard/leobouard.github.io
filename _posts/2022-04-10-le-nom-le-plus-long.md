---
layout: post
title: "Qui a le nom le plus long ?"
description: "Vous avez peut-être déjà une idée"
tags: challenges
thumbnailColor: "#334195"
icon: 🆔
---

Bon bah là pas besoin de broder... Tout est dans le titre ! 😄

Vous avez une liste d'utilisateurs (type annuaire Active Directory) et vous voulez savoir qui a le nom le plus long ? Est-ce que c'est le comptable d'origine indienne ? Ou votre collègue sud-américaine avec plus de prénoms que vous n'avez de lettres dans votre nom de famille ? Ou alors simplement un présentateur TV bien connu avec un nom à particule ?

![eminem-my-name-is](https://media2.giphy.com/media/xUOxf9Gau3L2B0kMPC/giphy.gif?cid=ecf05e4752pf5db8at27ms7voi8coytccw6il1v27e8o3mke&rid=giphy.gif&ct=g)

<div style="text-align: center">
  <i>🎶 My name is, chka-chka, "Bernard de La Villardière" 🎵</i>
</div>

## Liste d'utilisateurs

Comme vous n'avez peut-être pas un tenant Microsoft 365 ou un annuaire Active Directory sous la main, je vous ai mis à disposition un tableau CSV avec un liste d'utilisateurs fictif. Vous pouvez récupérer le CSV avec cette commande :

```powershell

$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'

```

...ou télécharger le fichier directement sur [GitHub](https://github.com/leobouard/leobouard.github.io/blob/main/assets/files/users.csv)