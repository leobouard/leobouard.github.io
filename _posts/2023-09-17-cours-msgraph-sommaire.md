---
layout: post
title: "Sommaire"
description: "Table des matières pour le cours"
nextLink:
  name: "Partie 1"
  id: "/2023/09/17/cours-msgraph-001"
prevLink:
  name: "Introduction"
  id: "/2023/09/17/cours-msgraph-introduction"
---

## Table des matières

{% assign posts = site.posts | sort: 'id' %}
<div class="summary">
  {% for post in posts %}
    {% if post.title contains 'Cours Microsoft Graph #' %}
      <a href="{{ post.id }}">
          <h3>{{ post.title }}</h3>
          <span>{{ post.description}}</span>
      </a>
    {% endif %}
  {% endfor %}
</div>
