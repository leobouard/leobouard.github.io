---
layout: post
title: "CSV vs. JSON"
description: "Les voyelles c'est pour les faibles"
tags: howto
thumbnailColor: "#ef5b5b"
icon: 🆚
---

## C'est quoi le CSV

Quoi de mieux qu'une bonne définition Wikipédia pour commencer ?

> Comma-separated values, connu sous le sigle CSV, est un format texte ouvert représentant des données tabulaires sous forme de valeurs séparées par des virgules.

Sur [Wikipédia](https://fr.wikipedia.org/wiki/Comma-separated_values)

### A quoi ça ressemble ?

givenName | surname | userPrincipalName | id
--------- | ------- | ----------------- | --
John | Doe | john.doe@labouabouate.fr | 51
Jack | Smith | jack.smith@labouabouate.fr | 85
Jane | Black | jane.black@labouabouate.fr | 22



```
givenName,surname,userPrincipalName,id

```

### Intégration avec PowerShell



## C'est quoi le JSON

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

## Gestion des types de données

### Entiers

```

PS C:\> $csv.Age -gt 5

False

```

```

PS C:\> $json.Age -gt 5

True

```

![json c'est mieux](https://i.kym-cdn.com/entries/icons/original/000/023/194/cover1.jpg)

<div style="text-align: center">
  <i>CSV vs. JSON</i>
</div>