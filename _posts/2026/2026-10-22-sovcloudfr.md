---
permalink: /sovcloudfr
title: "URLs Azure & M365 sovcloud.fr"
description: "Les liens utiles pour administrer vos tenants Microsoft 365 et Azure hébergés chez Bleu"
tags: ["microsoft365", "entraid"]
---

{{ page.description }}

## Liens rapides

{% include filter-link.html %}
<div class="searchbar-container">
  <input class="searchbar" type="text" id="searchbar" placeholder="Rechercher un lien..." onkeyup="filterLinkBySearch()" />
  <i class="fa-solid fa-magnifying-glass"></i>
</div>

<div style="display: grid; grid-gap: 1em; margin: 1em auto; grid-template-columns: repeat(auto-fill, minmax(min(13rem, 100%), 1fr));">

{% assign links = site.data.sovcloudfr %}
{% for link in links %}
  {% include sovcloudfr-link.html name=link.name url=link.url icon=link.icon %}
{% endfor %}

</div>

## Ressources

Voici les ressources qui ont été utilisées pour la création de cette page :

- L'idée originale vient de [cmd.ms](https://cmd.ms/)
- Les icônes proviennent de [dashboardicons.com](https://dashboardicons.com/icons?q=microsoft) ou directement des consoles Microsoft lorsque c'est possible
- Le fichier CSV d'origine est disponible ici : [sovcloudfr.csv](https://github.com/{{ site.github_owner }}/{{ site.github_repo }}/tree/{{ site.github_branch }}/_data/sovcloudfr.csv)
