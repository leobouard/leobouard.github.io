---
layout: post
title: "CanonicalName dans l'AD"
description: "Mort au DistinguishedName !"
tags: howto
thumbnailColor: "#4c5b61"
icon: 🌳
---

Bien souvent, tout est une question d'aborescence et par défaut on a tendance à utiliser la propriété "DistinguishedName" pour déterminer où se trouve un objet dans l'Active Directory. Ce n'est pas un mal en soit, mais 

`CN=John Smith,OU=Users,OU=US,OU=LBB,DC=labouabouate,DC=com`

En réel, ça se traduit donc par l'arborescence suivante :

```
  🌐 labouabouate.com
    📁 LBB
      📁 US
        📁 Users
          🧑‍💼 John Smith
```

Identifiant | Type d'attribut
----------- | ---------------
DC | domainComponent
CN | commonName
OU | organizationalUnitName

Le tableau complet est disponible ici : [Distinguished Names | Microsoft Docs](https://docs.microsoft.com/previous-versions/windows/desktop/ldap/distinguished-names)


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

## CanonicalName c'est quoi ?

