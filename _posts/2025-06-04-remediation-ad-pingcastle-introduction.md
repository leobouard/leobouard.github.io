---
title: "Remédiation AD avec Ping Castle"
description: "Toutes mes notes sur les remédiations à faire pour chaque Rule ID"
tags: activedirectory
listed: true
nextLink:
  name: "Stale Object"
  id: "/2025/06/05/remediation-ad-pingcastle-stale-object"
---

## Introduction

Mes notes sur les résolutions et les points de vérification pour chaque vulnérabilité trouvée par Ping Castle dans votre domaine Active Directory.

### Outils utiles

- [Download - PingCastle](https://www.pingcastle.com/download/)
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
