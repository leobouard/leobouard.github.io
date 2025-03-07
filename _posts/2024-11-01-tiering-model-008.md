---
title: "TIERING #8 - Recertification"
description: "S'assurer que le tiering model reste sécurisé"
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
prevLink:
  name: "Partie 7"
  id: "/2024/11/01/tiering-model-007"
---

## Exploitation Active Directory

Malgré tous vos efforts sur l'architecture et le "build" Active Directory sur le tiering model, la sécurité de votre environnement se fera principalement sur son exploitation. Un administrateur non catégorisé, un partage de mot de passe entre un compte T0 et T1 ou un groupe au mauvais emplacement et la sécurité de votre tiering model sera menacée.

Pour résoudre ces problématiques, le plus simple est de conduire régulièrement des actions de recertification pour s'assurer que l'environnement respecte bien les règles définies durant la phase de conception.

### Partage de mots de passe entre différents tiers

Tout l'intérêt du tiering model est de ralentir voir empêcher la progression d'un attaquant vers un niveau critique comme le Tier 0. Si un administrateur partage le même mot de passe entre tous ses comptes (compte sans privilège et comptes administrateurs), cela rend inutile l'utilisation de plusieurs comptes. Il est possible de vérifier rapidement l'utilisation d'un même mot de passe sur plusieurs comptes avec le module PowerShell `DSInternals` :

```powershell
Import-Module DSInternals
$server = (Get-ADDomainController).HostName
Get-ADReplAccount -All -Server $server | Test-PasswordQuality
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

### Mauvaise catégorisation d'un compte

Déplacer un compte dans une unité d'organisation du Tier 0 ne suffit pas à le catégoriser dans le Tier 0 : celui-ci doit impérativement être membre du groupe d'appartenance. L'appartenance à un groupe étant assez peu visible dans Active Directory, le plus simple est de faire un script pour mettre en lumière ce genre d'écart :

```powershell
$tier0Users = Get-ADUser -Filter * -SearchBase 'OU=TIER0,DC=contoso,DC=com'
$tier0GroupMembers = Get-ADGroupMember 'Utilisateurs du TIER0' -Recursive
$tier0Users | Where-Object {$_.SamAccountName -notin $tier0GroupMembers}
```

Vous pouvez réaliser le même genre de vérification pour le Tier 1 & Tier 2.

### Mauvais emplacement d'un groupe

Les groupes d'accès à une ressource du Tier 1 peut se trouver à deux endroits : Tier 0 ou Tier 1. Il faut donc vérifier, suivant votre préférence, que tous les groupes d'accès sont à l'endroit défini. BloodHound peut vous aider dans certains cas, sinon l'utilisation de scripts PowerShell personnalisés permettent de mettre en lumière ce genre de chose.

### Mouvement de ressources / serveurs

Il peut arriver qu'un serveur ou un compte de service doivent changer de niveau d'administration. Dans ce cas, il est important de traiter chaque mouvement comme une migration, avec un changement de mot de passe immédiat pour les comptes déplacés, et une destruction des empreintes utilisateurs sur le serveur.

## Outils d'audits

Tous les outils que vous avez pu utiliser dans la phase de remédiation ([TIERING #2 - Remédiation](/2024/11/01/tiering-model-002#outils-daudit)) peuvent/doivent être réutilisés plusieurs fois par an, afin de s'assurer que votre environnement avance bien dans la bonne direction.

Voici un résumé des outils proposés :

Produit | Description
------- | -----------
[Ping Castle by NETWRIX](https://www.pingcastle.com/download/) | Audit de la configuration Active Directory
[Purple Knight by SEMPERIS](https://www.semperis.com/fr/purple-knight/) | Audit de la configuration Active Directory
[Forest Druid by SEMPERIS](https://www.semperis.com/fr/forest-druid/) | Chemins d'attaque vers les ressources critiques
[Adalanche](https://github.com/lkarlslund/Adalanche) | Chemins d'attaque vers les ressources critiques
[Bloodhound](https://github.com/SpecterOps/BloodHound) | Chemins d'attaque vers les ressources critiques
