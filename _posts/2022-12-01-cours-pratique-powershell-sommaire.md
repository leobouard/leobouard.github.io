---
layout: post
title: "Sommaire"
description: "Table des matières pour le cours pratique"
nextLink:
  name: "Partie 1"
  id: "/2022/12/01/cours-pratique-powershell-001"
prevLink:
  name: "Introduction"
  id: "/2022/12/01/cours-pratique-powershell-introduction"
---

## Table des matières

{% assign posts = site.posts | sort: 'id' %}
<div class="summary">
  {% for post in posts %}
    {% if post.title contains 'Cours PowerShell #' %}
      <a href="{{ post.id }}">
          <h3>{{ post.title }}</h3>
          <span>{{ post.description}}</span>
      </a>
    {% endif %}
  {% endfor %}
</div>
