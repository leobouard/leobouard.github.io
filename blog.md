---
permalink: /blog
description: "Tous les défis, cours et articles sur PowerShell et d'autres technologies Microsoft"
---

# Articles

## Tous les articles

<div class="posts">
    {% for post in site.posts %}
        {% if post.listed == true %}
            <article>
                <small>{{ post.tags }}</small>
                <p style="text-align: center; font-size: 75px; line-height: 0px; user-select: none;">{{ post.icon }}</p>
                <hr>
                <h2>{{ post.title }}</h2>
                <p>{{ post.description }}</p>
                <a style="position: absolute; bottom: 15px; right: 15px;" href="{{ post.id }}">Continuer →</a>
            </article>
        {% endif %}
    {% endfor %}
</div>
