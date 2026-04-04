---
title: "Mon compte Microsoft a été compromis"
description: "Quand l'attaquant se trouve dans votre propre maison"
tags: ["securite", "trivia"]
---

> Aujourd'hui, je fais un article un peu différent. Pas de technique, simplement une histoire courte 😊

## Un mot de passe compromis

Vendredi soir, je prépare à manger dans la cuisine en écoutant un peu de musique quand je reçois une notification. Elle provient de Microsoft Authenticator, pour confirmer une connexion à mon compte en choisissant l'un des trois nombres affichés par l'application.

Évidemment, ce n'est pas moi (ou ma femme) qui ai déclenché cette demande de MFA, donc je la refuse et je me dis que **le mot de passe de mon compte Microsoft a été compromis**. Je commence à lister dans ma tête les choses à faire pour gérer cette situation :

- Changement de mot de passe du compte Microsoft
- Demande de déconnexion de tous mes appareils
- Changement de la master key de mon coffre-fort numérique
- Vérification de mon adresse e-mail sur [Have I Been Pwned](https://haveibeenpwned.com/)
- Vérification des activités de connexion sur mon compte Microsoft

Bien sûr, je n'ai pas envie de faire tout ça depuis mon écran de téléphone, donc je me dirige dans le bureau pour m'installer devant mon PC, avec un grand écran.

## Le ou la coupable

Et là, le mystère est résolu avant même d'allumer l'écran :

![J'ai trouvé le coupable](/assets/images/attaquant-dans-ma-maison001.jpg)

Après une journée en télétravail, ma fille a probablement voulu m'imiter en s'asseyant sur ma chaise de bureau et en tapant sur le clavier. Comme mon PC était verrouillé, l'option "J'ai oublié mon code confidentiel" était disponible juste en dessous du code PIN de déverrouillage. À partir de là, il est possible de réinitialiser le code PIN en choisissant "Envoyer une notification", ce qui a déclenché la demande de MFA sur mon téléphone.

La prochaine fois que je reçois une demande de MFA impromptue, je me demanderai avant tout pourquoi ma fille est aussi silencieuse depuis 5 minutes.
