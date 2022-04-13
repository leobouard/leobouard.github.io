---
permalink: /challenges.html
---

# Tous mes défis PowerShell

Et voilà le travail !

<div class="posts">
    {% for post in {{site.posts | where: 'tags',challenges}} %}
        <a href="{{ post.url }}">
            <div>
                <img src="{{ post.image | default: "https://flemmingss.com/wp-content/uploads/2019/08/featured_image_powershell.png" }}" loading="lazy"/>
                <h3>{{ post.title }}</h3>
                <p>{{ post.description }}</p>
            </div>
        </a>
    {% endfor %}
</div>
