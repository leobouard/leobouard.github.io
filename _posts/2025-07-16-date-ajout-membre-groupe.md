---
title: "Trouver la date d'ajout d'un membre dans un groupe"
description: "Utiliser les métadonnées de réplication pour retrouver la date d'ajout d'un membre dans un groupe"
tags: ["powershell", "activedirectory"]
listed: true
---

## Métadonnées de réplication

### Fonctionnement

Lorsqu'un changement est effectué sur un objet Active Directory, celui-ci est pris en charge par un contrôleur de domaine (DC) qui met à jour la base NTDS. Dans un environnement avec plusieurs contrôleurs, le DC partage ensuite la nouvelle information avec les autres DC, en transmettant la donnée modifiée ainsi que des **métadonnées de réplication**. Celles-ci servent à suivre l’historique des modifications des objets et de leurs attributs. Elles indiquent, pour chaque attribut :

- la date et l'heure de la dernière modification
- l'origine du changement (contrôleur de domaine)
- l'identifiant de la modification

### Utilité et exemples d'usage

En tant qu'administrateur, les métadonnées de réplication permettent de savoir quand et où une modification a été faite : c'est utile pour l’audit, le dépannage et la récupération de certaines informations "cachées". Un bon exemple est la détection de la prolongation de la vie d'un mot de passe. On peut détecter les anomalies en recherchant une différence de temps de réplication entre ces deux attributs :

- `unicodePwd` qui contient le mot de passe
- `pwdLastSet` qui contient la date de définition du mot de passe

