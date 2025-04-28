---
title: "Object dynamiques dans Active Directory"
description: "Cet objet s'auto-détruira dans 3, 2, 1..."
tags: active-directory
listed: true
---

## En bref

Windows Server 2003 a introduit de nombreuses fonctionnalités dans Active Directory, dont la plupart sont encore utilisées aujourd'hui. Cependant, au moins une nouveauté de Windows Server 2003 est tombé aux oubliettes : **les objets dynamiques**.

Les objets dynamiques désignent une classe d'objet qui ont une durée de vie limitée et qui seront supprimés automatiquement par Active Directory. Ceux-ci peuvent prendre la forme de n'importe quelle autre classe d'objet : utilisateur, groupe, unité d'organisation...

Cet article est inspiré du post de Narayanan Subramanian sur Medium : [fun with dynamic Objects in AD: Part 1](https://medium.com/@nannnu/fun-with-dynamic-objects-in-ad-part-1-743c21dd934f), à la différence que je n'utilise pas les outils `admod` et `adfind` mais plutôt les bonnes vieilles commandes PowerShell Active Directory.

### Fonctionnement

Les objets dynamiques : 

- Peuvent prendre la forme de n'importe quelle classe d'objet dans Active Directory
- Sont créés avec une durée de vie limitée qui est comprise entre 15 min minimum et 1 an maximum
- Leur durée de vie est indiquée en secondes dans l'attribut `entryTTL`
- L

### Création dans le schéma ou la partition

Les objets dynamiques en bref :

- Ils sont avec une durée de vie en seconde, lorsque la durée de vie atteint 0, le compte disparaît du domaine sans passer par la corbeille Active Directory
- Peuvent être des comptes utilisateurs, des groupes, des ordinateurs, des unités d'organisation...
- Ne peuvent pas être créés dans la partition "Configuration" ou "Schéma" de Active Directory


- Disparait sans laisser de trace, introuvable dans la corbeille Active Directory
- Une OU "dynamique" ne peut pas contenir d'objet statique
- La date de suppression est visible dans l'attribut `msDS-Entry-Time-To-Die` au format UTC

## Création d'un objet dynamique

### Contrôle de la configuration par défaut

Il existe deux paramètres sur les objets dynamiques dans la configuration du domaine Active Directory : `DynamicObjectMinTTL` et `DynamicObjectDefaultTTL`. Les deux valeurs se trouvent dans l'attribut `msDS-Other-Settings` présent sur l'objet `contoso.com/Configuration/Services/Windows NT/Directory Service`.

Paramètre | Valeur par défaut | Description
--------- | ----------------- | -----------
DynamicObjectMinTTL | 900 (15 minutes) | Si un objet dynamique est créé avec une durée de vie inférieure à celle indiquée dans ce paramètre, la durée de vie sera automatiquement ajustée à cette valeur
DynamicObjectDefaultTTL | 86400 (24 heures) | Si aucun TTL n'est spécifié pour un objet dynamique, c'est cette valeur qui sera utilisée par défaut

Pour consulter la configuration de votre domaine en PowerShell :

```powershell
$domainDn = (Get-ADDomain).DistinguishedName
$path = "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$domainDn"
Get-ADObject $path -Properties 'msDS-Other-Settings'
```

### Création d'un objet

Il n'existe pas de commande PowerShell issue du module Active Directory pour créer un objet dynamique, l'utilisation de .NET est obligatoire. Voici un exemple de code pour créer un objet dynamique de type "utilisateur" :

```powershell
$dynamicObject = ([ADSI]("LDAP://OU=Users,DC=contoso,DC=com")).Create('user', 'CN=dynamicUser,OU=Users,DC=contoso,DC=com')
$dynamicObject.PutEx(2, 'objectClass', @('dynamicObject', 'user'))
$dynamicObject.Put('entryTTL', 900)
$dynamicObject.SetInfo()
```

Ou plus simplement avec une fonction personnalisée : [New-ADDynamicObject](https://gist.github.com/leobouard/16f90612a5461d2a9cec49cad6056929)

```powershell
New-ADDynamicObject -Name 'dynamicUser' -Path 'OU=Users,DC=contoso,DC=com' -TimeToLive 900 -ObjectType user
```

Ces commandes vont créer un objet dynamique de type utilisateur nommé "dynamicUser" sous `contoso.com/Users` avec une durée de vie de 900 secondes (15 minutes).

### Modifier la durée de vie d'un objet dynamique

Avec la commande suivante, on va aller modifier directement la valeur de l'attribut `entryTTL` qui contient la durée de vie restante pour l'objet. Cette action permet donc de prolonger la durée de vie d'un objet si besoin.

```powershell
Get-ADObject -Filter {SamAccountName -eq 'dynamicUser'} | Set-ADObject -Replace @{entryTTL = 900}
```

> **Rappel :** vous ne pouvez pas réduire la durée de vie restante d'un compte en dessous de la valeur `DynamicObjectMinTTL` de votre domaine.

### Lister tous les objets dynamiques du domaine

Pour lister les objets dynamique, il n'est pas possible d'utiliser l'attribut `entryTTL`. La valeur de celui-ci n'étant pas fixe (elle est calculée en temps réel), il est impossible de l'utiliser comme filtre. Vous tomberez sur l'erreur suivante : *Get-ADObject : A Filter was passed that uses constructed attributes*.

A la place, on peut utiliser `msDS-Entry-Time-To-Die` qui contient la date programmée de fin de vie de l'objet (valeur fixe) :

```powershell
Get-ADObject -LDAPFilter '(msDS-Entry-Time-To-Die=*)' -Properties entryTTL, msDS-Entry-Time-To-Die
```

## Comportement d'un objet dynamique

### Création d'un objet statique dans un objet dynamique

Lorsque vous 

Aucun problème en revanche pour créer un objet dynamique dans un autre objet dynamique

"Windows cannot create the object testGroup because: The server is unwilling to process the request"

## Détection de la création d'objet dynamique

```powershell
$filterXPath = "Event[System[EventID=5136]] and *[EventData[Data[@Name='AttributeValue']='1.3.6.1.4.1.1466.101.119.2']]"
Get-WinEvent -ProviderName Microsoft-Windows-Security-Auditing -FilterXPath $filterXPath
```

[AD Object Detection: Detecting the undetectable (dynamicObject) \| Microsoft Learn](https://learn.microsoft.com/en-us/archive/blogs/pfesweplat/ad-object-detection-detecting-the-undetectable-dynamicobject)