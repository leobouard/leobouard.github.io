---
title: "Comprendre le filtre caché ANR"
description: "Rechercher efficacement plusieurs attributs en seulement quelques caractères"
tags: ["active-directory", "powershell"]
---

## C'est quoi le filtre ANR ?

L'ANR (Ambiguous Name Resolution) dans Active Directory est un mécanisme qui permet de rechercher n'importe quel type d'objet en utilisant un seul champ de recherche (ANR).

Au lieu de cibler un attribut précis, la recherche ANR interroge automatiquement plusieurs attributs courants (nom, prénom, sAMAccountName, etc.) pour trouver les correspondances (même partielles).

Voici la documentation officielle de Microsoft sur le sujet : [\[MS-ADTS\]: Ambiguous Name Resolution \| Microsoft Learn](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/1a9177f4-0272-4ab8-aa22-3c3eafd39e4b)

### Utilisation de la recherche ANR

Il y a maintenant deux ans, j'ai publié un outil pour réinitialiser facilement des mots de passe utilisateur : [leobouard/PasswordReset: A simple WPF interface for Active Directory user password reset](https://github.com/leobouard/PasswordReset). Le principe est simple : rechercher un compte Active Directory pour consulter toutes les informations relatives à son mot de passe et modifier son mot de passe avec 

Pour la partie "recherche du compte utilisateur", l'utilitaire propose une barre de recherche générique, où le texte en entrée peut être le nom, le SamAccountName, le prénom... Pour explorer toutes ces options à la fois, on peut construire un filtre complexe (et gourmand en ressource) comme celui-ci :

```powershell
Get-ADUser -Filter {
    (Name -like 'Donald*') -or
    (DisplayName -like 'Donald*' -or
    (GivenName -like 'Donald*') -or
    (Surname -like 'Donald*') -or
    (SamAccountName -like 'Donald*')
}
```

Ou plus simplement utiliser la recherche ANR qui indexe plusieurs attributs à la fois, pour avoir un filtre très simple et performant :

```powershell
Get-ADUser -Filter {ANR -eq 'Donald'}
```

Les deux commandes ci-dessus donnerons un résultat identique, pour une syntaxe beaucoup plus légère et de meilleures performances en utilisant la recherche ANR.

> La différence de performance se verra surtout sur les plus gros domaines Active Directory.

### Lister les attributs indexés par ANR

La liste des attributs qui sont utilisés lors d'une recherche ANR est personnelle à votre domaine. La version fonctionnelle ou la présence de Microsoft Exchange ont un impact sur la liste d'attributs concernés. Le plus simple est donc d'afficher la liste des attributs utilisés lors d'une recherche ANR sur votre domaine :

```powershell
$attributes = Get-ADObject -Filter {objectClass -eq 'attributeSchema'} -SearchBase (Get-ADRootDSE).schemaNamingContext -Properties ldapDisplayName, searchFlags
$attributes | Where-Object {$_.searchFlags -band 4} | Format-Table Name, ldapDisplayName, searchFlags
```

L'indexation (ou non) dans ANR se fait sur la propriété `searchFlags` qui est un *"bitfield"* qui stocke plusieurs informations en un seul nombre entier.

À titre indicatif, voici la liste des attributs indexés les plus utiles  :

Name | LDAPDisplayName | Description
---- | --------------- | -----------
Display-Name | displayName | Nom d'affichage
Given-Name | givenName | Prénom
Physical-Delivery-Office-Name | physicalDeliveryOfficeName | Bureau
Proxy-Addresses | proxyAddresses | Liste des alias de messagerie
RDN | name | Nom complet
SAM-Account-Name | sAMAccountName | Nom d'ouverture de session de l'utilisateur (antérieur à Windows 2000)
Surname | sn | Nom de famille

### Ajouter un attribut dans la recherche ANR

Par défaut, l'attribut `userPrincipalName` ne fait pas partie de la liste d'attributs indexés par ANR. Vous pouvez demander son indexation avec la commande suivante :

```powershell
$upnAttr = Get-ADObject -Filter {ldapDisplayName -eq 'userPrincipalName'} -SearchBase (Get-ADRootDSE).schemaNamingContext -Properties ldapDisplayName, searchFlags
$searchFlags = $upnAttr.searchFlags + 5
Set-ADObject $upnAttr -Replace @{searchFlags = $searchFlags}
```

> On ajoute 5 à la valeur par défaut (18) pour ajouter les options suivantes :
>
> - 1 pour créer un index de cet attribut
> - 4 pour ajouter cet attribut à la recherche ANR
>
> Il est obligatoire de créer un index pour ajouter un attribut à la recherche ANR.

Plus d'informations sur la signification des valeurs contenues dans le champ `searchFlags` ici : [Search-Flags attribute - Win32 apps \| Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/adschema/a-searchflags#remarks)


