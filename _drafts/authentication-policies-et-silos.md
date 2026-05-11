---
title: "Authentication Policies & Silos"
description: "Le tutoriel le plus simple possible pour apprivoiser cette fonctionnalité de Active Directory"
tags: activedirectory

---

## Concept

Après de nombreuses tentatives échouées de prendre le sujet en main et de monter un lab, j'ai enfin trouvé une source simple et concise : [How to implement Auth Policy and Silos : r/activedirectory](https://www.reddit.com/r/activedirectory/comments/12h3fua/how_to_implement_auth_policy_and_silos/)

Déjà le terme de Authentication Policy et Authentication Policy Silos est un peu abstrait. On pourrait parler d'un **pare-feu d'authentification** (la partie *policy*) qui s'applique à un **regroupement de machine** (la partie *silo*). On défini donc des règles dans le pare-feu (qui peut se connecter, quelle est la durée de vie maximum d'un ticket Kerberos, est-ce que l'usage du NTLM est autorisé) que l'on appliquera ensuite à un ensemble d'ordinateurs.

> Note : le silo est optionnel, et il est tout à faire possible de faire sans. Comme cet article vise à faire un tutoriel au plus simple, on va ignorer la configuration sans silo.

Si vous êtes familier du concept de tiering-model, vous comprendrez qu'on a simplement à ajouter nos utilisateurs du TIER 0 dans la *policy* et nos serveurs TIER 0 dans le *silo* pour empêcher n'importe quel compte en dehors du TIER 0 de s'y connecter.

### Avantages

Les avantages par rapport au tiering par GPO :

