---
title: "Object temporaires dans Active Directory"
description: "Cet objet s'auto-détruira dans 3, 2, 1..."
tags: active-directory
listed: true
---

- Disparait sans laisser de trace, introuvable dans la corbeille Active Directory
- Une OU "dynamique" ne peut pas contenir d'objet statique 
- La date de suppression est visible dans l'attribut `msDS-Entry-Time-To-Die` au format UTC



```powershell
function New-ADDynamicObject { 
    param(
        [string]$Name,
        [string]$Path = ((Get-ADDomain).DistinguishedName),
        [int]$TimeToLive = 60,
        [ValidateSet('computer','group','organizationalUnit','user')][string]$ObjectType
    )

    if ($ObjectType -eq 'organizationalUnit') { 
        $CommonName = "OU=$Name"
    }
    elseif ($ObjectType -eq 'computer') {
        $Name = if ($Name.Length -gt 14) { $Name.SubString(0, 14) } else { $Name }
        $SamAccountName = "$Name`$"
        $CommonName = "CN=$Name"
    }
    else {
        $CommonName = "CN=$Name"
        $SamAccountName = if ($Name.Length -gt 20) { $Name.SubString(0, 20) } else { $Name }
    }

    $dynamicObject = ([ADSI]("LDAP://$Path")).Create($ObjectType, $CommonName)
    $dynamicObject.PutEx(2, 'objectClass', @('dynamicObject', $ObjectType))
    $dynamicObject.Put('entryTTL', $TimeToLive)
    if ($ObjectType -ne 'organizationalUnit') { $dynamicObject.Put('SamAccountName', $SamAccountName) }
    $dynamicObject.SetInfo()

    Get-ADObject -Identity "$CommonName,$Path" -Properties SamAccountName, msDS-Entry-Time-To-Die
}
```
