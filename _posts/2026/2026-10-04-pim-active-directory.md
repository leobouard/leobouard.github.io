---
title: "Entra ID PIM, mais pour Active Directory"
description: "Preuve de concept pour un système d'élévation de privilèges avec approbation"
tags: ["activedirectory", "powershell"]
---

## Explication

Pour Entra ID (et Azure en général), la plupart des organisations sont habituées à utiliser PIM (Privileged Identity Management). Le principe est simple : on est éligible à certains privilèges que l'on peut activer au besoin, pour une durée déterminée et selon un processus défini (auto-approbation ou approbation par un pair).

Ce système permet de respecter le principe du JIT (Just-in-Time) et évite d'avoir des comptes super-admins de la plateforme en permanence.

PIM n’a pas d’équivalent natif dans Active Directory : il est impossible de s’élever temporairement au rang d’administrateur du domaine. L’objectif de ce POC (Proof of Concept) est de bricoler une solution qui reproduirait le comportement de PIM, tout en respectant quelques exigences personnelles :

1. **Pas de système (trop) complexe** : l’idée est de proposer un concept simple, facilement réplicable, qui ne nécessite pas de mettre en place toute une architecture avec des serveurs dédiés, une base de données et une interface web (par exemple).
2. **Pas de délégation sur AdminSDHolder ni de compte de service membre de "Domain Admins"** : c’est le meilleur moyen de faire hurler Ping Castle ou Purple Knight et de se rendre visible aux yeux d’un attaquant.
3. **Possibilité d’empêcher l’auto-approbation** : dans certains cas, l’approbation par un pair peut être nécessaire pour satisfaire des exigences de sécurité. Il faut alors prévoir des barrières qui empêchent l’auto-approbation et ne peuvent pas être facilement contournées.

## Solution proposée

### Prérequis

La solution présentée repose sur deux technologies natives, disponibles dans toute version récente de Windows Server et d’Active Directory :

