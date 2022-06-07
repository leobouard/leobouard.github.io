---
layout: post
title: "Solution - Père Noël aléatoire"
---

Encore une fois on tire partie au maximum des PSCustomObject pour ajouter une propriété "Random" qui va nous pemettre de mélanger la liste aléatoirement. Une fois que l'on a fait ça, on suit simplement le nouvel ordre aléatoire de la liste pour annoncer "A offre son cadeau à B", puis "B offre son cadeau à C", etc...

```powershell

function PereNoelAleatoire {

    param([array]$Participants)

    # Creation des objets
    $users = @()
    $Participants | ForEach-Object {
        $users += [PSCustomObject]@{
            Name   = $_
            Random = $null
        }
    }

    # Génération d'un liste aléatoire de chiffres entre 0 et le nombre d'utilisateurs
    $count  = ($users | Measure-Object).Count
    $random = 0..$count | Get-Random -Count $count
    $i = 0

    # Ajout de la colonne avec le chiffre aléatoire
    $users | ForEach-Object {
        $_.Random = $random[$i]
        $i++
    }

    # Triage des utilisateurs selon leur chiffre aléatoire
    $users = $users | Sort-Object -Property Random

    # Boucle afficher le résultat (nRandom offre à nRandom+1)
    0..($count-1) | ForEach-Object {
        $index = $_ + 1
        if ($index -ge $count) { $index = $count - $index }
        $giftTo   = ($users[$index]).Name
        $giftFrom = ($users[$_]).Name

        "#{0} {1} offre son cadeau à {2}" -f $_,$giftFrom,$giftTo
        Read-Host | Out-Null
    }

}

```

`if ($index -ge $count) { $index = $count - $index }` : ce petit bout de code permet de dire que quand on arrive à la dernière personne de la liste, celle-ci doit offrir son cadeau à la première personne.

`Read-Host | Out-Null` : permet d'attendre une action utilisateur avant d'afficher le prochain résultat. On pourrait tout à fait le remplacer par :

- la commande CMD "pause" (fonctionnement similaire)
- un "Start-Sleep -Second 1" pour afficher la ligne suivante après une seconde d'attente

## Exemple d'utilisation

``` 

PS C:\> PereNoelAleatoire -Participants Jake,Rosa,Terry,Amy,Charles,Holt

#0 Jake offre son cadeau à Terry

#1 Terry offre son cadeau à Holt

#2 Holt offre son cadeau à Amy

#3 Amy offre son cadeau à Rosa

#4 Rosa offre son cadeau à Charles

#5 Charles offre son cadeau à Jake

```
