---
permalink: /testing
title: "Testing"
description: "Page de contrôle"
---

# Titre 1

## Titre 2

### Titre 3

#### Titre 4

##### Titre 5

## Contrôle des éléments

### Texte de contrôle

Lorem ipsum dolor sit amet, **consectetur adipiscing elit**, sed do eiusmod tempor incididunt ut *labore et dolore magna aliqua*. Ut enim ad minim veniam, [quis nostrud exercitation](/) ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

> Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. 

Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt :

- Neque porro quisquam est
- Qui dolorem ipsum quia dolor sit amet
- Consectetur
- Adipisci velit

Sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. 

1. Ut enim ad minima veniam
2. Quis nostrum exercitationem ullam corporis suscipit laboriosam
3. Nisi ut aliquid ex ea commodi consequatur

Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur

### Code de contrôle

#### PowerShell

```powershell
Get-ADUser -Filter {ANR -eq 'john smith'}
```

#### JSON

```json
{
    "givenName": "John",
    "surname": "SMITH",
    "groups": [
        "All employees",
        "Domain Users"
    ]
}
```

#### PlainText

```plaintext
gpupdate /force /target:computer
```

#### Other

```other
item.innerHTML += '<i class="fa-solid fa-circle-check"></i>';
```

## Includes

### article-info.html

{% include article-info.html date="2025-01-15" content=page.content %}

### author-info.html

{% include author-info.html %}

### blog-header.html

{% include blog-header.html %}

### breadcrumbs.html

{% include breadcrumbs.html %}

### comments.html

{% include comments.html %}

### filter-searchbar.html

{% include filter-searchbar.html %}

### github-gist.html

{% include github-gist.html name="Fonction fictive" id="00000000000000000000000000000000" %}

### github-repository.html

{% include github-repository.html repository="exemple/Projet-fictif" %}

### post-preview.html

{% include post-preview.html id="/articles/exemple-fictif/" date="2025-01-15" title="Article fictif" description="Présentation d'un article de démonstration." tags=page.demo_tags %}

### quick-test.html

{% include quick-test.html %}

Exemple de question en utilisant l'include "quick-test.html" :

- [ ] Réponse A
- [ ] Réponse B
- [x] La bonne réponse
- [ ] Réponse D

Plusieurs bonnes réponses maintenant :

- [x] Première bonne réponse
- [ ] Réponse B
- [x] L'autre bonne réponse
- [ ] Réponse D

### risk-score.html

{% include risk-score.html impact="3" probability="3" comment="Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut *labore et dolore magna aliqua." %}

### sovcloudfr-link.html

{% include sovcloudfr-link.html name="Portail de test" url="portail.exemple.invalid" icon="microsoft" %}

### talk.html

{% include talk.html url=page.demo_event.url title="Présentation fictive" event=page.demo_event date="janvier 2025" place="En ligne" slide=page.demo_slide_url %}

### windows-shortcut.html

{% include windows-shortcut.html name="Console de commandes (exemple)" shortcut="cmd" %}