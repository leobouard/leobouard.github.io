---
layout: post
title: "MSGRAPH #4 - Les modules PowerShell"
description: "Travailler avec Microsoft Graph en PowerShell via les modules dédiés"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 5"
  id: "/2023/09/17/cours-msgraph-005"
prevLink:
  name: "Partie 3"
  id: "/2023/09/17/cours-msgraph-003"
---

## Microsoft Graph en PowerShell

Si vous aviez l'habitude d'administrer votre tenant avec les modules `MSOnline` et `AzureAD`, cette partie est pour vous. 

### Différences avec les anciens modules

Les modules Microsoft Graph sont assez différent des modules qu'ils remplacent. Voici quelques points d'attention à connaître avant de commencer.

#### Mises à jour des modules

Les commandes peuvent changer de nom d'une version à l'autre (voir même disparaitre). Par exemple, quatre modules (et les commandes qui vont avec) ont été supprimés entre la version 1.28.0 et la version 2.2.0.

#### Documentation officielle

La documentation associée aux commandes PowerShell est quasiment systématiquement de moins bonne qualité de la documentation de l'API sur laquelle la commande se base.

#### Différences entre commandes et API

Les commandes PowerShell ne retournent parfois pas le même résultat qu'une requête sur l'API correspondante. Ce problème tant à être de moins en moins fréquent, mais j'ai eu dernièrement des différences de résultats entre la commande `Get-MgBookingBusinesses` et l'API <https://graph.microsoft.com/v1.0/solutions/bookingBusinesses>.

#### Les commandes

Pour industrialiser les processus, Microsoft a décidé de générer automatiquement les modules et commandes à partir de l'API. On appelle cette méthode un "wrap".

Vous pouvez inspecter le code qui compose une commande et constater que la structure est la même pour quasiment toute les fonctions Microsoft Graph :

```powershell
(Get-Command -Name 'Get-MgUser').Definition
```

Cette méthode de génération a des avantages et des inconvénients. Côté avantages, les mises à jour des modules PowerShell se font très rapidement, ce qui permet d'obtenir des commandes seulement quelques jours après la publication d'une API (en théorie).

Les inconvénients sont principalement la génération du nom des commandes et les paramètres associés.

Le nom des commandes suit fidèlement l'API, ce qui peut donner les cmdlets extrêmement longs, ce qui impacte très fortement la lisibilité de votre code. Voici un exemple d'une commande que j'ai trouvé en mars 2022 et qui a disparu depuis (cf. [Mises à jour des modules](#mises-a-jour-des-modules)) :

```powershell
Invoke-MgExtendDeviceManagementDeviceConfigurationGroupAssignmentDeviceConfigurationMicrosoftGraphWindowUpdateForBusinessConfigurationQualityUpdatePause
```

Vous pouvez regarder quelle est la commande la plus longue de votre version avec ce script :

```powershell
Get-Command -Module Microsoft.Graph* |
  Select-Object Name,Module,@{N='Length';E={($_.Name).Length}} |
  Sort-Object Length
```

Pour les paramètres de commandes, ils sont en général très nombreux (et tant mieux) mais ils n'ont pas été pensés pour la praticité. Il faut par exemple très régulièrement utiliser l'ID d'un utilisateur car le UserPrincipalName n'est pas accepté.

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

