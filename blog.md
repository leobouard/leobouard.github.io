---
permalink: /blog
layout: standard
title: "Tous mes articles"
description: "Tous les articles, cours et défis sur PowerShell et d'autres technologies Microsoft"
---

<div class="posts">
    {% assign listed_posts = site.posts | where: "listed", true %}
    {% for post in listed_posts %}
        <a class="noDecoration" href="{{ post.id }}">
            {% if post.capsule %}<span class="articlePill">{{ post.capsule }}</span>{% endif %}
            <article>
                <div class="articleThumbnail">
                    <img src="{{ post.thumbnail }}" alt="">
                </div>
                <span class="articleTitle">{{ post.title }}</span>
                <span class="articleDescription">{{ post.description }}</span>
                <div class="articleTags">
                    {% for tag in post.tags %}<span>#{{ tag }}</span>{% endfor %}
                </div>
            </article>
        </a>
    {% endfor %}
</div>
