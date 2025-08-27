---
title: "Top 5 des commandes PowerShell pour MSGRAPH"
description: "Les seules commandes indispensables dans les modules Microsoft Graph"
tags: ["msgraph", "powershell"]
listed: true
---

> Article issu d'une publication de septembre 2024 sur LinkedIn  : [Top 5 des commandes PowerShell à connaître sur Microsoft Graph](https://www.linkedin.com/posts/leobouard\_top-5-des-commandes-powershell-%C3%A0-connaitre-activity-7239920803582996482-i6gi?utm\_source=share&utm\_medium=member\_desktop&rcm=ACoAACeUVyYBCG\_mSlyJ9Nb1h1VjxMttbiTk4Ec).

## Modules Microsoft Graph

Pour utiliser Microsoft Graph en PowerShell, il y a un peu moins de 25 000 commandes réparties dans plus de 80 modules (modules beta inclus). Si vous trouvez que c'est trop, sachez que vous n'avez besoin que d'un seul module et que d'une poignée de commandes pour (quasiment) tout faire. Le module qui nous intéresse est `Microsoft.Graph.Authentication` qui s'installe de la manière suivante :

```powershell
Install-Module Microsoft.Graph.Authentication
```

Ce module ne contient que 14 commandes et est le seul module réellement indispensable pour travailler sur Microsoft Graph avec PowerShell. En gras les commandes qui nous intéressent dans cet article :

- **Find-MgGraphCommand**
- **Find-MgGraphPermission**
- Add-MgEnvironment
- **Connect-MgGraph**
- Disconnect-MgGraph
- **Get-MgContext**
- Get-MgEnvironment
- Get-MgGraphOption
- Get-MgRequestContext
- **Invoke-MgGraphRequest**
- Remove-MgEnvironment
- Set-MgEnvironment
- Set-MgGraphOption
- Set-MgRequestContext

## Commandes à connaître

### Connect-MgGraph

Gère toutes les façons de **se connecter** à Microsoft Graph :

- En tant qu'utilisateur (délégué)
- En tant qu'application
- Avec un mot de passe (secret)
- Avec un certificat

Exemple d'utilisation pour une connexion en tant qu'utilisateur :

```powershell
Connect-MgGraph -NoWelcome
```

Documentation officielle : [Connect-MgGraph (Microsoft.Graph.Authentication) \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/connect-mggraph?view=graph-powershell-1.0)

### Get-MgContext

Permet d'obtenir le **contexte de votre connexion** à Microsoft Graph, avec des informations comme :

- Les permissions accordées
- Le type de connexion (application, déléguée)
- L'application Azure utilisée
- Le compte utilisateur connecté

Exemple d'utilisation :

```powershell
Get-MgContext
```

Résultat obtenu :

```plaintext
ClientId               : 26960a06-7e8d-424a-a664-96d19262c254
TenantId               : 04d0f287-a17c-423c-bcb6-69ee2aa71a92
Scopes                 : {AccessReview.Read.All, Application.ReadWrite.All, AuditLog.Read.All, Device.Read.All...}
AuthType               : Delegated
TokenCredentialType    : InteractiveBrowser
CertificateThumbprint  :
CertificateSubjectName :
SendCertificateChain   : False
Account                : john.smith@contoso.onmicrosoft.com
AppName                : Microsoft Graph Command Line Tools
ContextScope           : Process
Certificate            :
PSHostVersion          : 5.1.22621.2506
ManagedIdentityId      :
ClientSecret           :
Environment            : Global
```

Documentation officielle : [Get-MgContext (Microsoft.Graph.Authentication) \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/get-mgcontext?view=graph-powershell-1.0)

### Invoke-MgGraphRequest

La commande qui peut **remplacer toutes les autres**, puisqu'elle permet de d'interroger n'importe quelle API de Microsoft Graph en indiquant :

- La méthode (*GET, POST, DELETE*)
- L'URI
- Le corps (*optionnel*)

Exemple pour obtenir les informations sur l'utilisateur <john.smith@contoso.onmicrosoft.com>. Cette commande donne le même résultat qu'un `Get-MgUser` :

```powershell
Invoke-MgGraphRequest -Method GET -Uri '/v1.0/users/john.smith@contoso.onmicrosoft.com' -OutputType PSObject
```

Documentation officielle : [Invoke-MgGraphRequest (Microsoft.Graph.Authentication) \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/invoke-mggraphrequest?view=graph-powershell-1.0)

### Find-MgGraphCommand

Permet de trouver facilement :

- Les API associées à une commande
- Les commandes associées à une API
- Les permissions nécessaires

Utile pour trouver la documentation de l'API qui est **beaucoup plus complète** que la documentation des commandes PowerShell.

Exemple d'utilisation pour trouver les API et permissions liées à la commande `Get-MgUser` :

```powershell
Find-MgGraphCommand -Command Get-MgUser
```

Résultat obtenu :

Command    | Module | Method | URI              | OutputType          | Permissions
-------    | ------ | ------ | ---              | ----------          | -----------
Get-MgUser | Users  | GET    | /users           | IMicrosoftGraphUser | {User.ReadBasic.All, User.ReadBasic.All, User.ReadWrit...
Get-MgUser | Users  | GET    | /users/{user-id} | IMicrosoftGraphUser | {User.Read, User.ReadBasic.All, User.ReadBasic.All, De...

Documentation officielle : [Find-MgGraphCommand (Microsoft.Graph.Authentication) \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/find-mggraphcommand?view=graph-powershell-1.0)

### Find-MgGraphPermission

Permet de lister et rechercher dans toutes les **permissions disponibles** sur Microsoft Graph en filtrant :

- Sur un terme exact
- Sur un mot clé
- Sur le type de permission (déléguée ou application)

Exemple d'utilisation pour trouver toutes les permissions qui contiennent le mot "shift" :

```powershell
Find-MgGraphPermission -SearchString 'shift'
```

Résultat obtenu :

Id                                   | Consent | Name                               | Description
--                                   | ------- | ----                               | -----------
de023814-96df-4f53-9376-1e2891ef5a18 | Admin   | UserShiftPreferences.Read.All      | Allows the app to read all users' sh...
d1eec298-80f3-49b0-9efb-d90e224798ac | Admin   | UserShiftPreferences.ReadWrite.All | Allows the app to manage all users' ...

Documentation officielle : [Find-MgGraphPermission (Microsoft.Graph.Authentication) \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/microsoft.graph.authentication/find-mggraphpermission?view=graph-powershell-1.0)
