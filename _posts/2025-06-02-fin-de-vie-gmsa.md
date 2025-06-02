---
title: "Fin de vie d'un compte gMSA"
description: "Comment identifier, analyser et supprimer un compte de service gMSA inutile dans Active Directory"
tags: ["activedirectory"]
listed: true
---

## Gestion des comptes gMSA

### Lister tous les comptes de service

Voici une commande PowerShell pour lister l'ensemble des comptes de services, avec la date de dernière connexion (propriété `LastLogonDate`) et la date de dernier changement de mot de passe (propriété `PasswordLastSet`) :

```powershell
Get-ADServiceAccount -Filter * -Properties LastLogonDate, PasswordLastSet |
  Sort-Object LastLogonDate |
  Format-Table Name, LastLogonDate, PasswordLastSet
```

> **Rappel :** le mot de passe d'un gMSA n'est mis à jour que si celui-ci a plus de X jours (X étant la valeur de l'attribut `msDS-ManagedPasswordInterval`) au moment de l'utilisation du compte. Si le compte n'est pas utilisé : le mot de passe ne se mettra pas à jour.

## Étudier l'utilisation du compte

De manière générale, si un gMSA ne se connecte pas ou ne renouvelle pas son mot de passe, on peut considérer qu'il n'est plus utilisé. Sur ce genre de compte, il n'y a pas de faux positif puisque le contrôleur de domaine est systématiquement sollicité.

Pour avoir une idée claire des impacts, il est tout de même important de mener une enquête rapide sur l'usage du compte.

### Récupération des serveurs autorisés

Vous pouvez obtenir l'information des objets autorisés à obtenir le mot de passe avec la commande suivante :

```powershell
Get-ADServiceAccount gmsa -Properties PrincipalsAllowedToRetrieveManagedPassword
```

Une fois la liste des serveurs obtenues, il ne reste plus qu'à controller l'utilisation du gMSA sur chaque serveur, avec les étapes suivantes :

- État d'installation du gMSA
- Utilisation dans les tâches planifiées
- Utilisation dans les services Windows

### Vérification sur chaque serveur

#### Vérification de l'installation du gMSA

Première étape : vérifier que le gMSA est bien installé sur le serveur :

```powershell
Test-ADServiceAccount gmsa
```

Si le résultat de la commande donne "False" : le compte de service n'est pas utilisable sur le serveur.

> Si le résultat de la commande `Test-ADServiceAccount` est positif, cela peut générer une activité sur le compte de service (mise à jour de l'attribut `PasswordLastSet`).

#### Vérification des tâches planifiées

Avec cette commande, on va lister tous les comptes utilisés pour lancer une tâche planifiée sur le serveur :

```powershell
Get-ScheduledTask |
    Select-Object TaskName, State, @{N='Account';E={$_.Principal.UserID}} |
    Group-Object Account |
    Sort-Object Count -Descending
```

#### Vérification des services

Avec cette commande, on va lister tous les comptes utilisés pour lancer un service Windows sur le serveur :

```powershell
Get-WMIObject Win32_Service |
    Select-Object Name, StartName |
    Group-Object StartName |
    Sort-Object Count -Descending
```

## Décommissionnement d'un gMSA

### Désinstallation du compte

Si après vérification, on constate que le gMSA n'est pas ou plus utilisé sur le serveur, on peut passer à la désinstallation de celui-ci.

Sur le ou les serveurs autorisés à lire le mot de passe du compte :

```powershell
Uninstall-ADServiceAccount 
```

### Suppression des permissions locales

Pour éviter de se retrouver avec des SID orphelins, il est important de nettoyer les permissions nominatives (qui ne passaient pas par un groupe de permission) qui avaient été accordées au compte gMSA.

Il faut surtout regarder dans la console "Local Security Policy" (`secpol`) ou dans les GPO au chemin *Computer Configuration > Security Settings > Local Policies > User Rights Assignment*, sur les paramètres suivants :

- Log on as batch job
- Log on as a service

### Suppression des groupes

Si les permissions pour lire le mot de passe passaient par un groupe, supprimer le groupe.

### Suppression du gMSA

Dernière étape : suppression de l'objet gMSA dans Active Directory, soit :

- en PowerShell avec la commande `Remove-ADObject`
- dans la console "Active Directory Users and Computers" au chemin : `contoso.com/Managed Service Accounts`
