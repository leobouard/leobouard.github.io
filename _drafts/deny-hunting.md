---
title: "Deny Hunting dans Active Directory"
description: "Rechercher dans l'annuaire les configurations étranges au niveau des permissions des objets"
tags: ["activedirectory", "powershell"]
listed: true
---

## Explication

<iframe width="560" height="315" src="https://www.youtube.com/embed/BohWwsyGZuU?si=J_wyqd43_GvKHEin" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

## Deny Hunting

### Récupération des informations

```powershell
# Récupération de tous les objets du domaine qui nous intéressent
$includedClasses = 'user', 'inetOrgPerson', 'group', 'computer', 'organizationalUnit', 'container', 'domainDNS', 'msDS-ManagedServiceAccount'
$objects = Get-ADObject -Filter * -Properties NTSecurityDescriptor, AdminCount | Where-Object { $_.ObjectClass -in $includedClasses }

# Ajout des accès directs (non hérités)
$objects | Add-Member -MemberType NoteProperty -Name DirectAccess -Value $null -Force
$objects | ForEach-Object { $_.DirectAccess = $_.NTSecurityDescriptor.Access | Where-Object { $_.IsInherited -eq $false } }

# Ajout des accès directs en Deny
$objects | Add-Member -MemberType NoteProperty -Name DirectAccessDeny -Value $null -Force
$objects | ForEach-Object { $_.DirectAccessDeny = $_.DirectAccess | Where-Object {
    $_.AccessControlType -eq 'Deny' -and
    $_.ActiveDirectoryRights -notin 'DeleteTree, Delete', 'DeleteChild, DeleteTree, Delete' -and
    $_.ObjectType -ne 'ab721a53-1e2f-11d0-9819-00aa0040529b' }
}
```

Certaines autorisations "Deny" sont légitimes et font partie intégrante d'une configuration "normale" de Active Directory. On y retrouve notamment :

- les objets protégés contre la suppression accidentelle
- les utilisateurs avec la case "Cannot change password" cochée

Ces cas sont déjà générés dans le script ci-dessus.

### Visualisation des propriétaires

```powershell
$objects | Group-Object -Property { $_.NTSecurityDescriptor.Owner } |
Sort-Object Count -Descending |
Select-Object Count, Name, @{ N = 'Object'; E = { $_.Group.Name } }
```

### Vérification du cassage d'héritage

```powershell
$objects | Where-Object {
    $_.NTSecurityDescriptor.Access.IsInherited -notcontains $true -and
    $_.AdminCount -ne 1
} | Format-Table Name, ObjectClass, DistinguishedName -AutoSize
```

### Vérification des ACE "Deny" sur les objets AD

```powershell
$objects | Where-Object { $_.DirectAccessDeny -and $_.AdminCount -ne 1 } |
Select-Object Name, ObjectClass, AdminCount, 
    @{ N = 'IdentityReference'; E = { $_.DirectAccessDeny.IdentityReference } },
    @{ N = 'ActiveDirectoryRights'; E = { $_.DirectAccessDeny.ActiveDirectoryRights } },
    DistinguishedName
```
