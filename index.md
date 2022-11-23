---
permalink: /
---

# Bienvenue

...mais vous venez un peu trop tôt, j'ai pas eu le temps de tout finir ! La page est en cours de construction, promis elle sera belle !

Pour l'instant elle n'est pas prête, il me reste encore des choses à faire avant :

- [ ] Remettre en forme le pied de page
- [ ] Refaire le CSS pour les extraits de code
- [ ] Changer le style pour la balise "pre"
- [ ] Fusionner les pages "Articles" et "Défis"
- [ ] Faire de nouvelles cartes, plus jolies et plus petites avec :
  - [ ] le tag de l'article
  - [ ] la date d'écriture
  - [ ] un bouton pour lire l'article

## Les derniers articles

<div class="posts">
    {% assign listed_posts = sites.posts.listed | where: 'true'}
    {% for post in listed_posts limit:3 %}
        <article>
            <div style="background-color: {{ post.thumbnailColor }}; height: 100px;"></div>
            <h2>{{ post.title }}</h2>
            <hr>
            <p>{{ post.description }}</p>
            <p><small>{{ post.tags }}</small></p>
            <p><a href="{{ post.id }}">Continuer →</a></p>
        </article>
    {% endfor %}
</div>