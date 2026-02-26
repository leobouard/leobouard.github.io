---
title: "Deep Dive - Password Settings Object"
description: "On creuse en profondeur sur le fonctionnement des stratégies de mot de passe à fin grain sur Active Directory"
tags: ["activedirectory", "powershell"]
listed: true
---

## Introduction

Les *Password Settings Objects* (PSO) permettent de définir des stratégies de mots de passe granulaires en Active Directory. Contrairement à la *Default Domain Password Policy* qui s'applique globalement, les PSO offrent une flexibilité pour adapter les exigences de complexité, de longueur et de durée de vie des mots de passe à différentes catégories d'utilisateurs ou de comptes de service.

Cet article approfondit le fonctionnement des PSO, en particulier les mécanismes de priorité et le comportement "tie-breaker" qui intervient quand plusieurs PSO sont appliquées avec la même priorité. Vous découvrirez également comment auditer et visualiser la configuration des PSO dans votre domaine, ainsi que les bonnes pratiques pour les organiser correctement.

## Attributs liés aux PSO

### Obtenir la date d'expiration prévue d'un mot de passe

La propriété `msDS-UserPasswordExpiryTimeComputed` contient la date d'expiration prévue du mot de passe, selon la PSO appliquée, au format FileTime. On peut en extraire des informations pertinentes :

```powershell
$users = Get-ADUser john.smith -Properties 'msDS-UserPasswordExpiryTimeComputed'
$users | Select-Object Name, DistinguishedName, 'msDS-UserPasswordExpiryTimeComputed', @{
    N = 'PasswordExpirationTime'
    E = { [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed') }
}
```

> Pour les mots de passe qui n'expirent jamais, la propriété `msDS-UserPasswordExpiryTimeComputed` sera vide.

Résultat :

```plaintext
Name                                : john.smith
DistinguishedName                   : CN=john.smith,CN=Users,DC=corp,DC=contoso,DC=com
msDS-UserPasswordExpiryTimeComputed : 134253798109491502
PasswordExpirationTime              : 08/06/2026 10:10:10
```

### Obtenir la PSO prioritaire sur un utilisateur

Pour un utilisateur seul, la façon la plus simple et qui donne le résultat le plus complet est la commande `Get-ADUserResultantPasswordPolicy` :

```powershell
Get-ADUser john.smith | Get-ADUserResultantPasswordPolicy
```

> Si la réponse est vide : l'utilisateur est soumis à la *Default Domain Password Policy*.

### Lister le nombre de comptes par PSO

Pour plusieurs utilisateurs, la meilleure méthode est de requêter l'attribut calculé `msDS-ResultantPSO`. Celui-ci donne le DistinguishedName de la PSO appliquée sur le compte utilisateur.

Ce bout de code permet de montrer la répartition des différentes PSO sur les utilisateurs de votre domaine :

```powershell
$users = Get-ADUser -Filter * -Properties 'msDS-ResultantPSO'
$users | Group-Object 'msDS-ResultantPSO' -NoElement | Sort-Object Count -D | Format-Table -AutoSize
```

Voici un exemple de résultat :

Count | Name
----- | ----
5415 |
2070 | CN=Employees,CN=Password Settings Container,CN=System…
1546 | CN=Externals,CN=Password Settings Container,CN=System…
1115 | CN=ServiceAccounts,CN=Password Settings Container,CN=System…
354 | CN=Administrators,CN=Password Settings Container,CN=System…
157 | CN=Technical,CN=Password Settings Container,CN=System…

