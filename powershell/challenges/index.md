---
permalink: /powershell/challenges.html
---

# Tous mes défis PowerShell

Et voilà le travail !

<div class="posts">
    {% for post in site.posts %}
        <div>
            <a href="{{ post.url }}">
                <img src="{{ post.image }}" loading="lazy"/>
                <h1>{{ post.title }}</h1>
                <p>{{ post.description }}</p>
                <small class="tags">{{ post.tags }}</small>
            </a>
        </div>
    {% endfor %}
</div>
