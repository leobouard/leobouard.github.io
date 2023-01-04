---
layout: post
title: "Impossible de contacter un utilisateur externe sur Teams"
description: "L'utilisateur ne peut plus contacter des comptes externes à l'organisation"
tag: TEAMS
icon: 🤔
listed: true
---

## Symptôme

L'utilisateur concerné ne peut plus contacter des comptes externes à l'organisation : **l'option pour rechercher en externe n'est plus disponible** dans la barre de recherche de Microsoft Teams. Aucun contournement possible, le problème est le même qu'il utilise l'application Windows, la version web ou mobile : il s'agit donc probablement d'un souci sur la configuration du compte.

![L'option "Rechercher *** en externe" dans la barre de recherche de Microsoft Teams](/assets/images/option-rechercher-en-externe-teams.png)

<div style="text-align: center;">
    <p><i>Avec un compte utilisateur touché par le problème, l'option "Rechercher <strong>leo@labouabouate.fr</strong> en externe" ne serait pas disponible.</i></p>
</div>

<div class="information">
    <h4>A vérifier avant de continuer</h4>
    <p>Évidemment, pensez à vérifier que votre organisation autorise bien les utilisateurs à communiquer avec des comptes externes. Vous pouvez vérifier ce paramètre dans <a href="https://admin.teams.microsoft.com/company-wide-settings/external-communications">Microsoft Teams admin center - Users - External access</a></p>
</div>

Comme le problème vient probablement de la configuration du compte, on vérifie l'état de celui-ci en PowerShell avec le module `MicrosoftTeams` :

```powershell
Install-Module MicrosoftTeams
Connect-MicrosoftTeams
(Get-CsOnlineUser -Identity 'leo@labouabouate.fr').UserValidationErrors
```

La commande `Get-CsOnlineUser` retourne alors le résultat suivant : *CannotGenerateSipAddress: SipAddress format is invalid*. Il y a donc un problème sur l'adresse SIP.

## Résolution

Suivant votre architecture Exchange, il faut vous rendre dans Active Directory (attribut `proxyAddresses`) ou Exchange Online pour modifier ou ajouter une adresse SIP primaire au compte utilisateur en question :

Attribut `proxyAddresses` dans Active Directory :

- **SIP:leo@labouabouate.fr**
- SMTP:leo@labouabouate.fr
- smtp:leo@labouabouate.mail.onmicrosoft.com

Configuration Exchange :

Type | Address
---- | -------
**SIP** | **leo@labouabouate.fr**
SMTP | leo@labouabouate.fr
smtp | leo@labouaobuate.mail.onmicrosoft.com

Lien vers la documentation Microsoft pour ajouter une adresse SIP : [Add a SIP address: Exchange Server Help \| Microsoft Learn](https://learn.microsoft.com/en-us/exchange/add-sip-address-exchange-2013-help)

Dans mon exemple, le problème a été causé par un changement de nom d'utilisateur (userPrincipalName) dans l'Active Directory et d'adresse SMTP principale. Après le changement, l'adresse SIP côté Exchange Online avait disparue et n'a pas été régénérée  automatiquement.
