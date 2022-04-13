---
permalink: /challenges.html
---

# Tous mes défis PowerShell

Et voilà le travail !

<div class="posts">
    {% for post in site.posts %}
        <a href="{{ post.url }}">
            <div class="card">
                <div class="thumbnail" style="background-color: {{ post.thumbnailColor | default: "#9ea7eb" }}">{{ post.icon | default: ⚙️}}</div>
                <h3>{{ post.title }}</h3>
                <p>{{ post.description }}</p>
            </div>
        </a>
    {% endfor %}
</div>
