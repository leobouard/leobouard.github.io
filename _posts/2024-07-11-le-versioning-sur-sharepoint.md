---
layout: post
title: "Le versioning sur SharePoint"
description: "Comment récupérer facilement de l'espace de stockage sur SharePoint"
tags: sharepoint
listed: true
---

## C'est quoi le versioning ?

Lorsqu'un fichier est modifié, SharePoint conserve sa version précédente pour permettre à n'importe qui de revenir en arrière ou de visualiser le fichier avant sa modification. Par défaut, SharePoint permet de conserver jusqu'à 500 versions d'un même fichier.

C'est une fonctionnalité qui est très pratique, mais qui a comme désavantage de consommer beaucoup d'espace de stockage. En effet, au lieu de conserver une version différentielle du fichier (comme un GIT par exemple), SharePoint sauvegarde le fichier complet. Sur certains sites, cela peut donc mener à des multiplicateurs de 25 entre le poids des fichiers seuls sans leurs versions (100 GB par exemple) et le poids total du site SharePoint (2,5 TB dans cet exemple).

Si votre courbe d'usage de SharePoint monte en flèche et que vous allez bientôt être à court d'espace disponible, faire du ménage dans vos versions est une bonne idée pour gagner facilement des GB voir des TB de données.

## Modification de la configuration du tenant

### Contrôle de la configuration actuelle

> Dans la suite de cet article, j'utilise le module `PnP.PowerShell` plutôt que le module "officiel" `Microsoft.Online.SharePoint.PowerShell` par préférence personnelle.

On commence par installer le module `PnP.PowerShell` (uniquement disponible avec PowerShell dans ses dernières versions) :

```powershell
Install-Module PnP.PowerShell -Scope AllUsers
```

Avant de commencer à récupérer de l'espace de stockage, il faut arrêter l'hémorragie en réduisant le nombre maximal d'historiques de version et/ou leur durée de conservation.

> Depuis le mois de septembre 2024, l'utilisation du module PnP.PowerShell nécessite la création d'une application Entra ID dédiée : [Register an Entra ID Application to use with PnP PowerShell \| PnP PowerShell](https://pnp.github.io/powershell/articles/registerapplication.html)

On commence par se connecter sur votre portail d'administration SharePoint avec PowerShell, en indiquant l'URL de votre portail d'administration SharePoint et le ClientId de votre application Entra ID pour PNP :

```powershell
Connect-PnPOnline -Url 'https://contoso-admin.sharepoint.com' -ClientId '10a52256-36f0-4bb7-973d-986630ee8e3c' -Interactive
```

On consulte la configuration actuelle pour évaluer les changements à faire avec la commande suivante :

```powershell
Get-PnPTenant | Format-List *version*
```

On obtient alors les informations suivantes :

Propriété | Explication
--------- | -----------
ExpireVersionAfterDays | Durée de validité d'une version (en jours)
MajorVersionLimit | Nombre maximum de versions par fichier
EnableAutoExpirationVersionTrim | Limite automatique et intelligente des versions proposée par Microsoft
EnableVersionExpirationSetting | Disponibilité des paramètres d'expiration de versions (n'existe plus)

A titre d'exemple, voici les paramètres par défaut sur mon tenant de test :

```plaintext
ExpireVersionsAfterDays         : 0
MajorVersionLimit               : 500
EnableAutoExpirationVersionTrim : False
EnableVersionExpirationSetting  : 
```

### Modification de la configuration

Il est possible d'agir sur le nombre maximum de versions au niveau du tenant. Dans mon exemple, je descends de 500 à 100 versions majeures au maximum :

```powershell
Set-PnPTenant -MajorVersionLimit 100
```

On en profite aussi pour définir une durée de validité pour les versions. Dans ma configuration, un an après sa création, la version d'un fichier est **susceptible** d'être supprimée :

```powershell
Set-PnPTenant -ExpireVersionsAfterDays 365
```

