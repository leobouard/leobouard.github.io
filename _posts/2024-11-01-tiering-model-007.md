---
title: "TIERING #7 - Migration"
description: "Migrer les ressources vers le tiering model"
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 8"
  id: "/2024/11/01/tiering-model-008"
prevLink:
  name: "Partie 6"
  id: "/2024/11/01/tiering-model-006"
---

## Catégorisation des serveurs

Avant de commencer la migration, il est important d'avoir une idée précise de quel serveur va dans quel tier. Cette partie de catégorisation peut prendre du temps, mais doit être terminée à 100 % avant de passer à la phase de migration.

Le plus simple est de faire une extraction en CSV de tous vos serveurs, puis de les catégoriser un à un.

### Le cas du Tier 0

Les serveurs du Tier 0 sont assez simples à identifier, puisqu'ils regroupent souvent

- contrôleurs de domaine et contrôleurs de domaine en lecture seule
- autorité de certification
- Microsoft Entra ID Connect
- serveurs de fédération d'identité (ADFS)

Ils sont à catégoriser et à identifier en premier (avant les Tiers 1 et 2).

### Différence entre Tier 1 et Tier 2

En dehors de la connaissance précise de la fonction de chaque serveur, la différence entre un serveur du Tier 1 et un serveur du Tier 2 peut se faire en fonction des utilisateurs qui peuvent s'y connecter :

- Tier 1 : connexion d'administrateurs uniquement ou en grande majorité
- Tier 2 : connexion d'utilisateurs sans privilèges

### Le cas de Microsoft Exchange

Si vous avez un serveur Microsoft Exchange dans votre domaine, celui-ci devrait normalement être placé dans le Tier 1. Cependant, ce serveur possède de nombreuses de permissions par défaut dans Active Directory, et vous devez impérativement les réduire avant de le migrer.

