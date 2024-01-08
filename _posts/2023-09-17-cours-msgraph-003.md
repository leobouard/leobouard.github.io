---
layout: post
title: "MSGRAPH #3 - Microsoft Graph Explorer"
description: "Prendre en main efficacement l'outil web de requête d'API"
tableOfContent: "/2023/09/17/cours-msgraph-introduction#table-des-matières"
nextLink:
  name: "Partie 4"
  id: "/2023/09/17/cours-msgraph-004"
prevLink:
  name: "Partie 2"
  id: "/2023/09/17/cours-msgraph-002"
---

## Microsoft Graph Explorer

Microsoft Graph Explorer est une application web qui vous permet d’apprendre et d’essayer les API Microsoft Graph. Voici quelques-unes de ses fonctionnalités principales :

- **Tester les API Microsoft Graph** : Vous pouvez faire des requêtes pour récupérer, ajouter, supprimer et mettre à jour des données
- **Apprendre sur les permissions** : Vous pouvez découvrir les permissions requises pour les différentes API.
- **Explorer les ressources disponibles** : Microsoft Graph offre une multitude de ressources que vous pouvez explorer rapidement.
- **Intégration des modules PowerShell** : Executer une requête vous permet d'obtenir la commande PowerShell associée.
- **Gestion de l’authentification** : Graph Explorer gère le processus d’authentification pour vous et vous permet même de récupérer facilement un access token.

Vous pouvez commencer à utiliser Graph Explorer sans avoir besoin de vous connecter pour exécuter une requête GET. Cependant, pour essayer les requêtes POST, PUT, PATCH et DELETE, vous devez vous connecter à Graph Explorer en utilisant un compte Microsoft 365 (celui de votre tenant de test par exemple).

### Lancer Microsoft Graph Explorer

Se rendre sur <https://developer.microsoft.com/en-us/graph/graph-explorer>

Je vous recommande de garder la console en anglais pour mieux suivre le cours et éviter les traductions automatiques qui peuvent être parfois approximatives.

### Se connecter à votre tenant

Cliquer en haut à droite pour vous connecter sur votre tenant de test. Entrer votre nom d'utilisateur, votre mot de passe ou/et votre authentification multifacteur.

![Connexion avec mot de passe](/assets/images/msgraph-301.png)

Vous pouvez cocher la case "Consent on behalf of your organization" pour autoriser l'application Microsoft Graph à tous les utilisateurs de votre tenant. Si vous ne cochez pas la case, seul votre utilisateur pourra se connecter sans re-demander d'approbation.

![Demande de permission](/assets/images/msgraph-302.png)

### Votre première requête

Exécuter la requête par défaut `https://graph.microsoft.com/v1.0/me` avec le bouton "Run query" et consulter le résultat qui apparait dans la fenêtre "Response preview".

L'appel API devrait afficher les informations relatives à votre profil.

![Votre première requête](/assets/images/msgraph-318.png)

### Passage en version BETA

Selectionner le menu déroulant "v1.0" pour le modifier par "beta" puis exécuter la requête.

Vous pouvez observer alors que beaucoup d'informations supplémentaires sont disponibles en réponse.

![Passage en version beta](/assets/images/msgraph-317.png)

### Créer un utilisateur (POST)

Dans le volet gauche *"Sample queries"*, développer la section *"Users"* puis sélectionner **"\[POST] create user"**.

La méthode, l'URI et le corps de la requête vont être automatiquement modifiés pour définir tous les paramètres nécessaires à la création du compte.

Modifier le JSON pour remplacer {domain} par le domaine de votre tenant puis lancer votre appel API.

Celui-ci devrait tomber en erreur :

<blockquote style="
    background: var(--negative);
    border-color: red;
">
  <p>Forbidden - 403. Either the signed-in user does not have sufficient privileges, or you need to consent to one of the permissions on the Modify permissions tab</p>
</blockquote>

