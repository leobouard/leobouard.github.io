---
title: "TIERING #1"
description: ""
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 2"
  id: "/2024/11/01/tiering-model-002"
prevLink:
  name: "Introduction"
  id: "/2024/11/01/tiering-model-introduction"
---

### Définition

Le tiering model est un concept de sécurité de l'Active Directory qui segmente les ressources (ordinateurs, utilisateurs, groupes) en différents niveaux.

Ces différents niveaux sont classés du plus critique (Tier 0) au moins critique (Tier 2). Habituellement, voici ce que contiennent les différents niveaux :

1. **Tier 0 :** regroupe les ressources critiques pour Active Directory comme les administrateurs du domaine et les contrôleurs du domaine.
2. **Tier 1 :** contient les serveurs applicatifs de l'entreprise et leurs administrateurs.
3. **Tier 2 :** contient les utilisateurs sans privilèges, tous les périphériques sur lesquels ils se connectent et les adminstrateurs de stations de travail.

Tout le principe du tiering model repose sur la thèse qu'un attaquant peut obtenir le compte de n'importe quel utilisateur connecté ou s'étant connecté sur un ordinateur/serveur pour rebondir ensuite. En partant de ce principe, il faut donc segmenter les usages et utiliser un compte différent pour chaque tier.

L'idée de cette segmentation est d'empêcher ou ralentir l'escalade d'une attaque vers les ressources sensibles et/ou critiques (Tier 1 et Tier 0). Le Tier 2 étant de très loin le plus exposés aux attaques de par :

- le nombre de ressources, qui représente souvent 90% des objets dans un domaine
- l'exposition des utilisateurs standards à des attaques comme le hammeçonnage
- l'accès physique aux ressources (comme les ordinateurs)

...il est important d'isoler ces ressources pour éviter qu'un attaque puisse directement rebondir d'un ordinateur vers un serveur applicatif ou un contrôleur de domaine. Une attaque se produisant dans un tier **ne peut donc pas se propager aux autres tiers** (en théorie).

L'isolation des ressources entre-elles se fait principalement par l'interdiction de connexion vers une ressource un tier supérieur ou inférieur. Ainsi, un utilisateur du Tier 2 ne pourra pas se connecter sur un serveur du Tier 1, même si celui-ci est autorisé.
