---

title: "Cours PowerShell #9 - Réparation"
description: "Adaptation du script à la nouvelle interface graphique WPF, en tirant partie des éléments qui la compose comme la barre de progression ou les différents labels."
tableOfContent: "/2022/12/01/cours-pratique-powershell-introduction#table-des-matières"
nextLink:
  name: "Partie 10"
  id: "/2022/12/01/cours-pratique-powershell-010"
prevLink:
  name: "Partie 8"
  id: "/2022/12/01/cours-pratique-powershell-008"
---

## Consigne

On continue d'adapter notre script pour convenir à l'interface graphique. Dans cette partie, on va simplement s'assurer que le jeu re-fonctionne correctement sur sa base :

- 10 tentatives pour deviner le nombre aléatoire (indiquées par la barre de progression)
- toutes les tentatives du joueurs sont enregistrées
- la partie est chronométrée
- en cas de victoire ou de défaite :
  - un message annonce la victoire ou la défaite
  - les boutons "Recommencer" et "Meilleurs scores" deviennent visibles
  - le nombre aléatoire est affiché dans la boite de texte

### Résultat attendu

![Démonstration du résultat attendu pour la partie 9](/assets/images/resultat-cours-powershell-009.webp)

On note que les boutons "Recommencer" et "Meilleurs scores" n'ont pas a être fonctionnels, ils doivent simplement être rendus visible via le StackPannel qui regroupe les deux éléments.

---

## Étape par étape

1. Adaptation des variables
2. Intégration du traitement
3. Gestion de la victoire
4. Gestion de la défaite

### Adaptation des variables

Certaines de nos anciennes variables vont être directement intégrées à des éléments de l'interface graphique : les bornes inférieures et supérieures ainsi que la barre de progression :

Ancienne variable | Composant XAML | Description
----------------- | -------------- | -----------
`$i` | Barre de progression | Compte le nombre de tentatives du joueur
`$min` | Label | Borne inférieure
`$max` | Label | Borne supérieure

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

> #### Problème d'encodage
>
>Si vous rencontrez des problèmes avec l'affichage des accents à ce stade, il faut bien vérifier que votre script (c'est-à-dire le fichier `.ps1`) est enregistré au format UTF8-BOM.

### Gestion de la victoire

Si vous testez le script à ce stade et que vous parvenez à trouver le nombre aléatoire, vous constaterez que la victoire n'empêche pas le joueur de continuer à jouer. On va donc ajouter quelques traitement supplémentaires :

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

### Gestion de la défaite

Dans l'état, la défaite n'est pas possible puisque si le joueur dépasse le nombre de tentatives autorisées, il ne se passe rien. Pour résoudre le problème, on va mettre en place une condition : si l'on arrive à la valeur maximum de la barre de progression et que la dernière tentative du joueur n'est pas la bonne réponse, alors on effectue les actions suivantes :

- Rendre les boutons "Recommencer" et "Meilleurs scores" visibles
- Afficher le nombre aléatoire dans la boite de texte
- Désactiver la boite de texte
- Afficher un message de défaite via la variable `$labelText.Content`
- Arrêter le chronomètre

```powershell
if ($progressbarCoupsRestants.Value -eq $progressbarCoupsRestants.Maximum -and $textboxResponse.Text -ne $random) {
    $stackpanelButtons.Visibility = "Visible"
    $textboxResponse.Text = $random
    $textboxResponse.IsEnabled = $false
    $labelText.Content = "DEFAITE ! Le nombre etait : $random"
    $stopwatch.Stop()
}
```

## Correction

<a class="solution" href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-009.ps1" target="_blank">Voir le script complet</a>