| Nom |
| --- |
| Microsoft.Graph |
| Microsoft.Graph.Applications |
| Microsoft.Graph.Authentication |
| Microsoft.Graph.Bookings |
| Microsoft.Graph.Calendar |
| Microsoft.Graph.ChangeNotifications |
| Microsoft.Graph.CloudCommunications |
| Microsoft.Graph.Compliance |
| Microsoft.Graph.CrossDeviceExperiences |
| Microsoft.Graph.DeviceManagement |
| Microsoft.Graph.DeviceManagement.Actions |
| Microsoft.Graph.DeviceManagement.Administration |
| Microsoft.Graph.DeviceManagement.Enrollment |
| Microsoft.Graph.DeviceManagement.Functions |
| Microsoft.Graph.Devices.CloudPrint |
| Microsoft.Graph.Devices.CorporateManagement |
| Microsoft.Graph.Devices.ServiceAnnouncement |
| Microsoft.Graph.DirectoryObjects |
| Microsoft.Graph.Education |
| Microsoft.Graph.Files |
| Microsoft.Graph.Groups |
| Microsoft.Graph.Identity.DirectoryManagement |
| Microsoft.Graph.Identity.Governance |
| Microsoft.Graph.Identity.Partner |
| Microsoft.Graph.Identity.SignIns |
| Microsoft.Graph.Mail |
| Microsoft.Graph.Notes |
| Microsoft.Graph.People |
| Microsoft.Graph.PersonalContacts |
| Microsoft.Graph.Planner |
| Microsoft.Graph.Reports |
| Microsoft.Graph.SchemaExtensions |
| Microsoft.Graph.Search |
| Microsoft.Graph.Security |
| Microsoft.Graph.Sites |
| Microsoft.Graph.Teams |
| Microsoft.Graph.Users |
| Microsoft.Graph.Users.Actions |
| Microsoft.Graph.Users.Functions |

### Se connecter en PowerShell

```powershell
Connect-MgGraph -Scopes Group.ReadWrite.All
```

### Créer un groupe et ajouter un membre (POST)

```powershell
New-MgGroup
```

### Rechercher un groupe et les membres d'un groupe (GET)

```powershell
Get-MgGroup
Get-MgGroupMember
```

Vous devriez avoir une limite de 1000 résultats sur votre requête `Get-MgGroup` si vous n'avez pas invoqué le paramètre `-All`. Cette limitation est liée au système de pagination de l'API sous-jacente.

### Mettre à jour un groupe (PATCH)

```powershell
Update-MgGroup
```

```powershell
Invoke-MgGraphRequest
```

### Supprimer un groupe (DELETE)

## Passer à la version BETA

### Installation des modules

#### Liste des modules BETA

Voici la liste des modules BETA pour la version 2.8.0 :

Microsoft.Graph.Beta | Microsoft Graph PowerShell module
Microsoft.Graph.Beta.Applications
Microsoft.Graph.Beta.Bookings
Microsoft.Graph.Beta.Calendar
Microsoft.Graph.Beta.ChangeNotifications
Microsoft.Graph.Beta.CloudCommunications
Microsoft.Graph.Beta.Compliance
Microsoft.Graph.Beta.CrossDeviceExperiences
Microsoft.Graph.Beta.DeviceManagement
Microsoft.Graph.Beta.DeviceManagement.Actions
Microsoft.Graph.Beta.DeviceManagement.Administration
Microsoft.Graph.Beta.DeviceManagement.Enrollment
Microsoft.Graph.Beta.DeviceManagement.Functions
Microsoft.Graph.Beta.Devices.CloudPrint
Microsoft.Graph.Beta.Devices.CorporateManagement
Microsoft.Graph.Beta.Devices.ServiceAnnouncement
Microsoft.Graph.Beta.DirectoryObjects
Microsoft.Graph.Beta.Education
Microsoft.Graph.Beta.Files
Microsoft.Graph.Beta.Financials
Microsoft.Graph.Beta.Groups
Microsoft.Graph.Beta.Identity.DirectoryManagement
Microsoft.Graph.Beta.Identity.Governance
Microsoft.Graph.Beta.Identity.Partner
Microsoft.Graph.Beta.Identity.SignIns
Microsoft.Graph.Beta.Mail
Microsoft.Graph.Beta.ManagedTenants
Microsoft.Graph.Beta.Notes
Microsoft.Graph.Beta.People
Microsoft.Graph.Beta.PersonalContacts
Microsoft.Graph.Beta.Planner
Microsoft.Graph.Beta.Reports
Microsoft.Graph.Beta.SchemaExtensions
Microsoft.Graph.Beta.Search
Microsoft.Graph.Beta.Security
Microsoft.Graph.Beta.Sites
Microsoft.Graph.Beta.Teams
Microsoft.Graph.Beta.Users
Microsoft.Graph.Beta.Users.Actions
Microsoft.Graph.Beta.Users.Functions
Microsoft.Graph.Beta.WindowsUpdates
