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
            {% if post.selection == true %}<span class="articleSelection">⭐ Sélection</span>{% endif %}
            <article>
                <div class="articleThumbnail" {% if post.background %} style="background: {{post.background}};" {% endif %}>
                    <span class="articleTitle">{{ post.title }}</span>
                    <span class="articleDate">{{ post.date | date: "%d/%m/%Y" }}</span>
                </div>
                <div class="articleText">
                    <span class="articleDescription">{{ post.description }}</span>
                </div>
                <div class="articleTags">
                    {% for tag in post.tags %}<span>{{ tag }}</span>{% endfor %}
                </div>
            </article>
        </a>
    {% endfor %}
</div>
