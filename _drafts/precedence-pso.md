---
title: "Deep dive - Password Settings Object"
description: "Quel est le comportement "
tags: ["activedirectory", "powershell"]
listed: true
---

- [x] Attributs utiles
- [x] Répartition des utilisateurs par PSO
- [x] Comportement de tie-breaker
- [ ] Bonnes pratiques sur la priorité
- [ ] Fonctionnement sur un groupe de DL

## Attributs liés aux PSO

### Obtenir la date d'expiration prévue d'un mot de passe

La propriété `msDS-UserPasswordExpiryTimeComputed` contient la date d'expiration du mot de passe au format FileTime. On peut à partir de cette information extraire des informations pertinentes pour nous :

```powershell
$users = Get-ADUser john.smith -Properties 'msDS-UserPasswordExpiryTimeComputed'
$users | Select-Object *, @{
    N = 'PasswordExpirationTime'
    E = { [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed') }
}
```

> Pour les mots de passe qui n'expirent jamais, la propriété `msDS-UserPasswordExpiryTimeComputed` sera vide.

### Obtenir la PSO prioritaire sur un utilisateur

Pour un utilisateur seul, la façon la plus simple et qui donne le résultat le plus complet est la commande `Get-ADUserResultantPasswordPolicy` :

```powershell
Get-ADUser john.smith | Get-ADUserResultantPasswordPolicy
```

Si la réponse est vide : l'utilisateur est soumis à la Default Domain Password Policy.

### Lister le nombre de comptes par PSO

Pour plusieurs utilisateurs, la meilleure méthode est de requêter l'attribut calculé `msDS-ResultantPSO` qui va donner le DistinguishedName de la PSO qui est appliquée sur le compte utilisateur.

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

> Encore une fois, si la valeur est vide (comme c'est le cas pour 5415 utilisateurs dans mon exemple) c'est que le compte est soumis à la *Default Domain Password Policy*. Également, n'oubliez-pas que les PSO peuvent s'appliquer aux gMSA, donc le résultat donné n'est que partiel.

### Visualiser les utilisateurs soumis à plusieurs PSO

Si les priorités de vos PSO sont bien gérées, le fait qu'un utilisateur soit soumis à plusieurs PSO en même temps n'a rien de grave. Cependant, si vous avez plusieurs PSO appliquées avec la même priorité, vous laissez Active Directory choisir à votre place ce qui va peut-être réduire votre niveau de sécurité sur certains comptes.

En commençant, je ne m'attendais pas à faire un script aussi imposant pour faire ça, mais voilà la bête :

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

Oui je sais, on est pas censé avoir plusieurs PSO avec la même priorité mais le fait est que je vois ce problème de configuration chez beaucoup de mes clients. 

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

On commence par créé un compte de test :

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

Tous ces formats sont globalement similaires, mais ils m'ont donné une idée supplémentaire : le binaire. Et là, tout s'explique : l'ordre d'application des PSO en cas d'égalité est tranché avec le premier (et éventuellement le second) octet du Guid. La valeur la plus faible devient prioritaire par rapport aux autres :

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

## Fonctionnement d'une PSO avec un groupe de ciblage incompatible

Les PSO ne peuvent être appliquées que sur des groupes globaux car leur étendue est parfaite pour une PSO. Un groupe global ne peut contenir que des objets du domaine, de la même manière qu'une PSO ne peut s'appliquer que sur les utilisateur d'un domaine

Mais que se passe-t'il si on applique une PSO à un groupe de domaine local ou un groupe universel ?

Impossible de faire ça directement depuis la console `dsac`

- test de modification avec PowerShell
- conversion d'un groupe existant en DL ou U
