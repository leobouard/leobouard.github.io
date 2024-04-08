---
layout: post
title: "Cours PowerShell 101"
description: "Être opérationnel en PowerShell le plus rapidement possible"
tags: powershell
listed: true
nextLink:
  name: "Partie 1"
  id: "/2024/04/07/cours-powershell-from-scratch-001"
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
