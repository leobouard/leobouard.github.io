---
layout: post
title: "MSGRAPH #4 - Explorer et modules PowerShell"
description: "Commencer les requêtes via Microsoft Graph Explorer et les modules PowerShell dédiés"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 5"
  id: "/2023/09/17/cours-msgraph-005"
prevLink:
  name: "Partie 3"
  id: "/2023/09/17/cours-msgraph-003"
---

## Microsoft Graph en PowerShell

Si vous aviez l'habitude d'administrer votre tenant avec les modules `MSOnline` et `AzureAD`, cette partie est pour vous. Cependant, ces modules sont de moins bonne qualité que ceux qu'ils remplacent car ils ont été générés automatiquement à partir de l'API. Voici quelques choses à savoir avant de commencer :

- Les commandes peuvent changer de nom d'une version à l'autre (voir même disparaitre). Par exemple, quatre modules (et les commandes qui vont avec) ont été supprimés entre la version 1.28.0 et la version 2.2.0
- La documentation associée aux commandes PowerShell est quasiment systématiquement de moins bonne qualité de la documentation de l'API sur laquelle la commande se base.
- Les commandes PowerShell ne retournent parfois pas le même résultat qu'une requête sur l'API correspondante. Ce problème tant à être de moins en moins fréquent, mais j'ai eu dernièrement des différences de résultats entre la commande `Get-MgBookingBusinesses` et l'API <https://graph.microsoft.com/v1.0/solutions/bookingBusinesses>.
- Les paramètres de commandes sont génériques et n'ont pas été pensés pour la praticité, donc il faut très régulièrement utiliser l'ID d'un utilisateur plutôt le UserPrincipalName par exemple.
- Le nom des commandes suit fidèlement l'API, ce qui peut donner les cmdlets extrêmement longs comme `Invoke-MgExtendDeviceManagementDeviceConfigurationGroupAssignmentDeviceConfigurationMicrosoftGraphWindowUpdateForBusinessConfigurationQualityUpdatePause` (vu en mars 2022). Cette commande a depuis disparue des modules.

Vous pouvez d'ailleurs inspecter comment les commandes ont été créées en regardant le code qui les composent via la commande :

```powershell
(Get-Command -Name 'Get-MgUser').Definition
```

### Installer les modules

Vous pouvez installer les modules `Microsoft.Graph` depuis PSGallery avec cette commande PowerShell (à lancer dans un terminal en tant qu'administrateur) :

```powershell
Install-Module 'Microsoft.Graph'
```

L'installation peut être longue puisque l'on va installer *tout les modules* liés à Microsoft Graph mais sachez qu'il est possible de n'installer que les modules vraiment nécessaire à votre usage. En général, les modules `Microsoft.Graph` et `Microsoft.Graph.Authentication` sont les seuls modules incontournables.

#### Pourquoi autant de modules ?

Vous allez le constater, mais il y a beaucoup de modules (et encore plus de commandes) liés à Microsoft Graph. Chaque module représente une ressource de l'API (la partie après la version dans l'URI). Ainsi, toutes les commandes liées à la gestion des groupes vont se retrouver dans le module `Microsoft.Graph.Groups` puisqu'elles utilisent toutes une URI qui commence par <https://graph.microsoft.com/v1.0/groups>.

#### Liste des modules

Vous pouvez lister les modules `Microsoft.Graph` installés sur votre ordinateur avec la commande suivante :

```powershell
Get-InstalledModule -Name 'Microsoft.Graph*'
```

Voici la liste des modules pour la version 2.8.0 :

Name | Description
---- | -----------
Microsoft.Graph | Microsoft Graph PowerShell module
Microsoft.Graph.Applications | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Authentication | Microsoft Graph PowerShell Authentication Module.
Microsoft.Graph.Bookings | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Calendar | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.ChangeNotifications | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.CloudCommunications | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Compliance | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.CrossDeviceExperiences | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.DeviceManagement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.DeviceManagement.Actions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.DeviceManagement.Administration | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.DeviceManagement.Enrollment | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.DeviceManagement.Functions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Devices.CloudPrint | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Devices.CorporateManagement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Devices.ServiceAnnouncement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.DirectoryObjects | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Education | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Files | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Groups | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Identity.DirectoryManagement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Identity.Governance | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Identity.Partner | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Identity.SignIns | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Mail | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Notes | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.People | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.PersonalContacts | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Planner | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Reports | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.SchemaExtensions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Search | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Security | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Sites | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Teams | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Users | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Users.Actions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Users.Functions | Microsoft Graph PowerShell Cmdlets



### Se connecter en PowerShell

### Créer un groupe et ajouter un membre (POST)

### Rechercher un groupe et les membres d'un groupe (GET)

```powershell
Get-MgGroup
Get-MgGroupMember
```

Vous devriez avoir une limite de 1000 résultats sur votre requête `Get-MgGroup` si vous n'avez pas invoqué le paramètre `-All`. Cette limitation est liée au système de pagination de l'API sous-jacente.

### Mettre à jour un groupe (PATCH)

Cette fois-ci, pas de cmdlet tout prêt pour faire une requête, il va donc falloir utiliser la commande qui peut remplacer toutes les autres : `Invoke-MgGraphRequest`.

```powershell
Invoke-MgGraphRequest
```

### Supprimer un groupe (DELETE)

## Passer à la version BETA

### Installation des modules

#### Liste des modules BETA

Voici la liste des modules BETA pour la version 2.8.0 :

Microsoft.Graph.Beta | Microsoft Graph PowerShell module
Microsoft.Graph.Beta.Applications | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Bookings | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Calendar | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.ChangeNotifications | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.CloudCommunications | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Compliance | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.CrossDeviceExperiences | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.DeviceManagement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.DeviceManagement.Actions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.DeviceManagement.Administration | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.DeviceManagement.Enrollment | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.DeviceManagement.Functions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Devices.CloudPrint | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Devices.CorporateManagement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Devices.ServiceAnnouncement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.DirectoryObjects | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Education | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Files | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Financials | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Groups | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Identity.DirectoryManagement | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Identity.Governance | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Identity.Partner | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Identity.SignIns | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Mail | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.ManagedTenants | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Notes | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.People | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.PersonalContacts | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Planner | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Reports | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.SchemaExtensions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Search | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Security | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Sites | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Teams | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Users | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Users.Actions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.Users.Functions | Microsoft Graph PowerShell Cmdlets
Microsoft.Graph.Beta.WindowsUpdates | Microsoft Graph PowerShell Cmdlets
