---
layout: post
title: "Le nom le plus long"
prevLink:
  name: "Retour au défi"
  id: "/2022/04/10/le-nom-le-plus-long"
---

Dans les solutions ennoncées, je me base sur mon fichier CSV qui est récupérable avec ce bout de code :

```powershell
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'
```

## La solution classique

Droit au but et de manière scolaire, on va calculer la longueur du nom de chaque utilisateur. Si le nom est plus long que le précédent "record", on garde le nom & la longueur de celui-ci en mémoire.

```powershell
$longestName = ""
$maxLength   = 0
$users | Foreach-Object {
    $name = $_.displayName
    $length = ($_.displayName).Length
    if ($length -gt $maxLength) { 
        $maxLength = $length
        $longestName = $name
    }
}
"`'$longestName`' est le nom le plus long avec $maxLength caractères"
```

C'est bien sympa mais dans ce modèle, il ne peut y avoir qu'un seul "record" (même si dans la réalité la première place est peut-être partagée entre plusieurs noms).

On pourrait modifier le comportement du script en lui demandant d'afficher le texte *"Pierre Dupont est le nom le plus long avec 13 caractères"* à chaque fois que le record est battu ou égalé. On peut faire ça en modifiant l'opérateur de comparaison de `-gt` (plus grand que) à `-ge` (plus grand ou égal) :

```powershell
$longestName = ""
$maxLength   = 0
$users | Foreach-Object {
    $name = $_.displayName
    $length = ($_.displayName).Length
    if ($length -ge $maxLength) { 
        $maxLength = $length
        $longestName = $name
        "`'$longestName`' est le nom le plus long (pour l'instant) avec $maxLength caractères"
    }
}
```

Ça reste deux solutions valables puisqu'elles répondent bien à la question de départ : **Qui a le nom le plus long ?**

## Ma solution préférée

Cette fois-ci, on va un peu plus loin et on va venir dresser un classement des noms :

```powershell
$users | ForEach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name nameLength -Value ($_.displayName).Length -Force
}
$users | Sort-Object -Property nameLength -Descending | Select-Object -First 10 | Format-Table displayName,country,city,nameLength
```

Pour ça, on ajoute une nouvelle propriété "nameLength" à notre objet de base. Une fois que tous les utilisateurs ont reçu cette nouvelle propriété, il suffit simplement de trier les objets du nom le plus long au nom le plus court… et c'est bon !

Simple et efficace :

DisplayName | Country | City | NameLength
----------- | ------- | ---- | ----------
Alexandrin Courtemanche | FR | BELFORT | 23
Alphonsine De La Vergne | FR | AUXERRE | 23
Christophe Deslauriers | CH | STECKBORN | 22

On pourrait même faire une version dérivée qui se passerait de la boucle `ForEach-Object`. Pour ça, on utilise la commande `Select-Object` pour calculer la propriété "nameLength" à la volée :

```powershell
$users | Select-Object displayName,@{Name='nameLength';Expression={($_.displayName).Length}} | Sort-Object nameLength -Descending | Select-Object -First 10 | Format-Table
```

Et on peut même envisager une version condensée : `($users|select displayName,@{N='l';E={($_.displayName).Length}}|sort l -d)[0..5]`
