---
title: "Lancement de programmes depuis PowerShell"
description: "Comment lancer certains programmes depuis une console PowerShell"
tags: ["windows", "powershell"]
---

## Introduction rapide

Que vous soyez sur une version de Windows installée dans une langue que vous ne maîtriser pas ou que vous deviez lancer plusieurs programmes "en tant que", voici quelques raccourcis pour exécuter des utilitaires Windows directement depuis une console PowerShell.

Le principe est simple : chaque application Windows a souvent un nom court (ProcessName) qui peut être utilisé pour le lancer, directement depuis une console PowerShell.

Vous n'avez donc qu'à ouvrir une console PowerShell en tant qu'administrateur (ou avec un autre utilisateur que celui qui a ouvert la session) et lancer le reste des programmes depuis le terminal. Pour lancer le panneau de configuration par exemple, vous n'avez qu'à taper la commande `control`.

{% assign general = site.data.process-windows | where: "category", "Général" %}
{% assign active-directory = site.data.process-windows | where: "category", "Active Directory" %}
{% assign certificates = site.data.process-windows | where: "category", "Certificats" %}
{% assign powershell = site.data.process-windows | where: "category", "PowerShell et développement" %}

## Catégories

### Général

<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: 1em auto; width: auto;">
{% for process in general %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

### Active Directory

Pour installer les consoles liées à Active Directory, vous devez exécuter les commandes suivantes :

```powershell
Install-WindowsFeature RSAT-AD-Tools, GPMC
```

Pour avoir accès à la console de modification du schéma, il faudra faire une commande supplémentaire :

```powershell
regsvr32 schmmgmt.dll
```

<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: 1em auto; width: auto;">
{% for process in active-directory %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

### Certificats

Pour installer les consoles liées à Active Directory Certificate Services (ADCS), vous devez exécuter les commandes suivantes :

```powershell
Install-WindowsFeature RSAT-ADCS
```

<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: 1em auto; width: auto;">
{% for process in certificates %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

### PowerShell et développement

<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: 1em auto; width: auto;">
{% for process in powershell %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

## Conseils et informations

### Sélection des raccourcis

La sélection disponible ici est personnelle et correspond à mes besoins. Si jamais vous souhaitez trouver le "raccourci" PowerShell d'un programme qui n'est pas listé, vous n'avez qu'à utiliser la commande `Get-Process` et trouver le nom du processus correspondant à votre exécutable.

Pour mettre en évidence le nom du processus, vous pouvez faire ces commandes :

```powershell
$start = (Get-Process).ProcessName
# Ouvrir ou fermer le programme qui vous intéresse
$end = (Get-Process).ProcessName
Compare-Object $start $end
```

> Tous les programmes ne peuvent pas se lancer avec le ProcessName. C'est le cas de Microsoft Edge (`msedge` pour les intimes) par exemple.

### Extraction des icônes

Les icônes que vous voyez ont été extraites avec l'utilitaire [Iconsext de NirSoft](https://www.nirsoft.net/utils/iconsext.html) (oui il y a le mot "sex" dans le nom mais promis c'est complètement SFW) sur un Windows Server 2022. Les fichiers sont d'abord extraits au format .ICO, puis je sélectionne le .PNG avec la meilleure définition (souvent en 48x48).

> N'allez pas installer ce vieux logiciel sur un serveur dans une infrastructure de production évidemment !

Si la résolution n'est pas fameuse, sachez que c'est le maximum que j'ai pu tirer de la DLL ou de l'exécutable.

### Exécution en tant qu'administrateur

Si vous souhaitez lancer une application en tant qu'administrateur alors que votre terminal n'a pas été lancé en tant que tel, vous pouvez faire une élevation avec la commande `Start-Process` et le paramètre ` -Verb`.

Voici un exemple pour lancer une nouvelle fenêtre de PowerShell 7+ en tant qu'administrateur :

```powershell
Start-Process pwsh -Verb RunAs
```

> Certains programmes ne peuvent pas être lancés en tant qu'administrateur ou avec un autre utilisateur que celui qui a ouvert la session, quoi que vous fassiez. C'est notamment le cas de l'explorateur de fichiers (`explorer`).
