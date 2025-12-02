---
title: "La plupart de vos unités d'organisation ne servent à rien"
description: "Y'a deux types d'unités d'organisations : celles qui sont utiles et les autres"
tags: activedirectory
listed: true
---

Une unité d'organisation dans Active Directory ne sert techniquement qu'à deux choses :

- Appliquer des délégations
- Appliquer les liens de stratégie de groupe


## 

Il s'agit en général de l'une des premières choses que je fais chez mes clients :

{% include github-gist.html name="Show-ADOrganizationalUnitPurpose" id="23b52987223a05194207ea5c61b7b010" %}

Le point d'entrée est l'utilisation de ma commande `Show-ADOrganizationalUnitPurpose` avec un compte administrateur du domaine. À partir de là, on va pouvoir faire plusieurs requêtes pour souligner les informations importantes.

La première étape :

```powershell
$report = Show-ADOrganizationalUnitPurpose
```

### OU vides

De la même manière qu'un dossier vide ne sert à rien, une unité d'organisation qui ne contient aucun objet n'a aucune utilité dans votre Active Directory et peut être supprimée :

```powershell
$report | Where-Object { $_.membersCount -eq 0 } | Format-Table CanonicalName, MembersCount, LinkedGPOCount
```

### OU sans délégation ou lien GPO

Voici une vision de toutes les OU réellement utiles à votre domaine :

```powershell
$report | Where-Object { $_.DelegatedTo -or $_.LinkedGPOName } | Format-Table TreeView
```

Et voici maintenant les OU superflues :

```powershell
$report | Where-Object { !$_.DelegatedTo -and !$_.LinkedGPOName } | Format-Table CanonicalName, MembersCount
```

On peut même calculer le pourcentage d'OU superflues :

```powershell
$uselessOU = ($report | Where-Object { !$_.DelegatedTo -and !$_.LinkedGPOName } | Measure-Object).Count
$allOU = ($report | Measure-Object).Count
$ratio = [math]::Round(($uselessOU / $allOU * 100), 2)
Write-Host "$ratio% of your organizational unit are useless"
```

### Visibilité des délégations

Voici tous les objets qui possèdent au moins une délégation sur vos unités d'organisation :

```powershell
$report.DelegatedTo | Sort-Object -Unique
```

### OUs sur lesquelles un objet à une permission

Filtre inverse maintenant, on affiche toutes les OUs sur lesquelles le compte `CONTOSO\john.doe` a des permissions :

```powershell
$report | Where-Object {$_.delegatedTo -contains 'CONTOSO\john.doe'} | Format-Table CanonicalName, DelegatedTo
```

### OUs avec une délégation orphelines

```powershell
$report | Where-Object { $_.delegatedTo -like '*S-1-5-21-*' } | Format-Table CanonicalName, DelegatedTo
```

### Affichage des types d'objets par OU

Pour chaque OU, afficher la répartition de chaque type d'objets :

```powershell
$report | ForEach-Object {
    Write-Host $_.CanonicalName -ForegroundColor "Yellow"
    $_.MembersRepartition | Format-Table -AutoSize -RepeatHeader
}
```

### Afficher toutes les OUs qui contiennent un certain type d'objet

Toutes les OU qui contiennent au moins un objet ordinateur :

```powershell
$report | Where-Object { $_.MembersRepartition.Name -contains 'computer' } | Format-Table CanonicalName, MembersCount
```

### Autres scripts

```powershell
$dnsRoot = (Get-ADDomain).DNSRoot
$gpo = Get-ChildItem -Path "\\$dnsRoot\SYSVOL\$dnsRoot\Policies" -Filter "{*}"

$gpo | Add-Member -MemberType NoteProperty -Name "GPOName" -Value $null -Force
$gpo | Add-Member -MemberType NoteProperty -Name "NTSecurityDescriptor" -Value $null -Force

$gpo | ForEach-Object {
    $_.GPOName = (Get-GPO -Guid $_.PSChildName).DisplayName
    $_.NTSecurityDescriptor = Get-Acl -Path $_.FullName
}

# Filter GPOs where 'Authenticated Users' do not have access
$gpo | Where-Object {$_.NTSecurityDescriptor.Access.IdentityReference -notcontains 'NT AUTHORITY\Authenticated Users'}

# Mettre en évidence les GPOs sans paramètres utilisateur actifs
$gpo = Get-GPO -All
$test = $gpo | Where-Object {
    $_.User.DSVersion -eq 0 -and
    $_.User.SysvolVersion -eq 0 -and
    $_.GPOStatus -ne 'UserSettingsDisabled'
}

# Afficher les GPO orpherlines
$gpo = Get-GPO -All
$ous = Get-ADOrganizationalUnit -Filter * -Properties LinkedGroupPolicyObjects
$appliedGPO = $ous.LinkedGroupPolicyObjects | Sort-Object -Unique | ForEach-Object { ($_ -split '{' -split '}')[1] }
$gpo | Where-Object { $_.Id -notin $appliedGPO } | Sort-Object DisplayName | Select-Object DisplayName, Id
```