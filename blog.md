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
        <a href="{{ post.id }}">
            <article>
                <small>{{ post.tags }}</small>
                <p class="articleIcon">{{ post.icon }}</p>
                <hr>
                <span class="articleTitle">{{ post.title }}</span>
                <span class="articleText">{{ post.description }}</span>
                <a class="articleButton" href="{{ post.id }}">Continuer →</a>
            </article>
        </a>
    {% endfor %}
</div>
