---
permalink: /
description: "Blog technique sur PowerShell et les technologies Microsoft pour l'administration système"
---

# Bienvenue

## C'est quoi "LaBouaBouate" ?

LaBouaBouate est un blog technique pour partager des connaissances sur les technologies Microsoft (Active Directory, Microsoft 365, Azure AD...) et notamment <b>le langage de scripting PowerShell</b> (anciennement connu sous le nom de Windows PowerShell). Vous pourrez donc retrouver sur site :

- des articles techniques sur les produits Microsoft
- des retours d'expériences dans des contextes professionnels
- des défis PowerShell pour vous améliorer
- quelques cours rapides

## Les derniers articles

<div class="posts">
    {% assign listed_posts = site.posts | where: "listed", true %}
    {% assign last_three_posts = listed_posts | slice: 0, 3 %}
    {% for post in last_three_posts %}
        <article>
            <small>{{ post.tags }}</small>
            <a href="{{ post.id }}">
                <p style="text-align: center; font-size: 75px; line-height: 0px; user-select: none;">{{ post.icon }}</p>
            </a>
            <hr>
            <h2>{{ post.title }}</h2>
            <p>{{ post.description }}</p>
            <a style="position: absolute; bottom: 15px; right: 15px;" href="{{ post.id }}">Continuer →</a>
        </article>
    {% endfor %}
    <div class="buttonNext" style="display: flex; align-items: center; justify-content: center; margin: 20px;">
        <a href="/blog">Voir tous les articles</a>
    </div>
</div>