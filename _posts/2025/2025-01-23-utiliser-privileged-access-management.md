---
title: "Utiliser Privileged Access Management"
description: "Comment bien maitriser l'ajout temporaire dans un groupe Active Directory ?"
tags: activedirectory
listed: true
---

## Contexte

PAM (Privileged Access Management) est une fonctionnalité apportée avec Active Directory dans la version Windows2016Forest. Elle permet d'ajouter de manière temporaire un utilisateur dans un groupe (et l'utilisateur sera supprimé automatiquement à la fin de la période définie).

La durée de vie d'un membre dans un groupe est appelée "TTL" pour Time To Live.

Il n'y a actuellement pas de méthode pour définir un membre temporaire dans un groupe avec l'interface graphique, il faut obligatoirement utiliser PowerShell ou des scripts personnalisés comme celui-ci :

{% include github-repository.html repository="leobouard/TemporaryGroupMembership" %}

## Activation de la nouvelle fonctionnalité

Pour activer la fonctionnalité de l'ajout temporaire d'un membre dans un groupe sur votre forêt (si celle-ci est au moins au niveau fonctionnel Windows Server 2016) :

```powershell
$splat = @{
    Identity = 'Privileged Access Management Feature'
    Scope = 'ForestOrConfigurationSet'
    Target = (Get-ADDomain).DnsRoot
}
Enable-ADOptionalFeature @splat
```

## Utilisation de PowerShell

Pour pouvoir utiliser le nouveau paramètre `-MemberTimeToLive` de la commande `Add-ADGroupMember`, il faut impérativement avoir un Windows Server 2016 au minimum (module Active Directory en version 1.0.1.0).

### Ajout temporaire

Voici la ligne de commande pour ajouter le compte "john.doe" dans le groupe "Administrateurs de l'entreprise" pour une durée de 8 heures :

```powershell
$ttl = New-TimeSpan -Hours 8
Add-ADGroupMember -Identity "Administrateurs de l'entreprise" -Members 'john.doe' -MemberTimeToLive $ttl
```

Il est également possible de définir une heure précise (en l'occurrence 11h00) :

```powershell
$ttl = New-TimeSpan -Start (Get-Date -S 0 -Mil 0) -End (Get-Date '11:00')
Add-ADGroupMember -Identity "Administrateurs de l'entreprise" -Members 'john.doe' -MemberTimeToLive $ttl
```

> La définition des secondes et des millisecondes à zéro permet d'éviter une erreur.

Ou même une date, comme le 01 février 2025 dans cet exemple :

```powershell
$ttl = New-TimeSpan -Start (Get-Date -S 0 -Mil 0) -End (Get-Date '01/02/2025')
Add-ADGroupMember -Identity "Administrateurs de l'entreprise" -Members 'john.doe' -MemberTimeToLive $ttl
```

### Affichage des membres temporaires

Voici la ligne de commande pour voir la durée de vie des membres du groupe "Administrateurs de l'entreprise"

```powershell
Get-ADGroup -Identity "Administrateurs de l'entreprise" -Property Members -ShowMemberTimeToLive
```

> La commande plus connue `Get-ADGroupMember` ne permet pas d'obtenir l'information du TTL des membres.

Exemple de résultat :

```plaintext
DistinguishedName : CN=Administrateurs de l'entreprise,CN=Users,DC=contoso,DC=com
GroupCategory     : Security
GroupScope        : Universal
Members           : {<TTL=1429489>,CN=john.smith,CN=Users,DC=contoso,DC=com}
Name              : Administrateurs de l'entreprise
ObjectClass       : group
ObjectGUID        : a5b4d88c-1312-4d27-a32b-aa888b4cc491
SamAccountName    : Administrateurs de l'entreprise
SID               : S-1-5-21-227053094-6103227105-860985932-519
```

Le TTL indiqué dans les membres est exprimé en secondes. Pour obtenir la date de fin, vous pouvez utiliser la commande suivante :

```powershell
(Get-Date).AddSeconds(1429489)
```

### Rechercher tous les groupes avec des membres temporaires

Voici une commande PowerShell pour trouver tous les groupes qui ont au moins un membre temporaire :

```powershell
Get-ADGroup -Filter * -Properties Members -ShowMemberTimeToLive |
    Where-Object {$_.Members -match "<TTL=(\d+)>"}
```

### Fonction personnalisée

Pour visualiser simplement la durée de vie des membres d'un groupe, vous pouvez utiliser cette fonction personnalisée :

{% include github-gist.html name="Get-ADGroupMemberWithTTL" id="d0c9c07fe6fc2e46669580ac67aa1641" %}