> Encore une fois, si la valeur est vide (comme c'est le cas pour 5415 utilisateurs dans mon exemple) c'est que le compte est soumis à la *Default Domain Password Policy*. Également, n'oubliez pas que les PSO peuvent s'appliquer aux gMSA, donc le résultat donné n'est que partiel.

### Visualiser les utilisateurs soumis à plusieurs PSO

Si les priorités de vos PSO sont bien gérées, le fait qu'un utilisateur soit soumis à plusieurs PSO en même temps n'a rien de grave. Cependant, si vous avez plusieurs PSO appliquées avec la même priorité, vous laissez Active Directory choisir à votre place ce qui va peut-être réduire le niveau de sécurité sur certains comptes.

Au départ, je ne m'attendais pas à faire un script aussi imposant pour faire ça, mais voilà la bête :

```powershell
# Get all fine-grained password policies
$pso = Get-ADFineGrainedPasswordPolicy -Filter *

# Get all users
$users = Get-ADUser -Filter * | ForEach-Object {
    Get-ADUser $_ -Properties 'msDS-MemberOfTransitive', 'msDS-ResultantPSO'
}

# Get exposed PSO for each user
$users | Add-Member -MemberType NoteProperty -Name 'msDS-ExposedPSO' -Value @() -Force
$pso | ForEach-Object {
    Write-Host "Processing PSO: $($_.Name)"
    $psoDn = $_.DistinguishedName
    $_.AppliesTo | ForEach-Object {
        $appliesToDn = $_
        $users | Where-Object { $_.'msDS-MemberOfTransitive' -contains $appliesToDn } |
        ForEach-Object { $_.'msDS-ExposedPSO' += $psoDn }
    }
}

# Show results
$users | Where-Object { ($_.'msDS-ExposedPSO' | Measure-Object).Count -gt 1 } |
    Sort-Object 'msDS-ResultantPSO' |
    Format-Table Name, Enabled,
        @{ N = 'ResultantPSO' ; E = { (Get-ADFineGrainedPasswordPolicy $_.'msDS-ResultantPSO').Name } },
        @{ N = 'ExposedPSO' ; E = { ($_.'msDS-ExposedPSO' | Get-ADFineGrainedPasswordPolicy).Name | Sort-Object } } -GroupBy 'msDS-ResultantPSO'
```

## Tie-breaker en cas de priorité égale

Oui, je sais, on n'est pas censé avoir plusieurs PSO avec la même priorité, mais il est vrai que je vois ce problème de configuration chez beaucoup de mes clients. 

### Création de plusieurs PSO

On va commencer par créer cinq nouvelles PSO avec une priorité identique (1) et les groupes de ciblage qui vont avec :

```powershell
$pso = 'Administrators', 'ServiceAccounts', 'Externals', 'Employees', 'Technical'
$pso | ForEach-Object {
    New-ADGroup -Name "PSO_$_" -GroupScope 'Global'
    $groupDn = (Get-ADGroup "PSO_$_").DistinguishedName
    New-ADFineGrainedPasswordPolicy -Name $_ -OtherAttributes @{ 'msDS-PSOAppliesTo' = $groupDn } -Precedence 1 -Verbose
}
```

### Application de toutes les PSO sur un utilisateur

On commence par créer un compte de test :

```powershell
New-ADUser john.smith
```

Puis on ajoute le compte de test dans tous les groupes de ciblage de PSO :

```powershell
'Administrators', 'ServiceAccounts', 'Externals', 'Employees', 'Technical' | ForEach-Object {
    Add-ADGroupMember -Identity "PSO_$_" -Members john.smith
}
```

### Récupération de l'ordre d'application des PSO

Et enfin on peut découvrir l'ordre d'application des PSO en retirant un à un les groupes d'exposition du compte de test :

```powershell
$user = Get-ADUser john.smith -Properties 'msDS-ResultantPSO'
$i = 1
do {
    Write-Host "$i - User is exposed to the following PSO: $($user.'msDS-ResultantPSO')"
    [string]$psoGroup = (Get-ADObject $user.'msDS-ResultantPSO' -Properties *).'msDS-PSOAppliesTo'
    Remove-ADGroupMember $psoGroup -Members 'john.smith' -Confirm:$false
    $user = Get-ADUser john.smith -Properties 'msDS-ResultantPSO'
    $i++
} while ($user.'msDS-ResultantPSO')
```

Quand toutes les PSO sont appliquées avec un ordre de priorité identique, c'est l'ordre suivant qui est appliqué systématiquement, jusqu'à la suppression de la PSO :

1. Externals
2. ServiceAccounts
3. Administrators
4. Technical
5. Employees

### Attribut tie-breaker

Le caractère aléatoire mais systématique de ce classement ne peut correspondre qu'à un seul attribut : **le GUID de la PSO**. Celui-ci est généré aléatoirement, mais malheureusement cela ne correspond pas à l'ordre d'application des PSO sur mon utilisateur de test :

Ordre | Name | ObjectGuid
----- | ---- | ----------
5 | Employees | `137a3298-b43d-4e29-8526-904a73c23e15`
1 | Externals | `34967a25-ca21-4ff7-8ff9-82f5baeec8f5`
3 | Administrators | `a8cb3b47-57a1-4f8d-85d3-3f632bda6a63`
2 | ServiceAccounts | `b4276b26-a71c-4e1c-9f90-053972c55477`
4 | Technical | `db383b8d-dc91-4a97-8cd9-db6d5115be00`

Mais en creusant un peu plus, je me suis rendu compte qu'il existait plusieurs façons de représenter un GUID. Il y a plusieurs formats possibles, comme indiqué ici : [Guid.ToString Method (System) \| Microsoft Learn](https://learn.microsoft.com/en-us/dotnet/api/system.guid.tostring?view=net-10.0&amp;redirectedfrom=MSDN#System_Guid_ToString_System_String_).

Tous ces formats sont globalement similaires, mais ils m'ont donné une idée supplémentaire : le binaire. Et là, tout s'explique : l'ordre d'application des PSO en cas d'égalité est tranché avec le premier (et éventuellement le second) octet du GUID. La valeur la plus faible devient prioritaire par rapport aux autres :

Ordre | Name | ObjectGuid | ObjectGuidBinary
----- | ---- | ---------- | ----------------
1 | Externals | `34967a25-ca21-4ff7-8ff9-82f5baeec8f5` | 37
2 | ServiceAccounts | `b4276b26-a71c-4e1c-9f90-053972c55477` | 38
3 | Administrators | `a8cb3b47-57a1-4f8d-85d3-3f632bda6a63` | 71
4 | Technical | `db383b8d-dc91-4a97-8cd9-db6d5115be00` | 141
5 | Employees | `137a3298-b43d-4e29-8526-904a73c23e15` | 152

Voici le script PowerShell qui permet de visualiser le premier octet des GUID de toutes les PSO :

```powershell
$pso = Get-ADFineGrainedPasswordPolicy -Filter *
$pso | Select-Object Name, ObjectGuid, @{
    N = 'ObjectGuidBinary'
    E = { $_.ObjectGuid.ToByteArray() | Select-Object -First 1 }
} | Sort-Object ObjectGuidBinary
```

### Bonnes pratiques sur les priorités

Si je vois aussi souvent des PSO avec des priorités égales, c'est que la décision de hiérarchisation est compliquée. Avant tout, il est bon de rappeler les règles du jeu lorsqu'il s'agit des priorités :

- C'est la priorité la plus faible qui prime
- Les valeurs de priorité doivent être comprises entre 1 et 1024
- Toutes les PSO devraient avoir des priorités différentes pour éviter d'avoir un comportement d'application aléatoire

Maintenant pour la partie bonne pratique, je recommanderai de **définir les priorités en fonction de la longueur minimum du mot de passe**. En effet, c'est le seul paramètre qui n'est pas actif immédiatement après le changement d'exposition à une PSO :

Catégorie | Changement effectif | Auditable
--------- | ------------------- | ---------
Longueur et complexité | Au prochain changement du mot de passe | Non
Durée de vie | Immédiatement | Oui
Stratégie de blocage | Immédiatement | Oui

On peut également rappeler que une fois défini, il devient très compliqué d'auditer la longueur et la complexité d'un mot de passe, contrairement à l'âge d'un mot de passe (attribut `passwordLastSet`) ou sa stratégie de blocage (commande `Get-ADUserResultantPasswordPolicy`).

En bref : vous pouvez prioriser vos PSO en fonction du nombre de caractères minimum et/ou de la complexité du mot de passe. Dans mon exemple, on pourrait organiser nos PSO de la manière suivante :

Priorité | PSO | Longueur minimum
-------- | --- | ----------------
1 | ServiceAccounts | 25 caractères
10 | Administrators | 16 caractères
20 | Technical | 14 caractères
30 | Externals | 12 caractères
40 | Employees | 12 caractères

## Comportement des groupes de ciblage

### Étendue des groupes

Les PSO sont habituellement ciblées sur des groupes. Ces groupes doivent impérativement être des groupes de sécurité globaux, car leur étendue correspond parfaitement au champ d'application d'une PSO : uniquement les utilisateurs du domaine. Cela permet donc de ne pas impacter des utilisateurs issus d'un autre domaine ou d'une autre forêt Active Directory.

Depuis la console `dsac`, il est impossible d'ajouter un groupe de domaine local ou un groupe universel en cible d'une PSO mais vous pouvez contourner avec PowerShell (qui ne fait pas de vérification) ou en transformant un groupe de ciblage en groupe universel après-coup.

Pour ajouter un groupe de ciblage sur une PSO en PowerShell :

```powershell
$groupDn = (Get-ADGroup 'PSO_Administrators').DistinguishedName
Get-ADFineGrainedPasswordPolicy 'Administrators' | Set-ADObject -Add @{ 'msDS-PSOAppliesTo' = $groupDn }
```

À partir du moment ou le ciblage de la PSO passe par un groupe qui n'est pas un groupe global de sécurité : **la PSO ne s'appliquera pas**.

### Groupe de ciblage en doublon

Il est possible de mettre le même groupe de ciblage sur deux PSO différentes. Dans ce cas, c'est simplement la PSO avec la priorité la plus faible qui s'appliquera à l'utilisateur.
