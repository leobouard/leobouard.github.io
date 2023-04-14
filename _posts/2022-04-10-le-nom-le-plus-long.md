---
layout: post
title: "Qui a le nom le plus long ?"
description: "Saurez-vous retrouver la personne avec le nom complet (prénom et nom) le plus long de la liste ?"
background: "#e5a8a8"
tags: challenge
listed: true
nextLink:
  name: "Voir la solution"
  id: "/2022/04/10/le-nom-le-plus-long-soluce"
---

Bon bah là pas besoin de broder... Tout est dans le titre ! 😄

Vous avez une liste d'utilisateurs (type annuaire Active Directory) et vous voulez savoir qui a le nom le plus long ?

Est-ce que c'est le comptable d'origine indienne ? Ou votre collègue sud-américaine avec plus de prénoms que vous n'avez de lettres dans votre nom de famille ? Ou alors simplement un présentateur TV bien connu avec un nom à particule...

![eminem-my-name-is](https://media2.giphy.com/media/xUOxf9Gau3L2B0kMPC/giphy.gif?cid=ecf05e4752pf5db8at27ms7voi8coytccw6il1v27e8o3mke&rid=giphy.gif&ct=g)

<div style="text-align: center">
  <i>🎶 Hi, my name is, what? My name is, who?<br>My name is, chka-chka, "Bernard de la Villardière" 🎵</i>
</div>

## Un peu plus de défi

Vous trouvez ça trop facile ? Je comprends, du coup je vous propose d'essayer une version qui n'utilise aucune boucle. Donc pas le droit d'utiliser :

- foreach
- ForEach-Object 
- for
- while
- do-while ou do-until

(Et oui c'est quand même faisable ! 😁)

Pour ne pas vous laisser sans rien, voici deux indices :

1. [La commande qui peut-être utilisée pour faire ça](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/select-object)
2. [Comment l'utiliser dans ce contexte](https://docs.microsoft.com/fr-fr/powershell/scripting/samples/selecting-parts-of-objects--select-object-)

## Liste d'utilisateurs

Comme vous n'avez peut-être pas un tenant Microsoft 365 ou un annuaire Active Directory sous la main, je vous ai mis à disposition un tableau CSV avec un liste d'utilisateurs fictif. Vous pouvez récupérer le CSV avec cette commande :

```powershell
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'
```

...ou télécharger le fichier directement sur [GitHub](https://github.com/leobouard/leobouard.github.io/blob/main/assets/files/users.csv)