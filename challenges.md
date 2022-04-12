---
permalink: /challenges.html
---

# Tous mes défis PowerShell

Et voilà le travail !

<div class="posts">
    {% for post in site.posts | where: 'tags',challenges %}
        <div>
            <a href="{{ post.url }}">
                <img src="{{ post.image | default: "https://images.unsplash.com/photo-1542831371-29b0f74f9713?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1740&q=80" }}" loading="lazy"/>
                <h3>{{ post.title }}</h3>
                <p>{{ post.description }}</p>
            </a>
        </div>
    {% endfor %}
</div>
