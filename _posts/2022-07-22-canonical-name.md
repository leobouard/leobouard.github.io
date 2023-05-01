---
layout: post
title: "CanonicalName & DN"
description: "Et si on prennait la racine du domaine en point de départ pour une fois ?"
background: "#B4CFB4"
tags: active-directory
listed: true
---

L'emplacement dans l'arborescence Active Directory est souvent très important et peu s'avérer utile pour la génération de rapports. L'attribut le plus utilisé pour déterminer cette information est le "Distinguished Name", mais si vous ne connaissez pas son cousin le "Canonical Name", cet article est fait pour vous !

## Arborescence Active Directory

Pour illustrer mon propos, on va prendre l'exemple suivant. C'est une arborescence classique avec différentes OU et un domaine en "labouabouate.com".

```
🌐 labouabouate.com
  📁 LBB
    📁 FR
      📁 Rennes
        📁 Users
          🧑‍💼 Pierre Dupont
    📁 US
      📁 Users
        🧑‍💼 John Smith
```

## DistinguishedName

Le DistinguishedName fait partie des propriétés affichées par défaut lors d'une requête PowerShell, notamment avec la commande `Get-ADUser` par exemple.

Pour donner un exemple, voici les DistinguishedName des comptes utilisateurs John Smith et Pierre Dupont :

- CN=John Smith,OU=Users,OU=US,OU=LBB,DC=labouabouate,DC=com
- CN=Pierre Dupont,OU=Users,OU=Rennes,OU=FR,OU=LBB,DC=labouabouate,DC=com

**On part de l'objet cible pour remonter ensuite vers la racine du domaine**. On remarque que les éléments de l'arborescence sont séparés entre eux par des virgules et que la nature de l'objet est spécifiée à chaque fois (d'où la présence des "OU=", "DN=" et "CN=").

Voici un tableau synthèse sur les différents type d'objets que l'on retrouve couramment dans les DistinguishedName :

Identifiant | Type d'attribut
----------- | ---------------
DC | domainComponent
CN | commonName
OU | organizationalUnitName

Et le tableau complet est disponible ici : [Distinguished Names - Microsoft Docs](https://docs.microsoft.com/previous-versions/windows/desktop/ldap/distinguished-names)

On remarque également que le domaine est décomposé : au lieu d'être simplement affiché en "DC=labouabouate.com", on affiche bien chaque niveau du domaine :

Domaine | DistinguishedName
------- | -----------------
labouabouate.com | DC=labouabouate,DC=com
ldap.lbb.com | DC=ldap,DC=lbb,DC=com

## CanonicalName

Cette propriété est malheureusement en "option" lors des requêtes Active Directory. Il faut donc la spécifier pour l'obtenir lors des requêtes `Get-ADUser` :

```powershell
Get-ADUser john.smith -Properties CanonicalName
```

Les CanonicalName des deux utilisateurs :

- labouabouate.com/LBB/US/Users/John Smith
- labouabouate.com/LBB/FR/Rennes/Users/Pierre Dupont

Beaucoup plus lisible que le DistinguishedName, **on part de la racine du domaine pour descendre vers l'objet cible**. Les éléments sont séparés entre eux par des "/" et c'est tout. Simple et efficace !

## Cas pratique

On veut générer un rapport avec tous les utilisateurs du domaine en affichant à quelle unité organisationnelle l'utilisateur appartient. Les OUs qui nous intéressent sont "FR" ou "US". Pour obtenir cette information, on va se baser les valeurs du DistinguishedName et du CanonicalName (évidemment).

### Parser le DistinguishedName

Le problème avec le DistinguishedName dans notre cas, c'est que la valeur que l'on recherche "bouge". Je m'explique :

- pour John Smith, "US" est la troisième valeur de la chaine
- pour Pierre Dupont, "FR" est la quatrième valeur de la chaine (puisqu'il existe une "sous-OU" nommée "Rennes")

ID | John Smith | Pierre Dupont
-- | ---------- | -------------
0 | CN=John Smith | CN=Pierre Dupont
1 | OU=Users | OU=Users
2 | **OU=US** | OU=Rennes
3 | OU=LBB | **OU=FR**
4 | DC=labouabouate | OU=LBB
5 | DC=com | DC=labouabouate
6 | | DC=com

Mais si on retourne notre méthode et que l'on lit le DistinguishedName de droite à gauche (racine vers objet), on retrouvera toujours la valeur recherchée en avant-avant-avant dernière position.

```powershell
$root = "OU=LBB,DC=labouabouate,DC=com"
$dn = "CN=John Smith,OU=Users,OU=US,$root","CN=Pierre Dupont,OU=Users,OU=Rennes,OU=FR,$root"
$dn | ForEach-Object {
  (($_ -split ',')[-4] -split '=')[1]
}
```

Comme vous pouvez le voir, ça se fait mais y'a plus simple.

### Parser le CanonicalName

Pas besoin de se casser la tête puisque la valeur recherchée est toujours en troisième position :

ID | John Smith | Pierre Dupont 
-- | ---------- | -------------
0 | labouabouate.com | labouabouate.com
1 | LBB | LBB
2 | **US** | **FR**
3 | Users | Rennes
4 | John Smith | Users
5 | | Pierre Dupont

Et on se retrouve avec un code PowerShell beaucoup plus simple :

```powershell
$root = "labouabouate.com/LBB"
$cn = "$root/US/Users/John Smith","$root/FR/Rennes/Users/Pierre Dupont"
$cn | ForEach-Object {
  ($_ -split '/')[2]
}
```
