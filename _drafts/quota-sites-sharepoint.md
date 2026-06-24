---
title: "Application de quota sur des sites SharePoint"
description: "Comment limiter la taille maximum d'un site SharePoint avec PowerShell ?"
tags: ["sharepoint", "powershell"]
---

## Qu'est-ce qu'un quota SharePoint ?

Un quota SharePoint permet de limiter l'espace de stockage alloué à un seul site SharePoint. Par défaut, un site SharePoint peut faire jusqu'à 25 TB ce qui est souvent suffisant pour **consommer l'intégralité du stockage de votre tenant**. Pour éviter la croissance incontrôlée de l'utilisation de votre espace SharePoint, il peut être intéressant de définir des quotas sur vos sites pour :

- Inciter vos utilisateurs à faire du ménage régulièrement
- Empêcher l'ajout de plusieurs dizaines de gigaoctets d'un coup sans qualification du besoin

### Comment modifier le quota d'un site ?

Vous pouvez très simplement le faire depuis [la console d'administration SharePoint](https://contoso-admin.sharepoint.com/), comme indiqué dans la [documentation officielle de Microsoft](https://learn.microsoft.com/en-us/sharepoint/manage-site-collection-storage-limits) ou en PowerShell avec le module `PnP.PowerShell`.

Voici un exemple pour modifier le quota du site "Marketing" à 10 GB :

```powershell
$url = "https://contoso.sharepoint.com/sites/marketing"
$quota = 10 * 1024
Set-PnPTenantSite -Identity $url -StorageQuota $quota
```

> Le paramètre `-StorageQuota` attend une valeur en MB, c'est pour ça que l'on multiplie les 10 GB par 1024 dans notre variable `$quota`.

### Comment modifier le quota par défaut ?

Pour changer la valeur de 25 TB maximum pour les nouveaux sites SharePoint, il y a deux étapes à suivre :

1. Modifier du quota par défaut (passage de automatique à manuel) : [Limites de stockage de site - Paramètres - Centre d’administration SharePoint](https://contoso-admin.sharepoint.com/_layouts/15/online/AdminHome.aspx#/settings/AutoQuotaEnabled)
2. Réduire le quota maximum de 25600 GB à 10 GB pour les nouveaux sites : [Création de site - Paramètres - Centre d’administration SharePoint](https://contoso-admin.sharepoint.com/_layouts/15/online/AdminHome.aspx#/settings/SiteCreation)

Ces deux paramètres ne sont pas rétroactifs, il faut donc repasser sur tous les autres sites du tenant pour appliquer un quota différent que les 25 TB par défaut.

### Comment définir des quotas à grande échelle ?

On a vu comment modifier le quota d'un seul site et le quota par défaut pour les nouveaux sites, mais on souhaite maintenant plafonner à grande échelle tous les sites existants sur notre tenant. Pour faire cela, on va encore utiliser le module PowerShell `PnP.PowerShell` et appliquer les quotas suivants :

- Taille S (par défaut) : 10 GB
- Taille M : 50 GB
- Taille L : 250 GB

> On augmente la taille maximum par 5 entre chaque quota.

## Audit d'application des quotas

La première étape pour appliquer les quotas à grande échelle, c'est de savoir quel quota on va pouvoir appliquer à chaque site. Pour un site qui pèserait 100 GB, on va appliquer le quota de 250 GB par exemple.

### Quotas par tranche

On commence par se connecter sur le tenant à l'aide d'une application Azure. Si vous ne disposez pas d'application Azure pour PnP, vous pouvez la créer à l'aide de cette documentation : [Register an Entra ID Application to use with PnP PowerShell \| PnP PowerShell](https://pnp.github.io/powershell/articles/registerapplication.html).

```powershell
$appSettings = @{
    ClientId = '088a1da0-378b-4943-9374-925d408c82f2'
    Url = 'https://contoso-admin.sharepoint.com/'
    Interactive = $true
}
Connect-PnPOnline @appSettings
```

On récupère ensuite tous les sites du tenant (ce qui peut prendre plusieurs minutes si vous disposez de beaucoup de sites SharePoint) :

```powershell
$sites = Get-PnPTenantSite
```

Il ne nous reste plus qu'à associer chaque site avec la taille de quota qui lui correspond. Voici quelques exemples du comportement attendu :

- Pour un site de 7 GB : quota de 10 GB
- Pour un site de 25 GB : quota de 50 GB
- Pour un site de 100 GB : quota de 250 GB

> Les sites avec un quota personnalisé et un usage du stockage actuel de +200 GB ont été ignorés pour simplifier le script et éviter d'impacter des sites qui ont déjà été modifiés.

Voici le script pour faire l'analyse :

```powershell
$report = $sites | Where-Object { $_.StorageQuota -eq 26214400 -and $_.StorageUsageCurrent -lt 200000 } | ForEach-Object {

    $proposedQuota = if ([int]$_.StorageUsageCurrent / 1000 -lt 10) { 10 } # 10 GB
    elseif ([int]$_.StorageUsageCurrent / 1000 -lt 50) { 50 }              # 50 GB
    elseif ([int]$_.StorageUsageCurrent / 1000 -lt 250) { 250 }            # 250 GB

    $quotaUsage = [math]::Round(($_.StorageUsageCurrent / 1000) / $proposedQuota * 100, 2)

    [PSCustomObject]@{
        Name                = $_.Title
        Url                 = $_.Url
        StorageUsageCurrent = $_.StorageUsageCurrent / 1000
        ProposedQuota       = $proposedQuota
        QuotaUsage          = $quotaUsage
    }
}
```

On peut afficher les résultats avec la commande suivante :

```powershell
$report | Group-Object proposedQuota
```

### Sites trop proches du quota proposé

Si un site occupe déjà 9 GB sur son quota de 10 GB, on arrive tout de suite à 90% d'utilisation ce qui n'est pas souhaitable. On va donc identifier tous les sites qui seront à +80% d'usage pour mesurer l'impact et prendre des mesures :

```powershell
$report | Where-Object {$_.quotaUsage -gt 80} |
    Sort-Object proposedQuota, quotaUsage |
    Select-Object @{N='ShortURL';E={$_.Url -replace 'https://contoso.sharepoint.com', '...'}}, StorageUsageCurrent, ProposedQuota, QuotaUsage |
    Format-Table -GroupBy proposedQuota
```

### Application des quotas

Il ne reste plus qu'à définir les nouveaux quotas sur tous les sites du tenant. En se basant sur le rapport précédent, on peut appliquer des quotas en fonction de l'usage actuel. Si l'usage du quota est à 80% ou plus, on passe automatiquement sur la tranche supérieure (10 GB vers 50 GB par exemple)  :

```powershell
$report | ForEach-Object {

    Write-Host "Processing $($_.Name)" -ForegroundColor Yellow

    $proposedQuota = $_.proposedQuota
    if ($_.quotaUsage -gt 80) {
        $proposedQuota = $proposedQuota * 5
        Write-Host "  The proposedQuota has been increased from $($_.proposedQuota) GB to $proposedQuota GB because the usage was above 80% ($($_.quotaUsage)%)"
    }
    $proposedQuota = $proposedQuota * 1024

    Set-PnPTenantSite -Identity $_.Url -StorageQuota $proposedQuota
}
```

> N'oubliez pas de traiter manuellement (ou en PowerShell) les sites de +200 GB qui ont été ignorés dans le processus.
