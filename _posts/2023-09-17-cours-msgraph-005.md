---
layout: post
title: "MSGRAPH #5 - Applications Azure"
description: "Découvrir le rôle et le fonctionnement d'une application Azure pour utiliser Microsoft Graph"
tableOfContent: "/2023/09/17/cours-msgraph-introduction#table-des-matières"
nextLink:
  name: "Partie 6"
  id: "/2023/09/17/cours-msgraph-006"
prevLink:
  name: "Partie 4"
  id: "/2023/09/17/cours-msgraph-004"
---

## Les applications Azure

Les applications Azure font partie intégrante de Microsoft Graph, puisqu'il est impossible de s'y connecter sans faire appel à l'une d'entre-elle. Que ce soit via Microsoft Graph Explorer ou les modules PowerShell, vous passiez déjà par une application sans le savoir.

Si vous en voulez la preuve, vous pouvez consulter la section "Applications d'entreprise" de votre console Entra ID. Vous devriez y retrouver *Graph Explorer* et *Microsoft Graph Command Line Tools* :

![toutes les applications de votre tenant](/assets/images/msgraph-501.png)

Vous pouvez d'ailleurs consulter les étendues autorisées pour chaque application en cliquant l'application, puis "Autorisations" dans la catégorie "Sécurité".

## Création d'une application

Pour faire de l'administration ponctuelle avec votre compte à privilège, il n'y a pas ou peu d'intérêt à passer par une autre application que celles du Graph Explorer ou des modules PowerShell. Cependant, créer votre propre application Azure peut vous permettre de déléguer des tâches d'administration ou mettre des scripts se connectant à Microsoft Graph en tâches planifiées.

Pour créer votre propre application, vous pouvez vous rendre sur https://portal.azure.com puis "Microsoft Entra ID" et choisir le menu "Inscriptions d'applications" et enfin sectionner "+ Nouvelle inscription".

![créer une nouvelle application Azure](/assets/images/msgraph-502.png)

Vous pouvez alors choisir le nom de votre application et qui peut l'utiliser. L'URI de redirection ne nous concerne pas pour notre usage. Une fois votre nouvelle application inscrite, vous devriez avoir accès aux informations de celle-ci, notamment l'ID du client et de l'ID de votre tenant (locataire). Ces deux identifiants vous permettrons de vous connecter à votre application en PowerShell.

![informations importantes de votre application](/assets/images/msgraph-503.png)

Vous pouvez en profiter pour ajouter un logo et une description sur votre application.

### Autorisations

Par défaut et comme toujours avec Microsoft Graph, vous aurez comme seule permission de lire votre profil utilisateur. Si vous voulez consulter vos autorisations actuelles ou en ajouter de nouvelles (comme *Group.Read.All* ou *Directory.Read.All*), vous pouvez le faire dans le menu "API autorisées".

Lorsque vous cliquer sur "+ Ajouter une autorisation", vous avez alors beaucoup de choix à votre disposition : Microsoft Graph, Dynamics CRM, Intune, Purview, OneNote, Power Automate, etc... Pour rester dans notre sujet, on va s'en tenir à "Microsoft Graph".

![toutes les permissions disponibles](/assets/images/msgraph-504.png)

#### Types d'autorisation

Il y a deux types de permissions différentes pour les API Microsoft Graph :

- **Les autorisation déléguées** : Votre application doit accéder à l'API en tant qu'utilisateur connecté. Par exemple : un script ou une Power App pour déléguer l'attribution de licences Microsoft 365 à l'équipe support.
- **Les autorisation d'application** : Votre application s'exécute en tant que service en arrière-plan ou démon sans utilisateur connecté. Par exemple : un script de reporting mis en tâche planifiée.

> Toutes les autorisations déléguées n'ont pas forcément leur pendant en autorisations d'applications et inversement.

Comme d'habitude, la plupart des autorisations nécessiterons une approbation de l'administrateur pour être opérationnelles.

### Connexion à une application

Il vous faudra vous munir de trois éléments pour pouvoir vous connecter à votre application Azure :

- **L'ID de l'application**, également appelé *ClientID*
- **L'ID du l'annuaire (locataire)**, également appelé *TenantID*
- **Un moyen de s'authentifier** :
  - avec votre compte si vous souhaitez accéder à des autorisations déléguées
  - avec un secret ou un certificat si vous souhaitez accéder à des autorisations d'application

Les deux premières informations sont disponibles facilement dans la section "Propriétés" de votre app Azure, et la troisière dépendera du type de permissions auquelles vous voulez accéder (déléguées ou application).

### Connexion en mode délégué

#### URI de redirection

Pour vous connecter en mode délégué sur une application, vous devrez d'abord ajouter une URI de redirection pour que l'utilisateur puisse être rediriger correctement vers votre script PowerShell.

Pour cela, il faut se rendre dans Entra ID > Inscription d'application > Votre application > Authentification et ajouter une plateforme

Cliquer sur "Applications de bureau et mobile" puis ajouter l'URI de redirection personnalisée : <http://localhost>

Cette URI de redirection nous permettra de revenir au script PowerShell une fois que l'authentification se sera faite dans le navigateur.

#### Connexion en PowerShell

Une fois l'application configurée, vous pouvez alors vous y connecter en PowerShell en indiquant :

1. `-ClientId` : ID d'application (client)
2. `-TenantId` : ID de l'annuaire (locataire)
3. `-Scopes` : le ou les autorisation(s) que vous voulez utiliser parmi celles disponibles sur l'application (facultatif)

```powershell
Connect-MgGraph -ClientId <application-ID> -TenantId <locataire-ID> -Scopes 'User.Read'
```

