---
title: "Comment détruire votre Active Directory"
description: "Votre forêt s'auto-détruira dans 3, 2, 1..."
tags: active-directory
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

## Détection de la création d'objet dynamique

```powershell
$filterXPath = "Event[System[EventID=5136]] and *[EventData[Data[@Name='AttributeValue']='1.3.6.1.4.1.1466.101.119.2']]"
Get-WinEvent -ProviderName Microsoft-Windows-Security-Auditing -FilterXPath $filterXPath
```

[AD Object Detection: Detecting the undetectable (dynamicObject) \| Microsoft Learn](https://learn.microsoft.com/en-us/archive/blogs/pfesweplat/ad-object-detection-detecting-the-undetectable-dynamicobject)