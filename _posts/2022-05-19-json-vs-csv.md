---
layout: post
title: "CSV vs. JSON"
description: "Les voyelles c'est pour les faibles"
tags: howto
thumbnailColor: "#ef5b5b"
icon: 🆚
---

Si vous avez déjà utiliser PowerShell, vous êtes probablement déjà tombé sur

## Informations en bref

Dans cet article j'aborde le thème des "fichiers de données structurées". Souvent externe aux scripts PowerShell, ils permettent d'importer, exporter, stocker ou requêter des données via PowerShell. Dans les types de fichiers récurents, on retrouve :

- **CSV** : le meilleur ami de PowerShell, très souvent utilisé pour peupler ou extraire des données sur Active Directory
- **XAML** : utilisé pour les interfaces graphique en WPF ou la sauvegarde d'identifiants de connexion par exemple ([Import-CliXml](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-clixml) et [Export-CliXml](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/export-clixml))
- **JSON** : le meilleur ami de JavaScript, mais qui est de plus en plus utilisé pour les configurations Azure et en PowerShell
- **TXT** : souvent utilisé les journalisations d'un script ou les bannières d'affichage
- **YAML** : plus simple et plus complet que JSON, il n'est malheureusement pas supporté nativement par PowerShell
- ...et sûrement plein d'autres que j'oublie.

Chacun de ces types fichiers ont leurs usages, leurs avantages et inconvénients. On va ce concentrer exclusivement sur le CSV et le JSON qui sont les plus faciles à utiliser avec PowerShell (en attendant YAML 😄).

## C'est quoi le CSV

> Comma-separated values, connu sous le sigle CSV, est un format texte ouvert représentant des données tabulaires sous forme de valeurs séparées par des virgules.

Sur [Wikipédia](https://fr.wikipedia.org/wiki/Comma-separated_values)

Si vous faites déjà un peu de PowerShell, vous avez probablement déjà travaillé avec le format de fichier CSV. Celui-ci permet d'importer/exporter facilement et rapidement des données avec PowerShell via le duo de commandes [Import-Csv](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/import-csv) et [Export-Csv](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/export-csv). C'est un format de fichier très populaire et qui est assez simple à prendre en main : le fichier est facilement modifiable par des personnes non-techniques directement dans Excel.

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

Le nom des colonnes est indiqué sur la première ligne et les colonnes sont séparées par des virgules (ou des points-virgules, libre à vous de choisir le délimiteur qui vous convient le plus).

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

### Avantages

✅ Facile à prendre en main
✅ Modification dans Excel

### Inconvénients

❌ Passé un certain nombre de colonnes, c'est un format compliqué à modifier sans Excel (sur une station d'administration par exemple)
❌ Conservation des formats

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