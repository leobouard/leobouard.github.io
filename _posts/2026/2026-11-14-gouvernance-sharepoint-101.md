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

### Orienter les besoins vers le meilleur produit

Tous les besoins ne mènent pas à une solution unique. Microsoft 365 propose de nombreux modes de collaboration, et c'est à vous d'orienter et de conseiller les utilisateurs vers la solution la mieux adaptée à leurs besoins.

Voici quelques exemples associant chaque besoin à la solution la plus adaptée :

Usage | Solution adaptée | Description
----- | ---------------- | -----------
Discussion informelle ou échange ponctuel | Conversation de groupe dans Teams | Elle convient aux échanges rapides, mais ne devrait pas devenir le seul endroit où sont conservés des documents importants ou des décisions durables.
Projet avec une durée de vie et des participants identifiés | Équipe Teams | Les canaux permettent de séparer les sujets ou les lots de travail, tout en gardant les échanges et les fichiers dans un même espace de collaboration.
Sous-tâche ou sujet lié à un projet existant | Canal dans une équipe Teams | Cela évite de créer une nouvelle équipe pour chaque sujet ; un canal partagé peut être envisagé lorsque la collaboration doit inclure des personnes qui ne font pas partie de l'équipe principale.
Espace de collaboration pérenne, gestion documentaire structurée ou contenu destiné à un large public | Site SharePoint | Il convient mieux aux contenus qui doivent rester accessibles et organisés indépendamment d'un projet temporaire.

> À garder en tête : une équipe Teams s'appuie sur un groupe Microsoft 365 et dispose d'un site SharePoint associé pour ses fichiers.

Si vous souhaitez aller plus loin et obtenir des infographies pour vos utilisateurs, je vous recommande : [Quick tips on Microsoft Teams \| Teams2simple](https://www.teams2simple.com/)

### Définir un processus clair de création de site/équipe

Le processus devrait, si possible, être accessible depuis un point d'entrée unique : un formulaire qui crée automatiquement (avec ou sans validation) le site SharePoint ou l'équipe Teams demandée.

Ce formulaire permettra de vérifier quelques points clés :

- **Permet de cerner le besoin réel** et donc d'orienter vers une autre solution, si besoin
- **Permet de s'assurer de la légitimité de la demande**, grâce à la validation du manager, par exemple, ou, au minimum, de désigner clairement un responsable des données hébergées sur le site
- **Permet de garder la maîtrise de la convention de nommage** et d'éviter de se retrouver avec des sites portant un nom trop générique

> L'objectif n'est pas d'ajouter une étape administrative, mais de recueillir les informations nécessaires dès la demande et d'éviter les espaces créés sans responsable ni objectif clair.

Je n'ai d'expérience qu'avec le module `PnP.PowerShell`, mais il est a priori possible de créer des sites SharePoint très simplement avec Power Automate : [No Code SharePoint Site Creation with a Flow - WonderLaura @iwmentor - Laura Rogers](https://wonderlaura.com/2025/04/11/no-code-sharepoint-site-creation-with-a-flow/).

### Interdire la création de nouvelles équipes et de nouveaux sites

Lorsque le processus de demande est prêt et testé, vous pouvez restreindre la création libre afin que les nouveaux espaces soient provisionnés selon les règles définies.

Voici les liens vers la documentation correspondante :

- [Limiter les utilisateurs autorisés à créer des groupes Microsoft 365](https://learn.microsoft.com/en-us/microsoft-365/solutions/manage-creation-of-groups?view=o365-worldwide)
- [Gérer la création de sites SharePoint](https://learn.microsoft.com/en-us/sharepoint/manage-site-creation)

### Au moins deux propriétaires

Assurez-vous que chaque équipe et chaque site possède au moins deux propriétaires identifiés, actifs et en mesure d'assumer ce rôle. Cette redondance évite qu'un départ ou une absence bloque la gestion des membres, des accès, du contenu ou de la fermeture de l'espace.

> Les propriétaires doivent savoir ce qui est attendu d'eux : deux noms ajoutés sans suivi ne constituent pas une gouvernance.

Si vous disposez de [SharePoint Advanced Management (SAM)](https://learn.microsoft.com/en-us/sharepoint/advanced-management), vous avez à votre disposition une stratégie qui permet de définir un nombre minimal de propriétaires ou d'administrateurs, de repérer les sites qui ne respectent pas ce critère et d'envoyer des notifications.

### Suppression automatique des équipes inactives

Une stratégie d'expiration dans Microsoft Entra ID peut gérer le cycle de vie des groupes Microsoft 365, et donc des équipes Teams qui leur sont associées. Elle s'applique aux groupes qui n'ont pas été renouvelés pendant la période que vous aurez définie.

Si une équipe est concernée par l'expiration, ses propriétaires recevront des notifications en amont et pourront renouveler en autonomie le groupe qui lui est associé.

> Il s'agit bien d'une expiration de groupe, pas d'un archivage. À l'expiration, le groupe est supprimé. Un groupe supprimé peut être restauré pendant 30 jours, mais, passé ce délai, les données seront perdues !

La documentation pour la mise en place est disponible ici : [Stratégie d'expiration des groupes Microsoft 365](https://learn.microsoft.com/en-us/entra/identity/users/groups-lifecycle).

## Pour aller plus loin

Les mesures présentées ici constituent une base : elles permettent de mieux contrôler la création, la propriété et le cycle de vie des espaces, mais doivent s'inscrire dans une stratégie plus large de sécurité et de gestion de l'information.

Si vous souhaitez aller plus loin (tout en restant dans l'écosystème Microsoft), voici quelques pistes :

- Obtenir [SharePoint Advanced Management](https://learn.microsoft.com/en-us/sharepoint/advanced-management), qui propose des outils de gouvernance du cycle de vie, de gestion des sites inactifs et d'analyse des accès
- Mettre en place des [revues d'accès Microsoft Entra](https://learn.microsoft.com/en-us/entra/id-governance/access-reviews-overview) pour responsabiliser les gestionnaires de site sur la question : « Qui a accès à quoi ? »
- Préparer l'usage des [étiquettes de confidentialité](https://learn.microsoft.com/en-us/purview/sensitivity-labels) et des stratégies de [prévention contre la perte de données (DLP)](https://learn.microsoft.com/en-us/purview/dlp-learn-about-dlp), en lien avec les exigences de conformité et de protection des données de l'organisation.

> Toutes ces étapes de gouvernance seront très utiles le jour où vous commencerez à déployer Microsoft 365 Copilot, qui mettra inévitablement en lumière les lacunes de vos données disponibles (ou non) sur SharePoint !

La gouvernance SharePoint et Teams **n'est pas un projet ponctuel de nettoyage** : c'est un ensemble de règles, de processus et de responsabilités à faire vivre. En associant les utilisateurs aux choix, en automatisant les demandes courantes et en réévaluant régulièrement les espaces et leurs accès, vous pouvez conserver un environnement utile et maîtrisé sans freiner la collaboration.