Voici une fonction pour détecter cela : [Find users who are extending the password lifetime of their Active Directory account · GitHub](https://gist.github.com/leobouard/f6066b14db8199a864ff00620c08909d)

Un autre usage (et c'est celui qui nous intéresse aujourd'hui) est de connaître la **date d'ajout d'un membre dans un groupe**.

### Commande PowerShell

Pour consulter les métadonnées de réplication d'un objet, on peut utiliser la commande `Get-ADReplicationAttributeMetadata`. Associée à un pipe, elle permet de consulter les dates des derniers changements sur un objet :

```powershell
Get-ADGroup 'Domain Admins' |
    Get-ADReplicationAttributeMetadata -Server (Get-ADDomain).PDCEmulator |
    Format-Table AttributeName, AttributeValue, LastOriginatingChangeTime
```

La commande donne alors le résultat suivant :

AttributeName | AttributeValue | LastOriginatingChangeTime
------------- | -------------- | -------------------------
isCriticalSystemObject | True | 13/07/2025 13:29:47
objectCategory | CN=Group,CN=Schema,CN=Configuration,DC=contoso,DC=com | 13/07/2025 13:29:47
groupType | -2147483646 | 13/07/2025 13:29:47
sAMAccountType | 268435456 | 13/07/2025 13:29:47
sAMAccountName | Domain Admins | 13/07/2025 13:29:47
adminCount | 1 | 13/07/2025 13:44:57
objectSid | S-1-5-21-2608890186-2335135319-240251004-512 | 13/07/2025 13:29:47
name | Domain Admins | 13/07/2025 13:29:47
nTSecurityDescriptor | System.DirectoryServices.ActiveDirectorySecurity | 13/07/2025 13:44:57
whenCreated | 13/07/2025 13:29:47 | 13/07/2025 13:29:47
instanceType | 4 | 13/07/2025 13:29:47
description | Designated administrators of the domain | 13/07/2025 13:29:47
cn | Domain Admins | 13/07/2025 13:29:47
objectClass | group | 13/07/2025 13:29:47
member | CN=T0 - Léo BOUARD,OU=Administrators,OU=TIER 0,DC=contoso,DC=com | 15/07/2025 15:52:11

On voit ici la dernière valeur ajoutée dans l'attribut et la date de modification de celui-ci. Par exemple, le dernier membre ajouté dans le groupe est le compte "T0 - Léo BOUARD", le 15 juillet à 15h52.

> **À noter :** Dans cet exemple, la date de réplication des attributs `adminCount` et `nTSecurityDescriptor` diffère de celle d'autres attributs définis à la création de l'objet (environ 15 minutes de décalage). Il s'agit d'une trace visible du passage du processus [SDProp](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/plan/security-best-practices/appendix-c--protected-accounts-and-groups-in-active-directory#sdprop) sur l'objet.

## Date d'ajout dans le groupe

### LinkedValues

Dans Active Directory, certains attributs sont des références vers d'autres objets. C'est le cas de l'attribut "Manager" sur les utilisateurs ou "Members" sur les groupes. Si par défaut on ne peut voir que la dernière métadonnée de réplication, il est possible d'afficher l'intégralité des modifications de cet attributs avec le paramètre `-ShowAllLinkedValues`.

### Requête PowerShell

Voici un exemple de script pour voir les dates d'ajout de chaque membre sur groupe "Domain Admins" :

```powershell
Get-ADGroup 'Domain Admins' |
    Get-ADReplicationAttributeMetadata -Server (Get-ADDomain).PDCEmulator -ShowAllLinkedValues |
    Where-Object {$_.AttributeName -eq 'member'} |
    Sort-Object FirstOriginatingCreateTime |
    Format-Table AttributeName, AttributeValue, FirstOriginatingCreateTime -GroupBy Object
```

Et voici le résultat obtenu :

AttributeName | AttributeValue | FirstOriginatingCreateTime
------------- | -------------- | --------------------------
member | CN=Administrator,CN=Users,DC=contoso,DC=com | 13/07/2025 13:29:47
member | CN=T0 - Léo BOUARD,OU=Administrators,OU=TIER 0,DC=contoso,DC=com | 15/07/2025 15:52:11
member | CN=T0 - John Smith\0ADEL:4a6e9378-63f3-4138-adbb-3e7ed9b53044,CN=Deleted Objects,DC=contoso,DC=com | 14/07/2025 08:54:15
member | CN=gmsa_adconnect,CN=Managed Service Accounts,DC=contoso,DC=com | 13/07/2025 10:14:07

Les données de réplications nous indiquent alors l'intégralité des comptes qui ont été ajoutés dans le groupe, y compris :

- les comptes supprimés de Active Directory (comme "T0 - John Smith")
- les comptes qui ne sont plus membres du groupe (comme "gmsa_adconnect")

### Exclure les comptes qui ne sont plus membres du groupe

Cette partie a été ajoutée grâce au commentaire de [DTT59](https://github.com/DTT59). Merci à lui !

Pour exclure les comptes qui ne sont plus membres du groupe (qu'ils aient été supprimés de Active Directory ou juste supprimés des membres du groupe), on pourrait simplement faire une comparaison avec le résultat de la commande `Get-ADGroupMember`. Cependant, nous avons déjà toutes les informations nécessaires dans les données de réplication pour faire une discrimination sur ces comptes :

- `FirstOriginatingCreateTime` qui indique la date de création du changement (donc la date d'ajout du membre dans le groupe)
- `LastOriginatingChangeTime` qui indique la date du dernier changement (donc la date d'ajout ou suppression du membre dans le groupe)
- `LastOriginatingDeleteTime` qui indique la date de suppression du changement (donc la date de suppression du membre dans le groupe)

Type de membre | First Originating Create Time | Last Originating Change Time | Last Originating Delete Time
-------------- | ----------------------------- | ---------------------------- | ----------------------------
Membre actuel | **13/07/2025 13:29:47** | **13/07/2025 13:29:47** | 01/01/1601 01:00:00
Membre supprimé | 14/07/2025 08:54:15 | **17/07/2025 17:04:30** | **17/07/2025 17:04:30**
Ancien membre | 13/07/2025 10:14:07 | **15/07/2025 15:54:30** | **15/07/2025 15:54:30**

On repère alors le schéma suivant :

- Si l'utilisateur est toujours membre du groupe, alors la date indiquée dans `FirstOriginatingCreateTime` sera identique à celle indiquée dans `LastOriginatingChangeTime` et la valeur de `LastOriginatingDeleteTime` sera "01/01/1601 01:00:00"
- Si l'utilisateur n'est plus membre du groupe, alors la date indiquée dans `LastOriginatingDeleteTime` sera identique à celle indiquée dans `LastOriginatingChangeTime`

La date du "01/01/1601 01:00:00" n'est pas aléatoire, il s'agit de la première date du format FileTime (valeur 0) sur mon fuseau horaire (celui de Paris en l’occurrence) :

```powershell
[DateTime]::FromFileTime(0)
```

On peut alors adapter le script pour exclure facilement toutes les personnes qui ne sont plus membre du groupe :

```powershell
Get-ADGroup 'Domain Admins' |
    Get-ADReplicationAttributeMetadata -Server (Get-ADDomain).PDCEmulator -ShowAllLinkedValues |
    Where-Object {
        $_.AttributeName -eq 'member' -and
        $_.LastOriginatingDeleteTime -ne $_.LastOriginatingChangeTime
    } |
    Sort-Object FirstOriginatingCreateTime |
    Format-Table AttributeName, AttributeValue, FirstOriginatingCreateTime -GroupBy Object
```

## Date de suppression d'un membre

En me basant sur le précédent script, il est possible d'obtenir la date de suppression des membres du groupe "Domain Admins" :

```powershell
Get-ADGroup 'Domain Admins' |
    Get-ADReplicationAttributeMetadata -Server (Get-ADDomain).PDCEmulator -ShowAllLinkedValues |
    Where-Object {
        $_.AttributeName -eq 'member' -and
        $_.LastOriginatingDeleteTime -eq $_.LastOriginatingChangeTime
    } |
    Sort-Object LastOriginatingDeleteTime |
    Format-Table AttributeName, AttributeValue, LastOriginatingDeleteTime -GroupBy Object
```

Et voici le résultat obtenu :

AttributeName | AttributeValue | LastOriginatingDeleteTime
------------- | -------------- | --------------------------
member | CN=T0 - John Smith\0ADEL:4a6e9378-63f3-4138-adbb-3e7ed9b53044,CN=Deleted Objects,DC=contoso,DC=com | 17/07/2025 17:04:30
member | CN=gmsa_adconnect,CN=Managed Service Accounts,DC=contoso,DC=com | 15/07/2025 15:54:30
