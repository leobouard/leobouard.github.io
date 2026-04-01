---
marp: true
class: default
---

<style>

  @import url('https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap');

  /* Variables */
  :root {
    --primary: #783cbc;
    --secondary: #b89d23;
  }
  
  section {
      border-bottom: 0.5em solid  var(--primary);
      color: #3d3834;
      background-image: url('https://www.metsys.fr/wp-content/themes/metsys/images/svg/metsys-logo.svg');
      background-repeat: no-repeat;
      background-position: top 1em right 1em;
      background-size: 6em auto;
      font-family: Arial;
  }

  h1, h2, h3, h4, h5 {
    font-family: "Be Vietnam Pro",sans-serif;
  }

  h1 {
    text-align: center;
    font-size: 2.5em;
    padding: 1em;
    color: var(--primary);
  }

  h2 {
    border-bottom: 1px solid #ccc;
  }

  img {
    margin: auto;
    max-width: 100%;
    text-align: center;
    display: block;
  }

  span.chapter {
    position: absolute;
    top: 30px;
    left: 30px;
    background: #FAFAFA;
    padding: 0.1em 0.5em;
    border-radius: 0.25em;
    font-size: smaller;
    color: #666;
    border: 1px solid #666;
  }

  table {
    font-size: smaller;
  }
</style>

# Comment garder la configuration de votre tenant M365 au carré avec DSC et Maester ?

<!-- Remerciement pour le déplacement et pour les présentations précédentes -->

---

<span class="chapter">Introduction</span>

## Qui suis-je ?

