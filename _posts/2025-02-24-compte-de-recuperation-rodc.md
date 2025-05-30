---
title: "Le compte DSRM sur un contrôleur de domaine"
description: "Comment se connecter sur un DC/RODC avec un compte local ?"
tags: activedirectory
listed: true
---

## C'est quoi le compte DSRM ?

Un compte DSRM (Directory Services Restore Mode) dans Active Directory est un compte administrateur spécial utilisé pour effectuer des opérations de maintenance et de récupération sur un contrôleur de domaine. Le mode DSRM est un mode de démarrage spécial qui permet aux administrateurs de réparer ou de restaurer Active Directory en cas de problème grave. Ce compte est créé lors de la promotion d'un serveur en tant que contrôleur de domaine et son mot de passe doit être défini à ce moment-là.

Il y a **un compte DSRM par contrôleur de domaine**, et le mot de passe de celui-ci doit être différent pour chaque contrôleur de domaine.

Cet article se base en grande partie sur la source suivante : [Attacking Read-Only Domain Controllers (RODCs) to Own Active Directory – Active Directory Security](https://adsecurity.org/?p=3592)

### Risques de sécurité liés au compte DSRM

Le compte DSRM ne représente pas un risque d'élévation de privilège (tant que vous n'utilisez pas le même mot de passe DSRM sur tous vos DC et RODC) mais plutôt un risque de persistence dans votre infrastructure. En effet, il faut être administrateur d'un contrôleur de domaine pour pouvoir prendre le contrôle du compte DSRM, ce qui signifie que l'attaquant a déjà le plus haut niveau de privilège dans votre fôret.

L'utilisation d'un compte DSRM par un attaquant relève plus d'une porte dérobée (*backdoor*) pour s'assurer un accès à votre infrastructure plus tard.

## Préparation du compte DSRM

### Autorisation de l'utilisation du compte pour la connexion à distance

Par défaut, le comportement du compte DSRM pour la connexion est restreint. Le compte DSRM ne peut pas être utilisé pour se connecter à distance, sauf si des modifications spécifiques sont apportées aux paramètres de registre via la clé `DsrmAdminLogonBehavior`.

Pour autoriser (ou non) l'utilisation du compte DSRM à distance, on peut modifier la base de registre du contrôleur de domaine, en ajoutant la clé DWORD `DsrmAdminLogonBehavior` au chemin suivant : "Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Lsa".

La clé peut prendre trois valeurs :

- `DsrmAdminLogonBehavior = 0` : Le compte DSRM **ne peut pas** être utilisé pour se connecter à distance (comportement par défaut)
- `DsrmAdminLogonBehavior = 1` : Le compte DSRM peut être utilisé pour se connecter à distance uniquement si le contrôleur de domaine est en mode DSRM.
- `DsrmAdminLogonBehavior = 2` : Le compte DSRM peut être utilisé pour se connecter à distance même si le contrôleur de domaine n'est pas en mode DSRM.

Vous pouvez ajouter la clé de registre directement avec PowerShell :

```powershell
$params = @{
    Path = 'HKLM:\System\CurrentControlSet\Control\Lsa\'
    Name = 'DsrmAdminLogonBehavior'
    PropertyType = 'DWORD'
    Value = 1
}
New-ItemProperty @params
```

Ou la modifier avec la commande suivante :

```powershell
$params = @{
    Path = 'HKLM:\System\CurrentControlSet\Control\Lsa\'
    Name = 'DsrmAdminLogonBehavior'
    Value = 1
}
Set-ItemProperty @params
```

Ou la supprimer pour revenir au comportement par défaut :

```powershell
$params = @{
    Path = 'HKLM:\System\CurrentControlSet\Control\Lsa\'
    Name = 'DsrmAdminLogonBehavior'
}
Remove-ItemProperty @params
```

> La clé de registre peut être modifiée en masse sur tous les contrôleurs de domaine via une stratégie de groupe par exemple.

### Réinitialisation du mot de passe DSRM

