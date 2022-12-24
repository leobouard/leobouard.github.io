---
permalink: /blog
title: "Articles"
description: "Tous les articles, cours et défis sur PowerShell et d'autres technologies Microsoft"
---

# Articles

## Tous les articles

<div class="posts">
    {% assign listed_posts = site.posts | where: "listed", true %}
    {% for post in listed_posts %}
        <article>
            <small>{{ post.tags }}</small>
            <a href="{{ post.id }}">
                <p class="articleIcon">{{ post.icon }}</p>
            </a>
            <hr>
            <div class="article_description">
                <h2>{{ post.title }}</h2>
                <p>{{ post.description }}</p>
                <a class="articleButton" href="{{ post.id }}">Continuer →</a>
            </div>
        </article>
    {% endfor %}
</div>
