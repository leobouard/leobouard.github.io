---
title: "Remédiation AD avec Ping Castle"
description: "Toutes mes notes sur les remédiations à faire pour chaque Rule ID"
tags: activedirectory
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

### Outils utiles

- [Download - PingCastle](https://www.pingcastle.com/download/)
- [PingCastle Health Check rules](https://pingcastle.com/PingCastleFiles/ad_hc_rules_list.html)
- [leobouard/PingCastleDashboard: Consolidate and review your XML PingCastle files into a simple dashboard](https://github.com/leobouard/PingCastleDashboard)

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

<!--
{% assign posts = site.posts | sort: 'id' %}
{% for post in posts %}
  {% if post.title contains 'PING CASTLE -' %}
    <hr>
    {{ post.content }}
  {% endif %}
{% endfor %}
-->