Pour réinitialiser le mot de passe du compte DSRM, on peut utiliser l'utilitaire `ntdsutil.exe` qui permet d'agir sur le compte DSRM du serveur local ou d'un serveur distant.

1. Dans un terminal de commande PowerShell, lancer l'utilitaire : `ntdsutil.exe`
2. Entrer dans le mode "Reset DSRM Administrator Password" avec la commande : `set dsrm password`
3. Sélection du compte  le mot de passe :

    - Du serveur local : `reset password on server null`
    - D'un serveur distant : `reset password on server servername.contoso.com` (ou servername.contoso.com correspond au nom DNS du serveur)

> A ma connaissance, il n'y a aucun moyen simple d'obtenir l'âge du mot de passe DSRM sans synchroniser le compte avec le domaine ou garder l’événement 4795 en mémoire.

Documentation officielle de Microsoft sur le sujet : [How to reset the Directory Services Restore Mode administrator account password - Windows Server \| Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/reset-directory-services-restore-mode-admin-pwd#reset-the-dsrm-administrator-password)

#### Complexité du mot de passe

Les règles de complexité du mot de passe DSRM se basent directement sur la Default Domain Password Policy sur les critères de longueur minimum et de complexité. Les autres paramètres (âge minimum ou maximum du mot de passe ou l'historique de mot de passe) sont ignorés.

Si votre mot de passe ne respecte pas ces critères, vous obtiendrez l'erreur suivante : `WIN32 Error Code: 0x8c5. Error Message: The password does not meet the password policy requirements. Check the minimum password length, password complexity and password history requirements.`

> Malgré le message d'erreur, je confirme que l'historique de mot de passe **n'est pas pris** en compte.

#### Exemple

Voici un exemple d'utilisation de `ntdsutil.exe` pour réinitialiser le mot de passe du compte DSRM du serveur local :

```plaintext
PS C:\> ntdsutil.exe
C:\Windows\system32\ntdsutil.exe: set dsrm password
Reset DSRM Administrator Password: reset password on server null
Please type password for DS Restore Mode Administrator Account: ************************
Please confirm new password: ************************
Password has been set successfully.
```

Ou en une seule ligne :

```plaintext
ntdsutil.exe 'set dsrm password' 'reset password on server null'
```

### Synchronisation du compte DSRM avec un compte du domaine

Si vous le souhaitez, vous pouvez synchroniser le mot de passe du compte DSRM local de chaque contrôleur de domaine avec un compte du domaine Active Directory.

Pour faire cela, vous pouvez utiliser la commande suivante :

```plaintext
ntdsutil.exe 'set dsrm password' 'sync from domain account dsrm-dc01'
```

Cette commande va alors remplacer le mot de passe du compte local par la valeur du mot de passe du compte du domaine "dsrm-dc01".

Ce compte du domaine doit impérativement être considéré comme du Tier 0 et n'être accessible que par les administrateurs du domaine. Rappel : La bonne pratique est de créer un compte du domaine pour chaque DC.

> #### Mot de passe vide sur un compte DSRM
>
> Il est techniquement possible de définir un mot de passe vide pour votre compte DSRM lorsque la synchronisation avec un compte du domaine est utilisée. Plus d'information sur cet exploit ici : [GOING PASSWORDLESS WITH DSRM. Overview: \| by Narayanan subramanian \| Medium](https://medium.com/@nannnu/overview-72d7f737bdc6)

#### Exemple

```plaintext
C:\Windows\system32\ntdsutil.exe: set dsrm password
Reset DSRM Administrator Password: sync from domain account dsrm-dc01
Password has been synchronized successfully.
```

> #### Synchronisation du compte DSRM depuis un RODC
>
> Dans le cas d'un contrôleur de domaine en lecture seule, il faudra vous assurer que le mot de passe du compte ciblé (dsrm-dc01 dans mon exemple) est bien répliqué sur le RODC. Toutes les actions nécessaires pour sauvegarder le mot de passe peuvent être effectuées dans l'onglet "Password Replication Policy" de l'objet ordinateur du RODC.
>
> Si le mot de passe du compte n'est pas accessible par le RODC, la commande terminera avec l'erreur suivante : `WIN32 Error Code: 0x21ac. Error Message: The local account store does not contain secret material for the specified account`.

## Connexion avec le compte DSRM

Suivant la valeur indiquée dans la clé `DsrmAdminLogonBehavior`, les contraintes de connexions seront différentes.

Si la valeur de la clé `DsrmAdminLogonBehavior = 2`, alors vous allez pouvoir vous connecter sans aucune contrainte. Si vous avez défini la valeur à 1 en revanche, vous avez deux options :

1. Redémarrer le DC en mode DSRM pour pouvoir ouvrir une session
2. Stopper le service Active Directory Domain Services pour pouvoir ouvrir un programme depuis une session déjà ouverte sur un autre compte

### Option 1 - Redémarrage du contrôleur en mode DSRM

Si vous avez encore une session ouverte sur le contrôleur de domaine, vous pouvez utiliser la commande suivante qui permettra de redémarrer sur le safeboot :

```powershell
bcdedit.exe /set safeboot dsrepair
shutdown.exe -t 0 -r
```

N'oubliez pas qu'après avoir terminé les opérations nécessaires en mode DSRM, vous devrez réinitialiser la configuration de démarrage pour revenir à un démarrage normal. Vous pouvez le faire en utilisant la commande suivante :

```powershell
bcdedit.exe /deletevalue safeboot
```

Source : [Restart the domain controller in Directory Services Restore Mode: Active Directory \| Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-r2-and-2008/cc816897%28v=ws.10%29)

### Option 2 - Arrêt du service Active Directory Domain Services

Celui-ci est plutôt simple et ne nécessite pas de redémarrage :

```powershell
Stop-Service ntds -Force
```

L'arrêt du service NTDS sur le contrôleur de domaine va également arrêter les services suivants :

- `DFSR` : DFS Replication
- `DNS` : DNS Server
- `IsmServ` : Intersite Messaging
- `Kdc` : Kerberos Key Distribution Center

Cette manipulation va vous permettre d'ouvrir un programme avec le compte DSRM (PowerShell par exemple) depuis une session déjà ouverte.

Pour relancer les services :

```powershell
Start-Service ntds
```

### Utilisation du compte DSRM

Pour utiliser le compte DSRM, vous pouvez utiliser le nom d'utilisateur suivant : "SERVERNAME\Administrator". SERVERNAME représente le nom du serveur et Administrator le nom du compte.

> Attention : le nom du compte administrateur peut varier suivant la langue d'installation du serveur. Pour un serveur installé en français, le nom du compte sera donc "Administrateur" par exemple.

Pour le mot de passe, il s'agit de celui que vous avez défini précédemment.

Vous pouvez utiliser ce compte pour vous connecter via PowerShell WinRM ou avec le bureau à distance.

## Surveillance du compte DSRM

Les événements liés au compte DSRM (Directory Services Restore Mode) d'un contrôleur de domaine peuvent inclure les EventID suivants :

- **EventID 4794** : Utilisation du compte DSRM pour se connecter à un contrôleur de domaine
- **EventID 4795** : Modification du mot de passe du compte DSRM
- **EventID 4796** : Utilisation du compte DSRM pour effectuer des opérations de maintenance ou de récupération sur un contrôleur de domaine

Ces événements peuvent/doivent être surveillés pour des raisons de sécurité afin de s'assurer que le compte DSRM est utilisé de manière appropriée.

Voici une commande PowerShell pour consulter les trois EventID indiqués précédemment :

```powershell
$filterXPath = 'Event[System[(EventID=4794) or (EventID=4795) or (EventID=4796)]]'
Get-WinEvent -ProviderName Microsoft-Windows-Security-Auditing -FilterXPath $filterXPath
```
