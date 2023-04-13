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
        <a class="noDecoration" href="{{ post.id }}">
            <article>
                <small>{{ post.tags }}</small>
                <div class="articleThumbnail">
                    <span class="articleTitle">{{ post.title }}</span>
                </div>
                <div class="articleText">
                    <!-- <span class="articleDate">{{ post.date | date: "%d/%m/%Y" }}</span> -->
                    <span class="articleDescription">{{ post.description }}</span>
                </div>
            </article>
        </a>
    {% endfor %}
</div>
