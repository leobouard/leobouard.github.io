---
layout: post
title: "CSV vs. JSON"
description: "Les voyelles c'est pour les faibles"
tags: howto
thumbnailColor: "#ef5b5b"
icon: 🆚
---

## C'est quoi le CSV

> Comma-separated values, connu sous le sigle CSV, est un format texte ouvert représentant des données tabulaires sous forme de valeurs séparées par des virgules.

Sur [Wikipédia](https://fr.wikipedia.org/wiki/Comma-separated_values)

Si vous faites un peu de PowerShell, vous avez probablement déjà travaillé avec le format de fichier CSV qui permet d'importer/exporter facilement et rapidement des données avec PowerShell via le duo de commandes [Import-Csv](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/import-csv) et [Export-Csv](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/export-csv).

C'est un format de fichier très populaire et qui est assez simple à prendre en main : le fichier est facilement modifiable par des personnes non-techniques directement dans Excel.

### A quoi ça ressemble ?

La version mise en page :

givenName | surname | userPrincipalName | id
--------- | ------- | ----------------- | --
John | Doe | john.doe@labouabouate.fr | 51
Jack | Smith | jack.smith@labouabouate.fr | 85
Jane | Black | jane.black@labouabouate.fr | 22

La version brute :

```

givenName,surname,userPrincipalName,id
John,Doe,john.doe@labouabouate.fr,51
Jack,Smith,jack.smith@labouabouate.fr,85
Jane,Black,jane.black@labouabouate.fr,22

```

Bon du coup c'est simple à comprendre : les colonnes sont indiquées par des virgules (ou des points-virgules, c'est vous qui voyez).

### Intégration avec PowerShell

Avec un fichier CSV externe au script :

```powershell

Import-Csv -Path "C:\temp\export.csv" -Delimiter ',' -Encoding UTF8

```

ou alors avec un petit fichier CSV inclu directement dans le script :

```powershell

@'
givenName,surname,userPrincipalName,id
John,Doe,john.doe@labouabouate.fr,51
Jack,Smith,jack.smith@labouabouate.fr,85
Jane,Black,jane.black@labouabouate.fr,22
'@ | ConvertFrom-Csv -Delimiter ','

```

...et on se retrouve ensuite avec un bel objet PowerShell facilement requêtable ! 🙂

---

## C'est quoi le JSON

> JavaScript Object Notation (JSON) est un format de données textuelles dérivé de la notation des objets du langage JavaScript. Il permet de représenter de l’information structurée comme le permet XML par exemple.

Sur [Wikipédia](https://fr.wikipedia.org/wiki/JavaScript_Object_Notation)

### A quoi ça ressemble ?

### Intégration avec PowerShell

```powershell

$json = @'
[
    {
        "Prénom": "Jacques",
        "Nom": "Dupont",
        "Age": 30,
        "Couleurs": [
            "Kaki",
            "Gris",
            "Bleu marine"
        ]
    }
]
'@ | ConvertFrom-Json

```

---

## Comparaison des deux formats

### Formatage des données

#### Entiers

```

PS C:\> $csv.Age -gt 5

False

```

```

PS C:\> $json.Age -gt 5

True

```

#### Multi-valeurs

#### Objets complexes

#### Dates

### En résumé

![json c'est mieux](https://i.kym-cdn.com/entries/icons/original/000/023/194/cover1.jpg)

<div style="text-align: center">
  <i>CSV vs. JSON</i>
</div>