---
title: "La plupart de vos OU ne servent à rien"
description: "Y'a deux types d'unités d'organisations : celles qui sont utiles et les autres"
tags: activedirectory
listed: true
---

## Utilité d'une unité d'organisation

Les unités d'organisation (OU) dans Active Directory (AD) servent à structurer et à gérer les objets (utilisateurs, groupes, ordinateurs, etc.) de manière logique et hiérarchique. Voici leurs principaux rôles :

- Structuration logique de l'annuaire
- Délégation de l'administration
- Application de stratégie de groupe (GPO)
- Séparation des rôles et des responsabilités

### Structuration logique de l'annuaire

### Délégation de l'administration

### Application de stratégie de groupe (GPO)

### Séparation des rôles et des responsabilités

🎯 Objectifs des unités d'organisation

Structuration logique de l’annuaire

Permet de refléter l’organisation réelle de l’entreprise (par département, site géographique, fonction, etc.).
Facilite la navigation et la recherche dans l’annuaire.

Délégation de l’administration

On peut attribuer des droits d’administration spécifiques à une OU sans donner un accès global à tout l’AD.
Exemple : un responsable IT local peut gérer les comptes utilisateurs de son site sans toucher aux autres.

Application de stratégies de groupe (GPO)

Les GPO peuvent être appliquées à des OU spécifiques pour contrôler les paramètres des utilisateurs et des ordinateurs.
Cela permet une gestion fine des politiques de sécurité, des configurations système, etc.

Séparation des rôles et des responsabilités

Utile pour les grandes entreprises avec plusieurs équipes IT ou des environnements multi-tenant.

📌 Exemple concret
Imaginons une entreprise avec deux sites : Rennes et Nantes. On pourrait avoir :

- Entreprise
   ├── Rennes
   │    ├── Utilisateurs
   │    └── Ordinateurs
   └── Nantes
        ├── Utilisateurs
        └── Ordinateurs

Chaque site peut avoir ses propres GPO et ses propres administrateurs locaux.

###

```
🌐 contoso.com
  📁 CONTOSO
    📁 
```

```powershell
function Show-ADOrganizationalUnitPurpose {
    param(
        [string]$SearchBase = (Get-ADDomain).DistinguishedName,
        [int]$Indentation = 2
    )

    # Gather all the organizational units
    $ous = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName, LinkedGroupPolicyObject, NTSecurityDescriptor -SearchBase $SearchBase

    # Add new properties
    'TreeView', 'gpLinkCount', 'delegationCount', 'members' | ForEach-Object {
        $ous | Add-Member -MemberType NoteProperty -Name $_ -Value $null -Force
    }

    # Create report
    $ous | Sort-Object CanonicalName | ForEach-Object {
        Write-Host "Processing $($_.CanonicalName)" -ForegroundColor Yellow

    # Tree view
    $level = ([regex]::Matches($_.CanonicalName, "/" )).count
    $whiteSpaces = ("  " * $level)
    $_.TreeView = "$whiteSpaces$($_.Name)"

    # gpLinks count
    $_.gpLinkCount = ($_.LinkedGroupPolicyObjects | Measure-Object).Count

    # delegation count
    $_.DelegationCount = ($_.NTSecurityDescriptor.Access |
        Where-Object {
            $_.IsInherited -eq $false -and
            $_.AccessControlType -eq 'Allow' -and
            $_.IdentityReference -like "$((Get-ADDomain).NetbiosName)\*" -and
            $_.IdentityReference -notmatch 'Admins du domaine|Exchange Trusted Subsystem|Organization Management|Exchange Organization Administrators'
        } | Measure-Object).Count

    $_.Members = (Get-ADObject -Filter {objectClass -ne 'organizationalUnit'} -SearchBase $_.DistinguishedName | Measure-Object).Count
}

    
}
$ous = Get-ADOrganizationalUnit -Filter * -Properties CanonicalName, LinkedGroupPolicyObjects, NTSecurityDescriptor




$ous | Sort-Object CanonicalName | Format-Table gpLinkCount, DelegationCount, members, TreeView

```
