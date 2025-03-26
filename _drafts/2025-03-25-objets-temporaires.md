---
title: "Object temporaires dans Active Directory"
description: "Cet objet s'auto-détruira dans 3, 2, 1..."
tags: active-directory
listed: true
---



```powershell
function New-ADDynamicObject {
    param(
        [string]$Name,
        [string]$Path = ((Get-ADDomain).DistinguishedName),
        [int]$TimeToLive = 3600,
        [string]$ObjectType = 'user'
    )

    $dynamicObject = ([ADSI]("LDAP://$Path")).Create($ObjectType, "CN=$Name")
    $dynamicObject.PutEx(2,'objectClass',@('dynamicObject',$ObjectType))
    $dynamicObject.Put('entryTTL', $TimeToLive)
    $dynamicObject.Put('SamAccountName', $Name)
    $dynamicObject.SetInfo()
}
```

