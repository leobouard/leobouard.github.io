---
title: "TIERING #8 - Recertification"
description: ""
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
prevLink:
  name: "Partie 7"
  id: "/2024/11/01/tiering-model-007"
---

## Partage de mots de passe entre différents tiers

Tout l'intérêt du tiering model est de ralentir voir empêcher la progression d'un attaquant vers un niveau critique comme le Tier 0. Si un administrateur partage le même mot de passe entre tous ses comptes (compte sans privilège et comptes administrateurs). Il est possible de vérifier rapidement l'utilisation d'un même mot de passe sur plusieurs comptes avec le module PowerShell `DSInternals` :

```powershell
Import-Module DSInternals
Get-ADReplAccount -All | Test-PasswordQuality
```

La commande vous donnera plusieurs informations sur les mots de passe de votre domaine, et notamment cette partie :

```plaintext
These groups of accounts have the same passwords:
  Group 1:
    CONTOSO\graham
    CONTOSO\graham_admin
  Group 2:
    CONTOSO\admin
    CONTOSO\sql_svc01
```

Dans l'exemple ci-dessus, le compte `graham` utilise le même mot de passe que le compte `graham_admin`. Ce cas n'est pas acceptable et une action doit être effectuée au plus vite pour changer le mot de passe d'au moins l'un des deux comptes.

> Attention : l'utilisation de la commande `Get-ADReplAccount` s'apparente à une attaque DCSync. Elle est a exécuter en pleine connaissance de son effet et avec un compte administrateur du domaine, sur un serveur strictement Tier 0.

Plus d'information sur la commande : [DSInternals/Documentation/PowerShell/Test-PasswordQuality.md at master · MichaelGrafnetter/DSInternals](https://github.com/MichaelGrafnetter/DSInternals/blob/master/Documentation/PowerShell/Test-PasswordQuality.md)

## Comptes locaux

## Exploitation Active Directory

### Mauvaise catégorisation d'un compte

Déplacer un compte dans une unité d'organisation du Tier 0 ne suffit pas à le catégoriser dans le Tier 0 : celui-ci doit impérativement être membre du groupe d'appartenance. L'appartenance à un groupe étant assez peu visible dans Active Directory, le plus simple est de faire un script pour mettre en lumière ce genre d'écart :

```powershell
$tier0Users = Get-ADUser -Filter * -SearchBase 'OU=TIER0,DC=contoso,DC=com'
$tier0GroupMembers = Get-ADGroupMember 'Utilisateurs du TIER0' -Recursive
$tier0Users | Where-Object {$_.SamAccountName -notin $tier0GroupMembers}
```

### Mauvais emplacement d'un groupe

Les groupes d'accès à une ressource du Tier 1 peut se trouver à deux endroits : Tier 0 ou Tier 1. Il faut donc vérifier, suivant votre préférence, que tous les groupes d'accès 

### Délégation Active Directory

Les délégations Active Directory 

### Utilisation d'outils d'audits