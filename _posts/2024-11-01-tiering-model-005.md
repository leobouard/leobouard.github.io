---
title: "TIERING #5 - Limiter les connexions"
description: "Empêcher les connexions d'un compte vers un serveur d'un autre niveau"
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 6"
  id: "/2024/11/01/tiering-model-006"
prevLink:
  name: "Partie 4"
  id: "/2024/11/01/tiering-model-004"
---

## Blocage via GPO

Dans l'une des étapes préalables, nous avons créé des groupes pour pouvoir catégoriser les utilisateurs dans un niveau spécifique. Dans mon exemple, les groupes portaient le nom suivant :

- Utilisateurs du TIER0
- Utilisateurs du TIER1
- Utilisateurs du TIER2

Ces groupes vont nous permettre d'empêcher les utilisateurs du TIER0 de pouvoir se connecter sur une ressource d'un autre niveau (même si ceux-ci ont les permissions nécessaires).

Voici un article de Daniel Metzger de Microsoft sur le sujet : [Initially Isolate Tier 0 Assets with Group Policy to Start Administrative Tiering \| Microsoft Community Hub](https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/initially-isolate-tier-0-assets-with-group-policy-to-start-administrative-tierin/1184934)

Pour cela, on utilise les paramètres d'attribution des droits utilisateurs (*User Rights Assignments*). Ces paramètres vont agir en négatif : à aucun moment on autorise explicitement les utilisateurs du TIER1 à pouvoir se connecter aux ressources du TIER1. À la place, on va plutôt interdire l'accès au TIER1 à tous les utilisateurs du TIER0 et du TIER2.

### Création des GPO

Il va falloir créer au moins quatre GPO pour empêcher les connexions :

- **Accès TIER0** : interdiction de connexion des TIER1 & TIER2
- **Accès TIER1** : interdiction de connexion des TIER0 & TIER2
- **Accès TIER2** : interdiction de connexion des TIER0 & TIER1
- **Isolation TIERING** : interdiction de connexion des TIER0, TIER1 & TIER2

> On peut ajouter une cinquième GPO qui va interdire la connexion des anciens comptes administrateurs (*legacy*) sur des ressources qui auront été migrées vers le tiering model.

### Définition des paramètres

Pour chaque GPO, se rendre au chemin suivant : **Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateurs** et activer les quatre paramètres suivants :

- Interdire l'accès à cet ordinateur à partir du réseau (*WinRM, partage de fichiers, MMC à distance*)
- Interdire l'ouverture d'une session locale
- Interdire l'ouverture de session en tant que service
- Interdire l'ouverture de session en tant que tâche (*tâche planifiée*)
- Interdire l'ouverture de session par les services Bureau à distance

Pour se rendre compte des impacts de chaque paramètre, vous pouvez consulter ce lien : [Informations de référence sur les outils d’administration et les types d’ouverture de session - Windows Server \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/securing-privileged-access/reference-tools-logon-types).

Ces paramètres doivent ensuite être remplis avec tous les groupes d'utilisateurs autres que ceux du niveau en question. Exemple avec la GPO d'accès au TIER1 :

Stratégie | Paramètres de stratégie
--------- | -----------------------
Session locale | CONTOSO\Utilisateurs du TIER0, CONTOSO\Utilisateurs du TIER2
Session en tant que service | CONTOSO\Utilisateurs du TIER0, CONTOSO\Utilisateurs du TIER2
Session en tant que tâche | CONTOSO\Utilisateurs du TIER0, CONTOSO\Utilisateurs du TIER2
Session par les services Bureau à distance | CONTOSO\Utilisateurs du TIER0, CONTOSO\Utilisateurs du TIER2

> #### Pourquoi ne pas interdire l'accès à partir du réseau ?
>
> L'accès à un ordinateur depuis le réseau est très utilisé dans un environnement Active Directory, pour l'administation distante via les consoles MMC, pour l'authentification vers les contrôleurs de domaine ou l'accès au partage de fichiers par exemple. Dans la plupart des cas, ce genre de connexion ne laisse pas d'empreinte utilisable par un attaquant sur la machine distante. Le seul contre-exemple est la connexion WinRM avec CredSSP.
>
> Voici le document complet de l'ANSSI pour savoir quelle connexion laisse un secret réutilisable sur la machine distance : [anssi-guide-admin_securisee_si_ad_v1-0 (3).pdf](https://cyber.gouv.fr/sites/default/files/document/anssi-guide-admin_securisee_si_ad_v1-0%20%283%29.pdf) (page 84 et 85, partie "4.6 Risques de dissémination en fonction de la méthode de connexion").
>
> Pour désactiver l'utilisation de CredSSP avec WinRM, vous pouvez utiliser le paramètre GPO suivant : *Configuration ordinateur > Stratégies > Paramètres Windows > Modèles d'administration > Composants Windows > Gestion à distance de Windows (WinRM) > Service WinRM > Autoriser l'authentification CredSSP*.

