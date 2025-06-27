---
title: "SYSVOL quarantine avec Semperis ADFR"
description: "Renommer tous les fichiers exécutables contenus dans le SYSVOL lors d'une restauration de forêt"
tags: ["semperis", "activedirectory"]
listed: true
---

## Contexte

Lors d'une restauration de forêt avec Semperis ADFR (Active Directory Forest Recovery), si vous suspectez ou que vous avez le moindre doute sur la présence de malwares sur le partage SYSVOL de votre domaine, vous pouvez activer un mécanisme de quarantaine sur le serveur ADFR.

## Fonctionnement

Ce mécanisme va s'occuper de renommer les fichiers .EXE pour modifier l'extension et empêcher leur exécution.

### Clé de registre

Voici les informations sur la clé de registre à ajouter sur le serveur ADFR :

- Chemin : `HKLM\SOFTWARE\Semperis\Multiforest\<FORESTGUID>\Semperis\ADFR\Server
- Nom : AdfrQuarantineExecutablesInSysVol
- Type : REG_DWORD

Les valeurs possibles pour la clé de registre :

Valeur | Description
------ | -----------
0 | Continuer avec le comportement par défaut ; ne pas mettre en quarantaine (renommer) les fichiers exécutables dans SYSVOL
1 | Mettre en quarantaine (renommer) les fichiers exécutables lors de la restauration du contenu SYSVOL

<!--
Quelle extension est ajoutée sur les fichiers .EXE ?
Est-ce qu'il s'occupe de tous les répertoires SYSVOL du domaine ?
Comment récupérer le GUID de la forêt concernée ?
>