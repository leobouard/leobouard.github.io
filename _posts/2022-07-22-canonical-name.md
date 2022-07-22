---
layout: post
title: "CanonicalName dans l'AD"
description: "Mort au DistinguishedName !"
tags: howto
thumbnailColor: "#4c5b61"
icon: 🌳
---

L'emplacement dans l'aborescence Active Directory est souvent très important et peu s'avérer utile pour la génération de rapports. L'attribut le plus utilisé pour determiner cette information est le "Distinguished Name", mais si vous ne connaissez pas son cousin le "Canonical Name" cet article est fait pour vous !

En bref, la différence principale est la suivante :

- le DistinguishedName part de l'objet pour aller vers la racine
- le CanonicalName part de la racine pour aller vers l'objet

## Syntaxe

Pour prendre un exemple, voici une arborescence Active Directory :

```
🌐 labouabouate.com
  📁 LBB
    📁 US
      📁 Users
        🧑‍💼 John Smith
```

Qui peut être traduite de la manière suivante :

### DistinguishedName

DistinguishedName : `CN=John Smith,OU=Users,OU=US,OU=LBB,DC=labouabouate,DC=com`

Identifiant | Type d'attribut
----------- | ---------------
DC | domainComponent
CN | commonName
OU | organizationalUnitName

Le tableau complet est disponible ici : [Distinguished Names - Microsoft Docs](https://docs.microsoft.com/previous-versions/windows/desktop/ldap/distinguished-names)

### CanonicalName

`labouabouate.com/LBB/US/Users/John Smith`

## DistinguishedName c'est quoi ?

DistinguishedName fait partie des propriétés affichées par défaut lors d'une requête PowerShell :

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

