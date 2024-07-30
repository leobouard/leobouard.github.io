# Simple Resume

SaaS de gestion de CV interne pour les entreprises.

## Fonctionnalités nécessaires

- Editeur web dynamique pour pouvoir générer un fichier JSON
- Générateur de CV web à partir du fichier JSON
- Utilisation d'un thème corporate
- Fonctionnalité de partage de CV
- Consulter tous les CV des délégataires
- Intégration avec Entra ID (pour SSO et gestion des droits)
- Relance par email pour mettre à jour
- Routine de demande de mise à jour du CV
- Voir d'anciennes versions du CV
- Export du CV en HTML, PDF ou JSON
- Ajout d'un encart pour les coordonées du commercial

## Plan d'application

### resume.contoso.fr/home

Page d'accueil pour tous les utilisateurs avec :

- Date de dernière mise à jour
- Qui a mis à jour le CV
  
CTA :

- Mettre à jour le CV
- Partager le CV (optionnel)

### resume.contoso.fr/view/me/version/current

CTA :

- Mettre à jour le CV
- Partager le CV (optionnel)
- Voir les anciennes versions du CV

### resume.contoso.fr/view/me/version/

Visualisation du CV

### resume.contoso.fr/edit/me

Mise à jour du CV (par le collaborateur, le manager ou un administrateur)

### resume.contoso.fr/manage

Visualisation, modification et partage des CV des collaborateurs qui sont gérés par le manager/commercial.

### resume.contoso.fr/admin

Page d'administration pour gérer :

- les différents rôles de chaque utilisateurs
- les liens de partages actifs

### resume.contoso.fr/share/4d29a28c

Lien de partage avec expiration et mise à jour automatique (si le CV est mis à jour)

## Paramètres

- Envoyer automatiquement des relances pour mettre à jour le CV
- Laisser les collaborateurs générer un lien de partage externe
- Date d'expiration des liens CV
- Anonymiser le nom dans le CV
- Mettre à jour le lien partagé en même temps que le CV
- Nombre maximum d'historique de version (plafonné)
