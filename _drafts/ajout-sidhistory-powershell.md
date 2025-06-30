Source : [Update the sIDHistory attribute for existing accounts with Powershell \| Alwin Perotti's Blog](https://alwinperotti.wordpress.com/2013/03/29/update-the-sidhistory-attribute-for-existing-accounts-with-powershell/)

## Préparation des deux domaines

### Relations d'approbations

Commandes `netdom`

SOURCE & DESTINATION

Sur le domaine SOURCE :

```powershell
NETDOM TRUST source.local /Domain:destination.local /Quarantine:Yes
NETDOM TRUST source.local /Domain:destination.local /EnableSIDHistory:Yes
```

Sur le domaine DESTINATION :

```powershell
NETDOM TRUST destination.local /Domain:source.local /Quarantine:Yes
NETDOM TRUST destination.local /Domain:source.local /EnableSIDHistory:Yes
```

### Groupes SIDHistory

Création d'un groupe par domaine pour activer l'audit du SIDHistory

SOURCE$$$ et DESTINATION$$$

```powershell
$name = (Get-ADDomain).NetBIOSName + '$$$'
New-ADGroup -Name $name -GroupCategory Security -GroupScope DomainLocal
```

### Activation de l'audit
 
#### Account management

Policy | Audit
------ | -----
Audit Application Group Management | Success and Failure
Audit Computer Account Management | Success and Failure
Audit Distribution Group Management | Success and Failure
Audit Other Account Management Events | Success and Failure
Audit Security Group Management | Success and Failure
Audit User Account Management | Success and Failure

#### DS Access

Policy | Audit
------ | -----
Audit Detailed Directory Service Replication | Success and Failure
**Audit Directory Service Access** | Success and Failure
Audit Directory Service Changes | Success and Failure
Audit Directory Service Replication | Success and Failure

Source: [Configuring the Source and Target Domains for SID History Migration \| Microsoft Learn](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2008-R2-and-2008/cc974410%28v=ws.10%29?redirectedfrom=MSDN#to-enable-auditing-in-windowsserver2008-and-later-domains)

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

Sur un contrôleur de domaine :

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

```powershell
# Find the account SID you want to inject
Get-ADUser -Identity $InterestingUser

# Stop the NTDS service
Stop-Service NTDS -force

# Inject the SID into the SID History attribute
Add-ADDBSidHistory -SamAccountName AttackerUser -sidhistory $SIDOfInterestingUser -DBPath C:\Windows\ntds\ntds.dit

# Start the NTDS service
Start-Service NTDS
```

### Suppression d'un SIDHistory

Supprimer 

```powershell
Get-ADUser john.doe -Properties SIDHistory | Set-ADUser -Remove @{ SIDHistory = $_.SIDHistory.Value }}
```

