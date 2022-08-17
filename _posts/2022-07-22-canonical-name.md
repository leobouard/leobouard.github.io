---
layout: post
title: "CanonicalName dans l'AD"
description: "Mort au DistinguishedName !"
tags: howto
thumbnailColor: "#26c9fc"
icon: 🛣️
---

L'emplacement dans l'aborescence Active Directory est souvent très important et peu s'avérer utile pour la génération de rapports. L'attribut le plus utilisé pour determiner cette information est le "Distinguished Name", mais si vous ne connaissez pas son cousin le "Canonical Name" cet article est fait pour vous !

En bref, la différence principale est la suivante :

- le DistinguishedName part de l'objet pour aller vers la racine du domaine
- le CanonicalName part de la racine du domaine pour aller vers l'objet

## Syntaxe

Pour prendre un exemple, voici une arborescence Active Directory :

```
🌐 labouabouate.com
  📁 LBB
    📁 US
      📁 Users
        🧑‍💼 John Smith
```

Le chemin vers l'objet utilisateur "John Smith" sera traduit comme ça :

- DistinguishedName : "CN=John Smith,OU=Users,OU=US,OU=LBB,DC=labouabouate,DC=com"
- CanonicalName : "labouabouate.com/LBB/US/Users/John Smith"

On voit bien que dans le 

### DistinguishedName

Le DistinguishedName apparait par défaut lors d'une requête PowerShell du type Get-ADUser :

```

PS C:\> Get-ADUser john.smith

DistinguishedName : CN=John Smith,OU=Users,OU=US,OU=LBB,DC=labouabouate,DC=com
Enabled           : True
GivenName         : John
Name              : John Smith
ObjectClass       : user
ObjectGUID        : fb673fd3-3376-4d90-8128-6d148ff324e4
SamAccountName    : john.smith
SID               : S-1-5-21-8465173170-3674827177-1642800199-26067
Surname           : Smith
UserPrincipalName : john.smith@labouabouate.com

```

Si on veut parser le DistinguishedName pour obtenir 




On reprend l'exemple ci-dessus : `CN=John Smith,OU=Users,OU=US,OU=LBB,DC=labouabouate,DC=com`

Identifiant | Type d'attribut
----------- | ---------------
DC | domainComponent
CN | commonName
OU | organizationalUnitName

Le tableau complet est disponible ici : [Distinguished Names - Microsoft Docs](https://docs.microsoft.com/previous-versions/windows/desktop/ldap/distinguished-names)

### CanonicalName

`labouabouate.com/LBB/US/Users/John Smith`

## Cas pratique

On travaille dans l'arborescence Active Directory suivante :

```
🌐 labouabouate.com
  📁 LBB
    📁 FR
      📁 Rennes
        📁 Users
          🧑‍💼 Pierre Dupont
    📁 US
      📁 Users
        🧑‍💼 John Smith
```

Un élement important à connaître pour nos rapport est l'unité organisationnelle à laquelle l'utilisateur appartient. Dans notre cas, il est important de savoir s'il appartient à "FR" ou "US".

### Parser le DistinguishedName

```powershell

$root = "OU=LBB,DC=labouabouate,DC=com"
$dn = "CN=John Smith,OU=Users,OU=US,$root","CN=Pierre Dupont,OU=Users,OU=Rennes,OU=FR,$root"
$dn | ForEach-Object {
  (($_ -split ',' | Select-Object -Last 4)[0] -split '=')[1]
}

```

Comme vous pouvez le voir, ça se fait mais y'a plus simple. 

### Parser le CanonicalName

```powershell

$root = "labouabouate.com/LBB"
$cn = "$root/US/Users/John Smith","$root/FR/Rennes/Users/Pierre Dupont"
$cn | ForEach-Object {
  ($_ -split '/')[2]
} 

```