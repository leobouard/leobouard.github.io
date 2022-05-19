---
layout: post
title: "JS0N vs. CSV"
description: "Les voyelles c'est pour les faibles"
tags: howto
thumbnailColor: "#519E8A"
icon: 🆚
---

## C'est quoi le JSON

## C'est quoi le CSV

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

```powershell

$csv = @'
Prénom;Nom;Age;Couleurs
Jacques;Dupont;30;Kaki,Gris,Bleu marine
'@ | ConvertFrom-Csv -Delimiter ";"

```

PS C:\> $csv.Age -gt 5
False

PS C:\> $json.Age -gt 5
True

![json c'est mieux](https://i.kym-cdn.com/entries/icons/original/000/023/194/cover1.jpg)

<div style="text-align: center">
  <i>JSON versus CSV</i>
</div>