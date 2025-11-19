---
title: "Authentication Policies & Silos"
description: "Est-ce que sa complexité vaut vraiment le coup ?"
tags: activedirectory
listed: true
---

## Concept

Après de nombreuses tentatives échouées de prendre le sujet en main et de monter un lab, j'ai enfin trouvé une source simple et consise : [How to implement Auth Policy and Silos : r/activedirectory](https://www.reddit.com/r/activedirectory/comments/12h3fua/how_to_implement_auth_policy_and_silos/)

Déjà le terme de Authentication Policy et Authentication Policy Silos est un peu abstrait. En réel, il s'agit d'un pare-feu d'authentification (la partie *policy*) qui s'applique à un regroupement de machine (la partie *silo*). On défini donc des règles dans le pare-feu (qui peut se connecter, quelle est la durée de vie maximum d'un ticket Kerberos, est-ce que l'usage du NTLM est autorisé) que l'on appliquera ensuite à un ensemble d'ordinateurs.

Si vous êtes familier du concept de tiering-model, vous comprendrez qu'on a simplement à ajouter nos utilisateurs du T0 dans la policy et nos serveurs T0 dans le silo pour empêcher n'importe quel compte en dehors du T0 de s'y connecter.

L'avantage par rapport au tiering par GPO :

- **Le fonctionnement en positif** : contrairement aux GPO qui fonctionnent en négatif (interdiction de l'accès aux utilisateurs des autres tiers), le pare-feu d'authentification autorise explicitement une sélection d'utilisateurs tout en refusant tous les autres, ce qui empêche les comptes non catégorisés dans un tier de pouvoir se connecter aux ressources
- **Le découpage à l'intérieur d'un tier** : avec les silos, on peut faire des "bulles applicatives" isolées au sein d'un même tier
- **Plus de contrôle sur l'authentification** : vous pouvez contrôler la durée de vie du ticket Kerberos, l'usage du NTLM au sein d'un silo
- **L'application d'un tier est quasi instantanée** : pas besoin d'attendre que la GPO s'applique, le blocage est effectif dès que le contrôleur de domaine connait la plus

## Procédure

### Contexte

On va essayer de répliquer une configuration de tiering en utilisant exclusivement les AuthNPolicy & AuthNPolicySilo. Présentation des personnages principaux :

1. Le groupe *Allowed to authenticate to T1* qui va autoriser ses membres à se connecter aux serveurs du T1
2. L'utilisateur *t1_lbouard* qui représente un administrateur T1
3. Le serveur *SRV01* qui représente un serveur du T1

L'objectif va donc être de restreindre l'accès au serveur SRV01 uniquement aux utilisateurs du T1. Si un compte T0 (membre du groupe Domain Admins) tente de s'y connecter, la connexion sera refusée même si le compte T0 a les droits nécessaires.

### Ajout du support pour le Kerberos Armoring

Activation par GPO :

- Pour les clients : Kerberos client support for claims, compound authentication and kerberos armoring
- Pour les contrôleurs de domaine : KDC Support for claims, compound authentication and kerberos armoring

### Création des groupes de ciblage

Création d'un groupe "Allowed to authenticate to T1" pour regrouper tous les comptes qui auront l'autorisation de se connecter sur des serveurs du T1.

```powershell
$splat = @{
    Name          = 'Allowed to authenticate to T1'
    Path          = 'OU=Groups,OU=T1,DC=corp,DC=contoso,DC=com'
    Description   = 'Members of this group are allowed to access to T1 computers through the authentication firewall'
    GroupCategory = 'Security'
    GroupScope    = 'DomainLocal'
}
New-ADGroup @splat
```

### Création des règles du pare-feu d'authentification pour le T1

Création des règles du pare-feu avec le moins de paramètres possibles :

```powershell
$groupSid = (Get-ADGroup 'Allowed to authenticate to T1').SID.Value
$sddl = "O:SYG:SYD:(XA;OICI;CR;;;WD;(Member_of_any{SID($groupSID)}))"
$splat = @{
    Name                            = 'T1 Authentication Policy'
    Enforce                         = $true
    ComputerAllowedToAuthenticateTo = $sddl
}

New-ADAuthenticationPolicy @splat
```

Les paramètres invoqués ont la fonction suivante :

- `-Name` pour nommer l'objet "Authentication Policy"
- `-Enforce` pour indiquer que celle-ci doit être activée
- `-ComputerAllowedToAuthenticateTo` pour indiquer que seuls les membres du groupe *Allowed to authenticate to T1* sont autorisés à se connecter (via le SDDL)

### Création du silo

Création du silo qui va être soumis au pare-feu d'authentification que l'on a créé précédemment.

```powershell
$authNpolicy = Get-ADAuthenticationPolicy 'T1 Authentication Policy'
$splat = @{
    Name                         = 'T1 Silo'
    Enforce                      = $true
    ComputerAuthenticationPolicy = $authNpolicy
    ServiceAuthenticationPolicy  = $authNpolicy
    UserAuthenticationPolicy     = $authNpolicy
}
New-ADAuthenticationPolicySilo @splat
```

### Intégration des serveurs dans le silo

Ajouter le serveur SRV01 en tant que membre du silo :

```powershell
$computerDn = (Get-ADComputer SRV01).DistinguishedName
Set-ADAuthenticationPolicySilo 'T1 Silo' -Add @{ 'msDS-AuthNPolicySiloMembers' = $computerDn }
```

Affecter le silo au serveur SRV01, ce qui permet d'exposer le serveur au pare-feu d'authentification :

```powershell
Set-ADAccountAuthenticationPolicySilo 'SRV01$' -AuthenticationPolicySilo 'T1 Silo'
```

> Pourquoi est-ce qu'il y a deux étapes ? J'en ai aucune foutue idée, mais les deux étapes sont nécessaires pour que le blocage soit effectif. Si le serveur n'est pas membre du silo (attribut `msDS-AuthNPolicySiloMembersBL`), même si celui-ci est exposé au pare-feu d'authentification (attribut `msDS-AssignedAuthNPolicySilo`), le blocage des comptes non-autorisés n'est pas effectif.

À partir de maintenant, seul un membre du groupe *Allowed to authenticate to T1* pourra s'authentifier sur l'ordinateur "SRV01". Si un utilisateur ne faisant pas partie de ce groupe essaye de se connecter, il tombera sur l'erreur suivante : **The computer you are signing into is protected by an authentication firewall. The specified account is not allowed to authenticate to the computer.**

### Sortir un serveur d'un silo

Retirer le serveur SRV01 du silo :

```powershell
$computerDn = (Get-ADComputer SRV01).DistinguishedName
Set-ADAuthenticationPolicySilo 'T1 Silo' -Remove @{ 'msDS-AuthNPolicySiloMembers' = $computerDn }
```

Ne plus exposer le serveur SRV01 du pare-feu d'authentification :

```powershell
Set-ADComputer SRV01 -Clear 'msDS-AssignedAuthNPolicySilo'
```
