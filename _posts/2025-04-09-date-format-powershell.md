---
title: "Tous les formats de date en PowerShell"
description: "Les formats pour Get-Date avec les résultats en français"
tags: powershell
listed: true
---

## Documentation officielle

Ça va faire au moins trois ans que je me dis qu'il faut que j'écrive cet article.

Il existe déjà toute la documentation utile sur le site de Microsoft pour les formats de date/heure compatibles avec la commande PowerShell `Get-Date`. Cependant, je lui trouve quelques défauts :

- les tableaux qui m'intéressent sont disséminés sur différentes pages
- les tableaux ne peuvent pas être triés par colonne
- les exemples ne sont pas toujours disponible au format fr-FR

Voici donc ma version de la documentation sur les formats pris en charge par `Get-Date`.

## Formats standards

Les formats standards permettent d'obtenir rapidement un formatage en utilisant une seule lettre, au lieu d'avoir à utiliser une chaine de caractère complète.

Documentation officielle : [Chaînes de format de date et d’heure standard - .NET \| Microsoft Learn](https://learn.microsoft.com/fr-fr/dotnet/standard/base-types/standard-date-and-time-format-strings)

### Exemple d'utilisation

```powershell
Get-Date -Format d
```

### Tableau

Lettre(s) | Résultat | Description
------ | -------- | -----------
`d` | 27/09/2023 | Modèle de date courte
`D` | mercredi 27 septembre 2023 | Modèle de date longue
`f` | mercredi 27 septembre 2023 15:30 | Modèle de date/heure complet (heure courte).
`F` | mercredi 27 septembre 2023 15:30:00 | Modèle de date/heure complet (heure longue)
`g` | 27/09/2023 15:30 | Modèle de date/heure général (heure courte)
`G` | 27/09/2023 15:30:00 | Modèle de date/heure général (heure longue)
`m`, `M` | 27 septembre | Modèle de mois/jour
`o`, `O` | 2023-09-27T15:30:00.0000000 | Modèle de date/heure ISO 8601
`r`, `R` | Wed, 27 Sep 2023 15:30:00 GMT | Modèle RFC1123 
`s` | 2023-09-27T15:30:00 | Modèle de date/heure pouvant être trié
`t` | 15:30 | Modèle d’heure courte
`T` | 15:30:00 | Modèle d’heure longue
`u` | 2023-09-27 15:30:00Z | Modèle de date/heure universel pouvant être trié
`U` | mercredi 27 septembre 2023 13:30:00 | Modèle de date/heure complète universelle
`y`, `Y` | septembre 2023 | Modèle d’année/mois

## Formats personnalisés

Le format personnalisé permet de créer un formatage de date en indiquant précisément nos besoin dans une chaine de caractère.

Documentation officielle : [Chaînes de format de date et d’heure personnalisées - .NET \| Microsoft Learn](https://learn.microsoft.com/fr-fr/dotnet/standard/base-types/custom-date-and-time-format-strings)

### Exemple d'utilisation

```powershell
Get-Date -Format 'ddd dd MMM'
```

### Tableau

Il ne s'agit pas d'un tableau complet, mais uniquement des caractères utiles en France.

Chaine | Résultat | Description
------ | -------- | -----------
`dd` | 27 | Jour du mois sur deux caractères
`ddd` | mer. | Nom abrégé du jour de la semaine
`dddd` | mercredi | Nom complet du jour de la semaine
`HH` | 15 | Heure au format 24h sur deux caractères
`K` | +02:00 | Fuseau horaire
`mm` | 30 | Minutes sur deux caractères
`MM` | 09 | Mois sur deux caractères
`MMM` | sept. | Nom abrégé du mois
`MMMM` | septembre | Nom complet du mois
`ss` | 00 | Secondes sur deux caractères
`yy` | 23 | Année sur deux caractères
`yyyy` | 2023 | Année sur quatre caractères

## Traduction d'une date

Il est possible de "traduire" une date d'une langue vers une autre avec la commande suivante :

```powershell
(Get-Date).ToString('D', [System.Globalization.CultureInfo]::CreateSpecificCulture('fr'))
```

Le `'D'` indique le format standard ou personnalisé à utiliser.

Le `'fr'` indique la culture de destination. Vous pouvez obtenir la liste des cultures disponibles avec la commande `Get-Culture -ListAvailable` disponible à partir de PowerShell 7.