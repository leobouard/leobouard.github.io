---
layout: post
title: "Les données structurées"
description: "J'ai pas de jeu de mot pour celle-ci"
tags: howto
thumbnailColor: "#3C787E"
icon: 👓
---

## Informations en bref

Dans cet article j'aborde le thème des "fichiers de données structurées". Souvent externe aux scripts PowerShell, ils permettent d'importer, exporter, stocker ou requêter des données via PowerShell. Dans les types de fichiers récurents, on retrouve :

- **CSV** : le meilleur ami de PowerShell, très souvent utilisé pour peupler ou extraire des données sur Active Directory
- **JSON** : le meilleur ami de JavaScript, mais qui est de plus en plus utilisé pour les configurations Azure et en PowerShell
- **XAML** : utilisé pour les interfaces graphique en WPF ou la sauvegarde d'identifiants de connexion par exemple ([Import-CliXml](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-clixml))
- **TXT** : souvent utilisé les journalisations d'un script ou les bannières d'affichage
- **YAML** : plus simple et plus complet que JSON, il n'est malheureusement pas supporté nativement par PowerShell

...et sûrement plein d'autres formats que j'oublie.

Chacun de ces types fichiers ont leurs usages, leurs avantages et inconvénients. On va ce concentrer exclusivement sur le CSV et le JSON qui sont les plus faciles à utiliser avec PowerShell (en attendant le support natif du YAML 😄).

<div class="button">
    <a href="/2022/05/19/donnes-structurees-1" style="background-color: #43aa8b;">On commence par CSV</a>
</div>