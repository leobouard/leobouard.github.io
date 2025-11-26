---
title: "Montée de version du domaine et de la forêt vers Windows2016"
description: "Mettre à jour le niveau fonctionnel de votre domaine et votre fôret"
tags: activedirectory
listed: true
---

## Contexte

Voici comment obtenir le niveau fonctionnel du domaine et de la forêt :

```powershell
(Get-ADDomain).DomainMode
(Get-ADForest).ForestMode
```

La DFL & FFL permettent d'obtenir les dernières fonctionnalités disponibles pour Active Directory. L'ajout marquant de la version Windows2016Domain est l'appartenance temporaire à un groupe via "PAM" (Priviledged Access Management).

Toutes les nouveautés sont disponibles ici : [Niveaux fonctionnels des services de domaine Active Directory \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/active-directory-functional-levels#windows-server-2016-forest-and-domain-functional-level-features).

## Pré-requis

### DFL

Pour effectuer une montée de version du domaine, il faut que tous les contrôleurs de domaine fonctionnent sur un OS qui supporte le niveau fonctionnel en question.

Dans notre cas, il faut que les DC soit au minimum en version Windows Server 2016.

```powershell
Get-ADDomainController -Filter * | Sort-Object OperatingSystem | Format-Table Name, OperatingSystem
```

Résultat :

Name  | OperatingSystem
----  | ---------------
DC001 | Windows Server 2016 Standard
DC002 | Windows Server 2019 Standard
DC003 | Windows Server 2019 Standard
DC004 | Windows Server 2022 Standard
DC005 | Windows Server 2022 Standard
DC006 | Windows Server 2022 Standard

### FFL

Pour effectuer une montée de version de la forêt, il faut que tous les domaines enfants soient au niveau fonctionnel cible. Dans les architectures Active Directory mono-domaine, mono-forêt, la FFL sera une formalité.

```powershell
(Get-ADForest).Domains | ForEach-Object { Get-ADDomain $_ | Format-Table DNSRoot, DomainMode }
```

### Bonnes pratiques

Même si son absence n'empêche pas la montée de version, il est fortement conseillé d'avoir une sauvegarde fonctionnelle de son Active Directory et aucun problème de réplication.

Vérification des problèmes de réplication :

```powershell
repadmin /showrepl * /csv | ConvertFrom-Csv | Out-GridView
```

## Mise à niveau du domaine

Une fois tous les prérequis remplis, avec un utilisateur ayant le rôle "Admins du domaine", exécuter la ligne de commande suivante pour passer le domaine en version 2016 ou 2025 :

```powershell
$PDC = Get-ADDomainController -Discover -Service PrimaryDC
Set-ADDomainMode -Identity $PDC.Domain -Server $PDC.HostName[0] -DomainMode Windows2016Domain
```

> Si vous passez d'une version 2008R2 vers 2016, vous pouvez le faire en une seule fois. Aucun palier n'est nécessaire sur les montées de versions de domaine ou de forêt.

## Mise à niveau de la forêt

Une fois tous les domaines mis à niveau, nous pouvons passer à la mise à niveau de la forêt. Avant de faire l'action, il faut ajouter son compte dans le groupe "Administrateurs de l'entreprise" pour pouvoir effectuer l'opération :

```powershell
Add-ADGroupMember "Administrateurs de l'entreprise" -Members 't0_jdoe'
```

Puis on augmente le FFL :

```powershell
$CurrentForest = Get-ADForest
Set-ADForestMode -Identity $CurrentForest -Server $CurrentForest.SchemaMaster -ForestMode Windows2016Forest
```

On n'oublie pas de se retirer du groupe "Administrateurs de l'entreprise" après cette opération :

```powershell
Remove-ADGroupMember "Administrateurs de l'entreprise" -Members 't0_jdoe'
```

## Activation de nouvelles fonctionnalités

Le domaine étant maintenant capable de supporter les nouveautés apportées par Windows2016Domain, on peut activer la fonctionnalité d'ajout temporaire dans un groupe.

La fonctionnalité s'appelle "Privileged Access Management" et n'est pas désactivable. Il est donc recommandé de l'activer uniquement lors qu'on est sûr à 100% qu'il n'y aura pas besoin de faire un roll-back vers un DFL antérieur.

```powershell
Enable-ADOptionalFeature 'Privileged Access Management Feature' -Scope ForestOrConfigurationSet -Target (Get-ADDomain).DnsRoot
```
