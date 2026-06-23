---
title: "Gouvernance SharePoint 101"
description: ""
tags: ["sharepoint", "microsoft365"]
---

## Contexte

J'ai eu l'occasion d'accompagner quelques clients sur la mise en place de la gouvernance de leur espace SharePoint. Je fais donc cet article pour partager un ensemble de bonnes pratiques et de piste de travail pour reprendre le contrôle sur votre tenant Microsoft 365 pour de bon !

Cet article est à voir comme une check-list avec des liens utiles et des pistes à creuser pour chaque point. Je ne rentre pas spécialement dans le détail à chaque fois pour des raisons de simplicité, puisque la gouvernance est quelque chose de propre à chaque entreprise.

## Gestion du stockage

En général, vous allez vous réveiller de votre sommeil sur la gouvernance de SharePoint au moment où l'usage de votre stockage alloué arrive dans le rouge (vers 95% d'utilisation de mémoire). A partir de ce moment là, le problème devient visible et peut commencer à impacter l'activité de l'organisation si vous ne faites rien.

> Pour rappel, l'allocation du stockage SharePoint sur un tenant se fait de la manière suivante : 1 To *offert* puis 10 Go supplémentaires par utilisateur éligible (licence SharePoint Plan 1 ou Plan 2).

Il y a deux issues possibles :

