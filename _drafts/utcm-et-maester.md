---
---

## Sources

### M365DSC

- [Introduction - Microsoft365DSC - Your Cloud Configuration](https://microsoft365dsc.com/)
- [microsoft/Microsoft365DSC: Manages, configures, extracts and monitors Microsoft 365 tenant configurations](https://github.com/microsoft/Microsoft365DSC)
- [Configuring Azure Entra ID and M365 with DSC - Gael Colas & Raimund Andree - PSConfEU 2025](https://www.youtube.com/watch?v=z2VQMK4RD0k)

### UTCM

- [Microsoft Finally Built an Official M365DSC! (Introducing TCM) - YouTube](https://www.youtube.com/watch?v=_iKxt9Zk_PY)
- [UTCM: New Way to Monitor Microsoft 365 Tenant Config Changes](https://office365itpros.com/2026/02/03/utcm-beta/)
- [Introducing the Tenant Configuration Management APIs - Nik Charlebois - Crawl, Walk, Run, Automate](https://nik-charlebois.com/blog/posts/2026/introducing-tcm-apis/index.html)

### Maester

- [Advanced guide \| Maester](https://maester.dev/docs/writing-tests/advanced-concepts/)
- [Maester and UTCM Are Complementary Tools for Microsoft 365](https://office365itpros.com/2026/02/10/maester-and-utcm/)
- [GitHub - fortytwoservices/kickstarter-maester-and-utcm](https://github.com/fortytwoservices/kickstarter-maester-and-utcm)

## Histoire de Microsoft UTCM

Créé par Nik Charlebois, un employé de Microsoft et MVP qui a travaillé en tant que PFE SharePoint, sur le développement de Microsoft Graph et M365DSC (2018).

D'abord créé comme un outil de troubleshooting de fermes SharPoint onprem pour répliquer une configuration client, le produit a évalué vers un outil communautaire plus étendu. Le projet a pris en traction et a évolué vers un système qui gère plus de choses : Entra ID, Exchange, Intune, SharePoint & OneDrive, Purview, quelques briques de Microsoft Defender, Teams, PowerPlatform,  Azure Sentinel et Azure DevOps. Groso modo, tout ce qui dispose d'une API sur les consoles d'administration classiques.

Le problème principal de M365DSC est que même si le projet était mené par Microsoft et supporté par la communauté en open-source, ce support était en "best-effort" et n'arrivait pas toujours à suivre les évolutions de la plateforme Microsoft 365. Autre problème : la courbe d'apprentissage pour pouvoir participer au projet est abrupte. Le projet M365DSC est écrit en PowerShell mais les contributeurs doivent avoir une expérience et une comprehension de DSC (*Desired State Configuration*) et de Microsoft 365, ce qui réduit drastiquement le nombre de personnes qualifiées pour pouvoir participer au projet.

2024 : début du projet UTCM côté Microsoft, avec un support officiel pour sauvegarder, recréer, monitorer les écarts de configuration et faire du rollback si besoin. Offrir du support client. Pour réduire la complexité : utilisation de Microsoft Graph via des API ouvertes et utilisable par tous (que se soit en PowerShell, en .NET ou en Python).

### Fonctionnalités 

M365DSC pouvait gérer la configuration de nombreux produits comme Microsoft 365. Pour UTCM, dans la public preview sortie en janvier 2026, n'est supporté pour le moment uniquement :

- Defender (limited coverage)
- Entra ID
- Exchange Online
- Intune
- Purview
- Teams

> **Pourquoi une telle différence ?**
>
> Les deux produits, même si ils répondent aux mêmes besoins sont radicalement différents. UTCM n'est pas une intégration de M365DSC dans la Graph API. Par ailleurs, M365DSC continuera de vivre comme un projet communautaire.

Choses que UTCM ne fait pas : la sauvegarde de la partie "Données". UTCM ne se concentre que sur la partie **configuration** (comme son nom l'indique). Vous ne pourrez donc pas restaurer des groupes, des utilisateurs ou des fichiers SharePoint avec UTCM. CEPENDANT, certains groupes ou utilisateurs sont des éléments essentiels de la configuration, notamment ceux utilisés dans vos accès conditionnels. Ceux-ci sont alors sauvegardés pour pouvoir répliquer la configuration à 100%.

### Différence

M365DSC stocke sa configuration au format propriétaire DSC, et le processing se fait par PowerShell sur la machine cliente.
UTCM stocke sa configuration en JSON et tout le processing se passe du côté de Microsoft.

### Fonctionnement

1. Faire un appel API avec le scope des choses à sauvegarder
2. Télécharger le fichier qui a été généré (disponible pendant 7 jours côté Microsoft)

Possibilité de créé un Monitor (tâche planifiée) qui tourne toute les 6 heures (plusieurs schedules disponibles bientôt, ça ne descendra pas en dessous de 1h). Le Monitor va permettre d'analyser la configuration actuelle par rapport à celle sauvegardée pour ensuite faire de l'alerting ou du roll-back, suivant vos préférences.

Possibilité d'être extrèmement granulaire : exemple avec les accès conditionnels où il est possible de ne surveiller que la partie Groups Included & Excluded, et de laisser la partie Grant tranquille.

Possibilité d'utiliser UTCM pour faire de la copie de configuration entre tenant : il est possible de répliquer la conf d'un environnement de PROD sur le TEST en spécifiant des paramètres pour ajuster certaines variables.


Dans un monde idéal :

1. Refresh de la configuration PROD vers DEV
2. Modification du DEV
3. Promotion du changement sur le PREPROD
4. Promotion du changement sur la PROD

Le tout de manière complétement automatisée, en utilisant des variables et des paramètres spécifiques.

Obligation d'avoir une Entra ID P1

API uniquement pour le moment. Il y aura une interface graphique à terme
Les commandes PowerShell du module ne sont pas encore disponibles

800 objets par jour qui peuvent être monitorés en version gratuite. Objet = 1 groupe, une CA
donc 200 CA a superviser gratuitement.

Configuration.Monitoring.ReadWrite (nouveau rôle) pour tout faire, mais n'importe quel rôle intégré plus restrictif peut fonctionner pour un périmètre limité

## Comment commencer

1. Faire un snapshot
2. Créer un monitor
3. Créer un drift et faire un auto rollback


Quid de M365DSC : possibilité de conversion vers le fichier JSON compatible avec UTCM ou simplement faire un snapshot


### Création d'une app registration

Création d'un nouvelle inscription d'application nommée 'UTCM Demo' :

[Set up authentication for unified tenant configuration management APIs - Microsoft Graph \| Microsoft Learn](https://learn.microsoft.com/en-us/graph/utcm-authentication-setup)

Pour créer une snapshot :

```powershell
$uri = '/beta/admin/configurationManagement/configurationSnapshots/createSnapshot'
$body = @'
{
    "displayName": "UTCM Demo 006", 
    "description": "Demonstration de l'utilisation de UTCM", 
    "resources": 
    [
            "microsoft.entra.conditionalaccesspolicy", 
            "microsoft.entra.grouplifecyclepolicy", 
            "microsoft.exchange.transportrule",
            "microsoft.teams.meetingpolicy"
    ] 
}
'@
$responsePOST = Invoke-MgGraphRequest -Method POST -Uri $uri -Body $body
```

> Tous les displayName de vos snapshots doivent être uniques et ne doivent pas contenir de caractères spéciaux.

Vous allez obtenir un "Id" qui va vous permettre de consulter l'avancement de la création de votre snapshot :

```powershell
$responseGET = Invoke-MgGraphRequest -Method "GET" -Uri "/beta/admin/configurationManagement/configurationSnapshotJobs/$($responsePOST.id)"
```

Mon snapshot a mis un peu moins d'une minute a se terminer, et s'est soldé par un `status: partiallySuccessful`. Une fois terminée, la snapshot est disponible sur l'URL fournie dans la réponse, sous la propriété `resourceLocation` :

```powershell
Invoke-MgGraphRequest -Method GET -Uri $responseGET.resourceLocation -OutputFilePath "C:\temp\snapshot_$(Get-Date -Format 'yyyy-MM-dd_HHmmss').json"
```

### Création d'un monitor

Pour rappel, le monitor va permettre d'auditer la configuration actuelle en fonction de la configuration sauvegardée.

```powershell
$uri = 'https://graph.microsoft.com/beta/admin/configurationManagement/configurationMonitors/'
$body = @"
{
    "displayName": "Monitor - UTCM Demo 006", 
    "description": "Monitoring de la snapshot que l'on ", 
    "baseline": CONTENT OF YOUR CONFIGURATION TEMPLATE
}
"@
$responseMonitor = Invoke-MgGraphRequest -Method POST -Uri $uri
```

