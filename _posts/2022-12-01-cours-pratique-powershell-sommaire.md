---
layout: post
title: "Cours pratique PowerShell"
description: "Table des matières pour le cours pratique"
icon: 🎓
---

## Sommaire

<div>
    {% assign listed_posts = site.posts | where: "id", "-cours-pratique-powershell-0" | sort: 'id' %}
    {% for post in listed_posts %}
        <a href="{{ post.id }}" style="display: block; display: block; padding: 10px; margin: 10px; background: #fafafa; border-radius: 5px;">
            <h4>{{ post.Title }}</h4>
            <span>{{ post.Description }}</span>
        </a>
    {% endfor %}
</div>