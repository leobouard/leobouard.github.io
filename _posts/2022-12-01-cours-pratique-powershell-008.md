---
layout: post
title: "Cours PowerShell #8 - Ajout de l'interface graphique"
description: "On appose maintenant une interface graphique XAML au script PowerShell et on adapte le script existant pour convenir à ce changement"
tableOfContent: "/2022/12/01/cours-pratique-powershell-introduction#table-des-matières"
nextLink:
  name: "Partie 9"
  id: "/2022/12/01/cours-pratique-powershell-009"
prevLink:
  name: "Partie 7"
  id: "/2022/12/01/cours-pratique-powershell-007"
---

## Consigne

Nouveau départ ! On va implémenter une interface graphique réalisée avec Windows Presentation Foundation (WPF) et stockée dans un fichier XAML externe au script. Si vous le souhaitez, vous pouvez faire votre propre interface graphique en utilisant Visual Studio Community par exemple. Je vous recommande tout de même d'utiliser le fichier que je propose comme point de départ.

Dans un premier temps, on va juste vouloir lancer l'interface graphique et laisser le joueur entrer une estimation dans la boite de texte. Lorsque le joueur appuie sur la touchée "Entrée" de son clavier, l'estimation est affichée dans la console et la boite de texte est vidée de son contenu.

> #### Recommandation
>
> Pour cette partie, je vous recommande de créer un nouveau script plutôt qu'adapter le script existant. De cette manière, vous pourrez créer la structure liée à l'interface graphique, puis copier-coller les bouts de code encore pertinents.

### Résultat attendu

![Démonstration du résultat attendu pour la partie 8](/assets/images/resultat-cours-powershell-008.webp)

### Ressources

Comme cette partie est relativement compliquée, je vous donne quelques ressources :

- [Mon code XAML utilisé pour l'interface WPF](https://github.com/leobouard/leobouard.github.io/blob/main/assets/files/interface.xaml)
- [Créer une interface graphique WPF en PowerShell - Akril.net](https://akril.net/creer-une-interface-graphique-wpf-en-powershell/)
- [A propos des étendues - PowerShell \| Microsoft Learn](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_scopes)
- [A propos de l'encodage de caractères - PowerShell \| Microsoft Learn](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)

---

## Étape par étape

1. Charger l'interface graphique
2. Créer des variables pour chaque élément de l'interface graphique
3. Afficher l'interface graphique
4. Ajouter une action pour la boite de texte

### Charger l'interface graphique

Ce bout de code est assez barbare, mais il y a peu de choses à comprendre donc ne vous en faites pas !

Dans un premier temps, on ajoute les prérequis nécessaires à l'affichage de notre interface WPF avec le `Add-Type`. Une fois ajouté, on s'occupe de récupérer et de stocker le contenu de notre fichier XAML dans la variable globale `$xaml`. Dans l'exemple, je récupère le XAML via la commande `Invoke-WebRequest` puisque celui-ci est hébergé sur GitHub. Si vous souhaitez utiliser plutôt un fichier local, vous pouvez utiliser la commande `Get-Content`.

Une fois que l'on a tous les éléments en main, on peut maintenant utiliser la dernière ligne de notre exemple pour créer un nouvel objet du type interface graphique, stocké dans la variable globale `$interface`.

<div class="information">
  <span>À propos des variables globales</span>
  <p>Nous sommes obligé d'utiliser des variables du type <code>$Global:</code> car l'interface graphique et la console seront dans deux instances séparées. Sans cette indication d'étendue, les deux instances ne pourront pas communiquer entre-elles.</p>
</div>

Il ne s'agit bien évidemment pas de connaitre ces commandes par cœur, l'idée est simplement de savoir à quoi elles servent.

```powershell
Add-Type -AssemblyName PresentationFramework
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/interface.xaml"
[xml]$Global:xaml = (Invoke-WebRequest -Uri $uri).Content
$Global:interface = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
```

### Créer des variables pour chaque élément de l'interface graphique

Toutes les interactions que le code va avoir avec l'interface graphique vont se faire à travers des variables correspondant à chaque élément. On va donc avoir une variable pour la boite de texte (textbox), une variable pour la barre de progression, des variables pour les étiquettes (label), etc.

On fait donc une boucle du type `ForEach-Object` pour créer une variable globale pour chaque élément XAML avec un attribut "Name" :

```powershell
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
    Set-Variable -Name ($_.Name) -Value $interface.FindName($_.Name) -Scope Global
}
```

### Afficher l'interface graphique

Une fois que toutes les étapes préliminaires sont terminées, on peut enfin afficher notre interface graphique ! Pour ça, on utilise la méthode `ShowDialog()` sur la variable qui contient notre interface. Cette commande doit être placée à la dernière ligne de notre script.

Le `$null =` avant la commande permet d'empêcher d'afficher un résultat dans la console.

```powershell
$null = $Global:interface.ShowDialog()
```

### Ajouter une action pour la boite de texte

Avec une interface graphique, on va vouloir assigner des actions à certains éléments de l'interface. Par exemple : appuyer sur un bouton va afficher un message dans la console. Dans notre jeu, c'est quand le joueur soumet son chiffre que l'on veut déclencher une action. On pourrait très bien choisir d'assigner ça à un bouton, mais j'ai choisi d'opter pour un déclencheur via la boite de texte : on lance l'action dès que la touche "Entrée" est appuyée.

Pour récupérer la liste de tous les déclencheurs possibles (car les déclencheurs ne sont pas les mêmes suivant si l'élément est un bouton, une liste déroulante, une case à cocher…) on utilise la commande PowerShell : `Get-Member -MemberType Event`. J'ai choisi le déclencheur "KeyDown" qui correspond à une touche appuyée, mais d'autres choix sont possibles.

Pour déclarer une action à faire pour un déclencheur, la syntaxe est la suivante : `$textboxResponse.Add_KeyDown({ ... })`. Ensuite on ajoute une condition `if` pour vérifier que la touche qui a été appuyé correspond bien à la touche "Entrée" puis :

1. On vide le contenu de la boite de texte pour permettre une nouvelle estimation
2. On affiche l'estimation de l'utilisateur dans la console

```powershell
$textboxResponse.Add_KeyDown({
    if ($_.Key -eq "Return") {
        $answer = [int]($textboxResponse.Text)
        $textboxResponse.Text = $null
        Write-Host $answer
    }
})
```

## Correction

<a class="solution" href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-008.ps1" target="_blank">Voir le script complet</a>