---
title: "Découverte de UTCM"
description: "Démarrer rapidement Universal Tenant Configuration Manager"
tags: ["msgraph", "powershell", "microsoft365"]
listed: true
---

> Cet article est issu de la présentation technique effectuée au Microsoft User Group de Rennes, qui a eu lieu le mardi 31 mars dans les locaux de METSYS à Saint-Grégoire. Le support de présentation est disponible ici : [Comment garder la configuration de votre tenant M365 au carré avec UTCM ?](/assets/files/presentation-utcm.pdf)

## Histoire de Microsoft UTCM

### Les prémices : Microsoft 365 DSC

[Microsoft365DSC](https://github.com/microsoft/microsoft365DSC) est un module PowerShell communautaire qui permet d'automatiser le déploiement et la configuration de nombreux éléments d'un tenant Microsoft 365, en utilisant la technologie PowerShell DSC (Desired State Configuration).

Il a été créé en 2018 par Nik Charlebois, un employé de Microsoft et MVP qui a travaillé en tant que PFE (Premier Field Engineer) SharePoint et sur le développement de l'API Microsoft Graph.

M365DSC a d'abord été conçu comme un outil de troubleshooting de fermes SharPoint OnPrem, utilisé pour répliquer une configuration client à distance. Le produit a ensuite été mis en open-source pour bénéficier d'un support de la communauté.

Le projet a pris en traction et a évolué vers un système qui gère plus de choses : Entra ID, Exchange, Intune, SharePoint & OneDrive, Purview, quelques briques de Microsoft Defender, Teams, PowerPlatform, Azure Sentinel et Azure DevOps. Grosso modo, tout ce qui dispose d'une API sur les consoles d'administration classiques.

### Les limites de M365DSC

Le problème principal de M365DSC est que même si le projet était mené par Microsoft et supporté par la communauté en open-source, ce support était en "best-effort" et n'arrivait pas toujours à suivre les évolutions de la plateforme Microsoft 365 : les APIs changent rapidement, se multiplient et le projet a toujours un train de retard.

Autre problème : la courbe d'apprentissage pour pouvoir participer au projet est abrupte. Le projet M365DSC est écrit en PowerShell mais les contributeurs doivent avoir une expérience et une compréhension de DSC (*Desired State Configuration*) et de Microsoft 365, ce qui réduit drastiquement le nombre de personnes qualifiées pour pouvoir participer au projet.

### Début du projet UTCM

En 2024, Microsoft débute le projet UTCM (pour Universal Tenant Configuration Manager) avec comme objectif d'offrir un support officiel pour sauvegarder, recréer, monitorer les écarts de configuration et faire du rollback si besoin. L'idée est d'offrir un vrai support client et suivre plus facilement les évolutions de la plateforme Microsoft 365.

Pour réduire la complexité du projet, il est également décidé d'intégrer ce nouvel outil directement dans l'API Microsoft Graph. Cette nouvelle architecture permet donc d'interagir avec le langage que l'on veut (PowerShell, Python, Javascript, .NET) et depuis n'importe où (plus besoin d'installer un module ou de laisser tourner le script pendant des heures).

Autre changement : M365DSC stocke sa configuration au format propriétaire DSC, et le processing se fait par PowerShell sur la machine cliente. UTCM quant à lui, stocke sa configuration en JSON et tout le processing se passe du côté de Microsoft Graph.

## Fonctionnalités

### Licensing

UTCM est disponible à partir du niveau de licence Microsoft Entra ID P1. Je n'ai pas trouvé d'information sur le nombre minimum de licences pour être conforme aux exigences de Microsoft.

### Produits pris en charge

M365DSC pouvait gérer la configuration de nombreux produits à l'intérieur de Microsoft 365 (*Entra ID, Exchange, Intune, SharePoint & OneDrive, Purview, quelques briques de Microsoft Defender, Teams, PowerPlatform, Azure Sentinel et Azure DevOps*). Pour UTCM, dans la public preview sortie en janvier 2026, sont supportés uniquement :

