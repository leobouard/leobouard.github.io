---
layout: post
title: "Sommaire"
description: "Table des matières pour le cours pratique"
icon: 🎓
nextLink:
  name: "Partie 1"
  id: "/2022/12/01/cours-pratique-powershell-001"
prevLink:
  name: "Introduction"
  id: "/2022/12/01/cours-pratique-powershell-introduction"
---

## Table des matières

<div class="div_summary">
{% for post in site.posts %}
  {% if post.id starts_with "2022-12-01-cours-pratique-powershell-0" %}
    <a href="{{ post.id }}">
        <h3>{{ post.title }}</h3>
        <span>{{ post.description}}</span>
    </a>
  {% endif %}
{% endfor %}
</div>

