---
layout: post
title: "Cours PowerShell #8 - Ajout de l'interface graphique"
description: "On appose maintenant une interface graphique XAML au script PowerShell et on adapte le script existant pour convenir à ce changement"
icon: 🎓
nextLink:
  name: "Partie 9"
  id: "/2022/12/01/cours-pratique-powershell-009"
prevLink:
  name: "Partie 7"
  id: "/2022/12/01/cours-pratique-powershell-007"
---

## Consigne

Nouveau départ ! On va implémenter une interface graphique réalisée avec Windows Presentation Foundation (WPF) et stockée dans un fichier XAML externe au script. Si vous le souhaitez, vous pouvez faire votre propre interface graphique en utilisant Visual Studio Community par exemple. Je vous recommande tout de même d'utiliser le fichier que je propose comme base de travail.

Dans un premier temps, on va juste vouloir lancer l'interface graphique et laisser le joueur entrer une estimation dans la boite de texte. Lorsque le joueur appuie sur la touchée "Entrée" de son clavier, la boite de texte est alors vidée de son contenu et l'estimation est affichée dans la console.

<div class="information">
  <h4>Recommandation</h4>
  <p>Pour cette partie, je vous recommande de créer un nouveau script plutôt qu'adapter le script existant. De cette manière, vous pourrez créer la structure liée à l'interface graphique, puis copier-coller les bouts de code pertinents en dessous de chaque bouton.</p>
</div>

### Résultat attendu

### Ressources

Comme cette partie est relativement compliquée, je vous donne quelques ressources :

- [Mon code XAML utilisé pour l'interface WPF](https://github.com/leobouard/leobouard.github.io/blob/main/assets/files/interface.xaml)
- [Créer une interface graphique WPF en PowerShell - Akril.net](https://akril.net/creer-une-interface-graphique-wpf-en-powershell/)
- [A propos des étendues - PowerShell \| Microsoft Learn](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_scopes)
- [A propos de l'encodage de caractères - PowerShell \| Microsoft Learn](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)

---

## Etape par étape

1. Afficher l'interface graphique
2. Créer des évenements pour chaque action
3. Adapter le code PowerShell

### Charger l'interface graphique

Ce bout de code est assez barbare, mais il y a peu de chose à comprendre donc ne vous en faites pas !

Dans un premier temps, on ajoute les pré-requis nécessaires à l'affichage de notre interface WPF avec le `Add-Type`. Une fois ajouté, on s'occupe de récupérer et de stocker le contenu de notre fichier XAML dans la variable globale `$xaml`. Sans l'exemple, je récupère le XAML via la commande `Invoke-WebRequest` puisque celui-ci est hébergé sur GitHub. Si vous souhaitez utiliser plutôt un fichier local, vous pouvez utiliser la commande `Get-Content`.

Une fois que l'on a tous les éléments en main, on peut maintenant utiliser la dernière ligne de notre exemple pour créer un nouvel objet du type interface graphique, stocké dans la variable globale `$interface`.

Il ne s'agit bien évidemment pas de connaitre ces commandes par coeur, l'idée est simplement de savoir à quoi elle servent.

```powershell
Add-Type -AssemblyName PresentationFramework
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/interface.xaml"
[xml]$Global:xaml = (Invoke-WebRequest -Uri $uri).Content
$Global:interface = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
```

### Créer des variables pour chaque élement de l'interface graphique

Toutes les interactions que le code va avoir avec l'interface graphique va se faire à travers des variables correspondant à chaque élement. On va donc avoir une variable pour la boite de texte (textbox), une variable pour barre de progression, une variable pour les étiquettes (label), etc…

Voici donc un bout de code pour prendre tous les éléments XAML avec un attribut "Name" et créer une variable globale associée :

```powershell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
    Set-Variable -Name ($_.Name) -Value $interface.FindName($_.Name) -Scope Global
}
```

### Afficher l'interface graphique

Une fois que toutes les étapes préliminaires sont terminées, on peut enfin afficher notre interface graphique ! Pour ça, on utilise la méthode `ShowDialog()` sur la variable qui contient notre interface.

Le `$null =` avant la commande permet d'empêcher d'afficher un résultat dans le terminal.

```powershell
$null = $Global:interface.ShowDialog()
```

### Ajouter une action pour la boite de texte

```powershell
$textboxResponse.Add_KeyDown({
    if ($_.Key -eq "Return") {
        $answer = [int]($textboxResponse.Text)
        Write-Host $answer
        $textboxResponse.Text = $null
    }
})
```

## Correction

```powershell
Add-Type -AssemblyName PresentationFramework
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/interface.xaml"
[xml]$Global:xaml = (Invoke-WebRequest -Uri $uri).Content
$Global:interface = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
    Set-Variable -Name ($_.Name) -Value $interface.FindName($_.Name) -Scope Global
}

$textboxResponse.Add_KeyDown({
    if ($_.Key -eq "Return") {
        $answer = [int]($textboxResponse.Text)
        Write-Host $answer
        $textboxResponse.Text = $null
    }
})

$null = $Global:interface.ShowDialog()
```