### Application des GPO

Cette partie est simple comme bonjour, mais si les GPO sont mal appliquées vous pouvez impacter lourdement la production (comme toute GPO mal déployée).

Il suffit d'ajouter un lien GPO (*GPLink*) sur chaque unité d'organisation positionnée à la racine du domaine pour la catégoriser comme TIER0, TIER1 ou TIER2.

Emplacement | GPO
----------- | ---
contoso.com/Domain Controllers | Accès TIER0
contoso.com/TIER0 | Accès TIER0
contoso.com/TIER1 | Accès TIER1
contoso.com/TIER2 | Accès TIER2
contoso.com/CONTOSO | Accès TIER2

> Si vous devez multiplier le nombre de liens GPO et bloquer l'héritage des GPO sur certaines unités d'organisation, cela indique une mauvaise arborescence.

### Failles potentielles

La méthode d'isolation par GPO a beau être simple et peu coûteuse à mettre en place et à maintenir, il faut tout de même être vigilant sur deux points :

- **Appartenance à plusieurs niveaux** : lorsqu'un utilisateur appartient à plusieurs niveaux (exemple : TIER1 & TIER2), celui-ci ne pourra se connecter sur aucune ressource (ni du TIER1, ni du TIER2). Il s'agit donc d'une anomalie à corriger, mais celle-ci n'impacte pas la sécurité de votre Active Directory.
- **Compte non catégorisé dans un niveau** : dans ce cas, l'utilisateur ne sera pas soumis aux restrictions de connexion et pourra se balader librement sur tous les niveaux. Ça peut être utile dans le cas d'un compte de récupération, mais cela doit être surveillé régulièrement, car il s'agit d'une grosse faille dans la sécurité de votre Active Directory.

> L'utilisation de la méthode AGDLP permet d'associer les permissions (délégations Active Directory, droits d'administration locale des machines, etc) avec les contraintes (stratégie de mot de passe, restriction de connexion). De cette manière, l'un ne va pas sans l'autre.

## Authentication Policies & Silos

Depuis le niveau fonctionnel de domaine Active Directory Windows Server 2012 R2, il existe une solution taillée pour limiter les connexions entre les ressources : les Authentication Policies & Silos.

Dans ce guide/retour d'expérience, je ne parle pas cette technologie pour une simple et bonne raison : je ne suis actuellement pas à l'aise avec l'utilisation de cette technologie sur un environnement de production, surtout dans des entreprises qui n'ont pas d'équipe dédiée à Active Directory.

L'avantage principal de cette technologie est qu'elle bloque l'authentification avant le résultat du challenge des identifiants, contrairement aux GPOs qui effectue le blocage après la réussite du challenge.

### Contraintes

voici quelques contraintes fréquentes à l'utilisation de l'authentification en silo :

- L'ajout dans un silo ne se fait pas automatiquement à partir de l'appartenance à une OU (mais faisable en PowerShell)
- Authentification uniquement en Kerberos (NTLM est interdit)
- Intégration de serveurs avant Windows Server 2012R2 est déconseillée
- Incompatibilité avec les red forests
- Incompatibilité avec certains bastions mutualisés

### Plus d'informations

Si vous souhaitez poursuivre sur cette technologie, je vous conseille la lecture du document d'Aurélien Bordes à ce sujet : [SSTIC2017-Article-administration_en_silo-bordes.pdf](https://www.sstic.org/media/SSTIC2017/SSTIC-actes/administration_en_silo/SSTIC2017-Article-administration_en_silo-bordes.pdf).

Vous devez également bien comprendre le fonctionnement de Kerberos au global.

> L'utilisation des silos peut être envisagée après le déploiement du tiering model par GPO, en supplément et restreint sur le TIER0.