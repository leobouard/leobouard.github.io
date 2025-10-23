---
title: "KCLAD #2 - Epuisement des RID"
description: "Consommer tous les RID pour empêcher la création de nouveaux objets sur le domaine Active Directory"
tags: ["activedirectory", "powershell"]
listed: true
---

> **Disclaimer**
>
> KCLAD (*à lire "Casser l'AD"*) est une série d'articles techniques sur des trucs idiots à faire dans un domaine Active Directory. L'idée est de torturer un peu une maquette et essayer de mieux comprendre comment fonctionne Active Directory.
> Ces articles sont en deux parties : la partie "safe" et la partie "dangereuse". La partie dangereuse **n'est pas à reproduire sur la production, évidemment !**

Cet article s'appuie en grande partie sur l'excellent travail de Phillipe Barth sur le sujet : [Limite Active Directory : nombre de SID \| Philippe BARTH](https://pbarth.fr/node/257).

## Principe du SID

Tous les objets créés dans un domaine Active Directory sont pourvus d'un SID (*Security Identifier* ou identifiant de sécurité en français). Celui-ci va servir de plaque d'immatriculation de votre objet :

- Il est unique à votre domaine (et unique au monde normalement)
- Il n'est pas impacté par le déplacement ou le changement de nom de votre objet
- Même après la suppression de l'objet, le SID ne sera jamais réutilisé pour un nouvel objet

C'est ce SID qui va permettre d'identifier l'objet de manière pérenne, et c'est pour cela qu'il est utilisé notamment pour les permissions NTFS.

### Constitution du SID

Les SID sont constitués de trois parties :

Partie | Exemple | Explication
------ | ------- | -----------
Préfixe | `S-1-5-21-` | Commun à tous les SID de domaine
SID du domaine | `2608890186-2335135319-240251004` | Généré aléatoirement pour chaque domaine Active Directory créé
RID (*relative ID*) | `-26067` | Numéro incrémental unique au niveau du domaine, compris entre 3 600 et 1 073 741 823 pour les objets créés par l'administrateur

Ce qui donne la forme finale suivante : `S-1-5-21-2608890186-2335135319-240251004-26067`.

> Par défaut, il y a plus d'un milliard de RID disponibles (2^30) par domaine. Depuis Windows Server 2012, cette limite peut être augmentée à deux milliards (2^31) mais cette modification n'est a utiliser qu'en cas de dernier recours. Plus d'information sur le sujet ici : [Gestion de l'émission RID \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/manage/managing-rid-issuance#BKMK_GlobalRidSpaceUnlock)

### RID réservés

Certains RID sont connus (*well-known* en anglais) et réservés. Voici un tableau avec les objets les plus importants :

Name | ObjectClass | RID
---- | ----------- | ---
Enterprise Read-only Domain Controllers | group | `498`
Administrator | user | `500`
Guest | user | `501`
krbtgt | user | `502`
Domain Admins | group | `512`
Domain Users | group | `513`
Domain Guests | group | `514`
Domain Computers | group | `515`
Domain Controllers | group | `516`
Cert Publishers | group | `517`
Schema Admins | group | `518`
Enterprise Admins | group | `519`
Group Policy Creator Owners | group | `520`
Read-only Domain Controllers | group | `521`
Cloneable Domain Controllers | group | `522`
Protected Users | group | `525`
Key Admins | group | `526`
Enterprise Key Admins | group | `527`
Forest Trust Accounts | group | `528`
External Trust Accounts | group | `529`
RAS and IAS Servers | group | `553`
Allowed RODC Password Replication Group | group | `571`
Denied RODC Password Replication Group  | group | `572`

> Même si celui-ci n'est pas un RID réservé, dans mon lab, l'objet qui porte le RID -1000 est mon premier contrôleur de domaine (celui qui a permi de créer la forêt).

Le tableau a été généré par le script suivant :

```powershell
$objects = Get-ADObject -Filter {ObjectClass -ne 'domainDNS'} -Properties ObjectSid -IncludeDeletedObjects |
    Where-Object { $_.ObjectSID -like 'S-1-5-21-*' }
$objects | Select-Object Name, ObjectClass, 
    @{ N='RID' ; E={[int64]($_.ObjectSID.Value -split '-' | Select-Object -Last 1)} } |
    Sort-Object RID
```

Plus d'informations sur le sujet : [Active Directory Security Groups \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups)

### Nombre de RID restants

Pour consulter le nombre de RID restants, vous pouvez utiliser cette commande sur le contrôleur de domaine qui porte le rôle RIDMaster :

```powershell
Dcdiag.exe /TEST:RidManager /v | find /i "Available RID Pool for the Domain"
```

Mais je préfère l'utilisation d'une fonction PowerShell (issue du code original de Philippe Barth) qui a comme avantage de pouvoir être lancée depuis n'importe quel serveur avec le module PowerShell Active Directory installé :

{% include github-gist.html name="Get-ADDomainRidUsage" id="f15154cd996679e283fe3578045d0ec4" %}

En général, même sur des environnements Active Directory très larges et/ou très anciens, on dépasse rarement le 1% d'utilisation des RID.

## Système de pool RID

### Définition

Je ne pourrais pas faire mieux que la définition qui a été donnée par [Philippe BARTH](https://pbarth.fr/) sur le sujet, donc je me permets de le citer :

> Dans Active Directory, les contrôleurs de domaines sont multi-maitres, il est donc possible de créer des objets depuis n'importe quel contrôleur de domaine. Pour cela chaque contrôleur de domaine dispose d'une plage d'identifiant qui lui est dédiée. Un contrôleur de domaine dans le domaine dispose d'un rôle FSMO spécifique : le maître RID. Le contrôleur de domaine qui dispose de ce rôle a en charge de distribuer des plages d'identifiants réservés aux autres contrôleurs de domaine.

L'idée d'un pool RID est de permettre à n'importe quel contrôleur de domaine de pouvoir créer un objet sans avoir à contacter le RIDMaster systématiquement, tout en évitant les conflits d'utilisation de RID avec d'autres contrôleurs de domaine. Par défaut, les contrôleurs de domaine possèdent des pools de 500 RID qui sont renouvelés au moment de l'épuisement du pool précédent.

On peut visualiser les pools RID attribués aux contrôleurs de domaine avec la fonction suivante :

{% include github-gist.html name="Get-ADDomainControllerRidPool" id="0f2ffc0d8d840ee3c6a67d6cc914cfc2" %}

### Épuisement d'un pool RID

En auditant les pools RID disponibles sur le DC02 avec la fonction `Get-ADDomainControllerRidPool`, on obtient les informations suivantes :

Propriété | Valeur | Explication
--------- | ------ | ----------
RIDPoolMin | 2100 | Début de la plage du pool RID
RIDPoolMax | 2599 | Fin de la plage du pool RID
RIDPoolCount | 500 | Nombre de RID dans le pool

Depuis le DC02 (qui est tout neuf), je vais créer un nouvel objet qui devrait donc avoir le RID "2101" (le premier RID du pool) :

```powershell
New-ADUser rid-2101 -Server DC02
```

En vérifiant avec la commande `Get-ADUser`, on vérifie que c'est bien le RID "2101" qui a été utilisé.

> J'insiste sur le fait que le contrôleur de domaine en question (DC02) est tout neuf, ce qui veut dire que le pool RID est encore intact.

Pour épuiser le pool RID, j'ai simplement à éteindre le contrôleur de domaine qui porte le rôle RIDMaster (pour éviter que celui-ci partage un nouveau pool RID) et créer 499 comptes sur le deuxième contrôleur de domaine :

```powershell
2102..2600 | ForEach-Object {
    New-ADUser "rid-$_" -Server DC02
}
```

Tous les comptes de `rid-2102` à `rid-2599` ont pu être créés sans problème, mais pour la création du compte `rid-2600` on tombe alors sur l'erreur suivante : **New-ADUser : The directory service has exhausted the pool of relative identifiers**. Il faut alors relancer le RIDMaster pour obtenir un nouveau pool de 500 RID. L'attribution d'un nouveau pool est visible dans l'observateur d'événements avec la commande suivante :

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=16648} | Format-List
```

Voici le résultat dans l'observateur d'événements :

- **TimeCreated**: 22/10/2025 10:22:00
- **ProviderName**: Microsoft-Windows-Directory-Services-SAM
- **Message**: The request for a new account-identifier pool has completed successfully

### Augmenter la taille du pool RID

Il est possible d'allouer un pool de plus de 500 RID à chaque contrôleur de domaine. Pour faire cela, il suffit de modifier la clé de registre "RID Block Size" sur le serveur qui porte le rôle RIDMaster :

```powershell
$splat = @{
    Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\RID Values'
    Name = 'RID Block Size'
    Value = 1000
}
Set-ItemProperty @splat
```

Voici les différentes valeurs de la clé de registre :

- la valeur par défaut de la clé est 0 (ce qui correspond à des pools de 500 RID)
- la valeur minimum effective est de 500
- la valeur maximum effective est de 15 000

Le changement sera effectif après le redémarrage du RIDMaster et à l'épuisement des pools existants.

### Invalider un pool RID

Lors d'une procédure de restauration de forêt Active Directory, il est nécessaire d'invalider un pool RID : [AD Forest Recovery - Invalidating the RID Pool \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/forest-recovery-guide/ad-forest-recovery-invaildate-rid-pool). Pour faire cela, j'ai créé la fonction `Invoke-ADInvalidateRidPool` qui se base sur le code fourni par Microsoft :

{% include github-gist.html name="Invoke-ADInvalidateRidPool" id="b51500dc9cbddaf7f0ea6d8d5482d5fb" %}

On peut voir le résultat de la commande dans l'observateur d'événements :

```powershell
Get-WinEvent -FilterHashtable @{LogName='System'; Id=16654} | Format-List
```

Voici le résultat dans l'observateur d'événements :

- **TimeCreated**: 22/10/2025 10:19:20
- **ProviderName**: Microsoft-Windows-Directory-Services-SAM
- **Id**: 16654
- **Message**: A pool of account-identifiers (RIDs) has been invalidated. This may occur in the following expected cases:
    1. A domain controller is restored from backup.
    2. A domain controller running on a virtual machine is restored from snapshot.
    3. An administrator has manually invalidated the pool. See <http://go.microsoft.com/fwlink/?LinkId=226247> for more information.

#### Fonctionnement réel de l'invalidation

Voici la situation de départ pour le pool RID d'un contrôleur de domaine :

```plaintext
Server       : CN=DC01,OU=Domain Controllers,DC=contoso,DC=com
RIDPoolMin   : 5600
RIDPoolMax   : 6599
RIDPoolCount : 1000
```

Un utilisateur avec le RID "-5600" est créé :

```powershell
New-ADUser rid-5600 -Server DC01
```

On vérifie que celui-ci porte bien le RID correspondant :

```powershell
Get-ADUser rid-5600 -Server DC01 | Select-Object name, sid
```

Puis, on invalide le pool RID avec la fonction personnalisée `Invoke-ADInvalidateRidPool`. En apparence, rien ne change sur le pool RID attribué au contrôleur de domaine :

```plaintext
Server       : CN=DC01,OU=Domain Controllers,DC=contoso,DC=com
RIDPoolMin   : 5600
RIDPoolMax   : 6599
RIDPoolCount : 1000
```

Si on essaye de créer un nouvel objet, celui-ci devrait avoir le RID "-5601". Cependant, la création de l'objet échoue et on tombe sur l'erreur suivante : **The directory service was unable to allocate a relative identifier**. Si l'on ressaye quelques secondes plus tard, on arrive à créer l'objet, mais celui-ci a un RID en "-6601" (soit 1000 de plus que le RID estimé, c'est-à-dire la taille d'un pool RID dans mon domaine) ce qui indique que le contrôleur de domaine utilise un nouveau pool RID.

C'est cette erreur qui permet de mettre à jour le pool RID du contrôleur de domaine, puisque maintenant, on voit bien la nouvelle allocation avec la fonction personnalisée `Get-ADDomainControllerRIDPool` :

```plaintext
Server       : CN=DC01,OU=Domain Controllers,DC=contoso,DC=com
RIDPoolMin   : 6600
RIDPoolMax   : 7599
RIDPoolCount : 1000
```

> **Que ce passe-t-il maintenant si l'on révoque plusieurs fois d'affilée un pool RID ?**
>
> J'ai testé et il n'y a qu'une seule pool RID qui est révoquée à la fois, même si la commande a été faite plusieurs fois. Le seul moyen d'invalider plusieurs pools RID est d'alterner entre l'invalidation du pool RID et la création d'un objet Active Directory (pour débloquer la nouvelle pool RID).

## La partie dangereuse

Et maintenant c'est parti pour faire des conneries ! On a vu ensemble précédemment comment :

1. Augmenter la taille des pools RID jusqu'à 15000
2. Révoquer un pool RID complet
3. Forcer à récupérer un nouveau pool RID

Il ne nous reste plus qu'à consommer les plus d'un milliard de RID disponibles par défaut dans le domaine ! À raison de 15 000 RID épuisés par boucle, il ne faudra *que* 70 000 boucles pour en arriver à bout !

On augmente la taille des pools RID jusqu'au maximum sur le RIDMaster, puis on le redémarre pour que le changement de clé de registre soit effectif :

```powershell
$splat = @{
    Path = 'HKLM:\SYSTEM\CurrentControlSet\Services\NTDS\RID Values'
    Name = 'RID Block Size'
    Value = 15000
}
Set-ItemProperty @splat
Restart-Computer -Force
```

On peut désormais passer aux choses sérieuses ! Dans mon cas je vais m'arrêter à 10 000 boucles pour éviter de flinguer mon lab, mais la boucle est très simple :

1. On invalide le pool RID du contrôleur de domaine
2. On tente de créer un nouvel objet pour forcer la récupération d'un nouveau pool RID
3. On affiche une barre de progression pour éviter de s'impatienter

En PowerShell ça nous donne ça :

```powershell
$max = 10000
1..$max | ForEach-Object {
    Invoke-ADInvalidateRidPool
    try { New-ADUser "error-$_" } catch { $null }
    Write-Progress -Activity "Consuming all RID as fast as I can!" -PercentComplete ($_ / $max * 100)
}
```

Ce genre de manipulation n'étant pas prévue, on tombe sur des erreurs à l'invalidation du pool RID : **Exception calling "SetInfo" with "0" argument(s): "The server is unwilling to process the request**. Cela n'empêche pas la boucle de faire des dégâts et de consommer petit à petit tous les RID du domaine. Pour l'exécution de mes 10 000 boucles, il m'aura fallu seulement 5 minutes.

À la fin de mes tests, je suis passé de 0,0002% d'usage des RID à plus de 25% d'usage. Cela me laisse donc ~800 millions de RID disponibles (avant augmentation du nombre maximum de RID).
