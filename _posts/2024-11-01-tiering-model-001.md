---
title: "TIERING #1 - Définition et principe de base"
description: "Comprendre le concept du tiering model et la protection qu'il offre"
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 2"
  id: "/2024/11/01/tiering-model-002"
prevLink:
  name: "Introduction"
  id: "/2024/11/01/tiering-model-introduction"
---

## Définition

Le tiering model est un concept de sécurité de Active Directory qui segmente les ressources (ordinateurs, utilisateurs, groupes) en différents niveaux (ou couches). Le mot "tier" désigne chaque niveau/couche d'administration

Tout le principe du tiering model repose sur la thèse qu'un attaquant peut obtenir le compte de n'importe quel utilisateur connecté ou s'étant connecté sur un ordinateur/serveur pour rebondir ensuite. En partant de ce principe, il faut donc segmenter les usages et utiliser un compte différent pour chaque niveau.

Le concept du tiering model ne concerne pas uniquement Active Directory, c'est un principe qu'on retrouve dans l'architecture logicielle avec une séparation entre le front-end, la base de donnée et le back-end.

### Découpage des couches

Ces différents niveaux sont classés du plus critique (Tier 0) au moins critique (Tier 2). Habituellement, voici ce que contiennent les différentes couches :

1. **Tier 0 :** regroupe les ressources critiques pour Active Directory comme les administrateurs du domaine, les contrôleurs de domaine et l'autorité de certification.
2. **Tier 1 :** contient les serveurs applicatifs de l'entreprise et leurs administrateurs.
3. **Tier 2 :** contient les utilisateurs sans privilèges, tous les périphériques sur lesquels ils se connectent et les administrateurs de stations de travail.

On retrouve habituellement trois couches, mais les modèles peuvent varier. Dans le tiering model proposé par [Harden AD](https://hardenad.net/), deux niveaux supplémentaires sont ajoutés pour isoler les systèmes d'exploitations obsolètes.

## Principe

### Objectifs du tiering model

L'idée de cette segmentation est d'empêcher ou de ralentir la propagation d'une attaque partant du Tier 2 (le plus exposé) pour aller vers le Tier 0 (le plus critique).

Le Tier 2 est de très loin le plus exposé aux attaques de par :

- le nombre de ressources, qui représente souvent 90% des objets dans un domaine
- l'exposition des utilisateurs standards à des attaques comme le hameçonnage
- l'accès physique aux ressources (comme les ordinateurs)

Il est important d'isoler ces ressources pour éviter qu'un attaquant puisse directement rebondir d'un ordinateur vers un serveur applicatif ou un contrôleur de domaine. Une attaque se produisant dans un niveau **ne peut donc pas se propager aux autres niveaux** (en théorie).

### Isolation

L'isolation des ressources entre-elles se fait principalement par l'interdiction de connexion vers une ressource un niveau supérieur ou inférieur. Ainsi, un utilisateur du Tier 2 ne pourra pas se connecter sur un serveur du Tier 1, même si celui-ci possède les permissions nécessaires. On peut poursuivre l'isolation entre les différentes couches en ajoutant des restrictions de flux réseaux par exemple.
