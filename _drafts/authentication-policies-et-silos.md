---
title: "Authentication Policies & Silos"
description: "Est-ce que sa complexité vaut vraiment le coup ?"
tags: active-directory
listed: true
---

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
