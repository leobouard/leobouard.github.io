---
layout: post
title: "Cours Microsoft Graph"
description: "Bien commencer sur Microsoft Graph pour les administrateurs systèmes"
tags: ['cours','microsoft-graph']
thumbnail: "/assets/thumbnail/cours-msgraph.png"
listed: true
nextLink:
  name: "Partie 1"
  id: "/2023/09/17/cours-msgraph-001"
---

## Introduction

Ce cours est dédié aux administrateurs systèmes en charge de l'administration des services cloud de Microsoft (Entra ID, Microsoft 365...).

Microsoft Graph est la nouvelle plateforme de programmation qui connecte la plupart des services et des données de Microsoft 365. Cette nouvelle plateforme incarne **un changement de paradigme pour l'administration système** : si auparavant nous bénéficions de modules PowerShell dédiés à nos tâches, nous devons maintenant utiliser une API REST plus généraliste et avec un fonctionnement qui convient mieux au travail d'un développeur.

Avec [la fin de vie des modules PowerShell AzureAD et MSOnline](https://techcommunity.microsoft.com/t5/microsoft-entra-azure-ad-blog/important-azure-ad-graph-retirement-and-powershell-module/ba-p/3848270), il est donc important de mettre à jour ses connaissances et en développer de nouvelles, pour pouvoir commencer (ou continuer) à automatiser votre travail.

### Prérequis

Pour ce cours, je considère que vous maitrisez les bases du scripting PowerShell et l'administration de Microsoft 365, sans avoir pour autant de connaissances sur les anciens modules.

Pour réaliser les exercices pratiques, vous devrez avoir accès à un tenant Microsoft 365 (de test de préférence). Si vous n'en avez pas, vous pouvez en obtenir avec :

- [Microsoft 365 Developer Program](https://developer.microsoft.com/en-us/microsoft-365/dev-program), disponible pour tout le monde
- [Microsoft Customer Digital Experiences](https://cdx.transform.microsoft.com/), disponible si votre entreprise est un partenaire Microsoft

## Table des matières

{% assign posts = site.posts | sort: 'id' %}
<div class="summary">
  {% for post in posts %}
    {% if post.title contains 'MSGRAPH #' %}
      <a href="{{ post.id }}">
          <h3>{{ post.title }}</h3>
          <span>{{ post.description}}</span>
      </a>
    {% endif %}
  {% endfor %}
</div>

## Liens utiles

- [Graph Explorer](https://developer.microsoft.com/en-us/graph/graph-explorer)
- [Paramètres de requêtes](https://learn.microsoft.com/fr-fr/graph/query-parameters?tabs=http)
- [Correspondance MSOnline/AzureAD vers MSGraph](https://learn.microsoft.com/en-us/powershell/microsoftgraph/azuread-msoline-cmdlet-map?view=graph-powershell-1.0)
- [Liste complète de toutes les API v1.0](https://learn.microsoft.com/fr-fr/graph/api/overview?view=graph-rest-1.0)
- [Parcours de formation Microsoft Graph Fundamentals](https://learn.microsoft.com/en-us/training/paths/m365-msgraph-fundamentals/)
