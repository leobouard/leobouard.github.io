---
title: "Lancement de programmes depuis PowerShell"
description: "Comment lancer certains programmes depuis une console PowerShell"
tags: ["windows", "powershell"]
---

Que vous soyez sur une version de Windows installée en 

{% assign general = site.data.process-windows | where: "category", "Général" | first %}
{% assign active-directory = site.data.process-windows | where: "category", "Active Directory" %}
{% assign certificates = site.data.process-windows | where: "category", "Certificats" %}
{% assign powershell = site.data.process-windows | where: "category", "PowerShell et développement" %}

## Général

{% assign general = | where_exp: "item", "item.hidden != true" %}
<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: auto; width: auto;">
{% for process in general.processes %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

## Active Directory

<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: auto; width: auto;">
{% for process in active-directory.processes %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

## Certificats

<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: auto; width: auto;">
{% for process in certificates.processes %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

## PowerShell et développement

<div style="display: flex; grid-gap: 1em; flex-wrap: wrap; margin: auto; width: auto;">
{% for process in powershell.processes %}
  {% include windows-shortcut.html name=process.name shortcut=process.shortcut %}
{% endfor %}
</div>

> Pour lancer une nouvelle instance `cmd` ou `pwsh` (plutôt que simplement basculer vers), vous devez utiliser la commande `Start-Process pwsh` par exemple.
