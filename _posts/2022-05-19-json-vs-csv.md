---
layout: post
title: "CSV vs. JSON"
description: "Les voyelles c'est pour les faibles"
tags: howto
thumbnailColor: "#ef5b5b"
icon: 🆚
---

## Informations en bref

Dans cet article j'aborde le thème des "fichiers de données structurées". Souvent externe aux scripts PowerShell, ils permettent d'importer, exporter, stocker ou requêter des données via PowerShell. Dans les types de fichiers récurents, on retrouve :

- **CSV** : le meilleur ami de PowerShell, très souvent utilisé pour peupler ou extraire des données sur Active Directory
- **JSON** : le meilleur ami de JavaScript, mais qui est de plus en plus utilisé pour les configurations Azure et en PowerShell
- - **XAML** : utilisé pour les interfaces graphique en WPF ou la sauvegarde d'identifiants de connexion par exemple ([Import-CliXml](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-clixml))
- **TXT** : souvent utilisé les journalisations d'un script ou les bannières d'affichage
- **YAML** : plus simple et plus complet que JSON, il n'est malheureusement pas supporté nativement par PowerShell

...et sûrement plein d'autres formats que j'oublie.

Chacun de ces types fichiers ont leurs usages, leurs avantages et inconvénients. On va ce concentrer exclusivement sur le CSV et le JSON qui sont les plus faciles à utiliser avec PowerShell (en attendant le support natif du YAML 😄).

## C'est quoi le CSV

> Comma-separated values, connu sous le sigle CSV, est un format texte ouvert représentant des données tabulaires sous forme de valeurs séparées par des virgules.

Sur [Wikipédia](https://fr.wikipedia.org/wiki/Comma-separated_values)

Si vous faites déjà un peu de PowerShell, vous avez probablement déjà travaillé avec le format de fichier CSV. Celui-ci permet d'importer/exporter facilement et rapidement des données avec PowerShell via le duo de commandes [Import-Csv](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/import-csv) et [Export-Csv](https://docs.microsoft.com/powershell/module/microsoft.powershell.utility/export-csv). C'est un format de fichier très populaire et qui est assez simple à prendre en main : le fichier est facilement modifiable par des personnes non-techniques directement dans Excel.

La modification dans Excel est le plus gros point fort du CSV, car des fichiers peuvent être :

- peuplés par des personnes qui ne travaillent pas en informatique (exemple type : les ressources humaines pour la création de nouveaux utilisateurs dans Active Directory)
- modifiés en masse rapidement via la fonctionnalité *[poignée de recopie](https://support.microsoft.com/fr-fr/office/copier-une-formule-en-faisant-glisser-la-poign%C3%A9e-de-recopie-dans-excel-pour-mac-dd928259-622b-473f-9a33-83aa1a63e218)* (drag pour les anglophones)
- extrait pour être revus et étudié plus facilement

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

Le nom des colonnes est visible sur la première ligne et les colonnes sont indiquées par des virgules (ou des points-virgules, libre à vous de choisir le délimiteur qui vous convient le plus).

### Intégration avec PowerShell

Avec un fichier CSV externe au script :

```powershell

Import-Csv -Path "C:\temp\export.csv" -Delimiter ',' -Encoding UTF8

```

...et on se retrouve ensuite avec un bel objet PowerShell facilement requêtable ! 🙂 

Ou au moins c'est l'impression qu'il donne, mais le CSV possède tout de même quelques limitations.

### Les limites de CSV

Et bien oui, le CSV n'est pas parfait pour tous les besoins. Il possède notamment deux gros défauts (qui sont liés) :

- il ne sait pas compter
- il ne gère que des données "plates"

#### CSV ne sait pas compter

Malgré toutes ses qualités, les mathématiques ne sont pas le point fort du CSV.

Pour les exemples suivants, on va se baser sur la variable $CSV suivante :

```powershell

$csv = @'
givenName,surname,userPrincipalName,id
John,Doe,john.doe@labouabouate.fr,51
Jack,Smith,jack.smith@labouabouate.fr,85
Jane,Black,jane.black@labouabouate.fr,22
'@ | ConvertFrom-Csv -Delimiter ','

```

#### Exemple 1 - Les comparaisons

Ici on demande simplement de vérifier que chaque identifiant (colonne ID) est supérieur à 9. Le résultat attendu est donc 'True' à chaque fois, et pourtant...

```powershell

PS C:\> $csv | % {$_.id -gt 9}

False
False
False

```

#### Exemple 2 - Les additions

Encore plus simple, on demande d'ajouter 1 à chacun des identifiants. On devrait donc retrouver les valeurs 52, 86 et 23, et pourtant...

```powershell

PS C:\> $csv | % {$_.id + 1}

511
851
221

```

#### Exemple 3 - Les multiplications

On fait la même chose que d'habitude : on multiplie la valeur de chaque identifiant par deux :

```powershell

PS C:\> $csv | % {$_.id * 2}

5151
8585
2222

```

<div style="text-align: center">
  <i>A ce niveau, c'est un 0 pointé en maths</i>
</div>

#### Explication

Vous l'avez probablement déjà deviné avec les trois exemples précédents, mais PowerShell considère que toutes les données contenues dans le fichier CSV sont des valeurs de type "texte" (même quand la valeur n'est composée que de chiffres).

Dans certains cas, PowerShell comprend que la valeur est en fait un nombre entier, notamment sur la division et la soustraction (car il s'agit de deux opérations purement mathématiques qui ne concernent pas les chaines de caractères).

Pour corriger ça, on peut formater la "colonne" ID en amont en indiquant à PowerShell qu'il s'agit de nombres entiers et pas de chaines de caractères :

```powershell

$csv | % {$_.id = [int]($_.id)}

```

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