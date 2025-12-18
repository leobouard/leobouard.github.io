---
title: "Récupérer tous les appartenances de groupe d'un objet"
description: "Comment lister tous les groupes auquels appartient un utilisateur ?"
tags: ["activedirectory", "powershell", "windows"]
listed: true
---

## Relations groupes et membres

Dans Active Directory, il est souvent nécessaire de savoir quels sont les membres d'un groupe ou inversement, de quels groupes est membre un objet.

Si le premier besoin est couvert par la commande `Get-ADGroupMember` et son paramètre `-Recursive`, qui permet d'obtenir tous les membres (même indirects) le deuxième besoin n'a pas de commande dédiée.

### Différents types d'appartenance

Il y a plusieurs manières d'être membre d'un groupe Active Directory :

- **L'appartenance directe** (la plus évidente) : on ajoute l'objet directement dans le groupe en question, et celui-ci se retrouve alors listé dans l'attribut "Members" du groupe en question.
- **L'appartenance indirecte** : on ajoute un objet à Group1 qui est lui-même membre de Group2. L'utilisateur sera alors membre direct de Group1, et membre indirect de Group2. C'est notamment la méthode utilisée par le modèle AGDLP.
- **L'appartenance via le groupe primaire** : stocké dans l'attribut "PrimaryGroupID", il s'agit du groupe "Domain Users" pour les utilisateurs et "Domain Computers" pour les ordinateurs.

## Méthodes disponibles

À ma connaissance, voici les quatre méthodes les plus efficaces pour lister les appartenances d'un objet à des groupes, de la plus simple à la plus complexe :

1. Attribut MemberOf
2. Commande Get-ADPrincipalGroupMembership
3. Utilitaire WHOAMI
4. Attribut TokenGroups

Toutes ne fournissent pas la même information et ne peuvent pas être utilisées dans les mêmes conditions / sur tous les types d'objets.

D'autres méthodes existent (récupérer tous les membres de tous les groupes du domaine par exemple) mais elles ne sont pas aussi efficaces que celles indiquées dans l'article.

### Attribut MemberOf

Cette méthode est la plus simple : on interroge simplement l'attribut "MemberOf" présent sur l'objet pour voir les appartenances directes à des groupes :

```powershell
(Get-ADUser jsmith -Properties MemberOf).MemberOf | Get-ADGroup
```

- Compatibilité : utilisateurs, groupes et ordinateurs
- Groupes directs : oui
- Groupes indirects : non
- Groupe primaire : non

### Commande Get-ADPrincipalGroupMembership

Autre méthode, tout aussi simple : l'utilisation de la commande dédiée `Get-ADPrincipalGroupMembership` qui permet de faire la même chose que l'attribut MemberOf en ajoutant l'appartenance au groupe primaire.

```powershell
Get-ADPrincipalGroupMembership -Identity jsmith
```

- Compatibilité : utilisateurs, groupes et ordinateurs
- Groupes directs : oui
- Groupes indirects : non
- Groupe primaire : oui

### Utilitaire WHOAMI

L'utilitaire WHOAMI avec le paramètre /GROUPS permet de lire le contenu de l'Access Token LSA qui contient toutes les appartenances directes et indirectes de l'utilisateur actuellement connecté à des groupes. Ce n'est donc pas une requête sur Active Directory, mais simplement une lecture des informations de la session locale.

> Je n'ai pas trouvé de source qui explique clairement que WHOAMI exploite l'Access Token LSA, c'est une supposition de ma part.

```powershell
$whoami = WHOAMI /GROUPS /FO CSV |
    ConvertFrom-Csv |
    Where-Object {$_.SID -like 'S-1-5-21-*'}
$groups = $whoami | ForEach-Object {
    $sid = $_.SID
    Get-ADGroup -Filter {objectSid -eq $sid}
}
$groups | Sort-Object -Unique
```

- Compatibilité : utilisateur actuellement connecté sur la session
- Groupes directs : oui
- Groupes indirects : oui
- Groupe primaire : non

### Attribut TokenGroups

L'attribut [TokenGroups](https://learn.microsoft.com/en-us/windows/win32/adschema/a-tokengroups) permet de lister tous les SID des groupes auquel appartient un objet, de manière directe et indirecte. Cet attribut est calculé par le contrôleur de domaine et reste coûteux en ressources, donc à utiliser avec parcimonie.

```powershell
$dn = (Get-ADUser -Identity jsmith).DistinguishedName
(Get-ADUser $dn -Properties tokenGroups).tokenGroups.Value | Get-ADGroup
```

- Compatibilité : utilisateurs, groupes et ordinateurs
- Groupes directs : oui
- Groupes indirects : oui
- Groupe primaire : oui

### Comparatif des méthodes

Méthode | Compatibilité | Groupes directs | Groupes indirects | Groupe primaire
------- | ------------- | --------------- | ----------------- | ---------------
Attribut MemberOf | Utilisateurs, groupes et ordinateurs | ✅ Oui | ❌ Non | ❌ Non
Commande Get-ADPrincipalGroupMembership | Utilisateurs, groupes et ordinateurs | ✅ Oui | ❌ Non | ✅ Oui
Utilitaire WHOAMI | Utilisateur connecté uniquement | ✅ Oui | ✅ Oui | ❌ Non
Attribut TokenGroups | Utilisateurs, groupes et ordinateurs | ✅ Oui | ✅ Oui | ✅ Oui
