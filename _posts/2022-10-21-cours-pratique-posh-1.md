---
layout: post
title: "Partie 1 - Simple. Basique."
thumbnailColor: "#007acc"
icon: 🎓
---

## Consigne

Un nombre aléatoire entier compris entre 1 et 1000 est généré par PowerShell. Le joueur entre son estimation du nombre aléatoire et le script lui indique alors si le nombre aléatoire est plus grand ou plus petit que son estimation. Si le nombre aléatoire et égal à l'estimation du joueur, le script affiche un message de victoire.

A la fin du script, le nombre aléatoire et l'estimation du joueur sont affichés dans une liste.

### Résultats attendus

Si l'estimation est plus grande que le nombre aléatoire :

> Deviner le nombre: 500\
> ??? est plus petit que 500\
> \
> Random : 21\
> Answer : 500

Si l'estimation est plus petite que le nombre aléatoire :

> Deviner le nombre: 500\
> ??? est plus grand que 500\
> \
> Random : 746\
> Answer : 500

Si l'estimation est égale au nombre aléatoire :

> Deviner le nombre: 500\
> VICTOIRE ! Vous avez deviné le nombre aléatoire\
> \
> Random : 500\
> Answer : 500

---

## Etape par étape

1. Générer un nombre aléatoire entre 1 et 1000
2. Stocker le nombre aléatoire dans une variable
3. Demander au joueur de deviner le nombre
4. Comparer le nombre aléatoire à l'estimation du joueur
   - random est supérieur à answer
   - random est inférieur à answer
   - random est égal à answer
5. Affichage des données
6. Formater l'affichage en mode liste

### Générer un nombre aléatoire entre 1 et 1000

Pour générer un nombre aléatoire, on utilise la commande `Get-Random`, puis on spécifie les valeurs minimales et maximales possibles avec les paramètres `Minimum` et `Maximum`. Par défaut, la commande retourne un nombre entier, donc pas besoin de faire plus d'action.

```powershell
Get-Random -Minimum 1 -Maximum 1000
```

### Stocker le nombre aléatoire dans une variable

On utilise le nom de variable `$random` pour récupérer la valeur de la commande `Get-Random`.

```powershell
$random = Get-Random -Minimum 1 -Maximum 1000
```

### Demander au joueur de deviner le nombre

On va maintenant inviter le joueur a entrer son estimation avec la commande `Read-Host`. On affiche un message au joueur avec le paramètre `Prompt` et on stocke sa réponse dans la variable `$answer`. 

```powershell
$answer = Read-Host -Prompt "Deviner le nombre"
```

### Comparer le nombre aléatoire à l'estimation du joueur

Vérifier si le nombre aléatoire est strictement supérieur ou inférieur au nombre de l'utilisateur.

- Opérateurs de comparaison "-gt" et "-lt"

```powershell
# Aléatoire est supérieur au nb utilisateur
$random -gt $answer
$answer -lt $random
# Aléatoire est plus petit que nb utilisateur
$random -lt $answer
$answer -gt $random
```

#### random est supérieur à answer

Afficher un message pour dire que le nombre aléatoire est plus grand que le nombre de l'utilisateur 

- Commande "Write-Host"
- Condition "if(){}"

```powershell
if ($random -gt $answer) { Write-Host "??? est plus grand que $answer" }
```

#### random est inférieur à answer

Afficher un message pour dire que le nombre aléatoire est plus petit que le nombre de l'utilisateur

- Commande "Write-Host"
- Condition "elseif(){}"

```powershell
elseif ($random -lt $answer) { Write-Host "??? est plus petit que $answer" }
```

#### random est égal à answer

Afficher un message de victoire si le nombre aléatoire est égal au nombre de l'utilisateur

- Commande "Write-Host"
- Condition "else{}"

```powershell
else { Write-Host "VICTOIRE ! Vous avez devinez le nombre aléatoire" }
```

### Affichage des données

A la fin de votre script, afficher un objet avec les membres "Random" et "Answer"

- Objet "PSCustomObject"
- Propriétés "random" et "answer"

```powershell
$result = [PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
}
```

### Formater l'affichage en mode liste

Par défaut, l'objet va s'afficher sous forme de tableau (puisqu'il n'y a que deux valeurs). Il faut donc forcer un affichage sous forme de liste.

- Commande "Format-List"

```powershell
$result | Format-List
```

## Correction 

Encore une fois un petit rappel : il n'y a pas une seule bonne méthode donc si votre script ne ressemble pas au mien mais qu'il fonctionne, tant-mieux !

```powershell
$random = Get-Random -Minimum 1 -Maximum 1000
$answer = Read-Host "Deviner le nombre"

if ($random -gt $answer) { 
    Write-Host "??? est plus grand que $answer"
} elseif ($random -lt $answer) {
    Write-Host "??? est plus petit que $answer"
} else {
    Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
}

[PSCustomObject]@{
    "Random" = $random
    "Answer" = $answer
} | Format-List
```

<div class="buttons">
    <div class="buttonBack">
        <a href="/2022/10/21/cours-pratique-posh-0">← Introduction</a>
    </div>
    <div class="buttonNext">
        <a href="/2022/10/21/cours-pratique-posh-2">Partie 2 →</a>
    </div>
</div>