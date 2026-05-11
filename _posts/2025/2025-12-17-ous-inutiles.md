---
title: "La plupart de vos unités d'organisation ne servent à rien"
description: "Y'a deux types d'unités d'organisations : celles qui sont utiles et les autres"
tags: activedirectory
---

## Concept de base

Une unité d'organisation dans Active Directory, ça ressemble comme deux gouttes d'eau à un dossier dans lequel on peut mettre des objets (ordinateurs, utilisateurs, groupes...). Comme un dossier, on a tendance à en créer pour "regrouper" tous les objets similaires entre eux. Sauf que comme un dossier, l'utilisation d'une unité d'organisation ne devrait pas être uniquement cosmétique.

Une unité d'organisation dans Active Directory ne sert techniquement qu'à deux choses :

- **Appliquer des délégations** pour autoriser une sélection d'administrateurs à réinitialiser des mots de passe, modifier les membres d'un groupe, créer des utilisateurs...
- **Appliquer les liens de stratégie de groupe** pour imposer des règles de sécurité, monter un lecteur réseau, ajouter un raccourci sur le bureau...

Si vous avez un Entra ID Connect, on peut ajouter la possibilité de sélectionner des objets à synchroniser avec Entra ID (si vous passez par une synchronisation par OU).

En dehors de ces deux (ou trois) usages, on peut considérer qu'une unité d'organisation est "cosmétique" (qui est le terme diplomatique pour dire superflue).

> Garder en tête que je donne des conseils généraux, et que des exceptions existent pour chaque entreprise.

## Questions fréquentes

### Est-ce que c'est grave d'avoir des OU inutiles ?

En soi, avoir beaucoup d'unités d'organisation et/ou des OU inutiles n'est pas un risque de sécurité ou un danger pour la stabilité de votre Active Directory, cependant cela induit souvent de mauvaises pratiques.

Supprimer les OU inutiles et réduire au maximum leur nombre va avoir plusieurs effets positifs sur votre domaine :

