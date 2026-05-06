---
title: "Guide de passage des certifications Microsoft"
description: "Comment préparer et obtenir une certification Microsoft, et quelle est la vraie valeur de celle-ci ?"
tags: ["microsoft365", "entraid"]
listed: true
---

## L'utilité du passage de certification

Microsoft annonce sur sa page [Titres et certificats de compétences professionnelles et techniques \| Microsoft Learn](https://learn.microsoft.com/fr-fr/credentials/) différentes métriques et pourcentages sur l'utilité d'une certification.

Honnêtement, la vraie valeur technique d'une certification n'est connue que des personnes qui l'ont déjà passée. Sinon, ça reste un beau badge officiel à ajouter sur un CV, qui permettra de vous distinguer d'un profil similaire au vôtre. Au-delà de la valeur technique du badge, une certification atteste toujours d'une volonté de monter en compétence ou de valoriser ses connaissances (ce qui est un très bon point).

> D'expérience, la présence d'une certification Expert attire souvent l'attention des recruteurs, mais elle n'est plus utile ou reconnue au moment des qualifications techniques.

### Compétence ≠ certification

Je le dis fréquemment et je profite de ce post pour le mettre par écrit :

<p style="font-size: larger; text-align: center; margin: 1em 2em;"><i>Ce n'est pas parce que vous avez la compétence technique que vous aurez la certification. Ce n'est pas parce que vous avez la certification que vous aurez la compétence technique.</i></p>

Compétences et certifications peuvent malheureusement être assez éloignées. J'admet volontiers que [certains des badges que j'ai pu obtenir](/certificates) ne sont liés à aucune compétence technique réelle, simplement d'un apprentissage théorique pour pouvoir répondre au QCM.

Et à contrario, certaines de mes compétences techniques ne peuvent pas être prouvée par des badges, notamment sur Active Directory ou PowerShell.

A titre personnel, j'ai tendance à me méfier techniquement des profils "trop certifiés", avec des certifications sur des domaines éloignés. Une sélection cohérente de certification est plus valorisante à mon sens. Quand je vois cette liste de certification, je me dis qu'il n'y en a aucune qui prouve un niveau technique :

![trop de certifs tue la certif](/assets/images/certifications-ms-001.png)

> En bref : *trop de certifs tue la certif*.

### L'utilité cachée

Les certifications ne sont pas pensées pour valoriser les profils techniques à un niveau individuel. Les certifications sont avant tout un dispositif mis en place par un éditeur logiciel (Microsoft par exemple) pour attester d'un niveau global dans une entreprise partenaire.

Elles ont une forte valeur pour les Entreprises de Services du Numériques (ESN), car elles permettent d'améliorer ou de maintenir leur partenariat auprès des éditeurs. Ce partenariat va permettre d'être mieux identifié et de remporter des appels d'offres directement via leur référencement. Un bon exemple est le [Partner Program de Microsoft](https://partner.microsoft.com/fr-fr/partnership/find-a-partner) qui est divisé en deux niveaux : Gold Partner et Silver Partner (en fonction notamment du nombre de certifiés dans l'entreprise).

C'est donc pour cette raison que les ESN financent et récompensent l'obtention de certifications.

## Préparer et obtenir votre certification Microsoft

### Création de votre compte Microsoft

Commencer par créer un compte Microsoft **personnel** si vous n'en avez pas déjà un. L'utilisation d'un compte personnel est très fortement recommandée, pour que vous puissiez garder vos certifications si vous quittez votre entreprise actuelle.

### Choisir un examen à réviser

Pour les certifications de niveau Fundamentals ou Associate, la question est simple : en général, un seul examen vous permettra d'obtenir la certification.

Les certifications experts en revanche, requièrent souvent l'obtention de plusieurs examens (c'est le cas de la MS-102 par exemple). Dans ce cas, je vous conseille de passer d'abord un examen intermédiaire qui vous permettra d'obtenir une première certification, et ensuite l'examen final.

