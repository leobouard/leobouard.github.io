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

Name | ObjectClass | RID
---- | ----------- | ---
Enterprise Read-only Domain Controllers | group | 498
Administrator | user | 500
Guest | user | 501
krbtgt | user | 502
Domain Admins | group | 512
Domain Users | group | 513
Domain Guests | group | 514
Domain Computers | group | 515
Domain Controllers | group | 516
Cert Publishers | group | 517
Schema Admins | group | 518
Enterprise Admins | group | 519
Group Policy Creator Owners | group | 520
Read-only Domain Controllers | group | 521
Cloneable Domain Controllers | group | 522
Protected Users | group | 525
Key Admins | group | 526
Enterprise Key Admins | group | 527
Forest Trust Accounts | group | 528
External Trust Accounts | group | 529
RAS and IAS Servers | group | 553
Allowed RODC Password Replication Group | group | 571
Denied RODC Password Replication Group  | group | 572

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
        Usage = "$([math]::Round($currentPool/$totalSIDs*100,4))%"
    }
}
```

Récupération du prochain RID :

```powershell
function Get-ADNextRID {

    $ridMaster = Get-ADDomainController -Filter * | Where-Object {$_.OperationMasterRoles -contains 'RIDMaster'}
    (Get-ADObject $ridMaster.ComputerObjectDN -Property ridNextRid).ridNextRid
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

Étude des attributions de SID :

```powershell
$objects = Get-ADObject -Filter {ObjectClass -ne 'domainDNS'} -Properties ObjectSid -IncludeDeletedObjects |
    Where-Object { $_.ObjectSID -like 'S-1-5-21-*' }
$objects | Select-Object Name, ObjectClass, 
    @{ N='RID' ; E={[int64]($_.ObjectSID.Value -split '-' | Select-Object -Last 1)} } |
    Sort-Object RID
```


### Distribution du SID

Définir le rôle FSMO du RID Master et parler des pools de RID distribués à chaque contrôleur

- taille des pools de RID

<https://technet.microsoft.com/library/jj574229.aspx>

on peut invalider un pool rid qui a été distribué

est-ce que

### Epuisement du pool de RID

En auditant les pools de RID disponibles sur le DC02, on obtient les informations suivantes :

- Server : CN=DC02,OU=Domain Controllers,DC=contoso,DC=com
- RIDUsedPool : 0
- RIDPoolMin : 2100
- RIDPoolMax : 2599
- RIDPoolCount : 500

Depuis le DC02, je vais créer un nouvel objet qui devrait donc avoir le RID "2101" (le premier RID de la pool) :

```powershell
New-ADUser rid-2101 -Server DC02
```

Vérification avec la commande `Get-ADUser` :

```plaintext
DistinguishedName : CN=RID-2101,CN=Users,DC=contoso,DC=com
Enabled           : False
GivenName         :
Name              : RID-2101
ObjectClass       : user
ObjectGUID        : 75cfb8ce-035f-46ef-96b5-c8b74fc71c59
SamAccountName    : RID-2101
SID               : S-1-5-21-2608890186-2335135319-240251004-2101
Surname           :
UserPrincipalName :
```

Pour épuiser le pool de RID, j'ai simplement à éteindre le contrôleur de domaine qui porte le rôle RIDMaster et créer 499 comptes :

```powershell
2102..2600 | ForEach-Object { New-ADUser "rid-$_" }
```

Tous les comptes de `rid-2102` à `rid-2599` ont pu être créés sans problème, mais pour la création du compte `rid-2600` on tombe alors sur l'erreur suivante : **New-ADUser : The directory service has exhausted the pool of relative identifiers**.

Il faut alors redémarrer le RIDMaster pour obtenir un nouveau pool de 500 RID. L'attribution d'un nouveau pool est visible dans l'observateur d'évenements avec la commande suivante :

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=16648} | Format-List
```

Résultat :

```plaintext
TimeCreated  : 22/10/2025 10:22:00
ProviderName : Microsoft-Windows-Directory-Services-SAM
Message      : The request for a new account-identifier pool has completed successfully
```

### Invalider un pool de RID

Lors d'une procédure de restauration de forêt Active Directory, il est nécessaire de'invalider un pool de RID : [AD Forest Recovery - Invalidating the RID Pool \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-invaildate-rid-pool)

```powershell
$Domain = New-Object System.DirectoryServices.DirectoryEntry
$DomainSid = $Domain.objectSid
$RootDSE = New-Object System.DirectoryServices.DirectoryEntry("LDAP://RootDSE")
$RootDSE.UsePropertyCache = $false
$RootDSE.Put("invalidateRidPool", $DomainSid.Value)
$RootDSE.SetInfo()
```

On peut voir le résultat de la commande dans l'observateur d'évenement :

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=16654} | Format-List
```

Résultat :

```plaintext
TimeCreated  : 22/10/2025 10:19:20
ProviderName : Microsoft-Windows-Directory-Services-SAM
Id           : 16654
Message      : A pool of account-identifiers (RIDs) has been invalidated. This may occur in the following expected
               cases:
               1. A domain controller is restored from backup.
               2. A domain controller running on a virtual machine is restored from snapshot.
               3. An administrator has manually invalidated the pool.
               See http://go.microsoft.com/fwlink/?LinkId=226247 for more information.
```

En auditant le pool de RID disponibles sur le RIDMaster, on voit que celui-ci a été modifié :

- Server : CN=DC01,OU=Domain Controllers,DC=contoso,DC=com
- RIDUsedPool : 0
- RIDPoolMin : 3100
- RIDPoolMax : 3599
- RIDPoolCount : 500

## Augmenter la taille du RIDPool

