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

### Pour aller plus loin

Cette API reste relativement simple et est idéale pour débuter. Cependant, la plupart des APIs (Microsoft Graph en tête) sont souvent plus complexes. Pour aller plus loin, on va donc intégrer des nouveaux éléments :

- les paramètres de requêtes
- la pagination

#### Pagination

L'un des objectifs de n'importe quelle API est de pouvoir interagir avec de la donnée le plus rapidement possible. Pour cela, la plupart des API REST utilisent un principe de pagination : toutes les données ne sont pas disponibles dès la première requête : il va falloir défiler les pages.

Chaque page peut contenir un nombre maximum de données. Cela varie suivant l'API et il n'y a pas de règles strictes. Dans tous les cas, lorsqu'une API utilise de la pagination, l'une des propriétés retournée servira à indiquer l'adresse de la prochaine page, que l'on devra inclure dans notre prochaine requête.

#### Paramètres de requête

Pour éviter de demander de l'information qui ne nous est pas utile, on peut formater la donnée avant qu'elle nous soit envoyée. Pour cela on utilise donc les paramètres de requêtes. Ceux-ci vont nous permettre de trier, filtrer, compter ou formater de la donnée avant que celle-ci ne soit reçu. Cela permet donc d'améliorer grandement l'efficacité de nos requêtes.

Ce sont également les paramètres de requêtes qui vont nous permettre de tourner les pages.

#### Authentification

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
