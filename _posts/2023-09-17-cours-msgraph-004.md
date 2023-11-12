---
layout: post
title: "MSGRAPH #4 - Explorer et modules PowerShell"
description: "Commencer les requêtes via Microsoft Graph Explorer et les modules PowerShell dédiés"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 5"
  id: "/2023/09/17/cours-msgraph-005"
prevLink:
  name: "Partie 3"
  id: "/2023/09/17/cours-msgraph-003"
---

## Microsoft Graph Explorer

### Lancer Microsoft Graph Explorer

### Se connecter à votre tenant

### Créer un utilisateur (POST)

### Rechercher un utilisateur (GET)

### Mettre à jour un utilisateur (PATCH)

### Supprimer un utilisateur (DELETE)

### Passage en version BETA

---

## Modules PowerShell

### Installer les modules

```powershell
Install-Module 'Microsoft.Graph'
```

### Installation des modules

```powershell
Get-InstalledModule -Name 'Microsoft.Graph*'
```

### Se connecter en PowerShell

### Créer un groupe et ajouter un membre (POST)

### Rechercher un groupe et les membres d'un groupe (GET)

```powershell
Get-MgGroup
Get-MgGroupMember
```

Vous devriez avoir une limite de 1000 résultats sur votre requête `Get-MgGroup` si vous n'avez pas invoqué le paramètre `-All`. Cette limitation est liée au système de pagination de l'API sous-jacente.

### Mettre à jour un groupe (PATCH)

Cette fois-ci, pas de cmdlet tout prêt pour faire une requête, il va donc falloir utiliser la commande qui peut remplacer toutes les autres : `Invoke-MgGraphRequest`.

```powershell
Invoke-MgGraphRequest
```

### Supprimer un groupe (DELETE)

### Passer à la version BETA
