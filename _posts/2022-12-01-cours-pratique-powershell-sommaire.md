---
layout: post
title: "Cours pratique PowerShell"
description: "Table des matières pour le cours pratique"
icon: 🎓
---

## Sommaire

<div>
    {% assign posts = site.posts | sort: 'id' %}
    {% for post in posts %}
        <a href="{{ post.id }}" style="display: block; display: block; padding: 10px; margin: 10px; background: #fafafa; border-radius: 5px;">
            <h4>{{ post.Title }}</h4>
            <span>{{ post.Description }}</span>
        </a>
    {% endfor %}
</div>