---
title: "TIERING #2"
description: ""
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 3"
  id: "/2024/11/01/tiering-model-003"
prevLink:
  name: "Partie 1"
  id: "/2024/11/01/tiering-model-001"
---

## Remédiation de l'environnement

Avant d'attaquer le déploiement du tiering model, il convient de faire le ménage votre domaine Active Directory. L'idée est de repartir sur des bases saines avant d'attaquer de plus grands travaux.

### Bonnes pratiques

Plus votre environnement Active Directory est simple, plus facile sera le déploiement du tiering model. Voici donc quelques pistes de travail pour faire un peu de ménage et essayer d'y voir plus clair :

- Réduire le nombre d'administrateurs et leurs permissions
- Faire le ménage dans les objets inactifs (utilisateurs, ordinateurs)
- Faire le ménage des groupes vides et inutiles
- Supprimer les unités d'organisation vides et inutiles
- Supprimer les stratégies de groupes non-appliquées ou caduques
- Dédupliquer les stratégies en double dans vos GPO
- Mettre à jour vos contrôleurs de domaine
- Mettre à jour le niveau fonctionnel de votre domaine et de votre forêt
- Remettre au propre les partages NTFS (via la méthode AGDLP et des racines DFS)

### Outils d'audit

Voici une petite sélection d'outils d'audit (tous sont gratuits d'utilisation si vous n'êtes pas un auditeur professionnel).

#### Ping Castle by NETWRIX

Ping Castle est un outil d'audit référence sur la partie configuration de l'Active Directory. Il se calque à 90% sur les recommandations de l'ANSSI et permet d'avoir une très bonne alternative à ORADAD pour les entreprises ne pouvant pas l'utiliser.

Le score va de 0 (le meilleur) à la limite de 100 (le pire). Le score "global" permet de se faire rapidement une idée du niveau d'exposition, mais n'est pas un bon moyen de suivre la progression de votre remédiation. Pour suivre l'évolution du score, il faut surtout regarder le score cumulé des quatre catégories (non limité à 100).

A titre personnel, c'est mon outil de travail principal lorsqu'il s'agit de faire une remédiation de Active Directory.

Source : <https://www.pingcastle.com/download/>

#### Purple Knight by SEMPERIS

Alternative à Ping Castle mais évalue certains éléments que Ping Castle ne mesure pas, donc c'est un bon complément.

Source : <https://www.semperis.com/fr/purple-knight/>

#### Forest Druid by SEMPERIS

Permet d'auditer les chemins d'attaque vers le Tier 0, alternative à Adalanche ou BloodHound.

Source : <https://www.semperis.com/fr/forest-druid/>

#### Adalanche

Permet d'auditer et de visualiser les permissions dans Active Directory. Alternative à Forest Druid ou BloodHound.

Source : <https://github.com/lkarlslund/Adalanche>

#### BloodHound

La référence pour auditer les chemins d'attaque vers des ressources critiques. Alternative à Adalanche et Forest Druid

Source : <https://github.com/SpecterOps/BloodHound>

#### PowerHuntShares

Permet de découvrir tous les partages de fichiers disponibles dans votre domaine.

Source : <https://github.com/NetSPI/PowerHuntShares>

#### GPOZaurr

Outil d'audit de GPO, le plus complet disponible actuellement et très lisible. Ne fait pas directement de la sécurité mais permet de faire du ménage facilement.

Source : <https://github.com/EvotecIT/GPOZaurr>

#### Harden AD

Harden AD n'est pas un outil d'audit mais plutôt un framework pour déployer rapidement un environnement Active Directory renforcé, avec tout un ensemble de règles, de GPO et de délégations.

Source : <https://hardenad.net/>