- Une arborescence simple va **améliorer la lisibilité de votre annuaire**, l'administration quotidienne de celui-ci et fluidifier l'apprentissage de votre environnement par vos nouvelles recrues
- La **gestion des objets sensibles au déplacement est plus simple** puisqu'on utilise d'autres méthodes pour les administrer (ciblage des GPO par groupe, ajout d'une description...)
- Les **délégations sont plus claires** avec moins d'unités d'organisation et moins de structure hiérarchique

### Mais mon arborescence ne doit pas représenter mon entreprise pourtant ?

Oui et non. Votre Active Directory est une représentation de votre entreprise suivant ses propres contraintes (délégation et GPO en tête), mais celui-ci n'a pas forcément à suivre exactement l'organigramme.

Exemple concret : votre entreprise est peut-être divisée en plusieurs services (*comptabilité, services généraux, production, informatique, marketing...*), mais si tous ces comptes sont gérés par le même support informatique et sont soumis aux mêmes règles de sécurité, aucun intérêt à garder une unité d'organisation par service.

On passe alors de la structure suivante :

```plaintext
🌐 corp.contoso.com
  📁 CONTOSO
    📁 Computers
    📁 Groups
    📁 Users
      📁 Employees
        📁 Accounting
        📁 General services
        📁 IT
        📁 Marketing
        📁 Production
      📁 Service accounts
      📁 Shared mailboxes
    
```

À celle-ci :

```plaintext
🌐 corp.contoso.com
  📁 CONTOSO
    📁 Computers
    📁 Groups
    📁 Users
      📁 Employees
      📁 Service accounts
      📁 Shared mailboxes
```

On peut même aller plus loin et se poser la question de la pertinence de séparer les comptes employés des comptes de service ou des boites aux lettres partagées.

En l'occurence, on peut considérer que l'accès aux comptes de services doit être différencié de l'accès aux comptes employés, pour éviter que l'équipe de support utilisateur n'y ai accès.

### Mais comment faire si le marketing a besoin d'une GPO spécifique ?

Le "G" dans "GPO" signifie "Group". L'utilisation d'un groupe de ciblage pour appliquer une GPO spécifique uniquement aux utilisateurs du marketing est toute indiquée dans ce cas.

Mieux encore : si un utilisateur en dehors de l'équipe marketing doit être ciblé, il n'y a qu'à ajouter le compte dans le groupe de ciblage. De la même manière, si un utilisateur du marketing ne doit pas être soumis à cette GPO, il n'y a qu'à le supprimer du groupe de ciblage.

On gagne alors en flexibilité et on évite de déplacer un objet, créer une unité d'organisation supplémentaire ou multiplier les liens GPO.

### Je vais perdre de l'information en supprimant mes OUs

Normalement aucune information n'est perdue : elle sera simplement déplacée dans des attributs au niveau de l'objet. Dans le cas du service, l'information peut être ajoutée dans l'attribut "department" des comptes utilisateurs.

Si jamais aucun attribut ne correspond à l'usage de vos anciennes OU, la description est souvent le champ idéal. Comme elle est affichée par défaut dans la console, un tri par ordre alphabétique permet de regrouper les objets avec une même description.

## Analyse des unités d'organisation

Pour mener une analyse des unités d'organisation (afin de réduire leur nombre ou préparer un travail de délégation par exemple), j'utilise le script suivant :

{% include github-gist.html name="Show-ADOrganizationalUnitPurpose" id="23b52987223a05194207ea5c61b7b010" %}

Le point d'entrée est l'utilisation de ma commande `Show-ADOrganizationalUnitPurpose` avec un compte administrateur du domaine (pour être sûr d'obtenir toutes les informations liées aux GPO). À partir de là, on va pouvoir faire plusieurs requêtes pour souligner les informations importantes.

La première étape est donc celle-ci :

```powershell
$report = Show-ADOrganizationalUnitPurpose
```

### OUs vides

De la même manière qu'un dossier vide ne sert à rien, une unité d'organisation qui ne contient aucun objet n'a aucune utilité dans votre Active Directory et peut être supprimée :

```powershell
$report |
    Where-Object { $_.membersCount -eq 0 } |
    Format-Table CanonicalName, MembersCount, LinkedGPOCount
```

### OUs sans délégation ou lien GPO

Voici une vision de toutes les OUs réellement utiles à votre domaine :

```powershell
$report |
    Where-Object { $_.DelegatedTo -or $_.LinkedGPOName } |
    Format-Table TreeView
```

Et voici maintenant les OUs superflues :

```powershell
$report |
    Where-Object { !$_.DelegatedTo -and !$_.LinkedGPOName } |
    Format-Table CanonicalName, MembersCount, DelegationsCount, LinkedGPOCount
```

On peut même calculer le pourcentage d'OUs superflues :

```powershell
$uselessOU = ($report | Where-Object {
    !$_.DelegatedTo -and
    !$_.LinkedGPOName
} | Measure-Object).Count
$allOU = ($report | Measure-Object).Count
$ratio = [math]::Round(($uselessOU / $allOU * 100), 2)
Write-Host "$ratio% of your organizational unit are useless"
```

### Visibilité des délégations

Voici tous les objets qui possèdent au moins une délégation sur vos unités d'organisation :

```powershell
$report.DelegatedTo | Sort-Object -Unique
```

### OUs sur lesquelles un objet à une permission

Filtre inverse maintenant, on affiche toutes les OUs sur lesquelles le compte `CONTOSO\john.doe` a des permissions :

```powershell
$report |
    Where-Object {$_.delegatedTo -contains 'CONTOSO\john.doe'} |
    Format-Table CanonicalName, DelegatedTo
```

### OUs avec une délégation orpheline

Pour dresser la liste de toutes les unités d'organisation avec une délégation qui pointent vers un SID orphelin :

```powershell
$report |
    Where-Object { $_.delegatedTo -like '*S-1-5-21-*' } |
    Format-Table CanonicalName, DelegatedTo
```

### Affichage des types d'objets par OUs

Pour chaque OU, afficher la répartition de chaque type d'objets :

```powershell
$report | ForEach-Object {
    Write-Host $_.CanonicalName -ForegroundColor "Yellow"
    $_.MembersRepartition | Format-Table -AutoSize -RepeatHeader
}
```

### Afficher toutes les OUs qui contiennent un certain type d'objet

Toutes les OU qui contiennent au moins un objet ordinateur :

```powershell
$report |
    Where-Object { $_.MembersRepartition.Name -contains 'computer' } |
    Format-Table CanonicalName, MembersCount
```
