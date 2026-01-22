---
title: "Réinitialiser le propriétaire d'un objet AD"
description: "Tout remettre d'équerre pour respecter les bonnes pratiques de l'ANSSI"
tags: ["activedirectory", "powershell"]
listed: true
---

## Le propriétaire d'objet

Dans Active Directory, si le créateur d'un objet n'est pas membre du groupe "Domain Admins", le propriétaire de l'objet restera celui qui l'a créé. Par exemple, si le compte "T2 - John Smith" ajoute l'ordinateur "VFX751" dans le domaine, il restera le propriétaire de l'objet Active Directory.

Être propriétaire d'un objet dans Active Directory donne la permission de modifier les permissions appliquées à celui-ci.

La plupart du temps ce n'est pas grave, puisque si un compte a pu créer un objet, il n'y a rien de dangereux au fait qu'il en soit administrateur. Mais si jamais l'objet créé gagne en privilèges ou que le créateur de l'objet perd en privilèges, **l'autorisation va persister** (et c'est là que ça devient problématique).

### Recommandation de l'ANSSI

Dans ORADAD, il existe la vulnérabilité `vuln3_owner` qui indique la présence de propriétaires non-standard (à comprendre : autre que le groupe "Domain Admins") sur des objets Active Directory qui ont été créés il y a plus d'une semaine.

Pour résoudre la vulnérabilité : il suffit de définir le groupe "Domain Admins" en tant que propriétaire de l'objet et réinitialiser ses permissions.

## Audit et remédiation

Pour la phase de remédiation, j'utilise la fonction personnalisée suivante :

{% include github-gist.html name="Reset-ADPermission" id="e610f4d49dd58c66c3ed023256b33384" %}

Toutes les commandes ci-dessous concernent les ordinateurs, mais vous pouvez facilement adapter les scripts pour cibler :

- Les groupes avec la commande `Get-ADGroup`
- Les utilisateurs avec la commande `Get-ADUser`
- Certains types d'objets spécifiques avec la commande `Get-ADObject` et le filtre `{objectClass -eq 'yourclass'}`

### Audit des propriétaires

La première étape, c'est d'afficher rapidement les différents propriétaires d'objets et le nombre de comptes concernés :

```powershell
$computers = Get-ADComputer -Filter * -Properties NTSecurityDescriptor, CanonicalName, Created
$computers.NTSecurityDescriptor.Owner |
    Group-Object -NoElement |
    Sort-Object Count -Descending |
    Format-Table -AutoSize
```

### Vue des objets par propriétaires

Pour voir tous les objets dont le propriétaire est "BUILTIN\Administrators" :

```powershell
$owner = 'BUILTIN\Administrators'
$computers | Where-Object {$_.NTSecurityDescriptor.Owner -eq $owner} |
    Format-Table Name, Created, CanonicalName
```

Sinon, sur des plus petits environnements vous pouvez utiliser cette commande pour afficher tous les propriétaires et les objets associés :

```powershell
$computers | Where-Object {$_.NTSecurityDescriptor.Owner -notlike '*\Domain Admins'} |
    Select-Object *, @{N='Owner';E={$_.NTSecurityDescriptor.Owner}} |
    Sort-Object Owner |
    Format-Table Name, Created, CanonicalName -GroupBy Owner
```

> Ici j'ai filtré en amont pour exclure les objets qui sont déjà possédés par le groupe "Domain Admins" afin de réduire le nombre de résultat.

### Remédiation

C'est maintenant que rentre en scène la fonction `Reset-ADPermission` ! Ici on utilise directement l'arme nucléaire puisque l'on va corriger tout les objets d'un coup, mais vous pouvez y aller plus progressivement en adaptant le filtre.

```powershell
$computers |
    Where-Object {$_.NTSecurityDescriptor.Owner -notlike '*\Domain Admins'} |
    Reset-ADPermission -ResetOwner -Verbose
```

> **Attention :** Si vous avez des permissions légitimes définies directement sur l'objet (ce qui n'est pas une bonne pratique), la commande va les supprimer. Les permissions issues de l'objet parent (par héritage) ne seront pas impactées.