Dans le cas de la certification [Microsoft 365 Administrator Expert](https://learn.microsoft.com/credentials/certifications/m365-administrator-expert/), je vous recommande de passer d'abord l'une des certifications listée en prérequis (par exemple la [Identity and Access Administrator Associate](https://learn.microsoft.com/credentials/certifications/identity-and-access-administrator/?practice-assessment-type=certification)) pour éviter d'avoir réussi un examen qui ne vous donne pas de certification immédiatement.

> #### Le cas des Applied Skills
>
> Si jamais une compétence appliquée (ou Applied Skill en anglais) est disponible sur le sujet de votre certification, je vous recommande de la passer. Il s'agit d'un examen **pratique** (donc pas de QCM) qui peut vous permettre d'obtenir un badge rapidement.
>
> Exemple : si vous comptez passer la SC-400, le [Microsoft Applied Skills : Implémenter la protection des données et la protection contre la perte de données à l’aide de Microsoft Purview](https://learn.microsoft.com/fr-fr/credentials/applied-skills/implement-information-protection-and-data-loss-prevention-by-using-microsoft-purview/) sera une bonne étape intermédiaire.
>
> Ils n'ont pas beaucoup de valeur technique, mais permettent de montrer que vous êtes proactifs dans votre montée en compétence.

### Lecture du cours Microsoft Learn

Chaque examen possède un parcours de formation "officiel" disponible sur [Microsoft Learn](https://learn.microsoft.com/fr-fr/training/browse/?resource_type=learning%20path), affiché sur la page de la certification. Celui-ci permet un apprentissage en autonomie et à votre rythme. Ce n'est souvent pas suffisant pour réussir un examen (notamment au niveau Associate et Expert), mais il vous permettra d'obtenir les connaissances théoriques liées à la certification (qui seront utiles pour la partie QCM).

Si vous le pouvez, lire le cours en anglais est conseillé pour vous familiariser avec les termes techniques originaux et vous mettre en condition pour l'examen qui sera lui aussi en anglais.

A vous de prendre des notes sur les sujets que vous pensez important, et à valider vos connaissances en posant des questions à une IA sur les sujets qui vous paraissent flous.

Certaines questions reviennent souvent dans les certifications Microsoft :

- **Les différents niveaux de licences** : Entra ID Free, P1, P2 par exemple.
- **Les attributions de rôles** : Est-ce qu'un utilisateur avec le rôle Security Administrator peut faire cette action ?
- **Les différences entre produits** : Quel produit correspond au besoin demandé ?
- **Les consoles d'administration** : Dans quelle console se trouve le paramètre pour faire cette action d'administration.

Prennez le temps d'absorber ces notions pour éviter d'être pris au dépourvu le jour de l'examen.

Si vous n'aimez pas le format texte, il existe des alternatives comme :

- des playlists de formation sur YouTube (souvent en anglais)
- des podcasts au format audio
- des repositories GitHub qui listent des cas pratiques à refaire sur un environnement de test

### Mise en pratique des concepts

Si vous avez un environnement de test, mettre en pratique les connaissances sera vital pour mieux les intégrer et ne pas être pris au dépourvu si jamais votre examen comporte des travaux pratiques sur un environnement de lab.

Pour les partenaires Gold & Silver, des tenants gratuits peuvent être demandés. Sinon, vous allez devoir sortir la carte bleue pour acheter de manière temporaire un tenant Microsoft 365 ou un peu de crédits Azure ($200 sont offerts en général).

### S'entrainer au passage de certification

Si vous savez déjà mettre en pratique vos connaissance (soit par expérience, soit grâce votre environnement de test), ne partez pas la fleur au fusil vers l'examen.

Je le répète encore une fois :

<p style="font-size: larger; text-align: center; margin: 1em 2em;"><i>Ce n'est pas parce que vous avez la compétence technique que vous aurez la certification. Ce n'est pas parce que vous avez la certification que vous aurez la compétence technique.</i></p>

Le passage de certification est un exercice particulier, et si vous n'êtes pas bien préparé, vous allez vous casser les dents. Une bonne partie de l'examen repose sur des questions à choix multiple, il est donc important de se familiariser avec celles-ci.

Pour ça, deux options :

- **Les questions d'entrainement disponibles gratuitement sur Microsoft Learn** : ce sont des questions *proches* de celles que vous retrouverez en examen, avec un petit texte explicatif pour vous permettre de mieux comprendre la réponse attendue.
- **Les questions disponibles sur les dumps** : celles-ci sont directement issues de l'examen officiel, donc vous serez susceptibles de les recroiser le jour J. Attention quand-même à la qualité des réponses proposées par la communauté ou à l'âge des questions. Rappel : l'utilisation de dumps pour obtenir une certification est interdit par Microsoft, car cela s'apparente à de la triche.

Pour réussir votre examen, vous devez obtenir un score supérieur ou égal à 700 (sur 1000 points en général).

### Réserver un voucher

Une fois que vous maitrisez les notions clés, que vous vous êtes entrainé et habitués à la syntaxe des questions : vous pouvez passer à la caisse pour payer un voucher à l'examen.

Certains vouchers peuvent être offerts par Microsoft sur les certifications Fundamentals, en relevant des défis lors de périodes spéciales comme le Microsoft Ignite par exemple.

Mais pour les certifications Associate ou Expert, il vous faudra impérativement payer pour passer l'examen. Certaines écoles et entreprises proposent des réductions ou peuvent prendre en charge de le coût du passage, donc renseignez-vous en amont.

### Le jour de l'examen

Il y a deux méthodes pour passer l'examen : à distance ou dans un centre agréé.

#### Dans un centre agréé

Si vous avez un centre d'examen à proximité, c'est une bonne option pour une première certification car moins prise de tête en terme de sécurité :

- Rendez-vous sur place à l'heure indiquée
- Fournissez deux pièces d'identités
- Déposez vos affaires personnelles (montre, téléphone, portefeuille)
- Entrer en salle d'examen

Pour celles et ceux qui habitent dans la région rennaise, l'ENI Service à Chartres de Bretagne est un centre agréé, qui est disponible le jeudi matin.

> Attention : certains centres d'examen disposent d'écrans de petite taille (21 pouces et/ou basse résolution) qui peuvent être limitant durant les travaux pratiques. Rien d'insurmontable ou de bloquant, mais cela peut vous impacter sur votre confort.

#### A distance

Si vous préférez restez dans le confort d'un lieu connu et avoir plus de choix sur les horraires, vous pouvez passer votre certification à distance (chez vous ou au bureau). Dans ce cas, c'est vous qui devrez prouver que l'endroit où vous suivez l'examen est sécurisé, donc il faudra :

- Prendre des photos de l'environnement dans lequel vous êtes (devant l'écran, derrière l'écran...)
- Prouver votre identité avant le début de l'examen
- Rester devant votre caméra sur toute la durée de l'épreuve

Les examinateurs sont très stricts sur la suspicion de triche, donc si :

- Vous n'avez pas une connexion internet stable
- Des gens peuvent passer derrière vous ou entrer dans la pièce
- Il y a des cadres / affiches sur les murs que vous ne pouvez pas enlever

...passez votre chemin !

> J'ai certains collègues qui ont préféré passer leurs certifications dans les toilettes pour être sûr de réunir les bonnes conditions.

### Après avoir obtenu le résultat

En cas de réussite, félicitation à vous ! 🎉 Vous retrouverez prochainement votre nouveau badge sur votre [profil Microsoft Learn](https://learn.microsoft.com/users/me/credentials?tab=credentials-tab), avec le lien qui permet de prouver la validité de votre certification.

Sinon, vous pouvez repasser à la caisse pour obtenir un [Exam Replay](https://learn.microsoft.com/fr-fr/credentials/certifications/deals) et retentez votre chance.

> La seule personne que je connaisse qui ait utilisé un Exam Replay n'a pas eu la certification au deuxième essai... Donc même si vous avez échoué de peu, prennez le temps de réviser en profondeur !

## Ressources utiles

### Les différents niveaux de certification

Badge | Renouvellement | Description
----- | -------------- | -----------
![Fundamentals](/assets/cv/certifications/microsoft-certified-fundamentals-badge.svg) | Aucun | Les certifications fondamentales sont obtenues avec les examens "900" (exemple : MS-900, AZ-900).<br>Celles-ci sont plutôt adressées aux juniors, aux avant-ventes (ou commerciaux) et attestent d'une connaissance générale sur les produits Microsoft.
![Associate](/assets/cv/certifications/microsoft-certified-associate-badge.svg) | Tous les ans | Valident un niveau technique sur un aspect précis d'une technologie ou d'un produit qui est plus large.<br>L'obtention d'une certification ne nécessite en général de passer qu'un seul examen.
![Expert](/assets/cv/certifications/microsoft-certified-expert-badge.svg) | Tous les ans | Obtenues en passant plusieurs examens sur une même technologie. Est le plus haut niveau de certification que l'on peut avoir sur les certifications.

### Les renouvellements

Les certifications Associate et Expert sont soumises à un renouvellement annuel. Vous avez six mois pour renouveler gratuitement votre certification. Le renouvellement est un examen en "open-book", c'est-à-dire qu'il :

- N'est pas surveillé
- N'est pas soumis à une limite de temps
- Autorise les recherches web

Si vous échouez votre tentative, vous devrez attendre le lendemain pour réessayer (un essai par jour).

### Liens utiles

#### Pour tout le monde

Site | Catégorie | Description
---- | --------- | -----------
[learn.microsoft.com](https://learn.microsoft.com/) | Formation | Propose un parcours d'apprentissage complet lié aux certifications
[aka.ms/ExploreCredentials](https://aka.ms/ExploreCredentials) | Information | Agent IA pour vous aider à trouver les certifications pertinentes
[Certification Poster](https://arch-center.azureedge.net/Credentials/Certification-Poster_en-us.pdf) | Information | Regroupe toutes les certifications Microsoft par branche ou domaine
[all-the-exams](https://github.com/JurgenOnAzure/all-the-exams/blob/main/README.md) | Information | Suivre les mises à jour des examens
[examtopics.com](https://www.examtopics.com/) | Dumps | Interdit par Microsoft
[free-braindumps.com](https://free-braindumps.com/) | Dumps | Interdit par Microsoft

#### Pour les partenaires Gold ou Silver

Site | Description
---- | -----------
[esi.microsoft.com](https://esi.microsoft.com/) | Portail professionnel pour la préparation des certifications
[cdx.transform.microsoft.com](https://cdx.transform.microsoft.com/) | Portail de création de tenant Microsoft 365 gratuits

### Lexique

Terme | Définition
----- | ----------
Certification | Diplôme qui valide votre niveau de connaissance sur une ou plusieurs technologies. S'obtient après le passage d'un ou plusieurs examens.
"Dumps" ou "Brain dumps" | Base de données qui regroupe les questions officielles des examens, rapportées par ceux qui les ont passés.<br>Le partage de questions d'examen est interdit par Microsoft.<br>Il est tout à fait possible de passer une certification sans utiliser les "dumps", à condition de bien connaître le produit, les compétences évaluées et de prendre le temps de lire les questions.
Examen | Evaluation technique sous la forme d'un QCM, d'une étude de cas et/ou de travaux pratiques.<br>Peut-être passé dans un centre d'examen agréé ou chez vous.
QCM | Questionnaire à choix multiples, représente entre 60 et 90% du contenu d'un examen.
Voucher | Bon de réduction pour le passage d'un examen. Certains "vouchers" peuvent couvrir la totalité du prix de la certification (réduction de 100%).
"Transcript" ou Transcription | Document officiel de Microsoft qui atteste de la validité de vos certifications.
Etude de cas | Série de questions sur une mise en situation où vous devez répondre au mieux aux besoins d'une entreprise fictive. Représente entre 10 et 20% du contenu d'un examen
Travaux pratiques ou TP | Épreuve d'examen où vous devez réaliser une liste de tâches sur un environnement de test. Les TP ne sont pas systématiques et ne concernent pas tous les examens.
