---
layout: post
title: "MSGRAPH #7 - Questions"
description: "Questions pour évaluer votre niveau de connaissance sur Microsoft Graph"
tableOfContent: "/2023/09/17/cours-msgraph-introduction#table-des-matières"
prevLink:
  name: "Partie 6"
  id: "/2023/09/17/cours-msgraph-006"
---

## Questions

### Question #01

Sur quelles méthodes se reposent les API RESTful ?

- [ ] `GET`, `SET`, `NEW` et `REMOVE`
- [x] `GET`, `PATCH`, `PUT` et `DELETE`
- [ ] `GET`, `UPDATE`, `ADD` et `DELETE`
- [ ] `GET`, `PATCH`, `NEW` et `REMOVE`

### Question #02

L'utilisation d'applications Azure pour se connecter à Microsoft Graph est :

- [x] Indispensable
- [ ] Vivement recommandée par Microsoft
- [ ] Utile uniquement pour la connexion en tant qu'application
- [ ] Utile uniquement pour la connexion en mode délégué

### Question #03

Vous êtes l'administrateur global de votre annuaire. Vous vous connectez pour la première fois sur Microsoft Graph avec les modules PowerShell et vous lancer la commande `Get-MgUser`. Quel sera le résultat de la commande ?

- [ ] La liste de tous les utilisateurs de votre annuaire
- [ ] Les 1000 premiers utilisateurs de votre annuaire
- [ ] Les informations sur le compte avec lequel vous êtes connecté
- [x] Une erreur : vous n'avez pas les permissions nécessaires7

### Question #04

Vous effecutez une requête sur Microsoft Graph Explorer pour obtenir les groupes qui commencent par "Compta". Quelle est la bonne syntaxe pour votre paramètre de requête ?

- [ ] [?$filter=displayName -like 'Compta*'](/)
- [ ] [?$filter=displayName contains 'Compta'](/)
- [x] [`?$filter=startsWith(displayName,'Compta')](/)
- [ ] [?$search=(displayName,'Compta*')](/)

### Question #05

La durée de vie maximum autorisée pour un secret d'application Azure est de :

- [ ] 12 mois
- [x] 24 mois
- [ ] 48 mois
- [ ] L'expiration des secrets n'est pas obligatoire

### Question #06

Vous vous êtes déjà connecté à Microsoft Graph en PowerShell avec l'étendue `User.ReadWrite.All` et vous avez reçu l'approbation de l'administrateur. Vous vous reconnectez le lendemain avec la commande `Connect-MgGraph` sans indiquer d'étendue. Quelles seront vos permissions ?

- [ ] Les permissions par défaut (`User.Read`)
- [x] Les permissions déjà acquises (permissions par défaut et `User.ReadWrite.All`)
- [ ] Uniquement la permission `User.ReadWrite.All`
- [ ] Cela dépend du rôle Entra ID qui est attribué à votre compte

### Question #07

Toute votre équipe ainsi que vous-même utilisez systématiquement l'application Azure "Equipe IT 001" pour vous connecter à Microsoft Graph. L'un de vos collègues demande la permission `Organization.Read.All` et obtient l'approbation de l'administrateur. Vous souhaitez obtenir la même permission que lui avec votre compte :

- [ ] Vous devez faire une demande d'approbation auprès de l'administrateur pour votre compte
- [ ] Vous devez demander l'ajout d'un rôle sur votre compte Entra ID
- [x] Vous n'avez rien à faire

### Question #08

Plusieurs comptes Entra ID sont connectés sur votre ordinateur. Vous saisissez la commande `Connect-MgGraph` et celle-ci vous renvoie directement le texte *"Welcome To Microsoft Graph!"*. Vous souhaitez vérifier quel compte est utilisé pour la connexion. Quelle commande PowerShell pouvez vous utiliser ?

- [x] `Get-MgContext`
- [ ] `Get-MgUser -Filter "identity eq 'me'"`
- [ ] `Get-MgConnectedUser`
- [ ] `Get-MgConnectionInformation`

### Question #09

Vrai ou faux : Vous pouvez obtenir n'importe quelle information sur votre tenant en utilisant seulement les commandes `Connect-MgGraph` et `Invoke-MgGraphRequest` ?

- [x] Vrai
- [ ] Faux

### Question #10

Vrai ou faux : Toutes les permissions déléguées sont également disponibles en permissions d'applications.

- [ ] Vrai
- [x] Faux

### Question #11

Vrai ou faux : Vous n'avez pas besoin de demander d'approbation de l'administrateur lorsque vous avez le rôle d'administrateur global.

- [ ] Vrai
- [x] Faux