Comme évoqué dans [Permissions et étendues (scope)](/2023/09/17/cours-msgraph-002#permissions-et-étendues-scopes), même si vous êtes l'administrateur global de votre tenant vous n'avez pas tous les droits initialement : il faut les demander. Vous pouvez demander l'accès à la permission *User.ReadWrite.All* dans le volet supérieur sur l'onglet *"Modify permissions"* puis l'approuver.

![Comment modifier les permissions](/assets/images/msgraph-305.png)

![Approbation de la permission User.ReadWrite.All](/assets/images/msgraph-306.png)

Vous devriez alors recevoir le message de confirmation suivant : 

<blockquote style="
    border-color: green;
    background: var(--positive);
">
  <p>Success - Scope consent successful</p>
</blockquote>

Il n'y a maintenant plus aucun obstacle pour créer votre utilisateur.

![Création de l'utilisateur](/assets/images/msgraph-308.png)

### Rechercher un utilisateur (GET)

On va maintenant essayer de retrouver l'utilisateur qui vient d'être créé avec la requête suivante :

- Méthode : GET
- URI : `https://graph.microsoft.com/v1.0/users`

![Lister tous les utilisateurs](/assets/images/msgraph-309.png)

Mais cette requête permet d'obtenir tous les utilisateurs. Pour obtenir uniquement l'utilisateur qui a été créé, on va ajouter le UserID ou le UserPrincipalName du compte dans notre URI : `https://graph.microsoft.com/v1.0/users/{userId/upn}`.

![Rechercher un utilisateur en spécifique](/assets/images/msgraph-310.png)

On va maintenant ajouter un paramètre de requête pour obtenir une information supplémentaire : le pays de l'utilisatrice. Pour cela, on utilise `$select=` avec la propriété *"country"* :

![Utilisation des paramètres de recherche](/assets/images/msgraph-311.png)

Problème : l'API prend notre demande au pied de la lettre et n'affiche plus que la propriété *"country"*. On va donc corriger le problème en ajoutant des propriétés supplémentaires dans notre requête : DisplayName, Id et UserPrincipalName :

![Utilisation de plusieurs propriétés](/assets/images/msgraph-312.png)

### Mettre à jour un utilisateur (PATCH)

Nous allons maintenant ajouter une information au compte que nous avons précédemment créé. Vous pouvez sélectionner l'appel **"\[PATCH] update user"** pour charger les paramètres.

Remplacer `{id}` dans l'URI par le UserID ou le UserPrincipalName de l'utilisateur et modifier le JSON dans la fenêtre *"Request body"* pour indiquer la propriété "country" avec la valeur "Canada".

![Mise à jour d'un utilisateur](/assets/images/msgraph-313.png)

Si vous n'avez pas d'erreur, vous devez recevoir un objet de retour vide avec le code suivant :

<blockquote style="
    border-color: green;
    background: var(--positive);
">
  <p>No Content - 204</p>
</blockquote>

Vous pouvez vérifier les modifications avec la requête GET précédente. Vous pouvez accéder à l'historique de vos appels API avec l'onglet *"History"* présent dans le volet gauche.

![Vérification de la mise à jour](/assets/images/msgraph-315.png)

### Supprimer un utilisateur (DELETE)

Pour boucler la boucle, il ne nous reste plus qu'à utiliser la dernière méthode : DELETE. On va donc supprimer l'utilisateur que nous avons créé avec l'appel **"\[DELETE] delete user"**.

![Suppression de l'utilisateur](/assets/images/msgraph-316.png)

## Conclusion

Microsoft Graph Explorer est un outil formidable pour tester des requêtes simples, valider la syntaxe des paramètres de requêtes ou vérifier la disponibilité de certains filtres. Il est accessible facilement depuis n'importe quel ordinateur et sans installation supplémentaire. Il permet d'accéder simplement à la liste des appels API disponibles ainsi qu'à la documentation associée.

Il ne convient qu'à un usage ponctuel, principalement pour consulter de l'information ou tester des appels APIs.
