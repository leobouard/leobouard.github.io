---
title: "Formats externes de fichiers pour PowerShell"
description: "Résumé de toutes les choses à savoir sur l'utilisation du format CSV pour extraire ou importer des données avec PowerShell"
---

# CSV (Comma-separated values)

Le CSV est le format externe le plus utilisé avec PowerShell et pour cause :

## Commandes compatibles

- `Import-Csv` : pour importer un fichier CSV vers PowerShell
- `Export-Csv` : pour exporter des données PowerShell en fichier CSV
- `ConvertFrom-Csv` : pour convertir du texte CSV en données PowerShell
- `ConvertTo-Csv` : pour convertir des données PowerShell en texte CSV

## Avantages et limites

### Avantages

- modifiable directement dans Notepad
- modifiable facilement dans Excel
- format de fichier très répandu

### Limites

- ne fonctionne bien qu'avec les données "plates"
- pas de typage sur les données : toutes les valeurs contenues dans un tableau sont considérés comme du texte

## Exemples d'utilisation

---

# JSON (💖)

## Commandes compatibles

- `ConvertFrom-Json`
- `ConvertTo-Json`

## Avantages et limites

### Avantages

- peut stocker des données structurées complexes
- typage des données (texte, nombre, booléen, objets et multi-valeur)
- format de fichier répandu (notamment pour les API)
- s'apprend relativement rapidement
- suit la même logique que les données PowerShell

### Limites

- exigeant au niveau de la syntaxe
- n'est pas modifiable par une personne non technique
- gestion de la profondeur à faire
- performances catastrophiques sur la conversion

---

# XML (satan)

- `ConvertFrom-CliXml`
- `ConvertTo-CliXml`
- `ConvertTo-Xml`
- `[xml]()`

### Avantages

- peut stocker des données structurées complexes
- typage très précis des données
- gestion automatique de la profondeur
- beaucoup d'options

### Limites

- incompréhensible pour le commun des mortels
- nécessite un réel apprentissage
- ne suit pas la même logique que les données PowerShell
- performances moyennes sur la conversion

---

# Les autres

## Markdown (💖)

- `ConvertFrom-Markdown`
  
## HTML

- `ConvertTo-Html`

## YAML

Pas de commande pour YAML :-(

---

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

Pour récupérer rapidement et facilement les données d'un fichier CSV en PowerShell, on peut utiliser la commande dédiée [Import-Csv](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/import-csv).

```powershell
Import-Csv -Path "C:\temp\export.csv" -Delimiter ',' -Encoding UTF8
```

...et on se retrouve ensuite avec un bel objet PowerShell facilement requêtable ! 🙂 Ou au moins c'est l'impression qu'il donne, mais le CSV possède tout de même quelques limitations.

### Les limites de CSV

Et bien oui, le CSV n'est pas parfait pour tous les besoins. Il possède notamment deux gros défauts (qui sont liés) :

- il ne sait pas compter
- il ne gère que des données "plates"

#### CSV ne sait pas compter

Malgré toutes ses qualités, les mathématiques ne sont pas le point fort du CSV. Pour les exemples suivants, on va se baser sur la variable $CSV suivante :

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

#### Explication

Vous l'avez probablement déjà deviné avec les trois exemples précédents, mais PowerShell considère que toutes les données contenues dans le fichier CSV sont des valeurs de type "texte" (même quand la valeur n'est composée que de chiffres).

Dans certains cas, PowerShell comprend que la valeur est en fait un nombre entier, notamment sur la division et la soustraction (car il s'agit de deux opérations purement mathématiques qui ne concernent pas les chaines de caractères).

Pour corriger ça, on peut formater la "colonne" ID en amont en indiquant à PowerShell qu'il s'agit de nombres entiers et pas de chaines de caractères :

```powershell
$csv | % {$_.id = [int]($_.id)}
```