---
title: "Les priorités sur les PSO"
description: "Quel est le comportement "
tags: ["activedirectory", "powershell"]
listed: true
---

### Pour obtenir la date d'expiration d'un mot de passe en fonction de la PSO appliquée

La propriété `msDS-UserPasswordExpiryTimeComputed` contient la date d'expiration du mot de passe au format FileTime. On peut à partir de cette information extraire des informations pertinentes pour nous :

```powershell
$users = Get-ADUser john.smith -Properties 'msDS-UserPasswordExpiryTimeComputed'
$users | Select-Object *,
    @{
        Name = 'PasswordExpirationTime'
        Expression = { [datetime]::FromFileTime($_.'msDS-UserPasswordExpiryTimeComputed') }
    }
```

> Pour les mots de passe qui n'expirent jamais, la propriété `msDS-UserPasswordExpiryTimeComputed` sera vide.

## Pour obtenir la PSO prioritaire sur un utilisateur


```powershell
Get-ADUser john.smith | Get-ADUserResultantPasswordPolicy
```

Si la réponse est vide : l'utilisateur est soumis à la Default Domain Password Policy.

## Pour lister le nombre de comptes par PSO



```powershell
$users = Get-ADUser -Filter * -Properties 'msDS-ResultantPSO'
$users | Group-Object 'msDS-ResultantPSO' -NoElement | Sort-Object Count -D | Format-Table -AutoSize
```

Quand toutes les PSO sont appliquées avec un ordre de priorité identique :

1. Industrial service accounts
2. Administrators
3. Service accounts
4. Industrial generic accounts
5. gMSA

```powershell

```

Pistes évoquées :

- Par âge maximum du mot de passe : NON
- Par objectGuid : NON
- Par date de création : NON

