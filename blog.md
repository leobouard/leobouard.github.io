---
permalink: /blog
---

# Articles

## Tous les articles

<div class="posts">
    {% for post in site.posts %}
        {% if post.listed == true %}
            <article>
                <p style="text-align: center; font-size: 65px;">{{ post.icon }}</p>
                <hr>
                <h2>{{ post.title }}</h2>
                <p>{{ post.description }}</p>
                <p><small>{{ post.tags }}</small></p>
                <p style="text-align: right; position: absolute; bottom: 15px;"><a href="{{ post.id }}">Continuer →</a></p>
            </article>
        {% endif %}
    {% endfor %}
</div>

## Pourquoi des défis ?

Vous avez peut-être remarqué : certains articles ont la balise "Défi". **Parce qu'on apprend mieux en s'amusant, je propose une série de défis à relever avec PowerShell**. Comme d'habitude sur ce blog, je pars du principe que vous savez faire vos propres recherches, que vous êtes familier avec la syntaxe et que vous connaissez les bases du langages. En revanche, j'essaye de faire en sorte que vous n'ayez besoin ni d'une infrastructure de test (Active Directory ou tenant Microsoft 365 par exemple) ni d'installer des modules supplémentaires ! Donc si vous avez un accès à Internet (et normalement cette condition est remplie puisque vous lisez cette phrase sur un site web) et un terminal de commande avec Windows PowerShell 5.1 ou supérieur : félicitations, vous avez tous les outils pour participer aux défis !

Par contre vous êtes prévenus : il n'y a pas de récompense à la clé ! Mais qui sait, peut-être qu'à l'occasion vous aurez appris deux-trois trucs.
