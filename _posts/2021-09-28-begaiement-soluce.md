---
layout: post
title: "Solution - Bégaiement"
background: "#f7a4dd"
prevLink:
  name: "Retour au défi"
  id: "/2021/09/28/begaiement"
---

## Version simple

Cette version est simple et efficace, avec un nombre de paramètres limités. Elle ne prends pas en compte les syllabes et répète bêtement les deux premières lettres du mot :

```powershell
function ConvertTo-Stutter {
    param([Parameter(Mandatory,ValueFromPipeline)][string]$Text)

    $finalText = $Text -split ' ' | ForEach-Object {
        if ($_ -match '^[A-z]{3}' -and $_.Length -gt 5 -and ((0,1 | Get-Random) -eq 1)) {
                "$($_.Substring(0,2))… "*2 + $_
        } else { $_ }
    }
    return ($finalText -join " ")
}
```

1. Analyser le nom de la fonction en lui-même
2. Rappel sur les paramètes, notamment la récupération via pipeline
3. Transformation du texte en array pour appliquer un traitement pour chaque item
4. Créer la condition du IF()
5. Création du mot bégaiement

Pour tout savoir sur les fonctions PowerShell :  [Fonctions - PowerShell \| Microsoft Learn](https://learn.microsoft.com/powershell/scripting/learn/ps101/09-functions)

<!--

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

-->