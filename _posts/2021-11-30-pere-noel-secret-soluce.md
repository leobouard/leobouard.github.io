---
title: "SOLUCE #4 - Secret santa"
prevLink:
  name: "Retour au défi"
  id: "pere-noel-secret"
---

Voici la fonction `Get-SecretSanta` pour obtenir notre tirage au sort :

```powershell
function Get-SecretSanta {
    param(
        [array]$People,
        [switch]$Pause
    )

    $i = 0
    $People = $People | Get-Random -Count $People.Count
    $People | ForEach-Object {
        $giftFrom = $People[$i]
        $giftTo   = $People[$i+1]
        if (!$giftTo) { $giftTo = $People[0] }
        "#{0} {1} offre son cadeau à {2}" -f $i,$giftFrom,$giftTo
        if ($Pause.IsPresent) { $null = Read-Host }
        $i++
    }
}
```

## Explication de code

1. Modifier l'ordre de la liste
2. Appliquer le traitement
3. Affichage progressif

### Modifier l'ordre de la liste

La première étape est de mélanger la liste pour s'assurer que l'ordre diffère de la liste initiale qui a été envoyée en paramètre. Pour ça, c'est très simple :

```powershell
$People | Get-Random -Count $People.Count
```

### Appliquer le traitement

On va utiliser un fonctionnement basique : la première personne de la liste mélangée va offrir son cadeau à la personne suivante et ainsi de suite.

Pour faire ça en PowerShell, on va utiliser la boucle `ForEach-Object` pour appliquer un traitement à chaque élément. On va ensuite utiliser l'index de la liste qui va nous permettre d'obtenir facilement la première valeur de la liste (`$People[0]`), puis la deuxième (`$People[1]`), puis la troisième (`$People[2]`), etc. Notre index sera représenté par la variable `$i` qui commence à zéro et qui est incrémentée de 1 à chaque fin de boucle.

Pour obtenir le participant qui offre, on utilise `$People[$i]` et pour trouver le participant suivant (celui qui reçoit le cadeau), on utilise `$People[$i+1]`.

…mais si l'on arrive à la fin de la liste et qu'il n'y a personne après ? Dans ce cas, le résultat de  `$People[$i+1]` est vide, donc on créé une condition pour gérer cette situation et forcer le dernier participant à offrir son cadeau au premier participant :

```powershell
if (!$giftTo) { $giftTo = $People[0] }
```

### Affichage progressif

Pour afficher plusieurs variables dans un texte, il est possible d'utiliser la méthode avec le `-f` qui va remplacer tous les *placeholders* du type {0}, {1} et {2} dans le texte par la valeur des variables situées à la droite du `-f`.

On peut également utiliser `Write-Host` :

```powershell
Write-Host "#$i $giftFrom offre son cadeau à $giftTo"
```

Dans mon cas, l'affichage progressif doit être invoqué avec le paramètre `-Pause` de la fonction. Si ce paramètre est actif, alors on va attendre que l'utilisateur appuie sur la touche "Entrée" du clavier via une utilisation détournée du `Read-Host` (qui permet normalement de récupérer du texte). On peut également utiliser directement la commande `pause` qui fonctionne exactement de la même manière mais qui a comme désavantage d'imposer un texte dans la console : "*Cliquez sur Entrée pour continuer...:*".

Au passage, si vous souhaitez vérifier quel est le code d'une fonction, vous pouvez le faire très simplement avec la commande `Get-Command` :

```plaintext
PS C:\> Get-Command pause | Format-List

Name        : Pause
CommandType : Function
Definition  : $null = Read-Host 'Cliquez sur Entrée pour continuer...'
```
