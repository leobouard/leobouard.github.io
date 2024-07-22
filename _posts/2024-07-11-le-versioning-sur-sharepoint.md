---
layout: post
title: "Le versioning sur SharePoint"
description: "Comment récupérer des TB de données sur SharePoint"
tags: sharepoint
listed: true
---

## C'est quoi le versionning ?

Par défaut, lorsqu'un fichier est modifié, SharePoint conserve sa version précédente pour permettre à n'importe qui de revenir en arrière ou de visualiser le fichier avant sa modification. Par défaut, SharePoint permet de conserver jusqu'à 500 versions d'un même fichier.

C'est une fonctionnalité qui est très pratique mais qui a comme désavantage de consommer beaucoup d'espace. En effet, au lieu de conserver une version différentielle du fichier (comme un GIT par exemple), SharePoint sauvegarde le fichier complet. Sur certains sites SharePoint, cela peut donc mener à des multiplicateurs de 25 entre le poids réel des fichiers (100 GB par exemple) et le poids total des fichiers + leurs versions (2,5 TB dans cet exemple).

## Modification de la configuration du tenant

### Contrôle de la configuration actuelle

Avant de commencer à récupéré de l'espace de stockage, il faut arrêter l'hémoragie en réduisant le nombre maximal d'historique de version et/ou leur durée de conservation.

On commence par se connecter sur le portail d'administration de SharePoint avec PowerShell :

```powershell
Connect-PnPOnline -Url 'https://contoso-admin.sharepoint.com' -Interactive
```

On consulte la configuration actuelle pour évaluer les changements à faire avec la commande suivante :

```powershell
Get-PnPTenant | Select-Object *version* | Format-List
```

On obtient alors les informations suivantes :

Propriété | Explication
--------- | -----------
ExpireVersionAfterDays | Durée de validité d'une version (en jours)
MajorVersionLimit | Nombre maximum de versions par fichier
EnableAutoExpirationVersionTrim | Nettoyage automatique des versions caduques
EnableVersionExpirationSetting | Disponibilité des paramètres d'expiration de versions

A titre d'exemple, voici les paramètres par défaut sur mon tenant de test :

```plaintext
ExpireVersionsAfterDays         : 0
MajorVersionLimit               : 500
EnableAutoExpirationVersionTrim : False
EnableVersionExpirationSetting  : False
```

### Modification de la configuration

On commence par activer les fonctionnalités d'expiration de version de fichier au niveau du tenant :

```powershell
Set-PnPTenant -EnableVersionExpirationSetting:$true
```

Une fois les fonctionnalités débloquées, il est enfin possible d'agir sur le nombre maximum de versions au niveau du tenant. Dans mon exemple, je descend de 500 à 100 versions majeures au maximum :

```powershell
Set-PnPTenant -MajorVersionLimit 100
```

On en profite aussi pour définir une durée de validité pour les versions. Dans ma configuration, trois ans après sa création, la version d'un fichier est suceptible d'être supprimée automatiquement :

```powershell
Set-PnPTenant -ExpireVersionsAfterDays 1096
```

### Le paramètre EnableAutoExpirationVersionTrim

SharePoint propose un dernier paramètre pour gérer les versions : *EnableAutoExpirationVersionTrim*. Celui-ci est tentant puisqu'il permettrait de supprimer automatiquement les versions superflues (trop vieilles ou trop nombreuses) des fichiers.

Cependant, c'est un peu plus complexe que cela. Le paramètre fonctionne bel et bien, mais probablement pas de la manière dont vous pensez. Ce "nettoyage" des anciennes versions de fichiers ne se lance pas automatiquement : il doit être "provoqué" par la création d'un nouvelle version du fichier.

Ce premier point rend déjà ce paramètre inutile pour les vieux fichiers qui ne sont plus modifiés, mais ça ne s'arrête pas là. Ce nettoyage ne peut pas s'occuper de toutes les versions caduques d'un seul coup, il supprime en général une vintaine de versions à la fois.

Donc dans un scénario où vous passez de 500 versions à 100 versions maximum, il vous faudrait 20 modifications d'un fichier pour revenir sous la nouvelle limite de 100 versions.

> #### Pourquoi est-ce que ce paramètre fonctionne de cette manière ?
>
> La raison est plutôt simple : cela génèrerait trop de charge de travail pour SharePoint de lancer périodiquement le ménage des vieilles versions. Sur des tenants avec plusieurs centaines de TB de données, cela nécessiterait une énorme capacité de calcul côté SharePoint. Pour contourner ce problème, Microsoft profite donc de la création d'une nouvelle version d'un fichier pour faire le ménage dans les anciennes versions.

Si le fonctionnement de ce paramètre vous convient toujours, vous pouvez l'utiliser de cette manière :

```powershell
Set-PnPTenant -EnableAutoExpirationVersionTrim:$true
```

Lorsque celui-ci est défini, il se passe deux choses (en silence) sur la configuration du tenant :

1. Le paramètre *MajorVersionLimit* revient à sa valeur initiale (500 jours)
2. Le paramètre *ExpireVersionsAfterDays* passe quand à lui à 30 jours

Il n'est alors plus possible de modifier les paramètres *MajorVersionLimit* ou *ExpireVersionsAfterDays* qui restent bloqués à leurs valeurs par défaut :

> Set-PnPTenant: The parameter ExpireVersionsAfterDays can't be set because the Tenant has AutoExpiration enabled

## Contrôle de la propagation de la configuration

```powershell
Get-PnPTenantSite | Select-Object Title,*version*
```

## Suppression forcée des historiques de versions

Comme vu précédemment, ce n'est pas le paramètre *EnableAutoExpirationVersionTrim* qui va nous sauvez cette fois-ci. Il va donc falloir se retrousser les manches et aller chercher ces GB vous-même.

Bonne nouvelle pour vous, je vous ai préparé un script qui va vous permettre de faire ça plus ou moins rapidement : [Gist](https://gist.github.com/leobouard).

Pour vous rendre compte des temps d'exécution et des gains potentiels, voici les données que j'ai pu observer :

Site     | Poids initial | Fichiers | GB récup | % récup | Temps d'exec
-------- | ------------- | -------- | -------- | ------- | ------------
CONTOSO1 | 350 GB        | 1300     | 95 GB    | 27%     | 1h15
CONTOSO2 | 425 GB        | 1200     | 65 GB    | 15%     | 2h25
CONTOSO3 | 250 GB        | 570      | 35 GB    | 14%     | 0h15

Comme plan d'attaque, je vous recommande de vous attaquer en priorité aux sites SharePoint avec **le pire ratio entre le nombre de fichiers et l'espace de stockage occupé**. Un site SharePoint qui contient 500 fichiers et pèse 1 TB fait une moyenne à 2 GB par fichier. A moins qu'il s'agisse de fichiers lourds (comme de la vidéo par exemple), c'est probablement un site qui pourrait bénéficier d'un peu de ménage sur ses versions !
