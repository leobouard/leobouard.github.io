---
layout: post
title: "Cours PowerShell #1 - Simple. Basique."
description: "Création de la base du script PowerShell : générer un nombre aléatoire et le comparer avec l'estimation du joueur"
icon: 🎓
nextLink:
  name: "Partie 2"
  id: "/2022/12/01/cours-pratique-powershell-002"
prevLink:
  name: "Sommaire"
  id: "/2022/12/01/cours-pratique-powershell-sommaire"
---

## Consigne

Un nombre aléatoire entier compris entre 1 et 1000 est généré par PowerShell. Le joueur entre son estimation du nombre aléatoire et le script lui indique alors si le nombre aléatoire est plus grand ou plus petit que son estimation. Si le nombre aléatoire et égal à l'estimation du joueur, le script affiche un message de victoire.

À la fin du script, le nombre aléatoire et l'estimation du joueur sont affichés dans une liste.

### Résultats attendus

Si l'estimation est plus grande que le nombre aléatoire :

> Deviner le nombre: 500\
> ??? est plus petit que 500\
> \
> Nombre aléatoire : 21\
> Dernière réponse : 500

Si l'estimation est plus petite que le nombre aléatoire :

> Deviner le nombre: 500\
> ??? est plus grand que 500\
> \
> Nombre aléatoire : 746\
> Dernière réponse : 500

Si l'estimation est égale au nombre aléatoire :

> Deviner le nombre: 500\
> VICTOIRE ! Vous avez deviné le nombre aléatoire\
> \
> Nombre aléatoire : 500\
> Dernière réponse : 500

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

Pour générer un nombre aléatoire, on utilise la commande `Get-Random`, puis on spécifie les valeurs minimales et maximales possibles avec les paramètres `-Minimum` et `-Maximum`. Par défaut, la commande retourne un nombre entier, donc pas besoin de faire plus d'action.

```powershell
Get-Random -Minimum 1 -Maximum 1000
```

### Stocker le nombre aléatoire dans une variable

On utilise la variable `$random` pour récupérer la valeur de la commande `Get-Random`.

```powershell
$random = Get-Random -Minimum 1 -Maximum 1000
```

### Demander au joueur de deviner le nombre

On va maintenant inviter le joueur à entrer son estimation avec la commande `Read-Host`. On affiche un message au joueur avec le paramètre `-Prompt` et on stocke sa réponse dans la variable `$answer`. 

```powershell
$answer = Read-Host -Prompt "Deviner le nombre"
```

### Comparer le nombre aléatoire à l'estimation du joueur

On compare les deux variables `$answer` et `$random` avec les opérateurs `-gt` (*greater than*, plus grand que) et `-lt` (*lower than*, plus petit que).

```powershell
# Aléatoire est supérieur au nb utilisateur
$random -gt $answer
$answer -lt $random
# Aléatoire est plus petit que nb utilisateur
$random -lt $answer
$answer -gt $random
```

#### random est supérieur à answer

Si la condition `if` est remplie (`$random` est supérieur à `$answer`), on affiche un message au joueur avec la commande `Write-Host` pour indiquer que le nombre aléatoire est plus grand que son estimation.

```powershell
if ($random -gt $answer) { Write-Host "??? est plus grand que $answer" }
```

#### random est inférieur à answer

Si la condition `elseif` est remplie (`$random` est inférieur à `$answer`), on affiche un message au joueur avec la commande `Write-Host` pour indiquer que le nombre aléatoire est plus petit que son estimation.

```powershell
elseif ($random -lt $answer) { Write-Host "??? est plus petit que $answer" }
```

#### random est égal à answer

Si aucune des conditions précédentes (`if` et `elseif`) n'est remplie, alors on affiche un message de victoire avec la commande `Write-Host`.

```powershell
else { Write-Host "VICTOIRE ! Vous avez devinez le nombre aléatoire" }
```

### Affichage des données

A la fin du script, on crée un objet `PSCustomObject` qui regroupe les informations principales : le nombre aléatoire et la réponse du joueur.

```powershell
$result = [PSCustomObject]@{
    "Nombre aléatoire" = $random
    "Dernière réponse" = $answer
}
```

### Formater l'affichage en mode liste

Par défaut, l'objet va s'afficher sous forme de tableau puisqu'il n'y a que deux valeurs. On formate donc la vue avec la commande `Format-List`.

```powershell
$result | Format-List
```

## Correction

Encore une fois un petit rappel : il n'y a pas une seule bonne méthode donc si votre script ne ressemble pas au mien mais qu'il fonctionne, tant-mieux !

<details>
    <summary>Voir la solution</summary>
    <a href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-001.ps1">cours-pratique-powershell-001.ps1</a>
</details>