Vous pouvez vous référer à ce guide pour réduire les permissions associées à Exchange : [Configure Exchange Server for split permissions \| Microsoft Learn](https://learn.microsoft.com/en-us/exchange/permissions/split-permissions/configure-exchange-for-split-permissions?view=exchserver-2019)

### Association serveurs & comptes utilisateurs

Pour identifier facilement les utilisateurs ayant pu se connecter sur un serveur, je propose deux méthodes :

- via le partage administratif
- par la commande `New-CimSession`

#### Avec le partage administratif

```powershell
$server = 'SERVERNAME.contoso.com'
Get-ChildItem -Directory -Path "\\$server\C$\Users"
```

#### Avec CIM Session

```powershell
$server = 'SERVERNAME'
$opt = New-CimSessionOption -Protocol DCOM
$cs = New-CimSession -ComputerName $server -SessionOption $opt
Get-CimInstance -CimSession $cs -ClassName Win32_UserProfile |
    Sort-Object LocalPath |
    Select-Object @{N='User';E={Split-Path -Path $_.LocalPath -Leaf}}, LastUseTime
```

## Méthodologie globale de migration

De manière générale, il est important de procéder par phases, en commençant par le Tier 0, puis en descendant vers le Tier 1 puis le Tier 2.

Cette approche permet de gagner rapidement en sécurité (via l'isolation du Tier 0), sans impacter l'ensemble du système d'information. Dès la finalisation du Tier 0, on peut alors parler d'un modèle en deux niveaux.

## Vérifications et remédiations préalables pour chaque serveur

La migration d'un serveur dans un tier ne peut pas uniquement se faire en déplaçant l'objet ordinateur dans Active Directory. Il est nécessaire de faire quelques actions de contrôle ou correction sur chaque ressource à migrer.

Pour chaque serveur, il est recommandé de vérifier quelques points :

- les comptes et groupes locaux via l'utilitaire `compmgmt`
- les profils utilisateurs existants via l'utilitaire `sysdm`
- les tâches planifiées via l'utilitaire `taskschd`

### Comptes locaux

Il est important de vérifier les comptes locaux. Les comptes locaux ne sont pas affectés par le modèle de tiering et sont donc insensibles aux limitations de connexion déployées par GPO. Il est important de s'assurer que ceux-ci ont un mot de passe unique à chaque serveur, pour éviter la propagation d'une attaque à un autre tier.

Voici une commande permettant lister les comptes locaux actifs :

```powershell
Get-LocalUser | Where-Object {$_.Enabled -eq $true}
```

### Groupes locaux

Pour vérifier plus simplement la configuration du modèle de tiering, il est fortement recommandé de rendre explicite toutes les permissions (notamment celles qui sont issues de groupes restreints) via des groupes du domaine.

Voici une commande permettant de lister les membres des groupes "Administrateurs" et "Utilisateurs du bureau à distance"

```powershell
'S-1-5-32-544', 'S-1-5-32-555' | ForEach-Object {
    Write-Host (Get-LocalGroup -SID $_).Name -ForegroundColor Yellow
    Get-LocalGroupMember -SID $_
}
```

> Rappel : les membres du groupe "Administrateurs" n'ont pas besoin d'être membre du groupe "Utilisateurs du bureau à distance".

### Profils utilisateurs

Cette remédiation permet trois choses :

1. Contrôler tous les comptes utilisateurs qui ont pu se connecter sur le serveur, ce qui permet, par exemple, de qualifier certains comptes de service
2. Faire du ménage sur des profils utilisateurs obsolètes (et donc gagner un peu d'espace de stockage)
3. Supprimer des empreintes, qui ne pourront donc plus être utilisées par un attaquant

Pour lister les profils utilisateurs :

```powershell
Get-CimInstance Win32_UserProfile |
    Where-Object {$_.LocalPath -like 'C:\Users\*'} |
    Select-Object LocalPath, LastUseTime |
    Sort-Object LastUseTime
```

Pour supprimer un profil utilisateur :

```powershell
Get-CimInstance Win32_UserProfile |
    Where-Object {$_.LocalPath -like '*john.doe*'} |
    Remove-CimInstance
```

### Tâches planifiées

L'idée est d'inspecter les comptes utilisateurs qui peuvent être utilisés pour lancer des tâches planifiées. Ces comptes peuvent être impactés par la migration dans le tiering model, il est donc nécessaire d'en avoir la connaissance.

```powershell
Get-ScheduledTask | Where-Object {
    $_.TaskPath -notlike '\Microsoft\*' -and
    $_.TaskName -notlike 'User_Feed_Synchronization-*' -and
    $_.TaskName -notlike 'GoogleUpdateTaskMachine*' -and
    $_.TaskName -notlike 'MicrosoftEdgeUpdateTask*'
} | Select-Object TaskPath, TaskName, State, @{N='Account';E={$_.Principal.UserID}}
```

## Déplacement des ressources

### Déplacement du serveur

Une fois toutes les vérifications et remédiations effectuées sur le serveur, il ne reste plus qu'à le déplacer vers l'unité d'organisation correspondante.

```powershell
gpupdate /target:computer /force
```

Ensuite, vérifier le résultat avec la commande suivante :

```powershell
gpresult /scope:computer /R
```

Le résumé devrait afficher votre GPO de restriction d'accès dans la partie "Objets Stratégie de groupe appliqués". Cette GPO empêche la connexion d'utilisateurs catégorisés dans un autre niveau et confirme que le serveur a bien été migré.

### Déplacement des comptes des services liés

Une fois le serveur migré, il est également important de catégoriser les comptes de services utilisés sur le serveur dans le même tier. Même si le déplacement de l'objet dans une unité d'organisation différente est important, c'est surtout la catégorisation dans un tier qui est qui compte (et donc l'ajout dans un groupe).

> Attention : si vous catégorisez un compte de service dans le Tier 1, celui-ci ne pourra plus être sur un serveur du Tier 2 ou du Tier 0 !
