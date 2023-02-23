---
layout: post
title: "Cours PowerShell #9 - Réparation"
description: "Description"
icon: 🎓
nextLink:
  name: "Partie 10"
  id: "/2022/12/01/cours-pratique-powershell-010"
prevLink:
  name: "Partie 8"
  id: "/2022/12/01/cours-pratique-powershell-008"
---

## Consigne

### Résultat attendu

---

## Etape par étape

1. Adaptation des variables
2. 

### Adaptation des variables

Certaines de nos anciennes variables vont être directement intégrées à l'interface graphique. Il s'agit du nombre de tentatives et les bornes inférieures et supérieures.

Ancienne variable | Composant XAML | Nouvelle variable | Description
----------------- | -------------- | ----------------- | -----------
`$i` | Barre de progression | `$progressbarCoupsRestants.Value` | Compte le nombre de tentatives du joueur
`$min` | Label | `$labelMin.Content` | Borne inférieure
`$max` | Label | `$labelMax.Content` | Borne supérieure

```powershell
$progressbarCoupsRestants.Value = 0
$labelMin.Content = 1
$labelMax.Content = 1000
```

Pour les autres variables (`$allAnswers`, `$stopwatch` et `$random`) il va surtout s'agir de les passer dans l'étendue globale pour être sûr qu'elles puissent être utilisées n'importe où dans le script.

```powershell
$Global:allAnswers = [System.Collections.Generic.List[int]]@()
$Global:stopwatch  = [System.Diagnostics.Stopwatch]::New()
$Global:random     = Get-Random -Minimum $labelMin.Content -Maximum $labelMax.Content
```

### Intégration du traitement

Dans l'action de la boite de texte, on va remplacer l'actuel `Write-Host $answer` pour intégrer et adapter la comparaison entre l'estimation du joueur et le nombre aléatoire.

Changements a effectuer :

- Supprimer le `Read-Host`
- Remplacer les anciennes variables par les nouvelles
- Modifier les `Write-Host` pour que le texte soit affiché directement dans l'interface graphique via la variable `$labelText.Content`

```powershell
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
}
```

<div class="information">
    <span>Problème d'encodage</span>
    <p>Si vous rencontrez des problèmes avec l'affichage des accents à ce stade, il faut bien vérifier que votre script est enregistré au format UTF8-BOM.</p>
</div>

### Modification du comportement de la victoire

Si vous tester le script à ce stade et que vous parvenez à trouver le nombre aléatoire, vous constaterez que la victoire n'empêche pas le joueur de continuer à jouer. On va donc ajouter quelques traitement supplémentaires :

- Rendre les boutons "Recommencer" et "Meilleurs scores" visibles
- Afficher le nombre aléatoire dans la boite de texte
- Désactiver la boite de texte
- Arrêter le chronomètre

```powershell
$stackpanelButtons.Visibility = "Visible"
$textboxResponse.Text = $random
$textboxResponse.IsEnabled = $false
$stopwatch.Stop()
```

### Détection de défaite

Dans l'état, la défaite n'est pas possible puisqu
 
## Correction

```powershell
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
    }
})

$null = $Global:interface.ShowDialog()
```
