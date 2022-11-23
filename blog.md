---
permalink: /blog
---

# Articles

## Les derniers articles

<div class="posts">
    {% for post in site.posts %}
        {% if post.thumbnailColor contains "#" %}
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
