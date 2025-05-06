---
title: "Montée de version du domaine et de la forêt"
description: "Mettre à jour le niveau fonctionnel de votre domaine et votre fôret"
tags: activedirectory
listed: true
---

## Contexte

Actuellement, le domaine et la forêt galaxie.bb sont en version Windows2012R2. L'objectif est d'augmenter le DFL (*Domain Functionnal Level*) et FFL (*Forest Functionnal Level*) vers la dernière version stable disponible : Windows2016.

```powershell
(Get-ADDomain).DomainMode
(Get-ADForest).ForestMode
```

La DFL & FFL permettent d'obtenir les dernières fonctionnalités disponible pour Active Directory. La plus marquante pour la version Windows2016 est l'apparition de l'appartenance temporaire à un groupe.

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

Pour effectuer une montée de version de la forêt, il faut que tous les domaines enfants soit au niveau fonctionnel Windows2016. Dans les architectures Active Directory mono-domaine, mono-forêt, la FFL sera une formalité.

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

Une fois tous les prérequis remplis, avec un utilisateur ayant le rôle "Admins du domaine", exécuter la ligne de commande suivante pour passer le domaine en version 2016 :

```powershell
$PDC = Get-ADDomainController -Discover -Service PrimaryDC
Set-ADDomainMode -Identity $PDC.Domain -Server $PDC.HostName[0] -DomainMode Windows2016Domain
```

## Mise à niveau de la forêt

Une fois tous les domaines en version 2016, nous pouvons passer à la mise à niveau de la forêt. Avant de faire l'action, il faut ajouter son compte dans le groupe "Administrateurs de l'entreprise" pour pouvoir effectuer l'opération :

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
