---
title: "Créer un utilisateur sans mot de passe dans Active Directory"
description: "Comment faire du PasswordLess avec Active Directory (la sécurité en moins)"
tags: ["activedirectory", "powershell"]
listed: true
---

Ce post est inspiré d'un article de Narayanan Subramanian : [GOING PASSWORDLESS WITH DSRM \| Medium](https://medium.com/@nannnu/overview-72d7f737bdc6).

## Pour un nouvel utilisateur

### Création de l'utilisateur

La solution la plus simple pour avoir un utilisateur sans mot de passe est d'en créer un nouveau. En invoquant une sélection de paramètres, il est possible d'obtenir un utilisateur *passwordLess* prêt à l'emploi et sans mot de passe :

- Le paramètre `-Enabled` permet d'activer le compte
- Le paramètre `-PasswordNotRequired` désactive l'obligation d'avoir un mot de passe (via l'attribut `UserAccountControl`)
- Le paramètre `-ChangePasswordAtLogon` évite d'avoir à changer le mot de passe avant la première connexion

```powershell
$splat = @{
    Name = 'passwordLess'
    SamAccountName = 'passwordLess'
    Enabled = $true
    PasswordNotRequired = $true
    ChangePasswordAtLogon = $false
}
New-ADUser @splat
```

### Vérification du hash NTLM

Avec le module [DSInternals](https://github.com/MichaelGrafnetter/DSInternals), on peut inspecter le hash NTLM de n'importe quel compte du domaine :

```powershell
Get-ADReplAccount -SamAccountName passwordLess -Server (Get-ADDomainController).HostName
```

Voici le résultat de la commande sur le compte fraîchement créé. On voit que la propriété "NTHash" est vide (puisqu'aucun mot de passe n'a été défini) :

```plaintext
DistinguishedName: CN=passwordLess,CN=Users,DC=contoso,DC=com
Sid: S-1-5-21-3027461726-3000856684-1369132086-36554
Guid: 98b5196f-f161-4dda-9fc7-8e7c483e82f0
SamAccountName: passwordLess
UserAccountControl: PasswordNotRequired, NormalAccount
Secrets
  NTHash:
  LMHash:
  NTHashHistory:
  LMHashHistory:
  SupplementalCredentials:
```

### Utilisation du compte

Pour utiliser le compte `passwordLess`, vous n'avez plus qu'à indiquer l'identifiant et laisser le mot de passe vide. Voici un exemple de ligne de commande pour tester les identifiants :

```powershell
$cred = Get-Credential
Get-ADDomain -Credential $cred
```

La connexion en bureau à distance ou l'ouverture d'une nouvelle session Windows fonctionnera également sans mot de passe.

## Pour un compte existant

Pour un compte existant, le processus est légèrement différent puisque l'on doit composer avec un mot de passe défini précédemment. On va donc changer la logique :
au lieu de ne pas avoir de mot de passe, on va devoir ajouter un mot de passe vide.

### Créer une chaîne sécurisée vide

La première étape va être de créer une chaîne sécurisée (*SecureString*) vide. En essayant avec la commande `ConvertTo-SecureString`, on tombe sur les erreurs **Cannot bind argument to parameter 'String' because it is an empty string/it is null**. 

```powershell
'' | ConvertTo-SecureString -AsPlainText -Force
# ou
$null | ConvertTo-SecureString -AsPlainText -Force
```

Mais heureusement il y a au moins deux alternatives :

1. En utilisant la commande `Read-Host` avec le paramètre `-AsSecureString` et en validant tout de suite avec "Entrée"
2. En passant directement par la méthode .NET pour créer un objet de type `[SecureString]`

```powershell
Read-Host -AsSecureString
# ou
[SecureString]::New()
```

Avec la commande `ConvertTo-NTHash` du module [DSInternals](https://github.com/MichaelGrafnetter/DSInternals), on peut calculer le hash NTLM qui correspond à un mot de passe vide : `31d6cfe0d16ae931b73c59d7e0c089c0`. Voici la ligne de commande pour générer le hash d'une chaîne vide :

```powershell
[SecureString]::New() | ConvertTo-NTHash
```

### Désactivation de l'obligation d'un mot de passe

La première action a faire sur le compte est de désactiver l'obligation d'avoir un mot de passe (*PASSWD_NOTREQD*). Pour cela on peut utiliser la méthode simple :

```powershell
Set-ADUser emptyPassword -PasswordNotRequired:$true
```

...ou alors la méthode compliquée, qui consiste à modifier directement la valeur de l'attribut `UserAccountControl` pour ajouter 32 (ce qui correspond à *PASSWD_NOTREQD*) :

```powershell
$user = Get-ADUser emptyPassword -Properties userAccountControl
if (($user.userAccountControl -band 32) -eq 0) {
    $uac = $user.userAccountControl + 32
    Set-ADUser emptyPassword -Replace @{userAccountControl = $uac}
}
```

La signification de la valeur de UserAccountControl est disponible ici : [Indicateurs de propriété UserAccountControl - Windows Server \| Microsoft Learn](https://learn.microsoft.com/fr-fr/troubleshoot/windows-server/active-directory/useraccountcontrol-manipulate-account-properties#list-of-property-flags)

### Définir un mot de passe vide sur un compte

Il ne reste plus qu'à appliquer notre mot de passe vide sur le compte cible. On peut utiliser la commande PowerShell ci-dessous ou simplement faire une réinitialisation depuis  l'interface graphique :

```powershell
Set-ADAccountPassword 'emptyPassword' -NewPassword ([SecureString]::New()) -Reset
```

Et cette fois avec la commande `Get-ADReplAccount`, on retrouve bien une valeur dans le NTHash qui correspond au mot de passe vide :

```plaintext
DistinguishedName: CN=emptyPassword,CN=Users,DC=contoso,DC=com
Sid: S-1-5-21-3027461726-3000856684-1369132086-36555
Guid: 98b5196f-f161-4dda-9fc7-8e7c483e82f0
SamAccountName: emptyPassword
UserAccountControl: PasswordNotRequired, NormalAccount
Secrets
  NTHash: 31d6cfe0d16ae931b73c59d7e0c089c0
  LMHash:
  NTHashHistory:
  LMHashHistory:
  SupplementalCredentials:
```

### Utilisation du compte

Pour tester la connexion du compte, on va cette fois utiliser une autre méthode : la création d'un objet `PSCredential` :

```powershell
$cred = [System.Management.Automation.PSCredential]::New('emptyPassword', ([SecureString]::New()))
Get-ADDomain -Credential $cred
```

La connexion se fait une fois de plus sans encombre, malgré l'absence de mot de passe.