- Defender (limited coverage)
- Entra ID
- Exchange Online
- Intune
- Purview
- Teams

> **Pourquoi une telle différence ?**
>
> Les deux produits, même si ils répondent aux mêmes besoins, sont radicalement différents. UTCM n'est pas une intégration de M365DSC dans Microsoft Graph. Par ailleurs, M365DSC continuera de vivre comme un projet communautaire.

Chose que UTCM ne fait pas : la sauvegarde de la partie "Données". UTCM ne se concentre que sur la partie **configuration** (comme son nom l'indique). Vous ne pourrez donc pas restaurer des groupes, des utilisateurs ou des fichiers SharePoint avec UTCM.

Cependant, certains groupes ou utilisateurs sont des éléments essentiels de la configuration, notamment ceux utilisés dans vos accès conditionnels. Ceux-ci sont alors sauvegardés pour pouvoir répliquer la configuration dans son intégralité.

## Installation de UTCM

Pour la mise en pratique, nous allons nous concentrer sur un exemple très simple : la surveillance des stratégies d'accès conditionnel sur notre tenant.

Les informations ci-dessous sont directement issues de [Set up authentication for Tenant Configuration Management APIs - Microsoft Graph \| Microsoft Learn](https://learn.microsoft.com/en-us/graph/utcm-authentication-setup).

### Création de l'application

Création de l'application UTCM sur votre tenant :

```powershell
Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Applications
Connect-MgGraph -Scopes @('Application.ReadWrite.All', 'AppRoleAssignment.ReadWrite.All')
New-MgServicePrincipal -AppId '03b07b79-c5bc-4b5e-9bfa-13acf4a99998'
```

### Ajout de permissions

Ajouter les permissions `Policy.Read.ConditionalAccess` et `Directory.Read.All` pour que UTCM puisse surveiller et faire un rollback des modifications de la configuration sur les stratégies d'accès conditionnels :

```powershell
$permissions = 'Directory.Read.All', 'Policy.Read.ConditionalAccess'
$Graph = Get-MgServicePrincipal -Filter "AppId eq '00000003-0000-0000-c000-000000000000'"
$TCM = Get-MgServicePrincipal -Filter "AppId eq '03b07b79-c5bc-4b5e-9bfa-13acf4a99998'"

foreach ($requestedPermission in $permissions) {
    $AppRole = $Graph.AppRoles | Where-Object { $_.Value -eq $requestedPermission }
    $body = @{
        AppRoleId = $AppRole.Id
        ResourceId = $Graph.Id
        PrincipalId = $TCM.Id
    }
    New-MgServicePrincipalAppRoleAssignment -ServicePrincipalId $TCM.Id -BodyParameter $body
}
```

L'ajout de nouvelles permissions se fait également de manière très simple depuis le portail Entra ID : [Gouvernance des locataires - Centre d’administration Microsoft Entra](https://entra.microsoft.com/#view/Microsoft_Entra_TenantManagement/TenantGovernance.MenuView/~/permissions)

### Sélection des ressources

Les ressources vont permettre de cibler la configuration à sauvegarder ou auditer. Voici quelques exemples de ressources :

- `deviceCleanupRule` pour obtenir le paramétrage du nettoyage automatique des périphériques dans Intune
- `transportRule` pour les règles de flux dans Exchange
- `conditionalaccesspolicy` pour les stratégies d'accès conditionnels

Les ressources sont préfixées en fonction de leur provenance, donc `deviceCleanupRule` est préfixée avec `microsoft.intune.` par exemple.

Microsoft a déjà mis à disposition toutes les ressources disponibles, et il y en a déjà des milliers. Voici la liste par produit :

- [Entra resources](https://learn.microsoft.com/en-us/graph/utcm-entra-resources)
- [Exchange resources](https://learn.microsoft.com/en-us/graph/utcm-exchange-resources)
- [Intune resources](https://learn.microsoft.com/en-us/graph/utcm-intune-resources)
- [Security and Compliance resources](https://learn.microsoft.com/en-us/graph/utcm-securityandcompliance-resources)
- [Teams resources](https://learn.microsoft.com/en-us/graph/utcm-teams-resources)

## Utilisation de UTCM

La méthodologie d'utilisation de UTCM est très simple :

1. **Création d'un snapshot** : Il s'agit d'une capture à un instant T de la configuration actuelle de votre tenant sur les ressources qui auront été sélectionnées.
2. **Créer une baseline à partir du snapshot** : Adapter et modifier votre snapshot pour créer une baseline, c'est-à-dire l'état souhaité de votre tenant.
3. **Créer un monitor à partir de la baseline** : le monitor est une sorte de tâche planifiée qui va évaluer périodiquement la configuration actuelle du tenant par rapport à la baseline qui a été sauvegardée.
4. **Surveiller vos dérives de configuration** : Consulter les différences que le monitor aura trouvées entre la configuration de votre tenant et la baseline qui aura été sauvegardée.

### Snapshot

Il s'agit d'une capture à un instant T de la configuration actuelle de votre tenant sur les ressources qui auront été sélectionnées. Celle-ci va vous permettre de créer votre baseline.

#### Demande de snapshot

Vous pouvez initier la création d'un snapshot avec la commande ci-dessous. Dans mon cas, je cible uniquement la ressource `microsoft.entra.conditionalaccesspolicy` mais il est possible d'en mettre plusieurs d'un coup :

```powershell
$uri = '/beta/admin/configurationManagement/configurationSnapshots/createSnapshot'
$body = @"
{
    "displayName": "Snapshot CA $(Get-Date -Format 'yyyyMMddHHmmss')", 
    "resources": ["microsoft.entra.conditionalaccesspolicy"] 
}
"@
$responsePOST = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
```

> Tous les displayName de vos snapshots doivent être uniques et ne doivent pas contenir de caractères spéciaux ou d'accents.

#### Suivre l'avancement du snapshot

Dans votre retour de commande (qui est stocké dans la variable `$responsePOST`, vous allez obtenir un "Id" qui va vous permettre de consulter l'avancement de la création de votre snapshot :

```powershell
$responseGET = Invoke-MgGraphRequest -Method "GET" -Uri "/beta/admin/configurationManagement/configurationSnapshotJobs/$($responsePOST.id)"
```

Exemple de retour :

Name        | Value
----        | -----
status      | succeeded
id          | fc7e6096-e324-469e-aba9-ab00aac45b2b
displayName | Snapshot CA 20260331115104
resources   | {microsoft.entra.conditionalaccesspolicy}

Il y a plusieurs états possibles (propriété `status`) :

- *NotStarted* pour les snapshots qui n'ont pas encore commencé à être traité
- *Running* pour les snapshots en cours de traitement
- *Succeeded* pour les snapshots qui ont réussi à capturer l'intégralité des ressources
- *PartiallySucceeded* pour les snapshots qui ont échoués sur au moins une ressource
- *Failed* : pour les snapshots qui n'ont réussi à capturer aucune des ressources demandées

Au minimum, il faut compter une minute de temps de traitement, mais plus vous collectez d'informations, plus le snapshot sera long à récupérer.

### Télécharger le snapshot

Mon snapshot a mis un peu moins d'une minute à se terminer, et s'est soldé par un `status: succeeded`. Une fois terminé, le snapshot est disponible sur l'URL fournie dans la réponse, sous la propriété `resourceLocation` :

```powershell
Invoke-MgGraphRequest -Method GET -Uri $responseGET.resourceLocation -OutputFilePath "C:\temp\snapshot_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').json"
```

Le fichier reste disponible au téléchargement pendant 7 jours. Voici le contenu de mon snapshot :

```json
{
    "@odata.context": "https://graph.microsoft.com/beta/$metadata#admin/configurationManagement/configurationSnapshots/$entity",
    "id": "4a4e96bd-85d6-4624-93b2-e98d2b6f54f6",
    "displayName": "Snapshot CA 20260331115104",
    "description": "",
    "parameters": [],
    "resources": [
        {
            "displayName": "AADConditionalAccessPolicy-Multifactor authentication for Microsoft partners and vendors",
            "resourceType": "microsoft.entra.conditionalaccesspolicy",
            "properties": {
                "IncludeExternalTenantsMembershipKind": "",
                "DeviceFilterRule": "",
                "ApplicationEnforcedRestrictionsIsEnabled": false,
                "SecureSignInSessionIsEnabled": false,
                "Ensure": "Present",
                "TransferMethods": "",
                "SignInFrequencyIsEnabled": false,
                "GrantControlOperator": "OR",
                "ExcludeExternalTenantsMembershipKind": "",
                "CloudAppSecurityType": "",
                "CloudAppSecurityIsEnabled": false,
                "Id": "00565114-097a-4357-854b-e3687a4d74ef",
                "PersistentBrowserIsEnabled": false,
                "DisplayName": "Multifactor authentication for Microsoft partners and vendors",
                "PersistentBrowserMode": "",
                "SignInFrequencyType": "",
                "State": "enabled",
                "IncludeRoles": [],
                "IncludeExternalTenantsMembers": [],
                "ExcludeExternalTenantsMembers": [],
                "ExcludeLocations": [],
                "IncludeApplications": [
                    "All"
                ],
                "IncludeUsers": [
                    "All"
                ],
                "ProtocolFlows": [],
                "IncludePlatforms": [],
                "SignInRiskLevels": [],
                "ExcludeApplications": [],
                "UserRiskLevels": [],
                "IncludeLocations": [],
                "ExcludeGroups": [],
                "IncludeGroups": [],
                "CustomAuthenticationFactors": [],
                "ExcludeRoles": [
                    "Directory Synchronization Accounts"
                ],
                "AuthenticationContexts": [],
                "IncludeUserActions": [],
                "ClientAppTypes": [
                    "all"
                ],
                "ServicePrincipalRiskLevels": [],
                "ExcludePlatforms": [],
                "BuiltInControls": [
                    "mfa"
                ],
                "ExcludeUsers": [
                    "admin@M365x32408877.onmicrosoft.com"
                ]
            }
        }
    ]
}
```

> Il est tout à fait possible de modifier manuellement les valeurs, ou de supprimer les choses que l'on ne veut pas auditer (comme la propriété "ExcludeRoles" par exemple).

### Baseline

La baseline va représenter la configuration souhaitée de votre tenant, c'est-à-dire l'état de référence. Toutes les différences entre la baseline et l'état actuel seront soulignés.

**Vous ne pouvez pas utiliser votre snapshot directement comme baseline, il y a une légère adaptation à faire**.

#### Création d'une baseline

Notre snapshot au format JSON va devoir être modifié pour correspondre au format d'une baseline. Le document technique qui décrit ce qu'est une baseline est disponible ici : [configurationBaseline resource type - Microsoft Graph v1.0 \| Microsoft Learn](https://learn.microsoft.com/en-us/graph/api/resources/configurationbaseline?view=graph-rest-1.0)

Pour résumé, voici la structure attendue pour un format baseline :

```json
{
  "displayName": "Le nom de votre baseline",
  "baseline": {
    "displayName": "Le nom de votre snapshot",
    "resources": [ { ... } ]
  }
}
```

> Rappel : pas de caractères spéciaux ou d'accent dans le nom de votre baseline !

Dans la propriété JSON `resources` du fichier baseline, vous pouvez copier la valeur `resources` du snapshot qui a été récupéré précédemment.

> Il est tout à fait possible de modifier manuellement certaines valeurs, ou de supprimer les choses que l'on ne veut pas auditer (comme la propriété "ExcludeRoles" par exemple).

Dans mon cas, le fichier baseline ressemble à ça :

```json
{
  "displayName": "Acces conditionnels",
  "baseline": {
    "displayName": "Snapshot CA 20260331115104",
    "resources": [
      {
        "displayName": "AADConditionalAccessPolicy-Multifactor authentication for Microsoft partners and vendors",
        "resourceType": "microsoft.entra.conditionalaccesspolicy",
        "properties": {
          "IncludeExternalTenantsMembershipKind": "",
          "DeviceFilterRule": "",
          "ApplicationEnforcedRestrictionsIsEnabled": false,
          "SecureSignInSessionIsEnabled": false,
          "Ensure": "Present",
          "TransferMethods": "",
          "SignInFrequencyIsEnabled": false,
          "GrantControlOperator": "OR",
          "ExcludeExternalTenantsMembershipKind": "",
          "CloudAppSecurityType": "",
          "CloudAppSecurityIsEnabled": false,
          "Id": "00565114-097a-4357-854b-e3687a4d74ef",
          "PersistentBrowserIsEnabled": false,
          "DisplayName": "Multifactor authentication for Microsoft partners and vendors",
          "PersistentBrowserMode": "",
          "SignInFrequencyType": "",
          "State": "enabled",
          "IncludeRoles": [],
          "IncludeExternalTenantsMembers": [],
          "ExcludeExternalTenantsMembers": [],
          "ExcludeLocations": [],
          "IncludeApplications": [
            "All"
          ],
          "IncludeUsers": [
            "All"
          ],
          "ProtocolFlows": [],
          "IncludePlatforms": [],
          "SignInRiskLevels": [],
          "ExcludeApplications": [],
          "UserRiskLevels": [],
          "IncludeLocations": [],
          "ExcludeGroups": [],
          "IncludeGroups": [],
          "CustomAuthenticationFactors": [],
          "ExcludeRoles": [
            "Directory Synchronization Accounts"
          ],
          "AuthenticationContexts": [],
          "IncludeUserActions": [],
          "ClientAppTypes": [
            "all"
          ],
          "ServicePrincipalRiskLevels": [],
          "ExcludePlatforms": [],
          "BuiltInControls": [
            "mfa"
          ],
          "ExcludeUsers": [
            "admin@M365x32408877.onmicrosoft.com"
          ]
        }
      }
    ]
  }
}
```

### Monitor

Un monitor est l'équivalent d'une tâche planifiée ou d'une Azure Automation. Il va évaluer la configuration du tenant par rapport à la baseline qu'on lui aura donné pour souligner les différences ou la conformité.

Pour l'instant, un monitor tourne toutes les 6 heures, mais Microsoft permettra à terme d'agir sur la fréquence de celui-ci (jusqu'à toutes les heures au minimum).

Vous avez la possibilité d'auditer jusqu'à 800 objets par jour, ce qui correspond dans le cas d'un passage toutes les 6 heures à 200 objets audités 4 fois par jour (200 * 4 = 800).

Un objet correspond à n'importe quel objet de configuration (règle de flux Exchange, stratégie d'accès conditionnel...).

#### Création d'un monitor

Il est possible de créer un nouveau monitor en PowerShell avec la commande suivante :

```powershell
$uri = '/beta/admin/configurationManagement/configurationMonitors'
$body = @"
{
  "displayName": "Nom du monitor",
  "description": "Description du monitor",
  "baseline": { ... }
}
"@
$responsePOST = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
```

L'intégralité de votre fichier baseline est à mettre dans le body, à la place des `...`.

> Rappel : pas de caractères spéciaux ou d'accent dans le nom de votre baseline !

Même si honnêtement, la création par interface graphique reste plus simple et permet une vérification syntaxique immédiate de votre baseline. Le lien direct : [Gouvernance des locataires - Centre d’administration Microsoft Entra](https://entra.microsoft.com/#view/Microsoft_Entra_TenantManagement/TenantGovernance.MenuView/~/permissions)

Une fois le monitor créé, il sera lancé après sa création (pas besoin d'attendre 6 heures).

### Récupération des résultats

Si une différence est trouvée par le monitor entre la baseline et l'état actuel du tenant, une derive de configuration sera levée.

Cette commande PowerShell va permettre de récupérer tous les drifts, qu'importe leur ressource cible ou le monitor qui a soulevé la différence. Evidemment, la pagination des retours d'API est à prendre en compte si jamais vous avez plus de 100 configurationDrifts.

```powershell
$uri = 'beta/admin/configurationManagement/configurationDrifts'
$drifts = Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType PSObject
```

Voici un exemple de résultat :

property | value
-------- | -----
monitorId | c4918d3e-1deb-4973-a247-3a288bc8b418
tenantId | e18847da-294f-41ce-af09-227a65da0fd3
resourceType | microsoft.entra.conditionalaccesspolicy
baselineResourceDisplayName | AADConditionalAccessPolicy-Multifactor authentication for Microsoft partners and vendors
firstReportedDateTime | 31/03/2026 12:04:13
status | active
resourceInstanceIdentifier | @{DisplayName=Multifactor authentication for Microsoft partners and vendors}
driftedProperties | {@{propertyName=ExcludeUsers; currentValue=System.Object[]; desiredValue=System.Object[]}}

Ou plus simplement dans l'interface graphique :

![Configuration drift](/assets/images/utcm-001.png)

## Conclusion

### Exemples d'utilisation de UTCM

Il manque encore selon moi un élément de UTCM : **le rollback**.

Pour l'instant il n'est pas encore possible d'appliquer une baseline sauvegardée sur la configuration du tenant. Une fois que cette fonction sera disponible, on peut imaginer plusieurs usages :

- Audit hebdomadaire de la configuration pour suivre les modifications qui ont été effectuées
- Garantir un environnement de DEV & PREPROD iso à la PROD (en utilisant des variables pour s'adapter à l'environnement)
- ... ou simplement un garde-fou pour vos configurations sensibles

### Mot de la fin

UTCM a fortement évolué depuis sa sortie en janvier 2026 et va continuer d'évoluer (*nombres de ressources, possibilité de rollback, gestion d'autres tenants...*)

Aujourd'hui il permet simplement d'exporter et surveiller la configuration de votre tenant, mais très prochainement il devrait être en mesure de déployer une baseline sur un tenant vierge ou d'administrer plusieurs tenants de manière centralisée et programmatique (moyennant finances évidemment).

A terme, UTCM (et plus généralement le module **Tenant Governance**) pourrait venir challenger des produits comme [CoreView](https://www.coreview.com/).

### Sources

- [Introduction - Microsoft365DSC - Your Cloud Configuration](https://microsoft365dsc.com/)
- [microsoft/Microsoft365DSC: Manages, configures, extracts and monitors Microsoft 365 tenant configurations](https://github.com/microsoft/Microsoft365DSC)
- [Configuring Azure Entra ID and M365 with DSC - Gael Colas & Raimund Andree - PSConfEU 2025](https://www.youtube.com/watch?v=z2VQMK4RD0k)
- [Microsoft Finally Built an Official M365DSC! (Introducing TCM) - YouTube](https://www.youtube.com/watch?v=_iKxt9Zk_PY)
- [UTCM: New Way to Monitor Microsoft 365 Tenant Config Changes](https://office365itpros.com/2026/02/03/utcm-beta/)
- [Introducing the Tenant Configuration Management APIs - Nik Charlebois - Crawl, Walk, Run, Automate](https://nik-charlebois.com/blog/posts/2026/introducing-tcm-apis/index.html)
