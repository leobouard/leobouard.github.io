---
layout: post
title: "MSGRAPH #6 - Exercices pratiques"
description: "Travaux pratiques qui mobilisent l'ensemble des connaissances acquises"
tableOfContent: "/2023/09/17/cours-msgraph-introduction#table-des-matières"
nextLink:
  name: "Partie 7"
  id: "/2023/09/17/cours-msgraph-007"
prevLink:
  name: "Partie 5"
  id: "/2023/09/17/cours-msgraph-005"
---

## Exercice pratique n°1

Le support de premier niveau (support N1) a besoin d'avoir accès au nombre de licences Microsoft 365 disponibles en temps réel. Les opérateurs du support n'ont pas de comptes d'administration sur Microsoft 365, uniquement des comptes standards sans accès aux portails Azure ou Entra ID. Ceux-ci disposent cependant des modules PowerShell Microsoft Graph installés sur leurs postes de travail.

Vous devez donc leur fournir un script PowerShell qui permettrait d'obtenir l'état des licences Microsoft 365 en s'authentifiant avec leurs comptes standards.

Pour obtenir les informations nécessaires pour la disponibilité des licences, vous pouvez utiliser l'API suivante : [List subscribedSkus \| Microsoft Graph REST API v1.0](https://learn.microsoft.com/en-us/graph/api/subscribedsku-list?view=graph-rest-1.0&tabs=http)

### Script PowerShell

L'intérêt de cet exercice se situe dans la configuration d'une application Azure et la connexion à celle-ci en PowerShell. Si vous le souhaitez, vous pouvez réaliser votre propre script, sinon voici une version basique déjà fonctionnelle :

~~~powershell
(Invoke-MgGraphRequest -Method GET -Uri 'https://graph.microsoft.com/beta/subscribedskus' -OutputType PSObject).value |
    Select-Object skuId,skuPartNumber,consumedUnits,
        @{N='enabledUnits';E={$_.prepaidUnits.enabled}},
        @{N='availableUnits';E={$_.prepaidUnits.enabled-$_.consumedUnits}} |
    Out-GridView -Title "Microsoft 365 licenses subscriptions"
~~~

## Exercice pratique n°2

Votre entreprise a récemment modifié son mode d'attribution des licences Microsoft 365 pour passer à des groupes d'attribution. Cependant, vous avez remarqué que vous aviez fréquement des erreurs d'attribution (plus assez de licences ou conflit avec une licence déjà attribuée). Vous voulez mettre en place un script en tâche planifiée pour vous prévenir par email lorsqu'une erreur d'attribution de licence est découverte sur votre tenant.

Vous pouvez vous baser sur l'article officiel de Microsoft sur le sujet pour la partie scripting PowerShell : [PowerShell and Microsoft Graph examples for group-based licensing in Microsoft Entra ID \| Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/users/licensing-ps-examples)
