---
title: "KCLAD #2 - Epuisement des SID"
description: "Casser tous vos profils utilisateurs pour juste trier une liste déroulante ?"
tags: ["activedirectory", "powershell"]
listed: true
---

> **Disclaimer**
>
> KCLAD (*à lire "Casser l'AD"*) est une série d'articles techniques sur des trucs idiots à faire dans un domaine Active Directory. L'idée est de torturer un peu une maquette et essayer de mieux comprendre comment fonctionne Active Directory.
> Ces articles sont en deux parties : la partie "safe" et la partie "dangereuse". La partie dangereuse **n'est pas à reproduire sur la production, évidemment !**

Quasiment

- [Limite Active Directory : nombre de SID \| Philippe BARTH](https://pbarth.fr/node/257)
- [Limites et scalabilité maximales des services de domaine Active Directory \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/plan/active-directory-domain-services-maximum-limits)

## La partie sans danger

### Principe du SID

Tous les objets créés dans un domaine Active Directory sont pourvus d'un SID (*Security Identifier* ou identifiant de sécurité en français). Celui-ci va servir de plaque d'immatriculation de votre objet :

- Il est unique à votre domaine (et unique au monde normalement)
- Il n'est pas impacté par le déplacement ou le changement de nom de votre objet
- Même après la suppression de l'objet, le SID ne sera jamais réutilisé pour un nouvel objet

C'est ce SID qui va permettre d'identifier l'objet de manière pérenne, c'est cet élément qui est utilisé notamment pour les permissions NTFS.

### Constitution du SID

Les SID sont constitués de trois parties :

1. Le préfixe : `S-1-5-21-` qui est commun à tous les SID au monde
2. Le SID du domaine : `3245701951-2658985184-6587842991` qui est généré aléatoirement pour chaque domaine créé
3. Le RID (relative ID) : `-26067` qui est un numéro incrémental unique au niveau du domaine, compris entre 3 600 et 1 073 741 823 pour les objets créés par l'administrateur

Ce qui donne la forme finale suivante : `S-1-5-21-3245701951-2658985184-6587842991-26067`.

> Par défaut, il y a plus d'un milliard de RID disponibles (2^30) par domaine. Depuis Windows Server 2012, cette limite peut être augmentée à deux milliards (2^31) mais cette modification n'est a utiliser qu'en cas de dernier recours. Plus d'information sur le sujet ici : [Gestion de l'émission RID \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/manage/managing-rid-issuance#BKMK_GlobalRidSpaceUnlock)

#### Nombre de RID restants

Pour consulter le nombre de RID restants, vous pouvez utiliser cette commande sur le DC qui porte le rôle RIDMaster :

```powershell
Dcdiag.exe /TEST:RidManager /v | find /i "Available RID Pool for the Domain"
```

#### RID réservés

Certains RID sont connus et réservés : [Active Directory Security Groups \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups)

#### Attributs liés aux RID

- `rid` : toujours vide
- `ridAllocationPool` : défini sur les sous-objets "RID Set" présents sur chaque RWDC
  - 324699527652701 sur DC01
  - 438516161023201 sur DC02
  - 436368677374701 sur DC03
- `ridAvailablePool` : défini sur CN=RID Manager$,CN=System,DC=contoso,DC=com
  - Valeur trouvée : 4611686014132522709
- `ridManagerReference` : défini sur la racine du domaine
  - Valeur trouvée : CN=RID Manager$,CN=System,DC=contoso,DC=com
- `ridNextRid` : défini sur le sous-objet "RID Set" du DC "RIDMaster"
  - Valeur trouvée : 101672
- `ridPreviousAllocationPool` : défini sur le sous-objet "RID Set" du DC "RIDMaster"
  - Valeur trouvée : 438516161023201
- `ridServer` : toujours vide
- `ridSetReferences` : toujours vide
- `ridUsedPool` : défini sur les sous-objets "RID Set" présents sur chaque RWDC
  - Valeur trouvée : 0

Code pour lister tous les objets avec ces propriétés :

```powershell
$properties = 'rid', 'ridAllocationPool', 'ridAvailablePool', 'ridManagerReference', 'ridNextRid', 'ridPreviousAllocationPool', 'ridServer', 'ridSetReferences', 'ridUsedPool'
$object = Get-ADObject -Filter * -Properties $properties

$properties | ForEach-Object {
    Write-Host $_ -ForegroundColor Yellow
    $object | Group-Object -Property $_ | Format-Table -RepeatHeader
}
```

Fonction issue du site de Philippe Barth :

```powershell
function Get-ADDomainRIDUsage {
    param(
        [string]$Domain = (Get-ADDomain).DistinguishedName
    )

    $ridMaster = (Get-ADDomain $Domain).RIDMaster
    $ridManager = Get-ADObject "CN=RID Manager$,CN=System,$Domain" -Property * -Server $ridMaster

    $rid = $ridManager.ridAvailablePool
    [int32]$totalSIDs = $rid / [math]::Pow(2,32)
    [int64]$temp64Val = $totalSIDs * [math]::Pow(2,32)
    [int32]$currentPool = $rid - $temp64Val
    [int32]$remaining = $totalSIDs - $currentPool

    [PSCustomObject]@{
        TotalSID = $totalSIDs
        RIDIssued = $currentPool
        RemainingRID = $remaining
        Usage = "$([math]::Round($currentPool/$totalSIDs*100,2))%"
    }
}
```

Fonction de lecture d'un RID :

```powershell
function ConvertFrom-RIDNumber {
    param([int64]$RIDNumber)

    [int32]$totalSIDs = $RIDNumber / [math]::Pow(2,32)
    [int64]$temp64Val = $totalSIDs * [math]::Pow(2,32)
    [int32]$currentPool = $RIDNumber - $temp64Val
    [int32]$remaining = $totalSIDs - $currentPool

    $currentPool..$totalSIDs |
        Measure-Object -Minimum -Maximum |
        Select-Object Count, Minimum, Maximum
}
```

Code pour obtenir tous les RID Set :

```powershell
Get-ADObject -Filter {objectClass -eq 'rIDSet'} -Properties *, msds-ParentDistName | ForEach-Object {
    $ridPool = ConvertFrom-RIDNumber $_.ridAllocationPool
    [PSCustomObject]@{
        Server = $_.'msds-ParentDistName'
        RIDUsedPool = $_.ridUsedPool
        RIDPoolMin = $ridPool.Minimum
        RIDPoolMax = $ridPool.Maximum
        RIDPoolCount = $ridPool.Count
    }
}
```

### Distribution du SID

Définir le rôle FSMO du RID Master et parler des pools de RID distribués à chaque contrôleur

- taille des pools de RID

<https://technet.microsoft.com/library/jj574229.aspx>

on peut invalider un pool rid qui a été distribué

est-ce que
