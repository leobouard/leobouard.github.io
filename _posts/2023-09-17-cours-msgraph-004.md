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

Les modules Microsoft Graph sont assez différent des modules qu'ils remplacent. Voici quelques points d'attention à connaître avant de commencer :

- **Mises à jour des modules** : Les commandes peuvent changer de nom d'une version à l'autre (voir même disparaitre). Par exemple, quatre modules (et les commandes qui vont avec) ont été supprimés entre la version 1.28.0 et la version 2.2.0.
- **Documentation officielle** : La documentation associée aux commandes PowerShell est quasiment systématiquement de moins bonne qualité de la documentation de l'API sur laquelle la commande se base.
- **Différences entre commandes et API** : Les commandes PowerShell ne retournent parfois pas le même résultat qu'une requête sur l'API correspondante. Ce problème tant à être de moins en moins fréquent, mais j'ai eu dernièrement des différences de résultats entre la commande `Get-MgBookingBusinesses` et l'API <https://graph.microsoft.com/v1.0/solutions/bookingBusinesses>.

### Les commandes

Pour industrialiser les processus, Microsoft a décidé de générer automatiquement les modules et commandes à partir de l'API. On appelle cette méthode un "wrap". Vous pouvez inspecter le code qui compose une commande et constater que la structure est la même pour quasiment toute les fonctions Microsoft Graph :

```powershell
(Get-Command -Name 'Get-MgUser').Definition
```

Cette méthode de génération a des avantages et des inconvénients. Côté avantages, les mises à jour des modules PowerShell se font très rapidement, ce qui permet d'obtenir des commandes seulement quelques jours après la publication d'une API (en théorie).

Les inconvénients sont principalement la génération du nom des commandes et les paramètres associés. Le nom des commandes suit fidèlement l'API, ce qui peut donner les cmdlets extrêmement longs, comme par exemple :

```powershell
Invoke-MgExtendDeviceManagementDeviceConfigurationGroupAssignmentDeviceConfigurationMicrosoftGraphWindowUpdateForBusinessConfigurationQualityUpdatePause
```

Vous pouvez regarder quelle est la commande la plus longue de votre version avec ce script :

```powershell
Get-Command -Module Microsoft.Graph* |
  Select-Object Name,Module,@{N='Length';E={($_.Name).Length}} |
  Sort-Object Length
```

Pour les paramètres de commandes, ils sont en général très nombreux (et tant mieux) mais ils n'ont pas été pensés pour la praticité. Il faut par exemple très régulièrement utiliser l'ID d'une ressource plutôt que son DisplayName ou son UserPrincipalName (dans le cas d'un utilisateur).

### Installer les modules

Vous pouvez installer les modules `Microsoft.Graph` depuis PSGallery avec cette commande PowerShell (à lancer dans un terminal en tant qu'administrateur) :

```powershell
Install-Module 'Microsoft.Graph'
```

L'installation peut être longue puisque l'on va installer *tout les modules* liés à Microsoft Graph mais sachez qu'il est possible de n'installer que les modules vraiment nécessaire à votre usage. En général, les modules `Microsoft.Graph` et `Microsoft.Graph.Authentication` sont les seuls modules incontournables.

#### Pourquoi autant de modules ?

Vous allez le constater, mais il y a beaucoup de modules (et encore plus de commandes) liés à Microsoft Graph. Chaque module représente une ressource de l'API (la partie après la version dans l'URI). Ainsi, toutes les commandes liées à la gestion des groupes vont se retrouver dans le module `Microsoft.Graph.Groups` puisqu'elles utilisent toutes une URI qui commence par <https://graph.microsoft.com/v1.0/groups>.

Vous pouvez lister les modules `Microsoft.Graph` installés sur votre ordinateur avec la commande suivante :

```powershell
Get-InstalledModule -Name 'Microsoft.Graph*'
```

## Exercice pratique

### Se connecter en PowerShell

Comme pour Microsoft Graph Explorer, la première étape est de vous connecter à votre tenant de test. On utilise la commande `Connect-MgGraph` disponible dans le module "Microsoft.Graph.Authentication" :

```powershell
Connect-MgGraph
```

Votre navigateur web se lance et vous devriez pouvoir selectionner votre compte d'administration pour autoriser l'application "Microsoft Graph Command Line Tools" à se connecter. Une fois l'authentification terminée, la page web affiche le message suivant : *Authentication complete. You can return to the application. Fell free to close this browser tab.*

Côté PowerShell, vous devriez être accueilli par ce message :

> Welcome To Microsoft Graph!

### Votre première requête

De la même manière que dans Microsoft Graph Explorer, il est possible de lancer n'importe quelle requête API avec la méthode et l'URI en utilisant la commande `Invoke-MgGraphRequest` :

```powershell
Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/v1.0/me'
```

Par défaut, le retour de la commande est donné dans une hashtable. Il est possible de modifier le format de la réponse avec le paramètre `-OutputType`.

### Créer un groupe et ajouter des membres (POST)

```powershell
New-MgGroup
```

> New-MgGroup_CreateExpanded: Insufficient privileges to complete the operation.

```powershell
Connect-MgGraph -Scopes Group.ReadWrite.All
```

```powershell
Get-MgUser -Filter ''
```

### Rechercher un groupe et les membres d'un groupe (GET)

```powershell
Get-MgGroup
Get-MgGroupMember
```

Vous devriez avoir une limite de 1000 résultats sur votre requête `Get-MgGroup` si vous n'avez pas invoqué le paramètre `-All`. Cette limitation est liée au système de pagination de l'API sous-jacente.

### Mettre à jour un groupe (PATCH)

Si vous êtes habitué de PowerShell, vous êtes habitués à utiliser le verbe "Set" pour mettre à jour une ressource. Dans les modules Microsoft Graph, c'est plutôt le verbe "Update" qui est utilisé.

```powershell
Update-MgGroup
```

```powershell
Invoke-MgGraphRequest
```

### Supprimer un groupe (DELETE)

```powershell
Remove-MgGroup
```

## Passer à la version BETA

### Installation des modules

```powershell
Install-Module -Name 'Microsoft.Graph.Beta'
```

#### Liste des modules BETA

Vous pouvez lister les modules `Microsoft.Graph.Beta` installés sur votre ordinateur avec la commande suivante :

```powershell
Get-InstalledModule -Name 'Microsoft.Graph.Beta*'
```
