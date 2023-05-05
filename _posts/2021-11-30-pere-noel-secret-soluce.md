---
layout: post
title: "Solution - Père Noël aléatoire"
background: "#f78787"
prevLink:
  name: "Retour au défi"
  id: "/2021/11/30/pere-noel-secret"
---

Voici la fonction `Get-SecretSanta` pour obtenir notre tirage au sort :

```powershell
function Get-SecretSanta {
    param(
        [array]$People,
        [switch]$Pause
    )

    $i = 0
    $random = 1..$People.Count | Get-Random -Count $People.Count
    $People = $People | ForEach-Object {
        [PSCustomObject]@{
            Name = $_
            ID = $random[$i]
        }
        $i++
    } | Sort-Object -Property ID
    
    $People | ForEach-Object {
        $index = $_.ID+1
        $giftTo   = ($People | Where-Object {$_.ID -eq $index}).Name
        if (!$giftTo) { $giftTo = ($People | Where-Object {$_.ID -eq 1}).Name }

        "#{0} {1} offre son cadeau à {2}" -f $_.ID,$_.Name,$giftTo
        if ($Pause.IsPresent) { $null = Read-Host }
    }
}
```

## Explication de code

### Paramètres

### Première boucle

### Deuxième boucle

### Affichage progressif

Dans mon cas, l'affichage progressif doit être invoqué avec le paramètre `-Pause` de la fonction. Si ce paramètre est actif, alors on va attendre que l'utilisateur appuie sur la touche "Entrée" du clavier via une utilisation détournée du `Read-Host`. On peut également utiliser directement la commande `pause` qui fonctionne exactement de la même manière mais qui a comme désavantage d'imposer un texte dans la console : "*Cliquez sur Entrée pour continuer...:*".

Au passage, si vous souhaitez vérifier quel est le code d'une fonction, vous pouvez le faire très simplement avec la commande `Get-Command` :

> PS C:\> Get-Command 'pause' | Format-List
>\
> Name        : Pause\
> CommandType : Function\
> Definition  : $null = Read-Host 'Cliquez sur Entrée pour continuer...'
