---
permalink: /
title: "Accueil"
description: "Blog technique sur PowerShell et les technologies Microsoft pour l'administration système"
---

<div class="div_container">
    <div class="div_hero">
        <div class="div_hero_text">
            <h1 id="bienvenue">Bienvenue sur un blog qui se prend pas trop au sérieux</h1>
            <p>Vous l'avez peut-être deviné rien qu'au nom ! Ici on parle de PowerShell et d'autres technologies Microsoft</p>
            <a href=""></a>
            <a href=""></a>
        </div>
    </div>
</div>

<section style="margin-top: -50px;">
    <h2>Les derniers articles</h2>
    <div class="posts">
        {% assign listed_posts = site.posts | where: "listed", true %}
        {% assign last_three_posts = listed_posts | slice: 0, 3 %}
        {% for post in last_three_posts %}
            <article>
                <small>{{ post.tags }}</small>
                {% if post.favorite %}
                <div class="favoriteMarker">⭐</div>
                {% endif %}
                <a href="{{ post.id }}">
                    <p class="articleIcon">{{ post.icon }}</p>
                </a>
                <hr>
                <div class="articleDescription">
                    <h3>{{ post.title }}</h3>
                    <p>{{ post.description }}</p>
                    <a class="articleButton" href="{{ post.id }}">Continuer →</a>
                </div>
            </article>
        {% endfor %}
    </div>
    <div class="buttonNext" style="display: flex; align-items: center; justify-content: center; margin: 20px;">
        <a href="/blog">Voir tous les articles</a>
    </div>
</section>