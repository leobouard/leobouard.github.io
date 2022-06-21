---
layout: post
title: "Solution - Bégaiement"
---

Petit rappel de la tirade complète :

```powershell

$text = "Vous savez, moi je ne crois pas qu’il y ait de bonne ou de mauvaise situation. Moi, si je devais résumer ma vie aujourd’hui avec vous, je dirais que c’est d’abord des rencontres. Des gens qui m’ont tendu la main, peut-être à un moment où je ne pouvais pas, où j’étais seul chez moi. Et c’est assez curieux de se dire que les hasards, les rencontres forgent une destinée… Parce que quand on a le goût de la chose, quand on a le goût de la chose bien faite, le beau geste, parfois on ne trouve pas l’interlocuteur en face je dirais, le miroir qui vous aide à avancer. Alors ça n’est pas mon cas, comme je disais là, puisque moi au contraire, j’ai pu : et je dis merci à la vie, je lui dis merci, je chante la vie, je danse la vie… je ne suis qu’amour ! Et finalement, quand beaucoup de gens aujourd’hui me disent « Mais comment fais-tu pour avoir cette humanité ? », et bien je leur réponds très simplement, je leur dis que c’est ce goût de l’amour ce goût donc qui m’a poussé aujourd’hui à entreprendre une construction mécanique, mais demain qui sait ? Peut-être simplement à me mettre au service de la communauté, à faire le don, le don de soi…"

```

...comme ça on part sur la même base !

## Version "simple"

Je vous propose une première version "innocente" et la plus simple possible. 

```powershell

function Begaiement {

    param([string]$Text)

    $array = $text -split ' '
    $finalText = @()
    $array | % {
        $word = $PSItem
        if ($word -match '^[A-z]{3}' -and $word.Length -gt 5) { 
            if (($true,$false | Get-Random) -eq $true) {
                $cutWord = "$($word.Substring(0,2))… "
                $word    = $cutWord + $cutWord + $word
            }
        }
        $finalText += $word
    }
    return ($finalText -join " ")
}

```

## Version "j'ai poussé un peu trop loin pour un simple défi"

```powershell

function Begaiement {

    param(
        [string]$Text,
        [int]$StutterFrequency,
        [string]$StutterCharacter,
        [int]$MinimalWordLength,
        [switch]$OutLoud
    )

    $finalText = @()

    # Définition des valeurs par défaut
    if (!$MinimalWordLength) { $MinimalWordLength = 5 }
    if (!$StutterFrequency)  { $StutterFrequency = 50 }
    if (!$StutterCharacter)  { $StutterCharacter = "…" }
    $vowels = 'a','e','i','o','u','y','h' # Je sais que le H n'est pas une voyelle !

    # Convertion du texte en tableau (séparation à chaque espace)
    $array = $Text -split ' '

    # Pour chaque mot...
    $array | ForEach-Object {

        $word = $PSItem

        # Condition d'entrée : le mot commence par au moins 3 lettres consécutives & mesure la taille minimale
        if ($word -match '^[A-z]{3}' -and $word.Length -gt $MinimalWordLength) { 

            # Provoque le bégayement selon le pourcentage défini
            $stutter = (Get-Random -Minimum 0 -Maximum 100) -le $StutterFrequency
            if ($stutter -eq $true) {

                $cutWord = $word[0]
                $isVowel = $null
                $i = 1
 
                <# La partie du mot à bégayer continue jusqu'à rencontrer une consonne
                    Exemples :
                        - avancer  --> a…a…avancer
                        - mauvais  --> mau…mau…mauvaise
                        - beaucoup --> beau…beau…beaucoup
                #>
                do {
                    $letter = $word[$i]
                    if ($letter -in $vowels) { 
                        $cutWord += $letter 
                        $isVowel = $true
                    } else {
                        $isVowel = $false
                    }
                    $i++
                } until ($isVowel -eq $false)
                
                # Assemblage de la partie du mot à bégayer, du caractère de liaison et du mot entier
                $word = $cutWord + $StutterCharacter + $cutWord + $StutterCharacter + $word
            }
        }
        $finalText += $word
        Remove-Variable word
    }

    if ($OutLoud.IsPresent) {
        Add-Type -AssemblyName System.Speech
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $speak.Speak($finalText)
    }

    # Assemblage final du texte
    $finalText = $finalText -join " "

    return $finalText
}

```