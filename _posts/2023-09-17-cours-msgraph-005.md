---
layout: post
title: "MSGRAPH #5 - Applications Azure"
description: "Découvrir le rôle et le fonctionnement d'une application Azure pour utiliser Microsoft Graph"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 6"
  id: "/2023/09/17/cours-msgraph-006"
prevLink:
  name: "Partie 4"
  id: "/2023/09/17/cours-msgraph-004"
---

## Les applications Azure

Les applications Azure font partie intégrante de Microsoft Graph, puisqu'il est impossible de s'y connecter sans faire appel à l'une d'entre-elle. Que ce soit via Microsoft Graph Explorer ou les modules PowerShell, vous passiez déjà par une application sans le savoir.

Si vous en voulez la preuve, vous pouvez consulter la section "Applications d'entreprise" de votre console Entra ID. Vous devriez y retrouver *Graph Explorer* et *Microsoft Graph Command Line Tools* :

![toutes les applications de votre tenant](/assets/images/msgraph-501.png)

## Création d'une application

Pour faire de l'administration ponctuelle avec votre compte à privilège, il n'y a pas ou peu d'intérêt à passer par une autre application que celles du Graph Explorer ou des modules PowerShell. Cependant, créer votre propre application Azure peut vous permettre de déléguer des tâches d'administration ou mettre des scripts se connectant à Microsoft Graph en tâches planifiées.

Pour créer votre propre application, vous pouvez vous rendre sur https://portal.azure.com puis "Microsoft Entra ID" et choisir le menu "Inscriptions d'applications" et enfin sectionner "+ Nouvelle inscription".

![créer une nouvelle application Azure](/assets/images/msgraph-502.png)

Vous pouvez alors choisir le nom de votre application et qui peut l'utiliser. L'URI de redirection ne nous concerne pas pour notre usage. Une fois votre nouvelle application inscrite, vous devriez avoir accès aux informations de celle-ci, notamment l'ID du client et de l'ID de votre tenant (locataire). Ces deux identifiants vous permettrons de vous connecter à votre application en PowerShell.

![informations importantes de votre application](/assets/images/msgraph-503.png)

Vous pouvez en profiter pour ajouter un logo sur votre application et une description.

### Autorisations

Par défaut et comme toujours avec Microsoft Graph, vous aurez comme seule permission de lire votre profil utilisateur. Si vous voulez consulter vos autorisations actuelles ou en ajouter de nouvelles (comme *Group.Read.All* ou *Directory.Read.All*), vous pouvez le faire dans le menu "API autorisées".

Lorsque vous cliquer sur "+ Ajouter une autorisation", vous avez alors beaucoup de choix à votre disposition : Microsoft Graph, Dynamics CRM, Intune, Purview, OneNote, Power Automate, etc... Pour rester dans le sujet, on va s'en tenir à "Microsoft Graph".

![toutes les permissions disponibles](/assets/images/msgraph-504.png)

#### Types d'autorisation

Il y a deux types de permissions différentes pour les API Microsoft Graph :

- **Les autorisation déléguées** : Votre application doit accéder à l'API en tant qu'utilisateur connecté. Par exemple : un script ou une Power App pour déléguer l'attribution de licences Microsoft 365 à l'équipe support.
- **Les autorisation d'application** : Votre application s'exécute en tant que service en arrière-plan ou démon sans utilisateur connecté. Par exemple : un script de reporting mis en tâche planifiée.

> Toutes les autorisations déléguées n'ont pas forcément leur pendant en autorisations d'applications et inversement.

Comme d'habitude, la plupart des autorisations nécessiterons une approbation de l'administrateur avant de fonctionner correctement.

### Connexion à une application

Il vous faudra vous munir de trois éléments pour pouvoir vous connecter à votre application Azure :

- **L'ID de l'application**, également appelé *ClientID*
- **L'ID du l'annuaire (locataire)**, également appelé *TenantID*
- **Un moyen de s'authentifier** :
  - avec votre compte si vous souhaitez accéder à des autorisations déléguées
  - avec un secret ou un certificat si vous souhaitez accéder à des autorisations d'application

Les deux premières informations sont disponibles facilement dans la section "Propriétés" de votre app Azure, et la troisière dépendera du type de permissions auquelles vous voulez accéder (déléguées ou application).

#### Connexion en mode délégué

#### Connexion en tant qu'application

#### Certificat ou secret ?

- Durée de vie maximum d'un secret : 2 ans
- Durée de vie maximum d'un certificat : 4 ans ?

#### Connexion via secret

```powershell
"v0tr3SecR3tb1eNg4rDé" |
    ConvertTo-SecureString -AsPlainText |
    ConvertFrom-SecureString
```

<blockquote style="overflow-wrap: break-word;">
  <p>01000000d08c9ddf0115d1118c7a00c04fc297eb0100000095e99a1b60201a4db16911633fed29810000000002000000000003660000c000000010000000c2c7024dc2f0cbad69f5d305f752a91d0000000004800000a0000000100000001244c77406a80e93137f7d241e08525a10000000f8eaeca8a324cbb2c978146c7ef131ea14000000b7d3a8e0997d88fb47de646028570511952c3163</p>
</blockquote>

#### Connexion via certificat


## Exercice pratique n°1

### Contexte

utilisé par le support informatique de premier niveau et qui va nous donner les niveaux d'utilisation des licences Microsoft 365 de notre tenant

### Ajout des permissions

[List subscribedSkus \| Microsoft Graph REST API v1.0](https://learn.microsoft.com/en-us/graph/api/subscribedsku-list?view=graph-rest-1.0&tabs=http)

### Connexion à l'application

### Réalisation du script

```powershell
$params = @{
    
}
Connect-MgGraph @params
Get-MgSubscribedSku | Select-Object SkuPartNumber | Out-GridView
```

### Suppression des permissions

## Exercice pratique n°2

### Contexte

un script PowerShell en tâche planifiée pour nous remonter les groupes d'attributions de licence avec des membres en erreur via un email

### Ajout des permissions

[Group licensing with PowerShell and Graph](https://learn.microsoft.com/en-us/entra/identity/users/licensing-ps-examples)

> Réponses :
> - autorisation d'application sur la permission *Group.Read.All*
> - autorisation d'application sur la permission *Mail.Send*

### Connexion à l'application

#### Création du secret

#### Création du certificat

### Réalisation du script

```powershell

```

### Suppression des permissions