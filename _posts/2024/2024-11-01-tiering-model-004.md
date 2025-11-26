---
title: "TIERING #4 - Délégations et administrateurs"
description: "Mise en place de délégations pour les administrateurs du Tier 1 & 2"
tableOfContent: "tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 5"
  id: "tiering-model-005"
prevLink:
  name: "Partie 3"
  id: "tiering-model-003"
---

## Utilité des délégations

Les délégations sont des permissions appliquées au niveau des objets Active Directory (le plus souvent sur les unités d'organisation) pour permettre à un utilisateur, un ordinateur ou aux membres d'un groupe d'effectuer des actions d'administration précises comme :

- réinitialiser le mot de passe d'un compte utilisateur
- modifier les membres d'un groupe
- accéder à la clé BitLocker d'un ordinateur
- ajouter un lien d'objet de stratégie de groupe sur une unité d'organisation
- supprimer des enregistrements DNS sur une zone précise
- ajouter des partages sur une racine DFS

Le groupe "Admins du domaine" possède déjà toutes les permissions sur le domaine et donc n'a pas besoin de délégations supplémentaires pour faire son travail. La délégation va surtout servir à autoriser les futurs comptes du Tier 1 et du Tier 2 à pouvoir réaliser des tâches d'administration précises, sans avoir besoin de recourir à un compte Tier 0 en permanence.

> Attention : les délégations ne doivent pas permettre de remplacer intégralement les administrateurs du Tier 0, elles doivent simplement servir à déléguer les accès nécessaires au travail des administrateurs Tier 1 et Tier 2.

## Choses à ne pas faire

Comme évoqué précédemment, il est possible de faire toutes les délégations nécessaires et donc de ne jamais avoir à recourir au compte Tier 0 (Admins du domaine). Ce n'est pas l'idée d'une délégation, et le compte Tier 0 doit toujours avoir une utilité.

Un bon principe est de ne jamais déléguer l'accès à une ressource qui permet d'élever les droits de son propre compte. L'intérêt du tiering model est d'éviter l'escalade d'une attaque vers des ressources critiques, donc les délégations doivent également aller dans ce sens.

De plus, aucune délégation ne doit être autorisée sur le Tier 0.

### Donner le rôle DNSAdmins en dehors du Tier 0

Si vos administrateurs Tier 1 ou Tier 2 ont besoin d'administrer certaines zones DNS, veillez à bien qualifier le besoin avant de leur donner accès. Le plus sûr est de donner un compte Tier 0 ou de déléguer sur une zone DNS en particulier. En effet, même si le rôle DnsAdmins n'est pas protégé par AdminSDHolder, il permet à un attaquant de pouvoir compromettre le domaine.

Source : [From DnsAdmins to SYSTEM to Domain Compromise \| Red Team Notes](https://www.ired.team/offensive-security-experiments/active-directory-kerberos-abuse/from-dnsadmins-to-system-to-domain-compromise)

### Déléguer la corbeille Active Directory

Déléguer l'accès à la corbeille Active Directory est un piège classique que je vois dans beaucoup de domaines. L'idée de base est louable, puisqu'il s'agit souvent de donner tous les outils nécessaires au support pour qu'il puisse résoudre certains problèmes.

Le problème de la corbeille est qu'elle récupère tous les comptes Active Directory supprimés, qu'importe leur provenance. Ainsi, si un compte avec des privilèges importants (comme du Tier 1 ou du Tier 0) se retrouve dans la corbeille et qu'un compte Tier 2 possède des droits pour le restaurer vers une unité d'organisation dans laquelle il peut réinitialiser un mot de passe, cela peut permettre une escalade vers un niveau supérieur.

> Vous pouvez tout de même déléguer la corbeille sans compromettre la sécurité de votre domaine en mettant en place un processus strict de suppression des appartenances aux groupes (attribut `memberOf`) pour tous les comptes qui sont supprimés. Attention : si une permission était appliquée de manière nominative sur un compte (mauvaise pratique), ce processus ne vous protégera pas.
>
> Les comptes Tier 0 devraient normalement être protégés par le SDProp (autorisations issues du container AdminSDHolder).

### Déléguer la racine du domaine

Par défaut, une délégation appliquée à la racine du domaine se propage à tous les objets enfants et donc touche des containers considérés habituellement comme du Tier 0 (les containers "Users", "Built-in" et "Domain Controllers" par exemple).

Un bon principe est de ne déléguer que les unités d'organisation que vous avez créé.

### Déléguer AdminSDHolder

Le container "AdminSDHolder" (situé dans `contoso.com/System/AdminSDHolder`) contient les permissions qui seront appliquées à tous les objets qui portent la valeur '1' dans l'attribut `adminCount` (donc quasiment 90 % du Tier 0). En effet, les comptes administrateurs du domaine ne sont pas soumis aux permissions de l'objet parent, mais à celles de AdminSDHolder.

### Déléguer les stratégies de groupe

Le combo mortel pour garantir une escalade vers le Tier 0 : la permission d'ajouter des liens GPO (GPLink) et la permission de modifier les GPO (droits de modification sur le SYSVOL). Avec cette combinaison, un attaquant peut déployer n'importe quel paramètre sur n'importe quel compte du domaine, y compris le Tier 0.

Pour éviter cela :

- Ne pas déléguer toutes les GPO d'un coup
- Être précautionneux sur les délégations des GPLink (éviter le Tier 0)

...ou plus simplement ne pas déléguer la gestion des GPO et laisser ce travail aux administrateurs du Tier 0.

### Casser l'héritage et jouer sur les drapeaux de propagation

Ce n'est pas parce que vous avez un outil que vous devez l'utiliser. Casser l'héritage d'une permission pour empêcher sa propagation sur certains objets enfants reflète une mauvaise arborescence et ne devrait être utilisé qu'en dernier recours.

De la même manière, jouer sur les drapeaux de propagation complexifie beaucoup la lecture des permissions Active Directory et reste une mauvaise idée en général.

## Modèle de délégation

### Création des groupes

Avant de faire les délégations dans votre arborescence, il faut commencer par créer l'ensemble des groupes (sécurité de domaine local) qui vont recevoir les permissions. L'idée n'est pas de faire un seul groupe fourre-tout qui contiendrait l'ensemble des permissions que vous voulez donner au Tier 1 par exemple, mais plutôt un ensemble de groupes qui ne portent à chaque fois qu'une seule permission. Voici quelques exemples de groupes :

- Réinitialisation du mot de passe des utilisateurs sur consoto.com/FABRIKAM LLC
- Gestion complète des utilisateurs sur consoto.com/CONTOSO
- Récupération des clés BitLocker sur contoso.com/TIER1/Servers
- Administrateur local des ordinateurs sur contoso.com/TAILSPIN TOYS

Ceci s'apparente à la méthode AGDLP (**A**ccount > **G**lobal group > **D**omain **L**ocal group > **P**ermission), qui est très souvent utilisée dans la gestion des droits d'accès sur les serveurs de fichiers. Plus d'informations sur cette méthode ici : [La méthode AGDLP : L’art de gérer ses permissions selon Microsoft – NEPTUNET.FR](https://neptunet.fr/agdlp/)

> Prenez bien le temps de réfléchir à une convention de nommage simple et facilement compréhensible pour vos groupes. La description de ces groupes ne doit pas être oubliée, car c'est un élément crucial pour bien comprendre l'intérêt et la permission que chaque groupe porte.

### Création des délégations de contrôle

Il faut maintenant ajouter des droits sur les groupes de sécurité domaine local fraîchement créés. Dans l'idéal, plus aucune permission Active Directory existante ne devrait être attribuée à autre chose qu'à l'un de ces groupes.

#### Par l'interface graphique

Pour de petites infrastructures, vous pouvez déléguer le contrôle d'une unité d'organisation avec l'interface graphique. Vous pouvez faire un clic-droit sur n'importe quelle OU, sélectionner l'option "Délégation de contrôle..." et avoir accès à l'assistant dédié.

Plus d'informations sur cette méthode ici : [La délégation de contrôle Active Directory \| IT-Connect](https://www.it-connect.fr/la-delegation-de-controle-active-directory/)

#### En ligne de commande

Pour créer des délégations en ligne de commande, vous pouvez utiliser l'utilitaire [dsacls](https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/cc771151%28v=ws.11%29), mais je préviens : c'est une vraie plaie à utiliser. Pour contourner le problème, j'ai créé une fonction PowerShell qui "wrap" cet utilitaire dans une commande simple à utiliser :

{% include github-gist.html name="Grant-ADDelegation" id="027bbcc9941d80c8175cb337147fc0e4" %}

### Délégation des droits d'administration local

Par défaut, les seuls utilisateurs du domaine à avoir accès à tous les ordinateurs en tant qu'administrateur local sont les membres du groupe "Admins du domaine". Comme ce groupe est réservé aux membres du Tier 0, il faut déléguer cet aspect aux administrateurs du Tier 1 et du Tier 2 pour qu'ils puissent accéder à leurs machines.

Même chose que pour les délégations de contrôle : il faut bien créer un groupe de sécurité domaine local dont la seule raison d'exister sera de conférer les droits d'administration locaux à ses membres.

Plus d'informations sur comment ajouter un groupe du domaine dans les groupes restreints des ordinateurs : [How To Add Local Administrators via GPO (Group Policy)](https://thesysadminchannel.com/add-local-administrators-via-gpo-group-policy/)

> Je déconseille l'utilisation de la méthode plus moderne (via les préférences Windows) à cause des comportements capricieux que j'ai pu observer lors du retrait de la GPO.

### Création des rôles

Une fois toutes vos délégations créées, vous n'avez plus qu'à créer des groupes de sécurité globaux qui vont permettre de réunir toutes les permissions que vous avez créées précédemment. Ces groupes vont servir de rôle d'administration (comme le groupe "Admins du domaine" par exemple) pour que vous puissiez ajouter facilement vos nouveaux administrateurs.

L'idée de ce genre de groupe est de rationaliser les accès de tous les membres d'une équipe, pour simplifier l'administration quotidienne et répondre plus rapidement à un audit. Voici quelques exemples de groupes qui pourraient être créés :

- TIER1 FABRIKAM Devops
- TIER1 TAILSPIN TOYS SAP Admins
- TIER2 CONTOSO Helpdesk

L'onglet "Members" de ces groupes devrait contenir les comptes administrateurs, et l'onglet "Member of" devrait lister tous les groupes de sécurité domaine local qui portent des permissions.

Vous pouvez également en profiter pour ajouter votre groupe de ciblage pour une stratégie de mot de passe renforcée et votre groupe d'appartenance à un niveau (Utilisateurs du TIER1 par exemple) à chaque groupe global.

> Il est intéressant de faire de même pour vos comptes de service.

### Création de vos administrateurs

Il ne reste maintenant plus qu'à créer vos nouveaux comptes d'administration et à les positionner dans les rôles correspondants. Pour la convention de nommage des comptes, assurez-vous de respecter deux choses :

- Indiquer clairement le niveau du compte (Tier 0, Tier 1, Tier 2)
- Faire un lien entre tous les comptes d'une même personne : la sécurité par l'obscurité ne marche pas (surtout dans Active Directory), donc l'objectif est de faciliter la désactivation de tous les comptes d'un administrateur en cas de problème.
