---
title: "Créer un utilisateur sans mot de passe dans Active Directory"
description: "Faire du PasswordLess avec Active Directory, la sécurité en moins"
tags: ["activedirectory", "powershell"]
listed: true
---

## 

Bla bla bla normalement un compte c'est identifiant + mot de passe

Mais 

[Indicateurs de propriété UserAccountControl \| Microsoft Learn](https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties#list-of-property-flags)

## Pour un nouvel utilisateur

### Création d'un utilisateur sans mot de passe

```powershell
$splat = @{
    Name = 'passwordLess'
    SamAccountName = 'passwordLess'
    OtherAttributes = @{
        UserAccountControl = (512 + 32)
    }
}
New-ADUser @splat
```

Voici le résultat de la commande `Get-ADReplAccount` sur le compte fraîchement créé, où on voit que la propriété "NTHash" est vide :

```plaintext
DistinguishedName: CN=passwordLess,CN=Users,DC=contoso,DC=com
SamAccountName: passwordLess
UserAccountControl: PasswordNotRequired, NormalAccount
Secrets
  NTHash:
  NTHashHistory:
```

## Pour un utilisateur existant

### Créer une chaîne de caractères sécurisé vide

En essayant avec la commande `ConvertTo-SecureString`, on tombe sur les erreurs **Cannot bind argument to parameter 'String' because it is an empty string/it is null**. 

```powershell
$emptySs = '' | ConvertTo-SecureString -AsPlainText -Force
```

Mais heureusement il y a deux alternatives :

```powershell
$emptySs = Read-Host -AsSecureString
# ou
$emptySs = [SecureString]::New()
```

Et avec la commande `ConvertTo-NTHash` du module DSInternals, on peut calculer le hash NTLM qui correspond à un mot de passe vide : `31d6cfe0d16ae931b73c59d7e0c089c0`.

```powershell
$emptySs | ConvertTo-NTHash
```

### Définir un mot de passe vide sur un compte

```powershell
Set-ADUser 'passwordLess' -PasswordNotRequired:$true -Enabled:$true
Set-ADAccountPassword 'passwordLess' -NewPassword $emptySs
```

### Se connecter sur un compte sans mot de passe

```powershell
$cred = [System.Management.Automation.PSCredential]::New('passwordLess', $emptySs)
```



### Compte PasswordLess

[GOING PASSWORDLESS WITH DSRM by Narayanan Subramanian](https://medium.com/@nannnu/overview-72d7f737bdc6)

