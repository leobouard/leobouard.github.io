---
title: "Authentication Policies & Silos"
description: "Est-ce que sa complexité vaut vraiment le coup ?"
tags: activedirectory
listed: true
---

<!--

## Contexte

Lors ce que l'on doit mettre en place un modèle en tiers dans l'Active Directory, on a le choix entre deux options pour segmenter les différents niveaux d'administration :

1. **Utiliser des GPO** : avec les configurations *User Rights Assignment*, on peut facilement interdire l'accès à certaines machines à des groupes Active Directory (*Deny log on ...*). C'est assez facile à comprendre, la grande majorité des administrateurs systèmes sont familiers avec la technologie et si votre arborescence Active Directory est bonne ; la mise en place sera relativement rapide.
2. **Utiliser les Authentication Policies & Authentication Policy Silos** : recommandée par Microsoft pour obtenir un niveau de sécurité plus élevé, c'est une fonctionnalité ajoutée assez tardivement dans la vie de l'Active Directory (le niveau fonctionnel nécessaire est 2012 R2). La plupart des administrateurs systèmes n'en ont jamais entendu parler ou ne connaissent pas bien la technologie (c'est mon cas) et il y a assez peu de ressources pour comprendre et mettre en place ce système.

## Définition

Alors ces Authentication Policies & Authentication Policy Silos, qu'est-ce que c'est au juste ?

Déjà on peut noter que les deux vont de paire : les authentication policies définissent les règles liées à l'authentification (protocoles utilisés, durée de vie de la session, etc...) et les silos vont appliquer ces règles sur des membres (compte de service, utilisateur ou ordinateur).\
On parle donc bien d'une seule et même technologie, qui se décompose en deux éléments distincts.

## Fonctionnement

### Authentication Policies

### Authentication Policy Silos

### Différences avec les Group Object Policies

Du point de vue de la sécurité, la différence la plus importante se situe au niveau du blocage : dans le cadre d'une segmentation par GPO, le blocage intervient après la validation de l'authentification (l'authentification a donc été testée et réussie, puis interdite). En utilisant les Authentication Policies & Silos, le blocage intervient **avant** l'authentification (et donc ne teste même pas le combo nom d'utilisateur et mot de passe et n'envoie aucune requête sensible).

## Mise en place

### Prérequis

## Liens utiles et documentation

- [L'administration en silo (sstic.org)](https://www.sstic.org/media/SSTIC2017/SSTIC-actes/administration_en_silo/SSTIC2017-Article-administration_en_silo-bordes.pdf)
- [Authentication Policies and Authentication Policy Silos (learn.microsoft.com)](https://learn.microsoft.com/en-us/windows-server/security/credentials-protection-and-management/authentication-policies-and-authentication-policy-silos)
- [NTLM authentication: What it is and why you should avoid using it (blog.quest.com)](https://blog.quest.com/ntlm-authentication-what-it-is-and-why-you-should-avoid-using-it/)
- [Kerberos Explained in a Little Too Much Detail (syfuhs.net)](https://syfuhs.net/a-bit-about-kerberos)

Source principale :

- [How to implement Auth Policy and Silos : r/activedirectory](https://www.reddit.com/r/activedirectory/comments/12h3fua/how_to_implement_auth_policy_and_silos/)

-->

Déjà le terme de Authentication Policy et Authentication Policy Silos est un peu abstrait. En réel, il s'agit d'un pare-feu d'authentification (la partie policy) qui s'applique à un regroupement de machine (la partie silo). On défini donc des règles dans le pare-feu (qui peut se connecter, quelle est la durée de vie maximum d'un ticket Kerberos, est-ce que l'usage du NTLM est autorisé) que l'on appliquera ensuite à une ensemble d'ordinateurs.

Si vous êtes familier du concept de tiering-model, vous comprendrez qu'on a simplement à ajouter nos utilisateurs du Tier 0 dans la policy et nos serveurs T0 dans le silo pour empêcher n'importe quel compte en dehors du Tier 0 de s'y connecter.

L'avantage par rapport au tiering par GPO :

- Le refus de connexion par GPO se fait une fois que l'utilisateur s'est authentifié, donc après le challenge. Un attaquant peut donc tester la validité des identifiants d'un compte malgré le blocage de connexion
- **Le fonctionnement en positif** : contrairement aux GPO qui fonctionnent en négatif (interdiction de l'accès aux utilisateurs des autres tiers sans explicitement autoriser les utilisateurs du "bon" tier), le pare-feu d'authentification autorise explicitement une sélection d'utilisateurs tout en refusant tous les autres, ce qui empêche les comptes non catégorisés dans un tier de pouvoir se connecter aux ressources
- **Le découpage à l'intérieur d'un tier** : avec les silos, on peut faire des "bulles applicatives" isolées au sein d'un même tier.
- **Plus de contrôle sur l'authentification** : vous pouvez contrôler 
- **L'application d'un tier est quasi instantané**

## Procédure

### Contexte

On va essayer de répliquer une configuration de tiering en utilisant exclusivement les AuthNPolicy & AuthNPolicySilo. Présentation des personnages principaux :

1. Le groupe *Allowed to authenticate to T1* qui va autoriser ses membres à se connecter aux serveurs du T1
2. L'utilisateur *t1_lbouard* qui représente un administrateur T1
3. Le serveur *SRV01* qui représente un serveur du T1

L'objectif va donc être de restreindre l'accès au serveur SRV01 uniquement aux utilisateurs du T1 (s)

### Ajout du support pour le Kerberos Armoring

Activation par GPO :

- Pour les clients : Kerberos client support for claims, compound authentication and kerberos armoring
- Pour les contrôleurs de domaine : KDC Support for claims, compound authentication and kerberos armoring

### Création des groupes de ciblage

Création d'un groupe "Allowed to authenticate to T0" pour regrouper tous les comptes qui auront l'autorisation de se connecter sur des serveurs du T0.

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
- `-ComputerAllowedToAuthenticateTo` pour indiquer que seul les membres du groupe *Allowed to authenticate to T1* sont autorisés à se connecter

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

> Pourquoi est-ce qu'il y a deux étapes ? J'en ai aucune foutue idée, mais les deux étapes sont nécessaires pour que le blocage soit effectif. Si le serveur n'est pas membre du silo (attribut `msDS-AuthNPolicySiloMembersBL`) et est exposé au pare-feu d'authentification (attribut `msDS-AssignedAuthNPolicySilo`), le blocage des comptes non-autorisé n'est pas effectif.

A partir de maintenant, seul un membre du groupe "" pourra s'authentifier depuis l'ordinateur "SRV01". Si un utilisateur ne faisant pas partie de se groupe essaye de se connecter, il tombera sur l'erreur suivante : **The computer you are signing into is protected by an authentication firewall. The specified account is not allowed to authenticate to the computer.**

### Sortir un serveur d'un silo

```powershell
Set-ADComputer SRV01 -Clear 'msDS-AssignedAuthNPolicySilo', 'msDS-AuthNPolicySiloMembersBL'
```