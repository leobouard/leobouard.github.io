---
permalink: /blog
layout: standard
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
                {% if post.favorite %}<div class="favoriteMarker">⭐</div>{% endif %}
                <small>{{ post.tags }}</small>
                <div class="articleThumbnail">
                    <span class="articleIcon">{{ post.icon }}</span>
                </div>
                <div class="articleText">
                    <span class="articleTitle">{{ post.title }}</span>
                    <span class="articleDescription">{{ post.description }}</span>
                </div>
            </article>
        </a>
    {% endfor %}
</div>
