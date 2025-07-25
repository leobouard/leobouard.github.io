---
title: "Lister les permissions LogonAsBatch et LogonAsService en PowerShell"
description: "Obtenir la liste des objets qui peuvent se connecter en tant que tâche ou service"
tags: ["powershell", "windows"]
listed: true
---

## Permissions

Les permissions **LogonAsBatch** (SeBatchLogonRight) et **LogonAsService** (SeServiceLogonRight) sont des droits d’ouverture de session spéciaux dans Windows, attribués à des comptes utilisateurs ou groupes.

- **LogonAsBatch** (SeBatchLogonRight) : Permet à un compte de s’authentifier pour exécuter des tâches planifiées ou des scripts via le service de planification des tâches Windows (Task Scheduler). Sans ce droit, un utilisateur ou service ne peut pas lancer de tâche planifiée.
- **LogonAsService** (SeServiceLogonRight) : Autorise un compte à s’authentifier pour exécuter un service Windows (par exemple, un service personnalisé ou un logiciel serveur). Sans ce droit, un compte ne peut pas être utilisé comme compte de service pour démarrer un service Windows.

## Récupération en PowerShell

### Obtention des informations de SECPOL

Les informations pour ces permissions sont stockées dans la stratégie de sécurité locale (SECPOL), qui peut être exporté vers un fichier CFG.

Créer un dossier `C:\temp\` :

```powershell
mkdir C:\temp -Force
```

Exporter la stratégie de sécurité locale vers un fichier CFG :

```powershell
secedit /export /cfg C:\temp\secpol.cfg
```

### Extraction des informations

Parser la stratégie locale pour obtenir l'information :

```powershell
$cfg = Get-Content -Path 'C:\temp\secpol.cfg'
$batchLogon = (($cfg | Select-String 'SeBatchLogonRight') -split '=')[-1]
$serviceLogon = (($cfg | Select-String 'SeServiceLogonRight') -split '=')[-1]
```

Traduction des SID et affichage des résultats :

```powershell
Write-Host "Log on as a batch job" -ForegroundColor Yellow
$batchLogon = $batchLogon.Replace('*', '').Trim()
$batchLogon -split ',' | ForEach-Object {
    $SID = [System.Security.Principal.SecurityIdentifier]::New($_)
    ($SID.Translate([System.Security.Principal.NTAccount])).Value
}

Write-Host "Log on as a service" -ForegroundColor Yellow
$serviceLogon = $serviceLogon.Replace('*', '').Trim()
$serviceLogon -split ',' | ForEach-Object {
    $SID = [System.Security.Principal.SecurityIdentifier]::New($_)
    ($SID.Translate([System.Security.Principal.NTAccount])).Value
}
```