Une fois connecté, vous pouvez consulter les informations de connexion avec la commande `Get-MgContext`.

### Connexion en tant qu'application

La connexion en tant qu'application propose deux méthodes pour s'authentifier : soit par certificat, soit par un secret (mot de passe).

Microsoft recommande l'utilisation de certificats pour des questions de sécurité et de simplicité.

Vous pouvez utiliser plusieurs certificats et/ou plusieurs secrets en même temps, ce qui peut être utile lors de la période de renouvellement du certificat ou du secret en cours d'utilisation.

#### Connexion via certificat (recommandée)

Pour plus de détails, vous pouvez consulter directement la documentation officielle de Microsoft : [Create a self-signed public certificate to authenticate your application \| Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity-platform/howto-create-self-signed-certificate).

##### Création du certificat

Pour des questions d'accessibilité, nous allons utiliser des certificats auto-signés. Si vous avez accès à une autorité de certification (PKI), je vous recommande vivement de générer vos certificats via celle-ci.

Pour générer un certificat autosigné, vous pouvez utiliser la commande suivante :

```powershell
$certname = Read-Host -Prompt 'Nom du certificat'
$cert = New-SelfSignedCertificate -Subject "CN=$certname" -CertStoreLocation "Cert:\CurrentUser\My" -KeyExportPolicy Exportable -KeySpec Signature -KeyLength 2048 -KeyAlgorithm RSA -HashAlgorithm SHA256
```

Par défaut, les certificats auto-signés ont une période de validité d'un an. Si vous voulez repousser l'expiration, vous pouvez ajouter le paramètre `-NotAfter`. Exemple pour obtenir un certificat valide pendant 48 mois :

```powershell
-NotAfter (Get-Date).AddMonths(48)
```

##### Téléchargement du certificat dans Azure

Une fois votre certificat généré, vous devez maintenant exporter la clé publique à télécharger dans Azure :

```powershell
Export-Certificate -Cert $cert -FilePath "C:\temp\$certname.cer"
```

Vous n'avez plus qu'à déposer votre certificat sur Azure. Vous pouvez vous rendre dans la section "Certificats & secrets", dans l'onglet "Certificats" et enfin cliquer sur "↑ Télécharger le certificat".

Azure supporte les certificats du type .CER, .PEM et .CRT.

##### Utilisation du certificat pour la connexion

Une fois le certificat téléchargé dans Azure, vous pouvez vous connecter à votre application en spécifiant l'ID d'application, l'ID de l'annuaire et l'empreinte numérique de votre certificat :

```powershell
$params = @{
    ClientId = '10a52256-36f0-4bb7-973d-************'
    TenantId = '0649f7a2-affe-49fa-8a7e-************'
    CertificateThumbprint = 'DBA124203B11CD54F03DBCE272574FF287A3ADDB'
}
Connect-MgGraph @params
```

Vous devriez maintenant être connecté à votre application. Vous pouvez vérifier les informations de connexion avec la commande `Get-MgContext`.

#### Connexion via secret

Pour créer un secret, vous pouvez vous rendre dans la section "Certificats & secrets" puis cliquer sur "+ Nouveau secret client" dans l'onglet "Secrets client".

Le secret est une chaine de 40 caractères généré automatiquement avec des lettres minuscules, majuscules, chiffres et caractères spéciaux comme `cqG8Q~bAkFf.qPZOfR~XLuIWIP6Zn4PvTJclxar6` par exemple.

La durée de vie maximale d'un secret est de 730 jours soit environ deux ans.

##### Sécurisation du secret

Pour des raisons de sécurité évidentes, le secret ne doit pas être conservé en texte clair dans un script ou dans un fichier TXT.

Pour sécuriser le mot de passe, je vous propose donc de le transformer en un hash et de stocker ce hash dans un fichier TXT :

```powershell
Read-Host -Prompt 'Entrer le secret' -AsSecureString |
    ConvertFrom-SecureString |
    Set-Content -Path 'C:\temp\secret.txt'
```

Votre fichier "secret.txt" devrait ressembler à ça :

<blockquote style="overflow-wrap: break-word;">
  <p>01000000d08c9ddf0115d1118c7a00c04fc297eb0100000095e99a1b60201a4db16911633fed29810000000002000000000003660000c000000010000000c2c7024dc2f0cbad69f5d305f752a91d0000000004800000a0000000100000001244c77406a80e93137f7d241e08525a10000000f8eaeca8a324cbb2c978146c7ef131ea14000000b7d3a8e0997d88fb47de646028570511952c3163</p>
</blockquote>

Ce hash n'est déchiffrable que par le compte utilisateur et uniquement depuis l'ordinateur qui a généré ce fichier.

##### Récupération d'un token

Impossible de se connecter avec un secret en utilisant uniquement le module Microsoft Graph. Il va donc falloir installer le module "Microsoft Authentication Library for PowerShell" ou dans sa version courte : `MSAL.PS`.

```powershell
Install-Module 'MSAL.PS'
```

Ce module nous permet d'avoir accès à la commande `Get-MsalToken` qui nous permet d'obtenir un "Access token". Cet "Access token" pourra ensuite servir à la connexion à Microsoft Graph en utilisant la commande `Connect-MgGraph`.

```powershell
$params = @{
    ClientId = '10a52256-36f0-4bb7-973d-************'
    TenantId = '0649f7a2-affe-49fa-8a7e-************'
    ClientSecret = Get-Content -Path 'C:\temp\secret.txt' | ConvertTo-SecureString
}
$token = Get-MsalToken @params
Connect-MgGraph -AccessToken $token.AccessToken
```

Vous devriez maintenant être connecté à votre application. Vous pouvez vérifier les informations de connexion avec la commande `Get-MgContext`.