> #### Pourquoi je dis qu'une version est "susceptible" d'être supprimée ?
>
> La suppression d'une version au bout d'un certain temps n'est pas garantie : elle dépend de l'activité sur le fichier. En effet, la suppression des *vieilles* versions n'est effectuée que lors de la création d'une nouvelle version du fichier (et dans la limite de ~20 versions supprimées par nouvel évènement).

Cette configuration est appelée configuration "manuelle" par Microsoft, qui propose de son côté une méthode plus intelligente et automatique de gestion des versions avec le paramètre "EnableAutoExpirationVersionTrim".

### Le paramètre EnableAutoExpirationVersionTrim

Microsoft propose un dernier paramètre pour gérer les versions : *EnableAutoExpirationVersionTrim*. Celui-ci permettrait une configuration plus intelligente et plus efficace que de simples seuils définis manuellement sur la durée de vie et/ou le nombre de versions.

Avec ce paramètre, la conservation des versions se fait de manière différenciée suivant l'âge des versions :

- **Pendant les 30 premiers jours** : toutes les versions sont conservées dans la limite de 500 versions
- **Entre un et deux mois** : une seule version par heure du fichier est conservée
- **Entre deux et six mois** : une seule version par jour du fichier est conservée
- **Après six mois** : une seule version par semaine du fichier est conservée

Voici un graphique fourni par Microsoft sur les différences entre les configurations manuelles et la configuration automatique :

