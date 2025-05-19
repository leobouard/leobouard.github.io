---
title: "Modifier le schéma Active Directory"
description: ""
tags: ["activedirectory", "powershell"]
listed: true
---

## Prérequis

### Activation de la console "Active Directory Schema"

Installation des RSAT Active Directory :

```powershell
Install-WindowsFeature -Name 'RSAT-AD-Tools'
```

Activation de la DLL :

```powershell
regsvr32.exe schmmgmt.dll
```

La console devrait maintenant apparaitre dans la liste des snap-ins disponibles sur `mmc.exe`.

### Lister les membres du groupe "Schema Admins"

```powershell
$sid = "$((Get-ADDomain).DomainSID)-518"
$schmGroup = Get-ADGroup $sid
$schmGroup | Get-ADGroupMember
```

### Si besoin : ajout dans le groupe

```powershell
Add-ADGroupMember -Identity $schmGroup -Members $env:USERNAME
```

## Création d'un attribut

### Génération d'un OID

Commande New-Oid

### Préparation des syntaxes

Récupération de OMSyntax et AttributeSyntax

https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/7cda533e-d7a4-4aec-a517-91d02ff4a1aa

### Création de l'attribut HireDate

Création de l'attribut et ajout sur la classe "user"

```powershell
New-ADAttribute -Name 'hireDate' -Description 'First day of the contract' -Type 'datetime'
Add-ADAttributeToClass 'hireDate' 'user' # use the ldapName
```

Redémarrage du DC portant le rôle Schema Master sur la forêt :

```powershell
Restart-Computer -ComputerName (Get-ADForest).SchemaMaster
```

Ajout d'une valeur dans l'attribut :

```powershell
Set-ADUser leob -Replace @{ hireDate = Get-Date '17/09/2018' }
```

## Requête sur les attributs

Lister les attributs hors de la catégorie 1 (inclus dans le schéma de base avec le système) :

```powershell
Get-ADObject -Filter {objectClass -eq 'attributeSchema'} -SearchBase (Get-ADRootDSE).schemaNamingContext -Properties systemFlags | Where-Object {$_.SystemFlags -bxor 16}
```

Lister les attributs construits :

```powershell
Get-ADObject -Filter {objectClass -eq 'attributeSchema'} -SearchBase (Get-ADRootDSE).schemaNamingContext -Properties systemFlags | Where-Object {$_.SystemFlags -band 4}
```
