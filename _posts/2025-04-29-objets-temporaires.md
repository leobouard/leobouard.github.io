---
title: "Les objets dynamiques dans Active Directory"
description: "Ce compte utilisateur s'auto-détruira dans trois, deux, un..."
tags: active-directory
listed: true
---

## En bref

Windows Server 2003 a introduit de nombreuses fonctionnalités dans Active Directory, dont la plupart sont encore utilisées aujourd'hui. Cependant, au moins une nouveauté de Windows Server 2003 est tombée aux oubliettes : **les objets dynamiques**.

Les objets dynamiques désignent une classe d'objet qui a une durée de vie limitée et qui seront supprimés automatiquement par Active Directory. Ceux-ci peuvent prendre la forme de n'importe quelle autre classe d'objet : utilisateur, groupe, unité d'organisation...

Cet article est inspiré du post de Narayanan Subramanian sur Medium : [fun with dynamic Objects in AD: Part 1](https://medium.com/@nannnu/fun-with-dynamic-objects-in-ad-part-1-743c21dd934f), à la différence que je n'utilise pas les outils `admod` et `adfind` mais plutôt les bonnes vieilles commandes PowerShell Active Directory.

### Fonctionnement

Les objets dynamiques :

- peuvent prendre la forme de n'importe quelle classe d'objet dans Active Directory
- sont créés avec une durée de vie qui est comprise entre 15 min et 1 an
- ont leur durée de vie restante indiquée en secondes dans l'attribut `entryTTL`
- ont leur date de suppression visible dans l'attribut `msDS-Entry-Time-To-Die`
- disparaissent sans laisser de trace (ne passent pas par la case corbeille Active Directory)
- ne peuvent pas être créés dans la partition "Configuration" ou "Schéma" de Active Directory

### Création dans le schéma ou la partition

Pour le dernier point : il s'agit d'une mesure de sécurité visant à éviter de détruire le domaine. En effet : il n'est pas possible de supprimer un objet qui a été ajouté dans le schéma. Ajouter un objet dynamique qui finira par disparaître dans le schéma ou la configuration mènera donc à une corruption pure et simple de votre Active Directory.

Dans un commentaire sur l'article de Narayanan Subramanian, [Joe Richards](https://joeware.net/) annonce cependant qu'il y aurait plusieurs manière de créer un objet dynamique dans l'une de ces deux partitions, laissant ainsi une bombe à retardement dans le domaine.

**Commentaire original :**

> [...] We had a sit down with [Microsoft] about how to blow up an entire AD forest in seconds, or worse, leave a time bomb.
>
> I still remember a few guys from the [Product Group] sitting in a room in Redmond and Dean said this is what is possible and they said no it isn't and then boom he showed a whole schema disappear on a test forest right in front of them. [...]
>
> Then we pointed out multiple different ways it could be done via different angles with the dynamic object functionality [...]

### Usage

Je n'ai personnellement jamais vu des objets dynamiques utilisés en environnement de production. Probablement par méconnaissance puisque cette technologie est assez peu connue, mais surtout par manque d'intérêt selon moi :

- l'utilisation d'une date d'expiration convient parfaitement pour rendre inutilisable un compte après une certaine date
- l'utilisation d'un rappel dans un calendrier souvent utilisée pour les autres classes d'objets (groupe, ordinateur...)

L'absence de commande PowerShell native et/ou d'option dans l'interface graphique rend également cette technologie inaccessible pour beaucoup d'administrateurs.

## Création d'un objet dynamique

### Contrôle de la configuration par défaut

Il existe deux paramètres sur les objets dynamiques dans la configuration du domaine Active Directory : `DynamicObjectMinTTL` et `DynamicObjectDefaultTTL`.

Les deux valeurs se trouvent dans l'attribut `msDS-Other-Settings`, présent sur l'objet *contoso.com/Configuration/Services/Windows NT/Directory Service*.

Paramètre | Valeur par défaut | Description
--------- | ----------------- | -----------
DynamicObjectMinTTL | 900<br>(15 minutes) | Si un objet dynamique est créé avec une durée de vie inférieure à celle indiquée dans ce paramètre, la durée de vie sera automatiquement ajustée à cette valeur
DynamicObjectDefaultTTL | 86400<br>(24 heures) | Si aucun TTL n'est spécifié pour un objet dynamique, c'est cette valeur qui sera utilisée par défaut

Pour consulter la configuration de votre domaine en PowerShell :

```powershell
$domainDn = (Get-ADDomain).DistinguishedName
$path = "CN=Directory Service,CN=Windows NT,CN=Services,CN=Configuration,$domainDn"
Get-ADObject $path -Properties 'msDS-Other-Settings'
```

### Création d'un objet

Il n'existe pas de commande PowerShell issue du module Active Directory pour créer un objet dynamique, l'utilisation de .NET est obligatoire. Voici un exemple de code pour créer un objet dynamique de type "utilisateur" :

```powershell
$dynamicObject = ([ADSI]("LDAP://OU=Users,DC=contoso,DC=com")).Create('user', 'CN=dynamicUser,CN=Users,DC=contoso,DC=com')
$dynamicObject.PutEx(2, 'objectClass', @('dynamicObject', 'user'))
$dynamicObject.Put('entryTTL', 900)
$dynamicObject.SetInfo()
```

Ou plus simplement avec une fonction personnalisée : [New-ADDynamicObject](https://gist.github.com/leobouard/16f90612a5461d2a9cec49cad6056929)

```powershell
New-ADDynamicObject -Name 'dynamicUser' -ObjectType user
```

Ces commandes vont créer un objet dynamique de type utilisateur nommé "dynamicUser" sous *contoso.com/Users* avec une durée de vie de 900 secondes (15 minutes).

### Modifier la durée de vie d'un objet dynamique

Avec la commande suivante, nous allons modifier directement la valeur de l'attribut `entryTTL` qui contient la durée de vie restante pour l'objet. Cette action permet donc de prolonger (ou réduire) la durée de vie d'un objet.

```powershell
Get-ADObject -Filter {SamAccountName -eq 'dynamicUser'} | Set-ADObject -Replace @{entryTTL = 900}
```

> **Rappel :** vous ne pouvez pas réduire la durée de vie restante d'un compte en dessous de la valeur `DynamicObjectMinTTL` de votre domaine.

### Lister tous les objets dynamiques du domaine

Pour lister les objets dynamiques, il n'est pas possible d'utiliser l'attribut `entryTTL`. La valeur de celui-ci n'étant pas fixe (elle est calculée en temps réel), il est impossible de l'utiliser comme filtre. Vous tomberez sur l'erreur suivante : *Get-ADObject : A Filter was passed that uses constructed attributes*.

A la place, on peut utiliser `msDS-Entry-Time-To-Die` qui contient la date programmée de fin de vie de l'objet (valeur fixe) :

```powershell
Get-ADObject -LDAPFilter '(msDS-Entry-Time-To-Die=*)' -Properties entryTTL, msDS-Entry-Time-To-Die
```

Résultat :

```plaintext
DistinguishedName      : CN=dynamicUser,CN=Users,DC=contoso,DC=com
entryTTL               : 682
msDS-Entry-Time-To-Die : 29/04/2025 15:40:07
Name                   : dynamicUser
ObjectClass            : user
ObjectGUID             : 3cc5722f-c427-4918-a787-0bec0b3adf58

DistinguishedName      : OU=dynamicOU,DC=contoso,DC=com
entryTTL               : 817
msDS-Entry-Time-To-Die : 29/04/2025 15:42:22
Name                   : dynamicOU
ObjectClass            : organizationalUnit
ObjectGUID             : f5c7be5f-b006-4b94-b937-3c079a9cdf25
```

### Imbrication entre objets statiques et dynamiques

A la création, il est impossible d'ajouter un objet statique "staticUser" au sein d'un objet dynamique "dynamicOU".

Si vous essayez de faire cela, vous obtiendrez le message d'erreur générique suivant : *"Windows cannot create the object staticUser because: The server is unwilling to process the request"*.

```powershell
New-ADUser staticUser -Path 'OU=dynamicOU,DC=contoso,DC=com'
```

Cependant, ce mécanisme de protection ne fonctionne qu'à la création de l'objet enfant. Vous pouvez donc créer votre utilisateur "staticUser" ailleurs dans le domaine pour le déplacer ensuite vers l'objet parent "dynamicOU" :

```powershell
New-ADUser staticUser
Move-ADObject (Get-ADUser staticUser) -TargetPath 'OU=dynamicOU,DC=contoso,DC=com'
```

Dans le cas où un objet dynamique serait le parent d'au moins un objet statique, l'objet dynamique **ne sera pas supprimé** automatiquement (même lorsque `entryTTL` tombe à zéro) :

```plaintext
DistinguishedName      : OU=dynamicOU,DC=contoso,DC=com
entryTTL               : 0
msDS-Entry-Time-To-Die : 29/04/2025 15:42:22
Name                   : dynamicOU
ObjectClass            : organizationalUnit
ObjectGUID             : f5c7be5f-b006-4b94-b937-3c079a9cdf25
```

S'il n'y a plus aucun objet statique enfant d'un objet dynamique avec un `entryTTL = 0`, alors l'objet dynamique sera automatiquement supprimé.

### Fin de vie d'un objet dynamique

Lorsque la valeur de l'attribut `entryTTL` arrive à zéro, l'objet disparaît du domaine sans laisser de trace (ne tombe pas dans la corbeille Active Directory).

```powershell
Get-ADObject -Filter {SamAccountName -eq 'dynamicUser'} -IncludeDeletedObjects
```

> En pratique, la suppression de l'objet ne se fait pas immédiatement après que l'attribut `entryTTL` a atteint 0.\
> Il faut parfois attendre quelques minutes ou forcer une réplication pour que l'objet disparaisse.