![Comparaison entre les différentes méthodes](https://learn.microsoft.com/en-us/sharepoint/sharepointonline/media/version-history/cmpr-res-sto-opt-2.png)

Si vous souhaitez utiliser cette configuration, vous pouvez l'activer sur votre tenant de cette manière :

```powershell
Set-PnPTenant -EnableAutoExpirationVersionTrim:$true
```

Lorsque celui-ci est défini, il se passe deux choses (en silence) sur la configuration du tenant :

1. Le paramètre *MajorVersionLimit* revient à sa valeur initiale (500)
2. Le paramètre *ExpireVersionsAfterDays* passe quant à lui à 30 jours

Il n'est alors plus possible de modifier les paramètres *MajorVersionLimit* ou *ExpireVersionsAfterDays* qui restent bloqués à leurs valeurs par défaut :

```plaintext
Set-PnPTenant: The parameter ExpireVersionsAfterDays can't be set because the Tenant has AutoExpiration enabled
```

On retrouve donc la configuration évoquée précédemment, où pendant 30 jours, jusqu'à 500 versions peuvent être conservées.

> #### Rappel
>
> Le nettoyage des versions ne sera déclenché que lors de la création d'une nouvelle version du fichier (donc modification du fichier).

## Contrôle de la propagation de la configuration

Pour s'assurer que la configuration que vous venez de faire sur votre tenant s'est propagée correctement sur tous vos sites SharePoint, on utilise la commande suivante :

```powershell
Get-PnPTenantSite | Select-Object Title, *version*
```

La valeur qui nous intéresse est InheritVersionPolicyFromTenant qui devrait être à "True" sur la majorité des sites SharePoint.

Si un site SharePoint est à "False", cela signifie qu'une politique d'historique de version a été définie au niveau du site, ce qui bloque l'héritage de la configuration issue du tenant. Plus d'information sur ce mécanisme ici : [Version history limits for document library and OneDrive overview - SharePoint in Microsoft 365 \| Microsoft Learn](https://learn.microsoft.com/en-us/sharepoint/document-library-version-history-limits#how-version-history-limits-are-applied).

Pour lister tous les sites qui n'héritent pas de la configuration du tenant :

```powershell
Get-PnPTenantSite | Where-Object {$_.InheritVersionPolicyFromTenant -eq $false}
```

## Suppression des historiques de versions

Maintenant que la configuration de nos sites SharePoint est propre, on peut passer au nettoyage des versions superflues pour gagner rapidement de l'espace de stockage.

Se connecter au site SharePoint que l'on veut nettoyer :

```powershell
Connect-PnPOnline -Url 'https://contoso.sharepoint.com/sites/leadership-connection'
```

### Suppression des versions

Ne garder que les 100 dernières versions des fichiers :

```powershell
New-PnPSiteFileVersionBatchDeleteJob -MajorVersionLimit 100
```

Pour supprimer les versions qui ont plus d'un an :

```powershell
New-PnPSiteFileVersionBatchDeleteJob -DeleteBeforeDays 365
```

> Limitation côté Microsoft : il n'est pas possible de conserver des versions créées avant le 01 janvier 2023.

Utiliser la méthode automatique proposée par Microsoft :

```powershell
New-PnPSiteFileVersionBatchDeleteJob -Automatic
```

La suppression peut prendre jusqu'à quelques jours pour être complétée en totalité.

### Consulter les résultats

Pour suivre l'avancement de la suppression des versions inutiles, vous pouvez utiliser la commande suivante :

```powershell
$results = Get-PnPSiteFileVersionBatchDeleteJobStatus
$results
```

Voici un exemple de résultat :

```plaintext
Url                         : https://contoso.sharepoint.com/sites/leadership-connection
WorkItemId                  : e4f5ff2f-e7ff-48c8-b4ea-abe7bc755d6f
Status                      : InProgress
ErrorMessage                :
RequestTimeInUTC            : 08/01/2024 07:29:24
LastProcessTimeInUTC        : 08/01/2024 07:40:49
CompleteTimeInUTC           :
BatchDeleteMode             : DeleteOlderThanDays
DeleteOlderThan             : 01/01/2024 07:29:24
MajorVersionLimit           :
MajorWithMinorVersionsLimit :
FilesProcessed              : 2155
VersionsProcessed           : 3660
VersionsDeleted             : 3656
VersionsFailed              : 0
StorageReleasedInBytes      : 9583893219
```

Pour afficher la quantité de données récupérées (en GB) :

```powershell
[math]::Round($results.StorageReleasedInBytes / 1GB,2)
```

### Script complet

Voici un script qui permet de lancer un nettoyage des versions de plus d'un an sur tous les sites SharePoint de plus de 100 GB.

L'utilisation d'une application Entra ID est maintenant obligatoire. Vous aurez besoin de la permission déléguée SharePoint `AllSites.FullControl` et le rôle *SharePoint Administrator*.

Attention : ce script ajoute l'utilisateur indiqué dans la variable `$upn` en tant que propriétaire de tous les sites SharePoint sur lesquels il doit invervenir. Pensez à faire un peu de ménage après l'exécution du script.

```powershell
#Requires -Modules PnP.PowerShell
#Requires -RunAsAdministrator
#Requires -Version 7.4.5

Update-Module PnP.PowerShell

$minimumSizeGB = 100
$upn = 'admin@contoso.onmicrosoft.com'

# PnP PowerShell Entra ID app settings
$appSettings = @{
    ClientId    = '10a52256-36f0-4bb7-973d-986630ee8e3c'
    Url         = 'https://contoso-admin.sharepoint.com/'
    Interactive = $true
}

# Connect to SharePoint admin center
Connect-PnPOnline @appSettings

# Get all sites with over 100 GB of storage usage
$sites = Get-PnPTenantSite
$limit = $minimumSizeGB * 1000
$sites = $sites | Where-Object { $_.StorageUsageCurrent -gt $limit }

# Add as admin for all needed sites
$sites | ForEach-Object { Set-PnPTenantSite -Identity $_.Url -Owners $upn }

# Create the batch delete job foreach site over X GB
$sites | ForEach-Object {

    # Connect to the SharePoint site
    Write-Host "$($_.Url)"
    $appSettings.Url = $_.Url
    Connect-PnPOnline @appSettings

    # Create the batch delete job
    New-PnPSiteFileVersionBatchDeleteJob -DeleteBeforeDays 365 -Force
}
```