- Soit commencer à travailler sur des actions de remédiation pour réduire le stockage
- Soit passer à la caisse pour [acheter du stockage SharePoint supplémentaire](https://learn.microsoft.com/en-us/microsoft-365/commerce/add-storage-space?view=o365-worldwide), dont le prix peut être prohibitif

Pour que l'article soit pertinent, on va partir sur la piste du ménage !

### Nettoyage des versions inutiles

C'est la solution un peu miracle pour réduire rapidement son usage SharePoint sans (presque) supprimer aucune donnée. On vient simplement supprimer les versions de fichiers (des copies intégrales du fichier à une date antérieure) superflues, qu'elles soient trop anciennes pour être exploitées ou trop nombreuses.

Par défaut, SharePoint conserve 500 versions d'un même fichier, sans limite de temps. Un moyen de regagner rapidement du stockage est donc de plafonner le nombre de version ou leur âge, puis de nettoyer les versions superflues. Plus d'informations sur le sujet ici : [Le versioning sur SharePoint \| LaBouaBouate](https://www.labouabouate.fr/2024/07/11/le-versioning-sur-sharepoint)

### Nettoyage des sites caduques

Si aucune gouvernance n'a été faite de vos sites SharePoint et équipes Teams, il est fort à parier qu'il y a beaucoup de données inutiles ou caduques. Dans ce cas, avant de passer à la partie gouvernance il est nécessaire de faire du tri et de réduire le nombre d'éléments à gouverner (pour se simplifier la vie).

On va donc chercher et éliminer :

- Les sites sans propriétaires et/ou sans membres
- Les sites sans activité depuis + 3 ans
- Les sites qui ne contiennent plus aucune donnée
- Les sites caduques ou triviaux, comme par exemple : *Journée d'intégration du 18 juin 2020*, *Protocoles COVID-19*, *Pot de départ de Michel*...

### Déplacement de la donnée froide

SharePoint est un excellent outil pour la collaboration, notamment avec la co-édition sur les fichiers Excel, PowerPoint ou Word. Des fichiers PDF sont souvent liés à ceux-ci et peuvent être partagés en interne ou en externe. Le reste des fichiers (ceux qui ne sont pas modifiables ou à minima consultables depuis SharePoint) n'ont pas nécessairement à être sur ce genre de stockage. Dans ces cas-là, un Azure Blob Storage ou un bon vieux serveur de fichiers vont coûter largement moins cher et offrirons la même qualité de service. Je pense à des fichiers comme ceux utilisés par la conception 3D, la retouche vidéo et image, les fichiers compressés et ou d'archives...

En bref : **si la donnée n'est pas consultable, modifiable ou partagée sur SharePoint, elle peut être déplacée vers un stockage qui coûte moins cher.**

> Il y a également une limitation à 250 GB ou 10 000 fichiers maximum, ce qui peut être problématique . Plus d'informations ici : [Download files and folders from OneDrive or SharePoint \| Microsoft Support](https://support.microsoft.com/en-US/onedrive/download-files-and-folders-from-onedrive-or-sharepoint).

### Définir des quotas de site

Par défaut, un site SharePoint peut faire jusqu'à 25 To ce qui est suffisant pour consommer l'intégralité du stockage de votre tenant. Pour éviter la croissance incontrôlée de l'utilisation de votre espace SharePoint, je recommande la définition de quota d'usage maximum. Sans intervention d'un administrateur, un site ne pourra pas faire plus de 10 Go par défaut.

L'application d'un quota permet d'éviter qu'un utilisateur dépose une quantité de données énorme du jour au lendemain, et elle incite également les utilisateurs à supprimer dans les données caduques ou inutiles. Lorsque ce n'est pas important pour l'activité, la plupart des gens préférerons faire un peu de ménage en autonomie plutôt que d'ouvrir un ticket pour demander de l'espace supplémentaire.

Le plus simple sur l'application du quota est de planifier tout en amont (et éviter d'y aller *au feeling*). Définissez clairement les tailles des sites SharePoint pour ensuite les appliquer de manière uniforme et d'un seul coup. Exemple de configuration :

- Taille S (par défaut) : 10 Go
- Taille M : 50 Go
- Taille L : 250 Go
- Taille XL : 1 To
- Taille XXL : 5 To

## Accompagnement au changement

Une fois que vous avez nettoyé votre environnement et réduit l'usage du stockage de votre tenant, vous allez pouvoir attaquer le travail pour contrôler l'utilisation et maîtriser les données de votre organisation.

> Ne soyez pas trop restrictifs sur l'usage de SharePoint / Teams. Il faut trouver le juste milieu entre restrictions et ouverture pour éviter l'abandon des outils de collaboration de l'organisation au profit d'outil

### Orienter les besoins vers le meilleur produit

Idéalement avec un arbre de décision, pour guider de manière simple un utilisateur sur la meilleure solution pour lui. 

- Discussion informelle : Conversation de groupe Teams
- Projet spécifique avec une durée de vie définie : équipe Teams
- Sous-tâche d'un projet existant : canal dans une équipe Teams
- Espace de collaboration pérenne : site SharePoint

Site de référence pour guide l'usage : [Quick tips on Microsoft Teams | Teams2simple](https://www.teams2simple.com/)

### Définir un processus clair de création de site/équipe

Si possible entièrement automatisé, caché derrière un formulaire dans votre outil d'ITSM ou dans une PowerApp si vous souhaitez rester sur une stack 100% Microsoft.

Expérience uniquement avec `PnP.PowerShell`, mais possible à priori de le faire très simplement avec Power Automate : [No Code SharePoint Site Creation with a Flow - WonderLaura @iwmentor - Laura Rogers](https://wonderlaura.com/2025/04/11/no-code-sharepoint-site-creation-with-a-flow/)

### Interdire la création de nouvelles équipes & sites

Obliger les utilisateurs a passer dans votre tunnel de décision avec la création automatique du site SharePoint / équipe Teams à la fin de l'arbre de décision.

### Au moins deux propriétaires

S'assurer que tous les sites et équipes possèdent au moins deux propriétaires pour que les utilisateurs soient autonome dans 99% des cas et s'assurer que quelqu'un soit responsable des données hébergées sur l'espace de collaboration.

### Suppression automatique des équipes inactives

Paramètre disponible dans Entra ID pour supprimer automatiquement les groupes Microsoft 365 au bout d'un certains temps d'inactivité.

## Pour aller plus loin

- Microsoft Copilot pour avoir accès au SAM (SharePoint Advanced Management)
- Gérer les autorisations de partage
- Faire des revues régulières des autorisations (qui a accès à quoi ?) via les Access Review par exemple (d'où l'utilité des deux propriétaires)
- Préparer l'intégration des étiquettes de confidentialité, la protection contre la perte et la fuite de données, le déploiement de Copilot, etc...