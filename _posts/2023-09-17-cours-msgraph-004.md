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

- **Mises à jour des modules** : Les modules Microsoft Graph sont mis à jour très régulièrement pour suivre l'API. Ces mises à jour peuvent impacter le nom des commandes, voir même les supprimer. Par exemple, quatre modules complets (et les commandes qui vont avec) ont été supprimés entre la version 1.28.0 et la version 2.2.0 (deux mois d'écart entre les versions).
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

### Les paramètres de requêtes

Les paramètres de requêtes sont toujours présents en PowerShell, sauf qu'au lieu de les ajouter à la fin de l'URI, ils prennent maintenant la forme de paramètres de commande. Vous retrouverez donc :

- `-Filter` pour filtrer les résultats
- `Select` pour limiter les résultats à certaines propriétés
- `-Search` pour rechercher
- `-Top` pour obtenir seulement les X premiers résultats
- `-Skip` pour ignorer les X premiers résultats
- `-Sort` pour trier l'information
- `-CountVariable` pour compter le nombre de résultats

Le paramètre que vous utiliserez le plus sera probablement le filtre, il est donc important d'en maitriser la syntaxe. En effet, on garde la syntaxe OData qui est donc différente des opérateurs de comparaison PowerShell classique.

Voici quelques exemples sur la différence de syntaxe :

PowerShell | OData | Description
------------------ | ------------- | ----------
`accountEnabled -eq $true` | `accountEnabled eq true` | Le compte est actif
`displayName -like 'Ana*'` | startsWith(displayName, "Ana") | Le nom commence par "Ana"
`displayName -like '*abe*'` | displayName contains "abe" | Le nom contient "abe"
`displayName -like '*elle'` | endsWith(displayName,"elle") | Le nom se termine par "elle"

Si vous êtes familier avec les règles d'appartenance sur les groupes dynamiques, il s'agit de la même syntaxe.

Plus d'informations ici : [Utiliser un filtre \| Microsoft Graph](https://learn.microsoft.com/graph/filter-query-parameter)

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

### Créer un groupe

Avec la commande `New-MgGroup` nous allons créer un groupe "Equipe de nuit" avec les paramètres suivants :

- DisplayName : Equipe de nuit
- MailEnabled : False
- MailNickname : equipe-a
- SecurityEnabled : True

```powershell
$params = @{
    displayName     = "Equipe de nuit"
    mailEnabled     = $false
    mailNickname    = "7427fc71-0"
    securityEnabled = $true
}
New-MgGroup @params
```

Cependant, la commande tombe en erreur :

<blockquote style="
    background: var(--negative);
    border-color: red;
">
  <p>New-MgGroup_CreateExpanded: Insufficient privileges to complete the operation.</p>
</blockquote>

Si vous êtes encore tombé dans le piège, c'est que vous n'avez pas encore assimilé cette partie : [Permissions et étendues (scope)](/2023/09/17/cours-msgraph-002#permissions-et-étendues-scopes). Même si vous êtes l'administrateur global de votre tenant vous n'avez pas tous les droits intialement : il faut les demander. Pour demander une permission suplémentaire avec PowerShell, il faut se reconnecter via la commande `Connect-MgGraph` tout en spécifiant le scope dont vous avez besoin (en l'occurence : *Group.ReadWrite.All*).

```powershell
Connect-MgGraph -Scopes Group.ReadWrite.All
```

En rappelant la commande précédente vous devriez alors pouvoir créer votre groupe.

### Ajouter un membre

Pour ajouter un membre dans le groupe, il vous faudra connaitre l'identifiant du groupe que vous avez créé et l'identifiant de l'utilisateur que vous voulez ajouter (votre compte par exemple).

Vous pouvez trouver ces deux informations dans votre historique PowerShell, dans le portail d'administration Entra ID ou via des requêtes Microsoft Graph.

```powershell
New-MgGroupMember -GroupId {groupId} -DirectoryObjectId {userId}
```

### Mettre à jour le groupe

Si vous travaillez souvent avec PowerShell, vous avez peut-être l'habitude d'utiliser des commandes avec le verbe "Set" pour mettre à jour de l'information. Dans les modules Microsoft Graph, c'est plutôt le verbe "Update" qui est utilisé.

Pour mettre à jour les informations d'un groupe, on utilise la commande `Update-MgGroup` suivi du paramètre indiquant la propriété à mettre à jour (par exemple : `-Description`)

```powershell
Update-MgGroup -GroupId {groupId} -Description 'Première équipe du soir pour les 3-8'
```

### Rechercher les membres d'un groupe

Pour lister les membres d'un groupe, vous pouvez utiliser la commande `Get-MgGroupMember`.

```powershell
Get-MgGroupMember -GroupId {groupId}
```

#### Rappel pagination

N'oubliez pas la pagination des résultats ! Sur l'ensemble des requêtes GET, vous serez limité à un certain nombre de résultats (1000 en général). Pour obtenir tous les résultats, vous devez bien spécifier le paramètre `-All`.

### Supprimer le groupe

Dernière étape de l'exercice : supprimer le groupe que vous avez créé. Pour ça il n'y a qu'à utiliser la commande `Remove-MgGroup` en lui indiquant l'ID du groupe à supprimer.

```powershell
Remove-MgGroup -GroupId {groupId}
```

## Passer à l'API Beta

L'utilisation de l'API Beta via PowerShell a été modifiée depuis la version 2.0.0. Ici je ne parlerai que de la nouvelle méthode de passage à la Beta, mais si vous êtes curieux vous pouvez lire cet article : [Microsoft Graph V2 PowerShell \| IT-Connect](https://www.it-connect.fr/powershell-microsoft-graph-v2-nouveautes-migration-avenir-modules-actuels/).

Le passage sur l'API Beta est très simple en PowerShell, mais il nécessite l'installation (et la mise à jour régulière) de modules dédiés : les modules `Microsoft.Graph.Beta`.

### Installation des modules

Vous pouvez installer les modules avec la commande suivante :

```powershell
Install-Module -Name 'Microsoft.Graph.Beta'
```

Vous pouvez ensuite lister les modules Beta installés sur votre ordinateur avec la commande suivante :

```powershell
Get-InstalledModule -Name 'Microsoft.Graph.Beta*'
```

### Utilisation de l'API Beta

Les commandes issues des modules Beta fonctionnent de la même manière que ceux pour requêter l'API v1.0. Ils portent les mêmes noms, possèdent souvent les mêmes paramètres et fonctionnent dans la même session ouverte via `Connect-MgGraph`. Ils se distinguent simplement par le préfix "Beta" qui s'insère entre le préfix "Mg" et le nom de la commande.

Voici quelques exemples :

- Get-MgUser devient Get-Mg**Beta**User
- Exemple 2
- Exemple 3
- Exemple 4

Attention cependant : toutes les commandes n'ont pas forcément leur pendant "Beta"

## Conclusion
