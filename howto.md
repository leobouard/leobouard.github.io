---
permalink: /howto
---

# Comment qu'on fait ? 🤔

Je n'ai pas la science infuse, mais j'essaye de partager au mieux mes petites trouvailles, en espérant que ça puisse aider quelqu'un d'autre.

<div class="posts">
    {% for post in site.posts %}
        {% if post.tags contains "howto" %}
            <a href="{{ post.id }}">
                <div class="card">
                    <div class="thumbnailLimits">
                        <div class="thumbnail" style="background-color: {{ post.thumbnailColor | default: "#9ea7eb" }}">{{ post.icon | default: "⚙️"}}</div>
                    </div>
                    <div class="postInfo">
                        <h3>{{ post.title }}</h3>
                        <p>{{ post.description }}</p>
                    </div>
                </div>
            </a>
        {% endif %}
    {% endfor %}
</div>