![bg right:30%](https://www.labouabouate.fr/assets/images/profile-picture.webp)

### Léo BOUARD

- Ingénieur systèmes chez METSYS depuis 7 ans
- [www.labouabouate.fr](https://www.labouabouate.fr)
- 14 titres de MVP partagés entre Laurent, Yoann et moi

<!-- 7x MVP pour Laurent et 7x MVP pour Yoann -->

---

<span class="chapter">Introduction</span>

## Disclaimer

- J'ai pas eu le mémo sur la ligne édito
- J'ai menti sur le nom de la présentation

<!-- Pour vous mettre en confiance, je tiens à préciser deux petites choses :

- Mes deux collègues ont fait des présentations en lien avec l'IA, et je suis le seul a pas avoir compris la ligne éditoriale donc j'en suis désolé
- On va pas parler de DSC, et malheureusement pas de Maester

On va parler de UTCM, la nouvelle API de Microsoft et de tout ce qui va avec.

Entre le moment où j'ai choisi le sujet et aujourd'hui, Microsoft n'a pas chaumé ce qui explique pourquoi j'ai dû lâcher Maester
-->

---

# Comment garder la configuration de votre tenant M365 au carré avec *~~DSC et Maester~~* UTCM ?

---

<span class="chapter">Contexte</span>

## UTCM c'est quoi ?

- Universal Tenant Configuration Management
- Projet officiel de Microsoft, en succession de M365DSC
- Public Preview depuis janvier 2026
- La pierre angulaire d'un nouveau module de M365

<!-- Grosso modo, c'est du Configuration-as-Code pour votre tenant Microsoft 365 et c'est la pierre angulaire du nouveau menu de Conformité de Tenant qui est apparu il y a deux semaines. -->

---

<span class="chapter">Contexte</span>

### Source principale

![height:400px](https://substackcdn.com/image/fetch/$s_!MOcj!,w_960,h_639,c_fill,f_webp,q_auto:good,fl_progressive:steep,g_auto/https%3A%2F%2Fsubstack-video.s3.amazonaws.com%2Fvideo_upload%2Fpost%2F187149719%2F0ec77242-1185-4089-bf1c-7af944e4bb2c%2Ftranscoded-1770439490.png)

<!-- Podcast de Merill Fernando, dont la plupart des informations sont issues. Si vous préférez l'original à la copie, vous pouvez partir maintenant et regarder la vidéo à la place -->

---

<span class="chapter">Historique</span>

![bg left:40%](https://avatars.githubusercontent.com/u/2547149?v=4)

### M365DSC

Module PowerShell open-source créé en 2018 par Nik Charlebois (PFE Microsoft et MVP) pour répliquer des configurations clients à distance.

S'appuie sur la technologie DSC (*Desired State Configuration*) et les APIs des différents produits

<!--
DSC : Configuration-as-Code développé par Microsoft, on peut exporter et importer des configurations sur un système (Windows Server, Azure ou dans ce cas, Microsoft 365)

M365DSC prend en charge : 
-->

---

<span class="chapter">Historique</span>

### Les limites de M365DSC


- Projet mené par Microsoft, mais supporté par la communauté donc en "best effort"
- Peu de contributeurs et beaucoup de travail de maintenance

![height:150px](https://cdn-icons-png.flaticon.com/256/25/25231.png)

<!-- 
Le produit n'arrive pas toujours à suivre les évolutions de la plateforme Microsoft 365. Les APIs changent rapidement, se multiplient et le projet a toujours un train de retard.

Autre problème : la courbe d'apprentissage pour pouvoir participer au projet est abrupte
A main levée :

- Qui sait faire du PowerShell ?
- Qui sait interragir avec Microsoft Graph ?
- Qui connait bien DSC ?
- Qui réuni tous les prérequis pour participer ?

Finalement la question qui tue : Qui a suffisament de temps et de motivation pour partiper à un projet open-source ?
-->

---

<h1>Vous êtes une licorne ! 🦄</h1>

<!-- Défi relevé ! -->

---

<span class="chapter">Historique</span>

### Début du projet UTCM

2024 : début du projet UTCM côté Microsoft avec pour objectif :

- Répliquer les fonctionnalités de M365DSC
- Offrir un support client
- Suivre plus facilement des évolution de M365
- Plus simple d'utilisation

<!--
Fonctionnalités : sauvegarder, recréer, monitorer les écarts de configuration et faire du rollback si besoin.

Pour réduire la complexité du projet, il est également décidé d'intégrer ce nouvel outil directement dans l'API Microsoft Graph. Cette nouvelle architecture permet donc d'intéragir avec le language que l'on veut (PowerShell, Python, Javascript, .NET) et depuis n'importe où (plus besoin d'installer un module ou de laisser tourner le script pendant des heures).

Ne stocke plus sa configuration au format propriétaire DSC, mais plutôt dans un bon vieux fichier JSON
-->

---

<span class="chapter">Fonctionnement</span>

### Fonctionnalités prises en charge

M365DSC pouvait gérer la configuration de nombreux produits comme Microsoft 365. Pour UTCM, dans la public preview sortie en janvier 2026, n'est supporté pour le moment uniquement :

- Defender (limited coverage)
- Entra ID
- Exchange Online
- Intune
- Purview
- Teams

<!--
Pourquoi une telle différence ? (pas de support de Power Plateform ou Azure pour le moment)
Les deux produits, même si ils répondent aux mêmes besoins sont radicalement différents. UTCM n'est pas une intégration de M365DSC dans Microsoft Graph API. Par ailleurs, M365DSC continuera de vivre comme un projet communautaire.
-->

---

<span class="chapter">Fonctionnement</span>

### Périmètre d'action

UTCM ne gère que la partie configuration, donc pas de sauvegarde de données sauf si celles-ci sont directement liées à la configuration du tenant.

Disponible à partir de Entra ID P1

<!-- Impossible de restaurer des données SharePoint qui ont été supprimées ou un flux Power Automate, mais les groupes liés aux stratégies d'accès conditionnels le sont.

Je n'ai pas d'information sur le mode de licensing (savoir si une seule Entra ID p1 suffit)-->

---

<span class="chapter">Installation et configuration</span>

## Mise en place de UTCM

### Création de l'application

Avec les modules PowerShell Microsoft Graph :

```powershell
Install-Module Microsoft.Graph.Authentication, Microsoft.Graph.Applications
Connect-MgGraph -Scopes @('Application.ReadWrite.All', 'AppRoleAssignment.ReadWrite.All')
New-MgServicePrincipal -AppId '03b07b79-c5bc-4b5e-9bfa-13acf4a99998'
```

<!-- Commandes issues du Microsoft Learn, l'ID est réservé pour UTCM -->

---

<span class="chapter">Installation et configuration</span>

### Ajout de permissions

Code PowerShell :

```powershell
$permissions = 'User.ReadWrite.All', 'Group.ReadWrite.All', 'Directory.Read.All', 'Policy.ReadWrite.ConditionalAccess'
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

Mais beaucoup plus simple depuis l'interface graphique : [Gouvernance des locataires - Centre d’administration Microsoft Entra](https://entra.microsoft.com/#view/Microsoft_Entra_TenantManagement/TenantGovernance.MenuView/~/permissions/initialSection/governedTenants?Microsoft_AAD_IAM_legacyAADRedirect=true)

<!-- Les permissions vont autoriser UTCM à pouvoir accéder certains éléments de configurations qui sont normalement cachés -->

---

<span class="chapter">Installation et configuration</span>

Les ressources vont vous permettre de cibler la configuration à sauvegarder/auditer.

Quelques exemples :

- `deviceCleanupRule` pour obtenir le paramétrage du nettoyage automatique des périphériques dans Intune
- `transportRule` pour les règles de flux dans Exchange
- `conditionalaccesspolicy` pour les stratégies d'accès conditionnels

<!-- 
Les ressources sont préfixées en fonction de leur provenance, donc deviceCLeanupRule est préfixée par microsoft.intune... par exemple

Microsoft a déjà mis à disposition toutes les ressources disponibles, et il y a en déjà des milliers.

- [Entra resources](https://learn.microsoft.com/en-us/graph/utcm-entra-resources)
- [Exchange resources](https://learn.microsoft.com/en-us/graph/utcm-exchange-resources)
- [Intune resources](https://learn.microsoft.com/en-us/graph/utcm-intune-resources)
- [Security and Compliance resources](https://learn.microsoft.com/en-us/graph/utcm-securityandcompliance-resources)
- [Teams resources](https://learn.microsoft.com/en-us/graph/utcm-teams-resources)
-->

---

<span class="chapter">Utilisation</span>

## Utilisation de UTCM

Méthodologie :

1. **Faire un snapshot**
2. Créer une baseline à partir du snapshot
3. Créer un monitor à partir de la baseline
4. Surveiller vos dérives de configuration

<!-- 
Une fois que l'on a installé UTCM sur notre tenant, configuré les permissions pour qu'il puisse consulter la configuration et identifié les ressources que l'on veut auditer, il ne nous reste plus qu'à mettre en pratique tout ça !
-->

---

<span class="chapter">Utilisation - Création d'un snapshot</span>

### Création d'un snapshot

Instantané de votre configuration actuelle, sur les ressources ciblées (ici les accès conditionnels) :

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

<!--
Le snapshot est un export JSON de votre configuration du tenant, sur des ressources que vous souhaitez. Dans cet exemple, on va se concentrer uniquement sur les stratégies d'accès conditionnels.

Chose importante : le displayName doit être unique et il a été fait par Bertrand Renard et Laurent Romejko : uniquement des chiffres et des lettres (même pas le droit aux accents)

L'ID du snapshot est donné dans le retour de commande. Celui-ci va nous permettre de suivre l'avancement de la création du snapshot.
-->

---

<span class="chapter">Utilisation - Création d'un snapshot</span>

### Suivre l'avancement du snapshot

```powershell
$uri = "/beta/admin/configurationManagement/configurationSnapshotJobs/$($responsePOST.id)"
$responseGET = Invoke-MgGraphRequest -Method "GET" -Uri $uri
```

Exemple de retour :

Name              |  Value
----              |  -----
status            |  succeeded
id                |  fc7e6096-e324-469e-aba9-ab00aac45b2b
displayName       |  Snapshot CA 20260331115104
resources         |  {microsoft.entra.conditionalaccesspolicy}

<!--
Dans le retour de notre commande précédente, on a reçu un Id pour notre snapshot. On peut donc aller vérifier l'avancement du snapshot avec cette commande. 

Plusieurs états possibles : NotStarted, Running, Succeeded, PartiallySucceeded et Failed.

Au minimum, il faut compter une minute de temps de traitement, mais plus vous collectez d'informations, plus le snapshot sera long à récupérer.
-->

---

<span class="chapter">Utilisation - Création d'un snapshot</span>

### Télécharger le snapshot

Une fois que le snapshot est terminé :

```powershell
$splat = @{
    Method = 'GET'
    Uri = $responseGET.resourceLocation
    OutputFilePath = "C:\temp\snapshot_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').json"
}
Invoke-MgGraphRequest @splat
```

On télécharge le fichier JSON pour pouvoir le transformer en baseline.

<!--
Le snapshot est disponible au téléchargement pendant 7 jours maximum
-->

---

<span class="chapter">Utilisation - Création d'un snapshot</span>

```json
{
  "displayName": "AADConditionalAccessPolicy-Multifactor authentication for Microsoft partners and vendors",
  "resourceType": "microsoft.entra.conditionalaccesspolicy",
  "properties": {
    "ApplicationEnforcedRestrictionsIsEnabled": false,
    "SecureSignInSessionIsEnabled": false,
    "Ensure": "Present",
    "SignInFrequencyIsEnabled": false,
    "GrantControlOperator": "OR",
    "CloudAppSecurityIsEnabled": false,
    "Id": "00565114-097a-4357-854b-e3687a4d74ef",
    "PersistentBrowserIsEnabled": false,
    "DisplayName": "Multifactor authentication for Microsoft partners and vendors",
    "State": "enabled",
    "IncludeApplications": [ "All" ],
    "IncludeUsers": [ "All" ],
    "ExcludeRoles": [ "Directory Synchronization Accounts" ],
    "ClientAppTypes": [ "all" ],
    "BuiltInControls": [ "mfa" ],
    "ExcludeUsers": [ "admin@M365x32408877.onmicrosoft.com" ]
  }
}
```

<!--
Voici une partie du contenu du JSON obtenu pour le snapshot

Il est tout à fait possible de modifier manuellement les valeurs, ou de supprimer les choses que l'on ne veut pas auditer.
-->

---

<span class="chapter">Utilisation</span>

## Utilisation de UTCM

Méthodologie :

1. Faire un snapshot
2. **Créer une baseline à partir du snapshot**
3. Créer un monitor à partir de la baseline
4. Surveiller vos dérives de configuration

---

<span class="chapter">Utilisation - Création d'une baseline</span>

### Qu'est-ce qu'une baseline ?

La baseline va représenter la configuration souhaitée de votre tenant, c'est-à-dire l'état de référence. Toutes les différences entre la baseline et l'état actuel seront soulignés.

**Vous ne pouvez pas utiliser votre snapshot directement comme baseline, il y a une légère adaptation à faire**.

---

<span class="chapter">Utilisation - Création d'une baseline</span>

### Format d'une baseline

Voici la structure attendue :

```json
{
  "displayName": "Le nom de votre baseline",
  "baseline": {
    "displayName": "Le nom de votre snapshot",
    "resources": [ { ... } ]
  }
}
```

<!--
Le contenu de ressource correspond au JSON montré précédemment.

Vous pouvez choisir quoi auditer dans la baseline de manière granulaire. Dans l'exemple d'une stratégie d'accès conditionnel, on peut ignorer la partie "Grant" par exemple, et ne garder que "ExcludeUsers"

Une fois la baseline générée, vous pouvez la sauvegarder dans un fichier JSON
-->

---

<span class="chapter">Utilisation</span>

## Utilisation de UTCM

Méthodologie :

1. Faire un snapshot
2. Créer une baseline à partir du snapshot
3. **Créer un monitor à partir de la baseline**
4. Surveiller vos dérives de configuration

---

<span class="chapter">Utilisation - Création d'un monitor</span>

### Qu'est-ce qu'un monitor ?

Evaluation de la configuration du tenant par rapport à la baseline pour souligner les différences ou la conformité.

Passage toutes les 6 heures pour le moment

Possibilité d'auditer jusqu'à 800 objets par jour

<!-- 
L'équivalent d'une tâche planifiée ou d'une Azure Automation

Y'a moyen que Microsoft permettent à terme de lancer un monitor manuellement et de pouvoir régler la fréquence jusqu'à toute les heures

Les 800 objets par jour peuvent être simplifiés en 200 objets évalués quatre fois par jour

Un objet correspond à n'importe quel objet de configuration (règle de flux Exchange, une règle d'appartenance à un groupe dynamique, etc...)
-->

---

<span class="chapter">Utilisation - Création d'un monitor</span>

### Création d'un monitor

Possible de le faire en PowerShell / Graph API, mais beaucoup plus simple en interface graphique :

![alt text](image.png)

<!-- 
Le monitor sera lancé juste après sa création / modification, pas besoin d'attendre 6 heures

Une vérification syntaxique pas très verbeuse est proposée au moment d'intégrer la baseline
-->

---

<span class="chapter">Utilisation</span>

## Utilisation de UTCM

Méthodologie :

1. Faire un snapshot
2. Créer une baseline à partir du snapshot
3. Créer un monitor à partir de la baseline
4. **Surveiller vos dérives de configuration**

---

<span class="chapter">Utilisation - Surveillance des dérives</span>

### Dérives de configuration

Si une différence est trouvée par le monitor entre la baseline et l'état actuel du tenant, une derive de configuration sera levée.

![bg right:30%](https://i.pinimg.com/originals/86/96/8e/86968ee3ce8eda496e6c1c2dfe72abb9.gif)

```powershell
$uri = 'beta/admin/configurationManagement/configurationDrifts'
$drifts = Invoke-MgGraphRequest -Method GET -Uri $uri -OutputType PSObject
```

<!-- 
Cette commande PowerShell va permettre de récupérer tous les drifts, qu'importe leur ressource cible ou le monitor qui a soulevé la différence.

Evidemment, la pagination des retours d'API est à prendre en compte si jamais vous avez plus de 100 configurationDrifts
-->

---

<span class="chapter">Utilisation - Surveillance des dérives</span>

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

---

<span class="chapter">Utilisation - Surveillance des dérives</span>

![alt text](image-1.png)

---

<span class="chapter">Exemples d'utilisation</span>

## Exemples d'utilisation d'UTCM

Il manque encore un élément de UTCM : **le rollback**.

Pour l'instant il n'est pas encore possible d'appliquer une baseline sauvegardée sur la configuration du tenant. Une fois que cette fonction sera disponible :

- Audit quotidien de la configuration
- Garantir un environnement de DEV & PREPROD iso à la PROD
- ... ou simplement un garde-fou pour vos configurations sensibles

<!-- 
Audit : vous faites un snapshot de la configuration chaque jour à minuit, et vous comparer la configuration après 24h pour voir les différences. Puis vous recommencez :)

Copie de DEV/PREPROD : exporter la configuration de la PROD sur le DEV, faire le changement de le DEV et pousser ensuite vers la PREPROD et la PROD (après validation)
-->

---

<span class="chapter">Conclusion</span>

## Conclusion

UTCM a fortement évolué depuis sa sortie en janvier 2026 et va continuer d'évoluer (*nombres de ressources, possibilité de rollback, gestion d'autres tenants...*)

Aujourd'hui il permet simplement d'exporter et surveiller la configuration de votre tenant, mais très prochainement il devrait être en mesure de déployer une baseline sur un tenant vierge ou d'administrer plusieurs tenants de manière centralisée et programmatique (moyennant finances évidemment).

A terme, UTCM (et au général le module **Tenant Governance**) pourrait venir challenger des produits comme CoreView

---

<span class="chapter">Conclusion</span>

![bg left:30%](https://maester.dev/img/logo.svg)

## Quelques mots sur Maester

Module PowerShell pour faire une analyse des bonnes pratiques de votre tenant. Il permet également de faire des tests personnalisés sur vos propres indicateurs (via Pester).

**UTCM et Maester sont complémentaires**

[maester.dev](https://maester.dev/)

---

<span class="chapter">Conclusion</span>

![height:600px](https://i0.wp.com/office365itpros.com/wp-content/uploads/2026/02/Maester-V2-test-results.jpg?resize=1024%2C662&ssl=1)

---

# Merci à tous pour votre attention !
