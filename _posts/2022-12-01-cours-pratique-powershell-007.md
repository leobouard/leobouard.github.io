---
layout: post
title: "Cours PowerShell #7 - Highscores"
description: "Le résultat de chaque victoire est maintenant conservé dans un fichier externe pour stocker toutes les victoires du joueur"
tableOfContent: "/2022/12/01/cours-pratique-powershell-introduction#table-des-matières"
nextLink:
  name: "Partie 8"
  id: "/2022/12/01/cours-pratique-powershell-008"
prevLink:
  name: "Partie 6"
  id: "/2022/12/01/cours-pratique-powershell-006"
---

## Consigne

À partir de maintenant, les statistiques d'une partie qui se termine par une victoire du joueur seront sauvegardées dans un fichier externe au script (CSV par exemple). Pour l'occasion, on ajoute deux propriétés dans l'objet de fin : le nom du joueur et la date. À la fin de chaque partie (victoire ou défaite), on propose au joueur d'afficher les meilleurs scores dans un `Out-GridView`. La réponse par défaut est de ne rien afficher.

### Résultat attendu

> Joueur                    : john.smith\
> Date                      : 01/12/2022 12:00:00\
> Nombre aléatoire          : 20\
> Réponses                  : 500,250,125,75,50,25,15,20\
> Réponse moyenne           : 132\
> Temps de résolution (sec) : 10,027\
> Temps moyen par tentative : 1,253\
> Tentatives                : 8\
> Mode facile               : True\
> \
> Voulez-vous voir les meilleurs scores?\
> [O] Oui  [N] Non  [?] Aide (la valeur par défaut est « N ») :

---

## Etape par étape

1. Modification et stockage dans une variable de l'objet de fin
2. Affichage de l'objet dans la console
3. Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores
4. Sauvegarder le score dans un fichier CSV
5. Demander au joueur s'il veut voir le tableau
6. Afficher le tableau des meilleurs scores

### Modification et stockage dans une variable de l'objet de fin

On va maintenant vouloir stocker l'objet de fin dans une variable `$stats` pour pouvoir l'utiliser dans différents contextes. On prépare également le formatage des données pour pouvoir les stocker efficacement dans un fichier externe (CSV) :

1. Ajouter la propriété "Joueur" qui contient le nom de l'utilisateur actuel Windows accessible avec la variable d'environnement `$env:USERNAME`
2. Ajouter la propriété "Date" qui contient la date et l'heure de la partie. On utilise donc la commande `Get-Date` et on formate l'affichage avec le paramètre `-Format` et la valeur de paramètre `G` qui permet d'obtenir une date au format "31/12/2022 23:59:59"
3. Modifier la propriété "Réponses" pour transformer l'objet en chaine de caractères avec l'opérateur `-join` pour mieux l'exporter en CSV

```powershell
$stats = [PSCustomObject]@{
    "Joueur"   = $env:USERNAME
    "Date"     = Get-Date -Format G
    "Réponses" = $allAnswers -join ','
}
```

### Affichage de l'objet dans la console

Comme l'objet de fin a été mis dans une variable, plus rien n'est affiché dans la console. Pour modifier ça, on va utiliser la commande `Write-Output` plutôt que `Write-Host`. Je vous laisse faire le test pour voir la différence entre les deux commandes.

```powershell
$stats | Write-Output
```

### Ajout d'un paramètre pour indiquer l'emplacement de sauvegarde des scores

On ajoute un nouveau paramètre `-FilePath` du type `[IO.FileInfo]` qui contient le chemin vers le fichier CSV qui contiendra les meilleurs scores.

```powershell
param([IO.FileInfo]$FilePath = "$PSScriptRoot\highscore.csv")
```

### Sauvegarder le score dans un fichier CSV

Avec la commande `Export-Csv`, on va ajouter une nouvelle ligne au fichier qui contient les meilleurs scores. Détail des paramètres utilisés :

- `-Path` pour indiquer l'emplacement du fichier CSV
- `-Encoding` pour spécifier le type d'encodage (en l'occurrence  : "UTF8")
- `-Delimiter` pour indiquer quel caractère doit être utilisé pour séparer les valeurs entre-elles (dans notre cas, le point-virgule)
- `-NoTypeInformation` pour éviter d'avoir le type d'objet d'origine en première ligne du CSV (par exemple : `#TYPE System.Management.Automation.PSCustomObject`)
- `-Append` pour ne faire qu'ajouter une nouvelle ligne au fichier CSV au lieu d'écraser toutes les données
- `-Force` pour éviter les erreurs si jamais vous faites des modifications sur l'objet

```powershell
$stats | Export-Csv -Path $FilePath -Encoding UTF8 -Delimiter ';' -NoTypeInformation -Append -Force
```

### Demander au joueur s'il veut voir le tableau

Pour demander au joueur s'il veut voir le tableau des meilleurs scores, on va utiliser `$Host.UI.PromptForChoice()` avec les paramètres suivants (dans l'ordre) :  

1. Le titre
2. La question à poser 
3. Les différents choix possibles sous forme d'un array où chaque option commence par `&`
4. L'option par défaut (commence à 0)

```powershell
$question = 'Voulez-vous voir les meilleurs scores?'
$choices  = '&Oui', '&Non'
$decision = $Host.UI.PromptForChoice($null, $question, $choices, 1)
```

### Afficher le tableau des meilleurs scores

Si le premier choix est sélectionné par le joueur, alors on récupère le contenu du fichier CSV avec la commande `Import-Csv` pour l'afficher ensuite avec la commande `Out-GridView`.

```powershell
if ($decision -eq 0) {
    Import-Csv -Path $FilePath -Delimiter ';' -Encoding UTF8 | Out-GridView -Title "Meilleurs scores"
}
```

## Correction

<a class="solution" href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-007.ps1" target="_blank">Voir le script complet</a>