---
title: "Configuration d'un contrôleur de domaine en mode Core"
description: "Suivre les bonnes pratiques de l'ANSSI pour le déploiement de vos contrôleurs de domaine"
tags: ["activedirectory", "powershell"]
listed: true
---

## Utilisation du mode Core sur un contrôleur de domaine

### L'avis de l'ANSSI

En octobre 2025, l'ANSSI a sorti un document sur la sécurisation initiale d'un contrôleur de domaine. Le document est concis et donne toutes les bonnes pratiques à adopter, de la plateforme physique ou virtuelle du serveur à des conseils sur la configuration du serveur après l'installation du rôle.

Le fichier est disponible ici et je recommande vivement sa lecture, surtout que celui-ci est très court (seulement deux pages) : [Windows Server : Sécurisation initiale d'un contrôleur de domaine \| ANSSI](https://cyber.gouv.fr/sites/default/files/document/anssi_essentiels_serveur_Windows_controleur_domaine_v1.0.pdf)

On peut retenir un point essentiel, qui a tendance à faire peur à la plupart des administrateurs•trices systèmes : **l'utilisation du mode Core** (sans interface graphique), pour réduire la surface d'attaque du serveur.

### Réduction de la surface d'attaque

Même si je reste dubitatif sur l'argument de la sécurité (puisque je n'ai pas réussi à trouver des CVE n'ayant impacté des Windows Server en Desktop Experience mais pas ceux en mode Core), il est vrai que moins il y a de composants, plus petite est la surface d'attaque.

Dans les faits, si on prend quelques CVE critiques des cinq dernières années, on constate que le mode Core n'aurait eu aucun impact sur l'exploitation des failles par un attaquant :

1. [CVE-2020-1472 (Zerologon)](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2020-1472) : a impacté les serveurs Core & Desktop Experience
2. [CVE-2021-34527 (PrintNightmare)](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-34527) : a impacté les serveurs Core & Desktop Experience
3. [CVE-2021-1675 (Print Spooler)](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2021-1675) : : a impacté les serveurs Core & Desktop Experience
4. [CVE-2022-26809 (vulnérabilité RPC)](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2022-26809) : a impacté les serveurs Core & Desktop Experience
5. [CVE-2024-49113 (LDAP Nightmare)](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2024-49113) : a impacté les serveurs Core & Desktop Experience
6. [CVE-2024-38124](https://msrc.microsoft.com/update-guide/vulnerability/CVE-2024-38124) : a impacté les serveurs Core & Desktop Experience

L'argument de la réduction de la surface d'attaque reste donc théorique à mon humble avis.

### Les vrais bénéfices du mode Core

Selon moi, le mode Core a surtout l'énorme avantage d'être un OS plus léger que le Desktop Experience. Cela implique donc :

- une consommation de ressources plus réduite (notamment sur la RAM), donc idéal pour des home-labs
- un temps de redémarrage plus rapide

L'absence d'interface graphique implique également qu'on a moins tendance à prendre la main directement sur le serveur et/ou à installer des rôles supplémentaires ou des logiciels tiers, ce qui est pour le coup un vrai gain de sécurité.

L'utilisation exclusive de PowerShell implique aussi l'automatisation et l'industrialisation du déploiement d'un nouveau contrôleur de domaine, ce qui permet de les remplacer plus rapidement pour mettre à jour le niveau fonctionnel de la forêt et du domaine par exemple.

## Configuration d'un DC en mode Core

### Configuration du serveur

Renommer l'ordinateur :

```powershell
Rename-Computer 'DC01'
```

Définition de la configuration IP :

```powershell
# Récupération des informations de la carte réseau
$adapter = Get-NetAdapter -Name "Ethernet"
$adapter | Remove-NetIPAddress -Confirm:$false
$adapter | Remove-NetRoute -Confirm:$false

# Définition de l'adresse IP
$params = @{
    IfIndex        = $adapter.ifIndex
    IPAddress      = "10.0.0.1"
    AddressFamily  = "IPv4"
    PrefixLength   = 16
    DefaultGateway = "10.0.0.2"
}
New-NetIPAddress @params
```

Définition des serveurs DNS :

```powershell
Set-DnsClientServerAddress -InterfaceIndex $adapter.ifIndex -ServerAddresses ("10.0.0.2","10.0.0.1")
```

> Note : on évite d'utiliser l'adresse de loopback 127.0.0.1 pour le serveur DNS d'un contrôleur de domaine. Plus d'informations ici : [Recommendations for Domain Name System (DNS) client settings - Windows Server \| Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/windows-server/networking/best-practices-for-dns-client-settings#domain-controller-with-dns-installed)

Vérification de la configuration réseau :

```powershell
Get-NetIPConfiguration -InterfaceIndex $adapter.ifIndex
```

Installation du rôle Active Directory Domain Services (ADDS) et redémarrage du serveur :

```powershell
Install-WindowsFeature -Name AD-Domain-Services -Restart
```

### Préparation du disque E:\

Si vous suivez les bonnes pratiques de l'ANSSI, il est important de mettre le dossier SYSVOL & NETLOGON sur une autre partition que celle occupée par le système (C:\). Voici donc un guide rapide pour créer une partition depuis un disque virtuel vierge. Pour la taille du disque, vous pouvez tabler sur 10 Go pour être tranquille dans la plupart des cas.

Dans mon exemple, j'utilise la lettre E:\ puisque la lettre D:\ est déjà utilisée par mon support d'installation.

Lister les disques :

```powershell
Get-Disk
```

Initialiser le disque :

```powershell
Initialize-Disk -Number 1
```

Créer la nouvelle partition sur le disque E:\ :

```powershell
New-Partition -DiskNumber 1 -UseMaximumSize -AssignDriveLetter
```

Formater la partition :

```powershell
Get-Partition -DriveLetter 'E' | Format-Volume -FileSystem NTFS -NewFileSystemLabel 'NTDS'
```

On peut vérifier la présence du nouveau disque avec la commande suivante :

```powershell
Get-PSDrive
```

### Installation de la nouvelle forêt

Informations de la forêt :

- Nom de domaine : corp.contoso.com
- Nom NetBIOS : CONTOSO
- Mot de passe DSRM : à vous de le définir

```powershell
Import-Module ADDSDeployment
$params = @{
    DomainName                    = 'corp.contoso.com'
    DomainNetbiosName             = 'CONTOSO'
    SafeModeAdministratorPassword = (Read-Host -Prompt "Enter the DSRM password" -AsSecureString)
    LogPath                       = 'E:\NTDS'
    DatabasePath                  = 'E:\NTDS'
    SysvolPath                    = 'E:\SYSVOL'
}
Install-ADDSForest @params
```

> Rappel : il est important de définir un mot de passe DSRM différent pour chaque contrôleur de domaine. plus d'informations disponibles ici :
>
> - [Le compte DSRM sur un contrôleur de domaine \| LaBouaBouate](https://www.labouabouate.fr/2025/02/24/compte-de-recuperation-rodc)
> - [Automatiser le changement du mot de passe DSRM \| LaBouaBouate](https://www.labouabouate.fr/2025/04/01/rotation-mdp-dsrm)

Le serveur devrait redémarrer après la création de la forêt.

### Configuration du deuxième DC

Pour le deuxième contrôleur de domaine, on va suivre les mêmes étapes que pour le premier contrôleur de domaine, en modifiant certaines valeurs :

- Le nom du serveur est DC02 (au lieu de DC01)
- L'adresse IP est 10.0.0.2 (au lieu de 10.0.0.1)
- Les adresses des serveurs DNS doivent être interchangées

Une fois que le rôle ADDS est installé et que le serveur a redémarré, vous pouvez le promouvoir en tant que contrôleur de domaine de votre nouvelle forêt :

```powershell
$splat = @{
    DomainName   = 'corp.contoso.com'
    Credential   = (Get-Credential -Message 'Enter domain admin credential')
    LogPath      = 'E:\NTDS'
    DatabasePath = 'E:\NTDS'
    SysvolPath   = 'E:\SYSVOL'
}
Install-ADDSDomainController @splat
```

Après redémarrage, vous pouvez vérifier le statut avec la commande `Get-ADDomainController -Filter *` pour vérifier que le DC02 apparait bien.

### Administration du domaine

Une fois vos deux contrôleurs de domaine montés et opérationnels, vous n'avez plus à y toucher ! La maintenance (mise à jour et redémarrage) peut se faire intégralement à distance depuis une station d'administration avec les outils RSAT et WinRM.

Voici la ligne de commande pour installer les outils RSAT liés à l'administration de Active Directory :

```powershell
$features = 'GPMC', 'RSAT-AD-Tools', 'RSAT-DNS-Server'
Install-WindowsFeature $features
```
