---
title: "Remédiation Active Directory avec Ping Castle"
description: "Toutes mes notes sur les remédiations à faire pour chaque vulnérabilité trouvée par Ping Castle"
tags: ["activedirectory", "pingcastle"]
listed: true
nextLink:
  name: "Stale Object"
  id: "remediation-ad-pingcastle-001"
---

## Introduction

Mes notes sur les résolutions et les points de vérification pour chaque vulnérabilité trouvée par Ping Castle dans votre domaine Active Directory.

### Conseils

Si vous avez la possibilité de vous procurer une licence auditeur, je vous la recommande vivement ! Même si celle-ci n'est pas indispensable, elle reste très utile pour identifier les tâches prioritaires (criticité 1 & 2) et avoir accès à plus d'informations.

Pensez également à garder scrupuleusement vos fichiers XML générés par Ping Castle, et pas uniquement les fichiers HTML. Ceux-ci vous seront utiles pour rendre compte de l'avancée de votre remédiation.

{% include github-repository.html repository="leobouard/PingCastleDashboard" %}

## Table des matières

{% assign posts = site.posts | sort: 'id' %}
<div class="summary">
  {% for post in posts %}
    {% if post.title contains 'PING CASTLE -' %}
      <a href="{{ post.id }}">
          <h3>{{ post.title }}</h3>
          <span>{{ post.description}}</span>
      </a>
    {% endif %}
  {% endfor %}
</div>

## Toutes les vulnérabilités

{% include filter-vuln.html %}
<div class="searchbar-container">
  <input class="searchbar" type="text" id="searchbar" placeholder="Rechercher une vulnérabilité..." onkeyup="filterVulnBySearch()" />
  <i class="fa-solid fa-magnifying-glass"></i>
</div>

<div class="ping-castle-vuln">
{% assign posts = site.posts | sort: 'id' %}
{% for post in posts %}
  {% if post.title contains 'PING CASTLE -' %}
    {{ post.content }}
  {% endif %}
{% endfor %}
</div>
