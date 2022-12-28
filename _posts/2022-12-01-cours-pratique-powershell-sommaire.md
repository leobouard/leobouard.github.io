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

{% assign powershell_posts = site.posts | where: "title", "Partie" | sort "title" %}
<div class="div_summary">
{% for post in powershell_posts %}
    <a href="{{ post.id }}">
        <h3>{{ post.title }}</h3>
        <span>{{ post.description}}</span>
    </a>
{% endfor %}
</div>

