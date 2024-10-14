---
title: "Mettre à niveau les politiques de mots de passe"
description: "Comment mettre à jour vos politiques de mots de passe Active Directory (en évitant de tout casser) ?"
tags: active-directory
listed: true
---

## Introduction

Les politiques de mots

## Définition des nouvelles politiques

### Default Domain Password Policy

Paramètre                             | Valeur
---------                             | ------
Historique de mot de passe            | A votre convenance
Durée de vie maximale du mot de passe | 500 jours
Durée de vie minimale du mot de passe | 0 jour
Respect des exigences de complexité   | Oui
Longueur minimale du mot de passe     | 10 caractères

### PSO Administrateurs

### PSO Comptes de service

## Audit de la longueur des mots de passe

### Activation de l'audit

### Récupération des données de l'audit

## Communication et pédagogie

### Support utilisateurs

- CNIL : comment générer un bon mot de passe
- Mettre à disposition un coffre-fort numérique
- MOOC de l'ANSSI sur la gestion des mots de passe

### Déploiement d'un rappel par email

[leobouard/PasswordReminderByEmail: Send an email to your Active Directory users with a password about to expire (github.com)](https://github.com/leobouard/PasswordReminderByEmail)

## Déploiement des nouvelles politiques