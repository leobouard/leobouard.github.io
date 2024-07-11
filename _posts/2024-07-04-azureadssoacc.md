---
layout: post
title: "Rotation du mot de passe de AZUREADSSOACC"
description: "Suivre les recommandations pour Microsoft Entra Seamless SSO"
tags: active-directory
listed: true
---

## Contexte

Microsoft Entra Seamless SSO (ou anciennement Azure AD Seamless SSO) est une fonctionnalité qui permet aux utilisateurs de se connecter automatiquement lorsqu’ils utilisent leur ordinateur d’entreprise connecté à votre réseau d’entreprise. Cela signifie que lorsque cette fonctionnalité est activée, les utilisateurs n’ont pas besoin de taper leur mot de passe ou même leur nom d’utilisateur pour se connecter aux services cloud de Microsoft (Entra ID ou Microsoft 365) sur leur navigateur web.

Vous pouvez tester ce fonctionnement depuis une session vierge de Firefox ou de Microsoft Edge par exemple (attention : Microsoft Entra Seamless SSO ne fonctionne pas sur les fenêtres en navigation privée).

Pour pouvoir faire cette connexion automatique à partir de la session Windows, Microsoft Entra Seamless SSO fait un conversion d’un ticket Kerberos (issu d’Active Directory) en token SAML (pour Entra ID). Cette conversion utilise **un compte ordinateur dans Active Directory : AZUREADSSOACC**.

### Bonnes pratiques

Pour assurer la sécurité de ce service, Microsoft propose un ensemble de bonnes pratiques et de règles d'hygiène qui sont disponible ici : [Microsoft Entra Connect: Seamless Single Sign-On - How it works - Microsoft Entra ID \| Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/hybrid/connect/how-to-connect-sso-how-it-works).

En bref, Microsoft recommande les choses suivantes :

- Stockage du compte ordinateur dans une unité d'organisation uniquement accessible aux administrateurs du domaine
- Le type de chiffrement Kerberos supporté par le compte soit `AES256_HMAC_SHA1`
- Changement du mot de passe tous les 30 jours

Si vous voulez un exemple d’attaque qui utilise ce compte AZUREADSSOACC, vous pouvez consulter : [Impersonating Office 365 Users With Mimikatz \| DSInternals](https://www.dsinternals.com/en/impersonating-office-365-users-mimikatz/)

### Automatisation de la rotation

A première lecture, si Microsoft recommande de faire un changement de mot de passe sur ce compte au moins tous les 30 jours on pourrait penser à faire une tâche planifiée pour ça. Pourtant, cela me parait difficilement conçevable au vu des prérequis demandés pour faire cette rotation.

## Rotation du mot de passe

### Prérequis

Pour faire la rotation du mot de passe de ce compte, vous devez disposer :

- d’un compte Active Directory avec le rôle *Administrateur du domaine* (Domain Admin) **qui n’est pas membre du groupe Protected Users**
- d’un compte Entra ID avec l’un des deux rôles suivants :

  - *Administrateur général* (Global Admin)
  - *Administrateur d’identité hybride* (Hybrid Identity Admin)

### Procédure

Connectez-vous en tant qu’administrateur du domaine au serveur (où à l’un des serveurs) qui héberge l’Azure AD Connect :

Lancer une console PowerShell en tant qu’administrateur

Charger le module AzureADSSO avec la commande suivante :

```powershell
Import-Module "$env:ProgramFiles\Microsoft Azure Active Directory Connect\AzureADSSO.psd1"
```

Passer en TLS 1.2 :

```powershell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
```

Connectez-vous en tant qu’administrateur général ou administrateur d’identité hybride avec la commande :

```powershell
New-AzureADSSOAuthenticationContext
```

Vérifier que vous êtes bien sur la bonne forêt Active Directory avec la commande :

```powershell
Get-AzureADSSOStatus | ConvertFrom-Json
```

Stocker ses identifiants administrateur du domaine dans la variable `$cred` avec la commande :

```powershell
$cred = Get-Credential
```

> C’est le SamAccountName qui est attendu en nom d’utilisateur, avec le nom NETBIOS du domaine en préfixe. Exemple : `CONTOSO\admin`.

Faire la rotation de mot de passe avec la commande :

```powershell
Update-AzureADSSOForest -OnPremCredentials $cred
```

La dernière commande devrait vous donner les logs suivants :

```plaintext
[12:00:00.245] [9] [INFORMATIONAL] UpdateComputerAccount: Locating SSO computer account in CONTOSO..
[12:00:00.261] [9] [INFORMATIONAL] GetDesktopSsoComputerAccount: Searching in global catalog(forest) and CONTOSO for computer account AZUREADSSOACC
[12:00:00.817] [9] [INFORMATIONAL] TrySearchAccountUnderGlobalCatalog: Object was found in global catalog(forest), hence skipping CONTOSO search
[12:00:00.817] [9] [INFORMATIONAL] UpdateComputerAccount: Found SSO computer account at CN=AZUREADSSOACC,OU=Servers,OU=TIER 0,DC=CONTOSO,DC=com. Updating its properties..
[12:00:00.817] [9] [INFORMATIONAL] UpdateComputerAccount: Granting full control to account admins and enterprise admins for computer account CN=AZUREADSSOACC,OU=Servers,OU=TIER 0,DC=CONTOSO,DC=com...
[12:00:01.963] [9] [INFORMATIONAL] UpdateComputerAccount: Successfully updated SSO computer account properties. The operation completed successfully
```

### Vérification du changement de mot de passe

Sur un serveur avec le module Active Directory installé, lancer une console PowerShell et utiliser la commande suivante :

```powershell
(Get-ADComputer AZUREADSSOACC -Properties PasswordLastSet).PasswordLastSet
```

Vérifier que la valeur retournée correspond bien à la date du jour.
