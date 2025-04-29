---
title: "TIERING #6 - PAW"
description: "Mise en place de Privileged Access Workstation"
tableOfContent: "/2024/11/01/tiering-model-introduction#table-des-matières"
nextLink:
  name: "Partie 7"
  id: "/2024/11/01/tiering-model-007"
prevLink:
  name: "Partie 5"
  id: "/2024/11/01/tiering-model-005"
---

## Définition

Un PAW (Privileged Access Workstation) est une station de travail dédiée à l'administration sécurisée des environnements informatiques. Elle est conçue pour isoler les tâches administratives sensibles des activités quotidiennes des utilisateurs, réduisant ainsi les risques de compromission des comptes privilégiés.

Les PAW fournissent un environnement sécurisé pour les administrateurs, protégeant contre les attaques par hameçonnage, les vulnérabilités des applications et du système d'exploitation, ainsi que les vols d'informations d'identification. En séparant les tâches administratives des tâches utilisateur, les PAW renforcent la sécurité globale de l'infrastructure Active Directory.

## Modèles de PAW

Il existe principalement deux modèles pour les PAW :

- avec un PC physique dédié
- par un serveur de rebond sur lequel on se connecte via un bastion

### PC physique dédié

C'est le modèle le plus simple et le plus sécurisé, puisqu'il sépare physiquement les usages. Un ordinateur sert à la navigation web, aux tâches bureautiques, à l'envoi d'emails, à la documentation et aux réunions (par exemple). L'autre ordinateur sert uniquement aux tâches d'administration du système d'information.

Le PC dédié à l'administration est alors renforcé au maximum, avec tous les moyens utiles :

- durcissement de l'OS
- interdiction de déplacement avec cet ordinateur
- restrictions réseau et d'accès à Internet
- filtre de confidentialité obligatoire

Si le niveau de sécurité de ce modèle est prouvé, la facilité d'usage au quotidien pour les administrateurs est lourdement impactée.

### Serveur de rebond via un bastion

Un bastion sert de point d'accès sécurisé pour les administrateurs sur des ressources distantes. La plupart du temps, le bastion prend la forme d'une interface web qui permet d'avoir accès à un client RDP intégré.

Dans ce scénario, on autorise l'accès à un serveur de rebond depuis le PC "bureautique" uniquement à travers ce bastion.

Cette solution est de loin la plus facile à utiliser au quotidien (un seul ordinateur, la possibilité de faire du copier-coller rapidement, des captures d'écran...), mais elle vient au prix d'une sécurité moindre, car un keylogger ou une faille dans le bastion pourrait mener à une escalade d'un attaquant vers des ressources critiques de votre Active Directory.

## Renforcement de l'OS

Pour en savoir plus à ce sujet, vous pouvez consulter mon article sur HardeningKitty : [HardeningKitty \| LaBouaBouate](/2024/07/17/hardening-kitty)