- [PowerShell Just Enough Administration (JEA)](https://learn.microsoft.com/en-us/powershell/scripting/security/remoting/jea/overview?view=powershell-7.6), disponible nativement sur tous les Windows Server récents
- [Active Directory Privileged Access Management (PAM)](https://learn.microsoft.com/en-us/microsoft-identity-manager/pam/privileged-identity-management-for-active-directory-domain-services), disponible au niveau fonctionnel Active Directory 2016

Via PowerShell JEA, on va autoriser l’exécution de commandes spécifiques sur un contrôleur de domaine. Elles permettront de :

- Demander à être ajouté à un groupe pour une durée définie et avec une justification
- Voir toutes les demandes en cours
- Approuver les demandes d'ajout (si on y est autorisé)

Les informations seront stockées directement dans des groupes Active Directory prévus à cet effet.

### Architecture

La solution nécessitera au minimum deux types de serveurs :

1. Un serveur d’administration depuis lequel on lancera les demandes d’élévation et les approbations via PowerShell JEA
2. Un contrôleur de domaine qui réceptionnera les demandes via PowerShell JEA et les exécutera avec les permissions de Domain Admins

> On exécute les commandes PowerShell directement sur le contrôleur de domaine afin de bénéficier d’un compte virtuel disposant des droits d’administrateur local sur la machine. Or, sur un contrôleur de domaine, être administrateur local revient à être administrateur du domaine.

On aura également besoin de trois groupes pour gérer les demandes et les permissions liées à PowerShell JEA :

- Un groupe autorisé à demander une élévation de privilèges dans le groupe "Domain Admins", que l’on appellera **PIM_Requesters_Domain Admins**
- Un groupe chargé d’approuver les demandes d’élévation : **PIM_Approvers_Domain Admins**
- Un dernier groupe pour stocker les demandes en attente d’approbation : **PIM_WaitingApproval_Domain Admins**

> Encore une fois, l’idée est qu’un utilisateur membre à la fois des groupes "Requesters" et "Approvers" ne puisse pas approuver sa propre demande.

### Module PowerShell

Le module PowerShell ci-dessous n’est qu’un POC : il lui manque encore beaucoup de choses pour être prêt à être utilisé en production. Il ne comporte, par exemple, aucune journalisation, ce qui est évidemment problématique pour ce type d’usage.

{% include github-gist.html name="PIMActiveDirectory" id="34c2611b712e9ab6a4bf79f4046c8b19" %}

Il est composé des commandes suivantes :

- `New-PIMRequest` et `New-PIMDCRequest`, qui permettent de demander une élévation de privilèges
- `Get-PIMRequest` qui permet de consulter toutes les demandes d'élévation de privilège en attente d'approbation
- `Approve-PIMRequest` et `Approve-PIMDCRequest`, qui permettent d’approuver les demandes d’élévation de privilèges
- `Clear-PIMDCRequest` qui permet de supprimer toutes les demandes en attente d'approbation

Les fonctions dont le nom contient le préfixe `PIMDC` sont exécutées sur le contrôleur de domaine. Les autres sont disponibles depuis le serveur d’administration et servent, pour la plupart, d’enveloppes aux commandes `PIMDC`.

## Utilisation

### Demande d'élévation

Lorsqu’une personne demande une élévation de privilèges avec la commande `New-PIMRequest`, son compte est automatiquement ajouté au groupe "PIM_WaitingApproval". Le TTL de cette appartenance correspond au nombre d’heures demandé pour l’appartenance au groupe cible. Les demandes en attente doivent être automatiquement purgées chaque jour à minuit à l’aide de la commande `Clear-PIMDCRequest`, afin de supprimer les demandes expirées.

Exemple de demande :

```powershell
New-PIMRequest -Group 'Domain Admins' -Hours 12 -Reason 'Just need to update a few GPOs on the TIER 0'
```

> Il n’est pas nécessaire de préciser votre nom de compte : celui-ci est automatiquement récupéré à partir de la variable d’environnement `$PSSenderInfo.ConnectedUser` dans la session JEA. La durée est limitée à 24 heures dans le module, et la justification doit comporter entre 8 et 120 caractères.

### Consultation des élévations en attente d'approbation

Une fois la demande créée, tout le monde (demandeurs comme approbateurs) peut la consulter avec la commande `Get-PIMRequest` et obtenir les informations suivantes :

- Demandeur de l'élévation
- Groupe cible
- Heure de la demande (calculée à partir du TTL du membre dans le groupe "PIM_WaitingApproval")
- Durée demandée
- Raison invoquée (stockée dans l'attribut `wbemPath` du groupe "PIM_WaitingApproval")

Exemple de commande :

```powershell
Get-PIMRequest
```

Voici un exemple de résultat :

```plaintext
Group     : Domain Admins
Requestor : adm-jsmith
Hours     : 12
Timestamp : 04/10/2026 22:17:05
Reason    : Just need to update a few GPOs on the TIER 0
```

### Approbation d'une demande

L’approbateur peut alors approuver une demande en indiquant le nom du groupe et celui du membre à autoriser. L’approbation ajoute l’utilisateur au groupe cible pour la durée demandée, efface la justification stockée dans l’attribut `wbemPath` et supprime son appartenance au groupe "PIM_WaitingApproval".

```powershell
Approve-PIMRequest -Group 'Domain Admins' -Requestor 'adm-jsmith'
```

### Suppression de toutes les demandes en attente

Vous pouvez supprimer toutes les demandes non approuvées à l’aide de la commande suivante :

```powershell
Clear-PIMDCRequest
```

## Installation et mise en place

### Création des groupes

Commençons par créer les trois groupes nécessaires au fonctionnement de notre PIM :

```powershell
$group = 'Domain Admins'
$splat = @{
    GroupScope    = 'DomainLocal'
    GroupCategory = 'Security'
    Path          = 'OU=Groups,OU=TIER0,DC=corp,DC=contoso,DC=com'
}

New-ADGroup -Name "PIM_WaitingApproval_$group" -Description "Has requested an access to '$group' group" @splat
New-ADGroup -Name "PIM_Approvers_$group" -Description "Can approve membership for privileged '$group' group" @splat
New-ADGroup -Name "PIM_Requesters_$group" -Description "Can request membership to privileged '$group' group" @splat
```

### Import du module

Importons ensuite notre module PowerShell dans le dossier `PIMActiveDirectory`, en respectant la structure de fichiers suivante :

```plaintext
C:\Program Files\WindowsPowerShell\Modules\PIMActiveDirectory

  📂 RoleCapabilities
    📄 ApproverDA.psrc
    📄 RequesterDA.psrc
  📄 PIMActiveDirectory.psm1
  📄 SessionConfiguration.pssc
```

Par souci de simplicité, vous pouvez déployer le dossier complet à l’identique sur les contrôleurs de domaine et sur le serveur d’administration. En pratique, ce dernier n’a besoin que du fichier `.psm1` contenant les fonctions `New-PIMRequest`, `Get-PIMRequest` et `Approve-PIMRequest`. Les fichiers de configuration JEA (`.psrc` et `.pssc`) ne sont utiles que sur les contrôleurs de domaine.

### Fichier de configuration de session (PSSC)

Le fichier `SessionConfiguration.pssc` peut être généré avec la commande `New-PSSessionConfigurationFile`. Pour cet exemple, il suffit d’y copier le contenu suivant :

```powershell
@{
    SchemaVersion       = '2.0.0.0'
    GUID                = 'f8072fe2-2f5b-4790-9546-45df9fd3a312'
    Author              = 'Léo Bouard'
    Description         = 'Privileged Identity Management for Active Directory'
    SessionType         = 'RestrictedRemoteServer'
    # TranscriptDirectory = 'C:\Path\To\Transcript'
    RunAsVirtualAccount = $true
    ModulesToImport     = 'PIMActiveDirectory', 'ActiveDirectory'
    RoleDefinitions     = @{
        'CORP\PIM_Approvers_Domain Admins'  = @{ RoleCapabilities = 'ApproverDA' }
        'CORP\PIM_Requesters_Domain Admins' = @{ RoleCapabilities = 'RequesterDA' }
    }
}
```

Ce fichier permet notamment de définir les autorisations JEA (*RoleDefinitions*), c’est-à-dire les commandes que chaque rôle peut exécuter. Il contient également plusieurs paramètres généraux, comme :

- Le dossier de journalisation (*TranscriptDirectory*)
- Le fait de fonctionner sur un compte administrateur local virtuel (*RunAsVirtualAccount*)
- Les modules à importer au lancement de la connexion WinRM (*ModulesToImport*)

### Fichiers de configuration du rôle (PSRC)

Les fichiers `ApproverDA.psrc` et `RequesterDA.psrc`, placés dans le dossier `RoleCapabilities`, définissent les commandes, les paramètres et les valeurs autorisés pendant la session JEA.

Pour le rôle "ApproverDA", on autorise la commande `Approve-PIMDCRequest`. Le paramètre `-Requestor` est libre, tandis que `-Group` ne peut prendre que la valeur "Domain Admins" :

```powershell
@{
    GUID = 'd0611c28-162d-431a-b031-81635d31ceda'
    VisibleFunctions = @(@{
        Name = 'Approve-PIMDCRequest'
        Parameters = @{ Name = 'Group'; ValidateSet = 'Domain Admins' }, @{ Name = 'Requestor' }
    })
}
```

Pour le rôle "RequesterDA", on autorise la commande `New-PIMDCRequest`. Les paramètres `-Hours` et `-Reason` sont libres, tandis que `-Group` ne peut prendre que la valeur "Domain Admins" :

```powershell
@{
    GUID = '21155f4e-ec27-41fd-b63a-ce7e011bdd19'
    VisibleFunctions = @(@{
        Name = 'New-PIMDCRequest'
        Parameters = @{ Name = 'Group' ; ValidateSet = 'Domain Admins' }, @{ Name = 'Hours' }, @{ Name = 'Reason' }
    })
}
```

Un modèle de fichier de ce type peut être généré avec la commande `New-PSRoleCapabilityFile`.

### Activation sur le contrôleur de domaine

Dernière étape : enregistrons notre configuration PowerShell JEA depuis le contrôleur de domaine à l’aide de la commande suivante :

```powershell
$path = 'C:\Program Files\WindowsPowerShell\Modules\PIMActiveDirectory\SessionConfiguration.pssc'
Register-PSSessionConfiguration -Name PIMActiveDirectory -Path $path -Force
```

Le paramètre `-Force` permet de créer ou de mettre à jour la configuration. Pensez à exécuter cette commande après chaque modification du fichier `SessionConfiguration.pssc`.

## Conclusion

Cette approche permet de reproduire une partie du fonctionnement de PIM dans Active Directory, avec des demandes justifiées, une approbation par un pair et une appartenance temporaire aux groupes privilégiés. Elle reste toutefois un POC : avant toute utilisation en production, il faudrait notamment mettre en place une journalisation fiable et tester soigneusement les contrôles d’accès ainsi que les cas d’erreur. La solution doit être adaptée à chaque environnement, en particulier lorsqu’il s’agit de groupes aussi sensibles que Domain Admins.
