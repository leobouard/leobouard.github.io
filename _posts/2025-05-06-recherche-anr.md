---
title: "Utiliser et comprendre la recherche ANR"
description: "Filtrer efficacement plusieurs attributs en une seule ligne"
tags: ["activedirectory", "powershell"]
listed: true
---

## Qu'est-ce que l'ANR ?

L'ANR (Ambiguous Name Resolution) dans Active Directory est un mécanisme qui permet de rechercher un objet sur plusieurs attributs en utilisant un seul filtre (ANR).

Au lieu de cibler un attribut précis, la recherche ANR interroge automatiquement plusieurs attributs courants (nom, prénom, SamAccountName, etc.) pour trouver toutes les correspondances (même partielles).

Voici la documentation officielle de Microsoft sur le sujet : [\[MS-ADTS\]: Ambiguous Name Resolution \| Microsoft Learn](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/1a9177f4-0272-4ab8-aa22-3c3eafd39e4b)

### Utilisation de la recherche ANR

J'ai publié un outil pour réinitialiser facilement des mots de passe utilisateur : [leobouard/PasswordReset: A simple WPF interface for Active Directory user password reset](https://github.com/leobouard/PasswordReset). Le principe est simple : rechercher un compte Active Directory pour consulter toutes les informations relatives à son mot de passe et le modifier avec un mot de passe auto-généré ou une saisie manuelle.

Pour la partie "recherche du compte utilisateur", l'utilitaire propose une barre de recherche générique, où le texte en entrée peut être le nom, le prénom, le SamAccountName... Pour explorer toutes ces options à la fois, on peut construire un filtre complexe (et gourmand en ressources), comme celui-ci :

```powershell
Get-ADUser -Filter {
    (Name -like 'Léo*') -or
    (DisplayName -like 'Léo*') -or
    (GivenName -like 'Léo*') -or
    (Surname -like 'Léo*') -or
    (SamAccountName -like 'leo*')
}
```

Ou utiliser la recherche ANR qui indexe plusieurs attributs à la fois, pour obtenir un filtre très simple et performant.

```powershell
Get-ADUser -Filter {ANR -eq 'Léo'}
```

Les deux commandes ci-dessus donneront **un résultat identique**, pour une syntaxe beaucoup plus légère et de meilleures performances en utilisant la recherche ANR.

> La différence de performance est particulièrement notable sur les grands domaines Active Directory.

### Fonctionnement du filtre

La recherche ANR :

- s'apparente à un filtre `-like` avec un seul wildcard, sur la fin de la chaine de caractères (exemple : `name -like 'Léo*'`). Ainsi, on obtiendra des résultats comme "Léo", "Léonard" ou "Leonie", mais pas "Eléonore" (qui ne commence pas par "Léo...")
- n'est compatible qu'avec l'opérateur de comparaison `-eq`
- n'est ni sensible à la casse ni aux accents
- peut être utilisée sur n'importe quel type d'objet (utilisateur, groupe, ordinateur, unité d'organisation...)
- dispose d'une liste d'attributs cibles, modifiable dans le schéma Active Directory

### Lister les attributs indexés par ANR

La liste des attributs qui sont utilisés lors d'une recherche ANR est personnelle à votre domaine. La version fonctionnelle ou la présence de Microsoft Exchange ont un impact sur la liste d'attributs concernés. Le plus simple est donc d'afficher la liste des attributs utilisés lors d'une recherche ANR :

```powershell
$splat = @{
    Filter = {objectClass -eq 'attributeSchema'}
    SearchBase = (Get-ADRootDSE).schemaNamingContext
    Properties = 'ldapDisplayName', 'searchFlags'
}
Get-ADObject @splat |
    Where-Object {$_.searchFlags -band 4} |
    Format-Table name, ldapDisplayName, searchFlags
```

L'indexation (ou non) dans ANR se fait sur la propriété `searchFlags` qui est un *"bit field"* qui stocke plusieurs informations en un seul nombre entier.

À titre indicatif, voici la liste des attributs les plus utiles qui sont indexés par ANR :

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

On ajoute 5 (la somme de 1 et 4) à la valeur initiale (qui peut varier) pour ajouter les options suivantes :

- 1 pour créer un index de cet attribut
- 4 pour ajouter l'attribut à la recherche ANR

> Il est obligatoire de créer un index pour ajouter un attribut à la recherche ANR.

Plus d'informations sur la signification des valeurs contenues dans le champ `searchFlags` ici : [Search-Flags attribute - Win32 apps \| Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/adschema/a-searchflags#remarks)