- **Le fonctionnement en positif** : contrairement aux GPO qui fonctionnent en négatif (interdiction de l'accès aux utilisateurs des autres tiers), le pare-feu d'authentification autorise explicitement une sélection d'utilisateurs tout en refusant tous les autres, ce qui empêche les comptes non catégorisés dans un tier de pouvoir se connecter aux ressources
- **Le découpage à l'intérieur d'un tier** : avec les silos, on peut faire des "bulles applicatives" isolées au sein d'un même tier
- **Plus de contrôle sur l'authentification** : vous pouvez contrôler la durée de vie du ticket Kerberos, l'usage du NTLM au sein d'un silo sans avoir a ajouter tous les utilisateurs dans le groupe *Protected Users*.
- **L'application d'un tier est quasi instantanée** : pas besoin d'attendre que la GPO s'applique, le blocage est effectif dès que le contrôleur de domaine a répliqué le changement sur les AuthNPolicy & AuthNPolicySilo

### Inconvénients

Les inconvénients par rapport au tiering par GPO :

- **Incompatibilité avec NTLM** : malgré une option pour autoriser le l'authentification en NTLM, il semblerait que seul le Kerberos fonctionne réellement pour s'authentifier
- **Incompatibilité avec certaines versions de Windows** : les AuthNPolicy reposent sur Kerberos FAST, qui n'est disponible qu'à partir de Windows 8 & Windows Server 2012
- **Risque accru de blocage** : un problème de configuration d'une AuthNPolicy peut mener à bloquer intégralement l'accès à certains serveurs
- **Ne s'applique pas aux contrôleurs de domaine** : appliquer une AuthNPolicy sur les contrôleurs de domaine pourrait bloquer les authentifications de la plupart des utilisateurs du domaine

> Je n'ai pas encore eu le temps de tester la partie "Inconvénients", donc je ne fait que relater des points qui m'ont été remontés par des collègues ou dans d'autres articles.

## Procédure

### Contexte

On va essayer de répliquer une configuration de tiering en utilisant exclusivement les AuthNPolicy & AuthNPolicySilo. Présentation des personnages principaux :

1. Le groupe *Allowed to authenticate to T1* qui va autoriser ses membres à se connecter aux serveurs du TIER 1
2. L'utilisateur *t1_lbouard* qui représente un administrateur TIER 1
3. Le serveur *SRV01* qui représente un serveur du TIER 1
4. L'utilisateur *t2_lbouard* qui représente un administrateur TIER 2
5. Le serveur *SRV02* qui représente un serveur du TIER 2

L'objectif va donc être de restreindre l'accès au serveur SRV01 uniquement aux utilisateurs du TIER 1. Si un compte TIER 0 (membre du groupe Domain Admins) tente de s'y connecter, la connexion sera refusée même si le compte TIER 0 a les droits nécessaires.

### Ajout du support pour le Kerberos Armoring

Activation par GPO :

- Pour les clients : Kerberos client support for claims, compound authentication and kerberos armoring
- Pour les contrôleurs de domaine : KDC Support for claims, compound authentication and kerberos armoring

### Création du groupe de ciblage

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

Ajout de mon compte administrateur T1 dans le nouveau groupe :

```powershell
Add-ADGroupMember 'Allowed to authenticate to T1' -Members 't1_lbouard'
```

### Création des règles du pare-feu d'authentification

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

Le SDDL peut être créé à partir de la commande `Show-ADAuthenticationPolicyExpression`. Plus d'informations sur la commande ici : [Show-ADAuthenticationPolicyExpression (ActiveDirectory) \| Microsoft Learn](https://learn.microsoft.com/en-us/powershell/module/activedirectory/show-adauthenticationpolicyexpression?view=windowsserver2025-ps)

### Création du silo

Création du silo qui va être soumis au pare-feu d'authentification que l'on a créé précédemment :

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

Ici encore une fois on vise la configuration la plus simple possible : on applique les mêmes règles pour les authentifications d'ordinateurs, d'utilisateurs ou de comptes de service.

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

> D'après mes tests, le compte administrateur par défaut (avec le SID 500) n'est pas affecté par les AuthNPolicy. Il pourra donc servir de compte brise glace sur tous les ordinateurs / serveurs du domaine (qu'importe le silo d'authentification).

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

> Si l'ajout dans un silo se fait en deux étapes, deux étapes sont également nécessaires pour le retrait.

## Questions supplémentaires

### Double attribution

Que se passe-t'il si jamais un serveur est affecté dans deux silos différents (exemple : "T1 Silo" et "T2 Silo") ?

J'ai testé pour vous, et si mon hypothèse initiale était que le serveur allait bloquer les connexions pour les utilisateurs du TIER 1 & 2 : ce n'est pas le cas ! En fait l'attribut qui prime sur quel AuthNPolicy va être appliquée est `msDS-AssignedAuthNPolicySilo`, qui ne peut contenir qu'une seule valeur.

Donc pour répondre, à la question : un ordinateur ne peut techniquement pas être dans deux silos en même temps. On peut consulter celui qui est utilisé avec la commande suivante :

```powershell
Get-ADComputer SRV01 -Properties AuthenticationPolicySilo
```

### Intérêt de la cohabitation avec les GPO User Rights Assignment

Dans ses [recommandations relatives à l'administration sécurisée des systèmes d'information reposant sur Microsoft Active Directory](https://messervices.cyber.gouv.fr/guides/recommandations-pour-ladministration-securisee-des-si-reposant-sur-ad), l'ANSSI conseille le déploiement conjoint des AuthNPolicy et des GPO de restriction de connexion classiques (qui utilise les *User Rights Assignment*), sans détailler la raison de se design. Et visiblement je ne suis pas le seul à ne pas savoir pourquoi :

<iframe width="560" height="315" src="https://www.youtube.com/embed/eQ0VSHYFEik?si=zlMz0kF9F6uskJMG&amp;start=1941" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; web-share" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>

Après avoir creusé un peu, je pense que la raison principale de déployer AuthNPolicy + GPO est pour réduire l'administration quotidienne. L'ajout systématique dans un silo pour les ordinateurs personnels me paraît peu crédible sur la durée, et la GPO sert de filet de sécurité pour appliquer une restriction de connexion dès qu'un objet ordinateur est déplacé dans une unité d'organisation du TIER (dans le cas d'un oubli).

Comme le fonctionnement des deux méthodes est différent, elles restent complémentaires :

- L'AuthNPolicy vient autoriser uniquement une sélection d'utilisateurs à se connecter sur des ordinateurs du silo, mais n'empêche pas ceux-ci de se connecter ailleurs
- La GPO *User Rights Assignment* permet d'interdire la connexion des utilisateurs sur les ordinateurs en dehors du silo

Pour plus d'informations sur les GPO de limitation de connexion, vous pouvez consulter [mon article sur le sujet](/2024/11/01/tiering-model-005).

### Automatisation de l'ajout dans le silo

C'est cadeau, je n'ai pas pu le tester de manière extensive mais voici un bout de code qui permet d'ajouter automatiquement tous les serveurs TIER 1 dans le silo du TIER 1 :

```powershell
$sb = 'OU=Servers,OU=T1,DC=corp,DC=contoso,DC=com'
$computers = Get-ADComputer -Filter * -SearchBase $sb -Properties 'msDS-AssignedAuthNPolicySilo'
$silo = Get-ADAuthenticationPolicySilo 'T1 Silo' -Properties 'msDS-AuthNPolicySiloMembers'

$computers | Where-Object { $_.'msDS-AssignedAuthNPolicySilo' -ne $silo.DistinguishedName } |
ForEach-Object {
    Write-Host "Processing $($_.Name)"
    Set-ADAuthenticationPolicySilo $silo -Add @{ 'msDS-AuthNPolicySiloMembers' = $_.DistinguishedName }
    Set-ADAccountAuthenticationPolicySilo $_.SamAccountName -AuthenticationPolicySilo $silo
}
```

Et comme je suis très gentil, voici de quoi mettre en place les délégations de contrôle qui permettrons d'exécuter le script avec un compte dédié (`svc_authnpolicysilo`) en utilisant le principe du moindre privilège.

> Pour des raisons de simplicité je donne les droits directement sur le compte de service, mais la bonne pratique est de donner les droits sur des groupes dédiés, pour rendre les permissions explicites.

Ajout du droit d'écriture de l'attribut `msDS-AssignedAuthNPolicySilo` sur les objets ordinateurs sous "OU=Servers,OU=T1,DC=corp,DC=contoso,DC=com" :

```powershell
dsacls "OU=Servers,OU=T1,DC=corp,DC=contoso,DC=com" /G "CORP\svc_authnpolicysilo:WP;msDS-AssignedAuthNPolicySilo;computer" /I:S
```

Ajout du droit d'écriture de l'attribut `msDS-AuthNPolicySiloMembers` sur les objets silos  sous "CN=AuthN Silos,CN=AuthN Policy Configuration,CN=Services,CN=Configuration,DC=corp,DC=contoso,DC=com" :

```powershell
dsacls "CN=AuthN Silos,CN=AuthN Policy Configuration,CN=Services,CN=Configuration,DC=corp,DC=contoso,DC=com" /G "CORP\svc_authnpolicysilo:WP;sDS-AuthNPolicySiloMembers;msDS-AuthNPolicySilo" /I:S
```
