---
permalink: /powershell/challenges.html
---

# Tous mes défis PowerShell

Et voilà le travail !

<div class="posts">
    {% for post in site.posts %}
        <div>
            <a href="{{ post.url }}">
                <img src="{{ post.image }}"/>
                <h1>{{ post.title }}</h1>
                <p>{{ post.description }}</p>
            </a>
        </div>
    {% endfor %}
</div>