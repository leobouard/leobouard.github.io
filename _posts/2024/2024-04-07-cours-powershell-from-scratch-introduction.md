---

title: "Cours PowerShell 101"
description: "Être opérationnel en PowerShell le plus rapidement possible"
tags: ['cours','powershell']
listed: true
nextLink:
  name: "Partie 1"
  id: "cours-powershell-from-scratch-001"
---

## Table des matières

{% assign posts = site.posts | sort: 'id' %}
<div class="summary">
  {% for post in posts %}
    {% if post.title contains 'PS101 #' %}
      <a href="{{ post.id }}">
          <h3>{{ post.title }}</h3>
          <span>{{ post.description}}</span>
      </a>
    {% endif %}
  {% endfor %}
</div>

## Téléchargements

- [Téléchargement de PowerShell 7](https://learn.microsoft.com/powershell/scripting/install/installing-powershell-on-windows#msi)
- [Téléchargement de Visual Studio Code](https://code.visualstudio.com/)
- [Support Markdown pour les étudiants](/assets/files/PowerShell%20101.md)
