---
permalink: /challenges
---

# Mes défis PowerShell 💪

Parce qu'on apprend mieux en s'amusant, je vous propose une série de défis à relever avec PowerShell.
Vous êtes prévenus : il n'y a rien de bien sérieux et aucun prix à la clé !

Mais qui sait, peut-être qu'à l'occasion vous apprendrez deux-trois trucs. 😉

<div class="posts">
    {% for post in site.posts %}
        {% if post.tags contains "challenges" %}
            <a href="{{ post.url }}">
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
