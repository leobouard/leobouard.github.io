
## Général

Nom court | Console
--------- | -------
`taskschd` | Planificateur de tâches
`taskmgr` | Gestionnaire de tâches
`sysdm` | Propriétés systèmes
`compmgmt` | Gestion de l'ordinateur
`msconfig` | Configuration du système
`eventvwr` | Observateur d'événements
`perfmon` | Moniteur de performances
`services` | Services Windows
`regedit` | Éditeur du Registre
`devmgmt` | Gestionnaire de périphériques
`diskmgmt` | Gestion des disques
`ncpa.cpl` | Connexions réseau
`control` | Panneau de configuration
`appwiz.cpl` | Programmes et fonctionnalités
`sysdm.cpl` | Propriétés système (avancé)
`comexp` | Services de composants

## Active Directory

### RSAT Active Directory

```powershell
Install-WindowsFeature -Name RSAT-ActiveDirectory
```

Nom court | Console
--------- | -------
`dsa` | Utilisateurs et ordinateurs Active Directory
`dsac` | Centre d'administration Active Directory
`dssite` | Sites et services Active Directory
`domain` | Domaines et approbations Active Directory
`adsiedit` | Modification ADSI
`gpmc` | Gestion de stratégie de groupe
`mmc schmmgmt` | Schéma Active Directory

### Certificats

Nom court | Console
--------- | -------
`certlm` | Certificats - Ordinateur local
`certmgr` | Certificats - Utilisateur actuel
