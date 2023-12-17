---
layout: post
title: "MSGRAPH #6 - Exercices pratiques"
description: "Travaux pratiques qui mobilisent l'ensemble des connaissances acquises"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 7"
  id: "/2023/09/17/cours-msgraph-007"
prevLink:
  name: "Partie 5"
  id: "/2023/09/17/cours-msgraph-005"
---

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

---

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