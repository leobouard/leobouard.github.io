Source : [Update the sIDHistory attribute for existing accounts with Powershell \| Alwin Perotti's Blog](https://alwinperotti.wordpress.com/2013/03/29/update-the-sidhistory-attribute-for-existing-accounts-with-powershell/)

## Préparation des deux domaines

### Relation d'approbation

Commandes netdom

### Groupes SIDHistory

SOURCE$$$ et DESTINATION$$$

### Activation de l'audit

> Note sur la priorité des paramètres

## Ajout d'un SIDHistory en PowerShell

> A faire sur un contrôleur de domaine uniquement !

### ClonePrincipal

La librairie ClonePrincipal (fichier `clonepr.dll`) contient l'objet "DSUtils.ClonePrincipal" qui support les méthodes suivantes :

1. `Connect()`: établi une connexion authentifiée entre les contrôleurs de domaine sources et destinations
2. `AddsIDHistory()` : copie le SID de l'objet source dans l'attribut `SIDHistory` de l'objet destination
3. `CopyDownlevelUserProperty()` : copie les propriétés Windows NT 4.0 de l'utilisateur source vers l'utilisateur destination.

Source : [ClonePrincipal \| Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-2000-server/cc960697%28v=technet.10%29)

C'est la seconde méthode qui nous intéresse dans ce cas.

#### Chargement de la DLL

Sur un contrôleur de domaine, 

```powershell
regsvr32.exe clonepr.dll
```

#### Utilisation de la DLL

```powershell
$clonepr = [DSUtils.ClonePrincipal]::New()
$clonePr.Connect($sourceDC, $sourceDomain, $TargetDC, $TargetDomain)
$clonePr.AddSidHistory($sourceUserName, $targetUserName, 0)
```

### Ajout d'un SIDHistory avec DSInternals

### Suppression d'un SIDHistory

