---
title: "Gouvernance SharePoint 101"
description: "Conseils pratiques pour maîtriser les sites SharePoint de votre tenant"
tags: ["sharepoint", "microsoft365"]
---

## Contexte

J'ai eu l'occasion d'accompagner quelques clients dans la mise en place de la gouvernance de leur espace SharePoint. Je vous propose donc cet article pour partager des bonnes pratiques et des pistes de travail afin de reprendre durablement le contrôle de votre tenant Microsoft 365 !

Cet article se veut une check-list, avec des liens utiles et des pistes à explorer pour chaque point. Je n'entre pas dans le détail de chaque sujet, par souci de simplicité : la gouvernance est propre à chaque entreprise.

## Gestion du stockage

En général, on commence à s'intéresser à la gouvernance de SharePoint lorsque l'utilisation du stockage alloué atteint un niveau critique (environ 95 %). À partir de ce moment-là, le problème devient visible et peut commencer à affecter l'activité de l'organisation si vous ne faites rien.

> Pour rappel, l'allocation du stockage SharePoint sur un tenant se fait de la manière suivante : 1 To *offert* puis 10 Go supplémentaires par utilisateur éligible (licence SharePoint Plan 1 ou Plan 2).

Il y a deux issues possibles :

- Soit mettre en place des actions de remédiation pour réduire l'utilisation du stockage
- Soit passer à la caisse pour [acheter du stockage SharePoint supplémentaire](https://learn.microsoft.com/en-us/microsoft-365/commerce/add-storage-space?view=o365-worldwide), dont le prix peut être prohibitif

Pour la suite de cet article, on va partir sur la piste du ménage !

### Nettoyage des versions inutiles

C'est une solution presque miracle pour réduire rapidement l'utilisation de SharePoint sans (presque) supprimer de données. Il s'agit simplement de supprimer les versions superflues des fichiers (des copies intégrales conservées à une date antérieure), qu'elles soient trop anciennes pour être utiles ou trop nombreuses.

Par défaut, SharePoint conserve 500 versions d'un même fichier, sans limite de temps. Un moyen de regagner rapidement de l'espace consiste donc à plafonner le nombre de versions ou leur ancienneté, puis à nettoyer les versions superflues. Pour en savoir plus : [Le versioning sur SharePoint \| LaBouaBouate](https://www.labouabouate.fr/2024/07/11/le-versioning-sur-sharepoint)

### Nettoyage des sites caduques

Si vos sites SharePoint et vos équipes Teams n'ont jamais fait l'objet d'une gouvernance, il y a fort à parier qu'ils contiennent beaucoup de données inutiles ou caduques. Avant de mettre en place la gouvernance, il est donc nécessaire de faire du tri et de réduire le nombre d'éléments à gérer (pour se simplifier la vie).

On va donc chercher et éliminer :

- Les sites sans propriétaires et/ou sans membres
- Les sites sans activité depuis plus de trois ans
- Les sites qui ne contiennent plus aucune donnée
- Les sites caduques ou triviaux, comme par exemple : *Journée d'intégration du 18 juin 2020*, *Protocoles COVID-19*, *Pot de départ de Michel*...

Pour trouver les sites inactifs, voici un article de l'un des G.O.A.T de SharePoint sur le sujet : [How to find all unused sites in SharePoint Online?](https://www.sharepointdiary.com/2019/08/sharepoint-online-find-unused-sites-using-powershell.html)

### Déplacement de la donnée froide

SharePoint est un excellent outil de collaboration, notamment grâce à la coédition de fichiers Excel, PowerPoint ou Word. Des fichiers PDF sont souvent associés à ces documents et peuvent être partagés en interne ou en externe. Les autres fichiers, qui ne sont pas destinés à être modifiés ou consultés directement depuis SharePoint, n'ont pas nécessairement besoin d'être stockés sur cette plateforme. Dans ces cas-là, un stockage Azure Blob ou un bon vieux serveur de fichiers coûtera souvent beaucoup moins cher, pour une qualité de service comparable. Je pense notamment aux fichiers utilisés pour la conception 3D, au montage vidéo, à la retouche d'images, ainsi qu'aux fichiers compressés et/ou d'archives...

En bref : **si la donnée n'est pas consultable, modifiable ou partagée sur SharePoint, elle peut être déplacée vers un stockage qui coûte moins cher.**

> Le téléchargement depuis OneDrive ou SharePoint est également soumis à des limites (250 Go ou 10 000 fichiers maximum), ce qui peut poser problème. Pour en savoir plus : [Download files and folders from OneDrive or SharePoint \| Microsoft Support](https://support.microsoft.com/en-US/onedrive/download-files-and-folders-from-onedrive-or-sharepoint).

### Définir des quotas de site

Par défaut, un site SharePoint peut atteindre 25 To, ce qui suffit à consommer l'intégralité du stockage de votre tenant. Pour éviter une croissance incontrôlée de l'utilisation de votre espace SharePoint, je recommande de définir des quotas d'utilisation maximaux. Sans intervention d'un administrateur, un site ne pourra pas dépasser 10 Go par défaut.

L'application d'un quota permet d'éviter qu'un utilisateur dépose une quantité énorme de données du jour au lendemain. Elle incite également les utilisateurs à supprimer les données caduques ou inutiles. Lorsque ces données ne sont pas essentielles à l'activité, la plupart des gens préféreront faire un peu de ménage en autonomie plutôt que d'ouvrir un ticket pour demander de l'espace supplémentaire.

Le plus simple est de planifier l'application des quotas en amont (et d'éviter d'y aller *au feeling*). Définissez clairement les tailles des sites SharePoint afin de pouvoir les appliquer uniformément. Exemple de configuration :

- Taille S (par défaut) : 10 Go
- Taille M : 50 Go
- Taille L : 250 Go
- Taille XL : 1 To
- Taille XXL : 5 To

> J'ai déjà fait un article sur [l'application de quota sur des sites SharePoint si besoin](/2026/06/24/quota-sites-sharepoint).

## Accompagnement au changement

Une fois votre environnement nettoyé et l'utilisation du stockage de votre tenant réduite, vous pouvez vous attaquer au travail de contrôle des usages et de maîtrise des données de votre organisation.

> Ne soyez pas trop restrictifs sur l'utilisation de SharePoint et Teams. Il faut trouver le juste milieu entre restrictions et ouverture pour éviter que les utilisateurs abandonnent les outils de collaboration de l'organisation au profit d'outils non maîtrisés ou inadaptés.

La gouvernance ne repose pas uniquement sur des paramètres techniques : elle doit aussi être comprise et adoptée par les utilisateurs. Expliquez les objectifs des règles, indiquez clairement où demander un nouvel espace et accompagnez les équipes dans leurs premiers usages. Des formations courtes, des guides adaptés aux différents profils et un réseau de référents ou de *champions* peuvent faciliter l'adoption.

Avant un déploiement général, testez les règles et le processus avec quelques équipes représentatives. Leurs retours permettront d'identifier les blocages, d'ajuster les modèles et de préparer une communication utile. La [ressource Microsoft sur l'adoption de Teams](https://adoption.microsoft.com/en-us/microsoft-teams/) propose notamment des outils pour les responsables de l'adoption, tandis que le [guide de démarrage sur la gouvernance Teams](https://learn.microsoft.com/en-us/microsoftteams/teams-adoption-governance-quick-start) aide à cadrer les décisions avant un déploiement plus large.

### Orienter les besoins vers le meilleur produit

Idéalement, un arbre de décision guidera simplement les utilisateurs vers la solution la mieux adaptée à leurs besoins.

- Discussion informelle ou échange ponctuel : conversation de groupe dans Teams. Elle convient aux échanges rapides, mais ne devrait pas devenir le seul endroit où sont conservés des documents importants ou des décisions durables.
- Projet avec une durée de vie et des participants identifiés : équipe Teams. Les canaux permettent de séparer les sujets ou les lots de travail, tout en gardant les échanges et les fichiers dans un même espace de collaboration.
- Sous-tâche ou sujet lié à un projet existant : canal dans l'équipe concernée. Cela évite de créer une nouvelle équipe pour chaque sujet ; un canal partagé peut être envisagé lorsque la collaboration doit inclure des personnes qui ne font pas partie de l'équipe principale.
- Espace de collaboration pérenne, gestion documentaire structurée ou contenu destiné à plusieurs publics : site SharePoint. Il convient mieux aux contenus qui doivent rester accessibles et organisés indépendamment d'un projet temporaire.

À garder en tête : une équipe Teams s'appuie sur un groupe Microsoft 365 et dispose d'un site SharePoint associé pour ses fichiers. Teams et SharePoint ne sont donc pas toujours deux choix concurrents : créez une équipe lorsque les conversations et le travail collectif sont au cœur du besoin, et un site SharePoint autonome lorsque la gestion et la diffusion de contenus sont prioritaires. Microsoft détaille le [cycle de vie des équipes et leurs sites associés](https://learn.microsoft.com/en-us/microsoftteams/plan-teams-lifecycle).

Site de référence pour guider les usages : [Quick tips on Microsoft Teams | Teams2simple](https://www.teams2simple.com/)

### Définir un processus clair de création de site/équipe

Le processus devrait, si possible, être accessible depuis un point d'entrée unique : un formulaire dans votre outil d'ITSM ou une Power App si vous souhaitez rester dans un environnement 100 % Microsoft. L'objectif n'est pas d'ajouter une étape administrative, mais de recueillir les informations nécessaires dès la demande et d'éviter les espaces créés sans responsable ni objectif clair.

Le formulaire peut demander le besoin métier, le type d'espace souhaité, son nom, sa description, les propriétaires et membres, la présence d'invités externes, la sensibilité des données, la durée prévue et, au besoin, le quota de stockage. Le processus peut ensuite appliquer un modèle validé, attribuer les propriétaires, configurer les paramètres de partage et de confidentialité, puis envoyer les informations utiles aux demandeurs. Prévoyez également une étape de renouvellement, d'archivage ou de fermeture à la fin de vie de l'espace.

Je n'ai d'expérience qu'avec le module `PnP.PowerShell`, mais il est a priori possible de le faire très simplement avec Power Automate : [No Code SharePoint Site Creation with a Flow - WonderLaura @iwmentor - Laura Rogers](https://wonderlaura.com/2025/04/11/no-code-sharepoint-site-creation-with-a-flow/)

Pour cadrer les règles et les décisions de gouvernance à intégrer au processus, vous pouvez également consulter le [guide Microsoft de planification de la gouvernance dans Teams](https://learn.microsoft.com/en-us/microsoftteams/plan-teams-governance).

### Interdire la création de nouvelles équipes et de nouveaux sites

Lorsque le processus de demande est prêt et testé, vous pouvez restreindre la création libre afin que les nouveaux espaces soient provisionnés selon les règles définies. Il faut toutefois distinguer deux réglages : la création des groupes Microsoft 365, qui concerne notamment les équipes Teams et plusieurs autres services, et la création des sites SharePoint autonomes. Désactiver l'une ne désactive pas automatiquement l'autre.

Microsoft explique comment [limiter les utilisateurs autorisés à créer des groupes Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/solutions/manage-creation-of-groups?view=o365-worldwide) et comment [gérer la création de sites SharePoint](https://learn.microsoft.com/en-us/sharepoint/manage-site-creation). La restriction des groupes peut aussi affecter Planner, Outlook et d'autres services qui s'appuient sur ces groupes ; vérifiez les impacts et les exceptions nécessaires avant de l'activer. Les rôles d'administration conservent par ailleurs des capacités de création.

### Au moins deux propriétaires

Assurez-vous que chaque équipe et chaque site possède au moins deux propriétaires identifiés, actifs et en mesure d'assumer ce rôle. Cette redondance évite qu'un départ ou une absence bloque la gestion des membres, des accès, du contenu ou de la fermeture de l'espace. Les propriétaires doivent savoir ce qui est attendu d'eux ; deux noms ajoutés sans suivi ne constituent pas une gouvernance à eux seuls.

Microsoft recommande également d'identifier au moins deux propriétaires pour une équipe dans ses [conseils sur le cycle de vie des équipes](https://learn.microsoft.com/en-us/microsoftteams/plan-teams-lifecycle). Si vous disposez de [SharePoint Advanced Management (SAM)](https://learn.microsoft.com/en-us/sharepoint/advanced-management), sa stratégie de propriété des sites permet de définir un nombre minimal de propriétaires ou d'administrateurs, de repérer les sites qui ne respectent pas ce critère et d'envoyer des notifications. Consultez les [prérequis et informations de licence de SAM](https://learn.microsoft.com/en-us/sharepoint/sharepoint-advanced-management-prerequisites) avant de bâtir votre processus sur cette fonctionnalité.

### Suppression automatique des équipes inactives

Une stratégie d'expiration dans Microsoft Entra ID peut gérer le cycle de vie des groupes Microsoft 365, et donc des équipes Teams qui leur sont associées. La période est configurable ; l'activité dans les services Microsoft 365, par exemple la consultation ou la modification de fichiers SharePoint ou la visite d'un canal Teams, peut renouveler automatiquement un groupe. Les propriétaires reçoivent des notifications avant l'expiration lorsque le groupe n'est pas renouvelé automatiquement.

Il s'agit bien d'une expiration de groupe, pas d'un simple archivage : à l'expiration, le groupe est supprimé. Un groupe supprimé peut être restauré pendant 30 jours, mais il est préférable de définir au préalable les règles de conservation et de prévoir l'archivage lorsqu'un espace doit rester consultable. La fonctionnalité requiert des licences Microsoft Entra ID P1 ou P2 pour l'administrateur qui la configure et les membres des groupes concernés. Consultez la documentation sur la [stratégie d'expiration des groupes Microsoft 365](https://learn.microsoft.com/en-us/entra/identity/users/groups-lifecycle) et sur la [planification du cycle de vie des équipes](https://learn.microsoft.com/en-us/microsoftteams/plan-teams-lifecycle) ; commencez par un périmètre pilote et vérifiez les notifications et les besoins de conservation avant de généraliser.

## Pour aller plus loin

Les mesures présentées ici constituent une base : elles permettent de mieux contrôler la création, la propriété et le cycle de vie des espaces, mais doivent s'inscrire dans une stratégie plus large de sécurité et de gestion de l'information.

- Découvrir [SharePoint Advanced Management](https://learn.microsoft.com/en-us/sharepoint/advanced-management), qui propose des outils de gouvernance du cycle de vie, de gestion des sites inactifs et d'analyse des accès. Les fonctionnalités disponibles dépendent des licences de votre organisation ; consultez les [prérequis de SAM](https://learn.microsoft.com/en-us/sharepoint/sharepoint-advanced-management-prerequisites).
- Définir les règles de partage externe et vérifier régulièrement qui a accès à quoi. Les [revues d'accès Microsoft Entra](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview) peuvent aider les propriétaires à confirmer ou retirer les accès qui ne sont plus nécessaires.
- Préparer l'usage des [étiquettes de confidentialité](https://learn.microsoft.com/en-us/purview/sensitivity-labels) et des stratégies de [prévention contre la perte de données (DLP)](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp), en lien avec les exigences de conformité et de protection des données de l'organisation.
- Évaluer les impacts de ces règles dans le cadre du déploiement de Microsoft 365 Copilot : la qualité des contenus, leur classification et la maîtrise des autorisations influencent les informations auxquelles les utilisateurs peuvent accéder.

La gouvernance SharePoint et Teams n'est pas un projet ponctuel de nettoyage : c'est un ensemble de règles, de processus et de responsabilités à faire vivre. En associant les utilisateurs aux choix, en automatisant les demandes courantes et en réévaluant régulièrement les espaces et leurs accès, vous pouvez conserver un environnement utile et maîtrisé sans freiner la collaboration.
