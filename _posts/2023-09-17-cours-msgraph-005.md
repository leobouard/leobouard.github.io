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

### Création d'une application

Pour faire de l'administration ponctuelle avec votre compte à privilège, il n'y a pas ou peu d'intérêt à passer par une autre application que celles du Graph Explorer ou des modules PowerShell. Cependant, créer votre propre application Azure peut vous permettre de déléguer des tâches d'administration ou mettre des scripts se connectant à Microsoft Graph en tâches planifiées.

### Autorisations déléguées ou autorisations d'application ?

Quel type d'autorisation votre application nécessite-t-elle ?

- **Autorisation déléguées** : Votre application doit accéder à l'API en tant qu'utilisateur connecté. Par exemple : un script ou une Power App pour déléguer l'attribution de licences Microsoft 365 à l'équipe support.
- **Autorisation d'application** : Votre application s'exécute en tant que service en arrière-plan ou démon sans utilisateur connecté. Par exemple : un script de reporting mis en tâche planifiée.

### Se connecter à une application

Il vous faudra vous munir de trois éléments pour pouvoir vous connecter à une application Azure :

- **L'ID de l'application**, également appelé *ClientID*
- **L'ID du l'annuaire (locataire)**, également appelé *TenantID*
- **Un moyen de s'authentifier** :
  - avec votre compte si vous souhaitez accéder à des autorisations déléguées
  - avec un secret ou un certificat si vous souhaitez accéder à des autorisations d'application

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

#### Créer un certificat
