---
permalink: /sovcloudfr
title: "URLs Azure & M365 sovcloud.fr"
description: "Les liens utiles pour administrer votre tenant Microsoft 365 et Azure hébergé chez Bleu"
---

## Liens rapides

<div style="display: grid; grid-gap: 1em; margin: 1em auto; grid-template-columns: repeat(auto-fill, minmax(min(13rem, 100%), 1fr));">

{% assign links = site.data.sovcloudfr %}
{% for link in links %}
  {% include sovcloudfr-link.html name=link.name url=link.url category=link.category %}
{% endfor %}

</div>

## Ressources

L'idée originale vient évidemment de [cmd.ms](https://cmd.ms/) par [Merill Fernando](https://merill.net/) 🐐

Les icônes produits au format SVG proviennent de [Dashboard Icons](https://dashboardicons.com/icons?q=microsoft).

Pour consulter le fichier CSV original : [sovcloudfr.csv](https://github.com/{{ site.github_owner }}/{{ site.github_repo }}/tree/{{ site.github_branch }}/_data/sovcloudfr.csv)
