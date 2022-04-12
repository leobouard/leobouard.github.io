---
permalink: /challenges.html
---

# Tous mes défis PowerShell

Et voilà le travail !

<div class="posts">
    {% for post in site.posts | where: "tags","challenges" %}
        <div>
            <a href="{{ post.url }}">
                <img src="{{ post.image }}" loading="lazy"/>
                <h1>{{ post.title }}</h1>
                <p>{{ post.description }}</p>
            </a>
        </div>
    {% endfor %}
</div>
