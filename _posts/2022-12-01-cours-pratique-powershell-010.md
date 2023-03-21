---
layout: post
title: "Cours PowerShell #10 - Finalisation"
description: "Implémentation des dernières fonctionnalités au script PowerShell, avec notamment un mode triche et une amélioration globale de l'utilisation de l'interface graphique."
icon: 🎓
prevLink:
  name: "Partie 9"
  id: "/2022/12/01/cours-pratique-powershell-009"
---

## Consigne

Il nous reste encore quelques éléments à implémenter au script graphique pour le déclarer comme terminé :

- Rendre le bouton "Recommencer" fonctionnel
- Réimplémenter le mode facile
- Créer un mode triche
- 

### Résultat attendu

---

## Etape par étape

### Rendre le bouton "Recommencer" fonctionnel

Le fait de recommencer une nouvelle partie implique de réinitialiser un bon nombre d'éléments de l'interface graphique : la barre de progression, les bornes supérieures et inférieures, les boutons supplémentaires, etc. Pour éviter de répéter des lignes de code, il convient donc de créer une fonction.

Nous utiliserons donc la fonction `Reset-UI` pour regrouper les actions déjà effectuées en début de script (comme la génération du nombre aléatoire, la définition des valeurs maximum et minimum, la réinitialisation du chronomètre et de la barre de progression, etc.) et d'autres actions spécifiques à une nouvelle partie comme :

- rendre les boutons "Recommencer" et "Meilleurs scores" invisibles
- vider le contenu de la boite de texte et la rendre active
- réinitialiser la valeur du label qui indique "Le nombre est plus petit / grand que ..."

```powershell
function Reset-UI {
    # ...
    $stackpanelButtons.Visibility = "Hidden"
    $textboxResponse.IsEnabled = $true
    $textboxResponse.Text = $null
    $labelText.Content = "Le nombre est plus..."
    # ...
}
Reset-UI
```

Il ne reste plus qu'à déclarer une action pour le bouton "Recommencer" :

```powershell
$buttonRetry.Add_Click({ Reset-UI })
```

### Réimplémenter le mode facile

On ajoute le paramètre `[switch]$EasyMode` pour réduire la complexité du nombre aléatoire : celui-ci est forcément un multiple de 5.

```powershell
if ($EasyMode.IsPresent) {
    while ($random % 5 -ne 0) {
        $Global:random = Get-Random -Minimum $labelMin.Content -Maximum $labelMax.Content
    }
}
```

### Création du mode triche

On ajoute le paramètre `[switch]$CalcBot` pour invoquer le mode triche : celui-ci va calculer pour nous la valeur moyenne entre la borne inférieure et la borne supérieure, puis l'inscrire directement dans la boite de texte.

Calculer la valeur moyenne des bornes est la meilleure méthode pour parvenir à la victoire de manière assurée, puisque 2¹⁰ = 1024. Cette méthode est appelée *[binary search](https://en.wikipedia.org/wiki/Binary_search_algorithm)* et consiste à découper une liste en deux lots égaux pour exclure le maximum de résultats à chaque tour, et donc de diviser le nombre de possibilités par deux. Au bout de 10 tours, il ne reste qu'une seule possibilité :

Tentative | Bornes | Possibilités
--------- | ------ | ------------
n°0 | 1 à 1000 | 1000 ≃ 2¹⁰
n°1 | 1 à 500 | 500 ≃ 2⁹
n°2 | 1 à 250 | 250 ≃ 2⁸
n°3 | 125 à 250 | 125 ≃ 2⁷
n°4 | 188 à 250 | 62 ≃ 2⁶
n°5 | 188 à 219 | 31 ≃ 2⁵
n°6 | 188 à 204 | 16 = 2⁴
n°7 | 188 à 196 | 8 = 2³
n°8 | 192 à 196 | 4 = 2²
n°9 | 192 à 194 | 2 = 2¹
n°10 | 193 | 1 = 2⁰

Pour le joueur, il ne lui reste qu'à faire une estimation initiale et à appuyer frénétiquement sur "Entrée" pour finir la partie.

```powershell
if ($CalcBot.IsPresent) {
    $textboxResponse.Text = [math]::Round((($labelMax.Content+$labelMin.Content)/2),0)
}
```

### Rendre le bouton "Meilleurs scores" fonctionnel

### Améliorer le tableau des scores

## Correction

```powershell
param(
    [switch]$CalcBot
)

Add-Type -AssemblyName PresentationFramework
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/interface.xaml"
[xml]$Global:xaml = (Invoke-WebRequest -Uri $uri).Content
$Global:interface = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
    Set-Variable -Name ($_.Name) -Value $interface.FindName($_.Name) -Scope Global
}

$progressbarCoupsRestants.Value = 0
$labelMin.Content = 1
$labelMax.Content = 1000
$Global:allAnswers = [System.Collections.Generic.List[int]]@()
$Global:stopwatch  = [System.Diagnostics.Stopwatch]::New()
$Global:random     = Get-Random -Minimum $labelMin.Content -Maximum $labelMax.Content

$textboxResponse.Add_KeyDown({
    if ($_.Key -eq "Return") {
        $answer = [int]($textboxResponse.Text)
        $textboxResponse.Text = $null
        
        $progressbarCoupsRestants.Value++
        if ($stopwatch.IsRunning -eq $false) { $stopwatch.Start() }
        $allAnswers.Add($answer)
        if ($random -gt $answer) { 
            $labelText.Content = "Le nombre aléatoire est plus grand que $answer"
            $labelMin.Content = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object | Select-Object -Last 1
        } elseif ($random -lt $answer) {
            $labelText.Content = "Le nombre aléatoire est plus petit que $answer"
            $labelMax.Content = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1
        } else {
            $labelText.Content = "VICTOIRE ! Vous avez deviné le nombre aléatoire"
            $stackpanelButtons.Visibility = "Visible"
            $textboxResponse.Text = $random
            $textboxResponse.IsEnabled = $false
            $stopwatch.Stop()
        }

        if ($progressbarCoupsRestants.Value -eq $progressbarCoupsRestants.Maximum -and $textboxResponse.Text -ne $random) {
            $stackpanelButtons.Visibility = "Visible"
            $textboxResponse.Text = $random
            $textboxResponse.IsEnabled = $false
            $labelText.Content = "DEFAITE ! Le nombre etait : $random"
            $stopwatch.Stop()
        }

        if ($CalcBot.IsPresent) {
            $textboxResponse.Text = [int](($labelMax.Content+$labelMin.Content)/2)
        }
    }
})

$null = $Global:interface.ShowDialog()
```