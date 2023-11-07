---
layout: post
title: "MSGRAPH #2"
description: "???"
tableOfContent: "/2023/09/17/cours-msgraph-sommaire"
nextLink:
  name: "Partie 3"
  id: "/2023/09/17/cours-msgraph-003"
prevLink:
  name: "Partie 1"
  id: "/2023/09/17/cours-msgraph-001"
---

## Pour aller plus loin

Cette API reste relativement simple et est idéale pour débuter. Cependant, la plupart des APIs (Microsoft Graph en tête) sont souvent plus complexes. Pour aller plus loin, on va donc intégrer des nouveaux éléments :

- les paramètres de requêtes
- la pagination
- l'authentification

### Pagination

L'un des objectifs de n'importe quelle API est de pouvoir interagir avec de la donnée le plus rapidement possible. Pour cela, la plupart des API REST utilisent un principe de pagination : toutes les données ne sont pas disponibles dès la première requête : il va falloir faire défiler les pages.

Chaque page peut contenir un nombre maximum de données. Cela varie suivant l'API et il n'y a pas de règles strictes. Dans tous les cas, lorsqu'une API utilise de la pagination, l'une des propriétés retournée servira à indiquer l'adresse de la prochaine page (sous forme d'URI le plus souvent), que l'on devra inclure dans notre prochaine requête.

Voici un exemple de réponse de Microsoft Graph avec une indication sur l'adresse de la page suivante avec la propriété `@odata.nextLink`.

```json
{
    "@odata.context": "https://graph.microsoft.com/v1.0/...",
    "value": [{...}],
    "@odata.nextLink": "https://graph.microsoft.com/v1.0/..."
}
```

### Paramètres de requête

Pour éviter de demander de l'information qui ne nous est pas utile, on peut formater la donnée avant qu'elle nous soit envoyée. Pour cela on utilise donc les paramètres de requêtes. Ceux-ci vont nous permettre de trier, filtrer, compter ou formater de la donnée avant que celle-ci ne soit reçu. Cela permet donc d'améliorer grandement l'efficacité de nos requêtes.

Les paramètres de requête vont se placer à la fin de notre URI

Nom |	Description
--- | -----------
$count | Récupère le nombre total de ressources correspondantes
$expand	| Récupère les ressources connexes
$filter	| Filtre les résultats (lignes)
$format	| Renvoie les résultats dans le format de média spécifié
$orderby | Classe les résultats
$search | Renvoie les résultats en fonction des critères de recherche
$select | Filtre les propriétés (colonnes)
$skip | Indexe dans un jeu de résultats. Également utilisé par certaines API pour implémenter la pagination et peut être utilisé avec $top pour pager manuellement les résultats
$top | Définit la taille de la page de résultats

Toutes les informations sur les paramètres de requêtes généraux pour Microsoft Graph sont disponibles ici : [Utilisation de paramètres de requête pour personnaliser des réponses](https://learn.microsoft.com/graph/query-parameters)

### Authentification

---

## Questions

**Qu’est-ce qu’une API ?**

- [ ] Une interface de programmation d’application
- [ ] Un langage de programmation
- [ ] Un système d’exploitation

**Quel est le rôle principal d’une API ?**

- [ ] Faciliter la communication entre deux logiciels
- [ ] Créer des interfaces utilisateur
- [ ] Stocker des données

**Quels sont les types courants de requêtes HTTP utilisées dans les API REST ?**

- [ ] GET, POST, DELETE
- [ ] GET, SET, REMOVE
- [ ] READ, WRITE, ERASE

**Qu’est-ce que JSON dans le contexte d’une API ?**

- [ ] Un format pour envoyer et recevoir des données
- [ ] Un protocole de transfert de données
- [ ] Un type de base de données**