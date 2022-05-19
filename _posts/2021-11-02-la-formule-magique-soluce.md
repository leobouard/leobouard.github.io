---
layout: post
title: "[SOLUTION] La formule magique"
---

Vous l'avez probablement trouvé, il suffisait simplement d'additionner les chiffres qui composent le nombre entre eux. Pour reprendre le premier exemple : **2568 = 21** donc 2+5+6+8 devient 21. Une fois qu'on a compris le principe, il faut maintenant le convertir en PowerShell. 

## Ma solution

Pour ça j'avais envie de vous partager une commande assez spécifique mais qui peut avoir son utilité : [Invoke-Expression](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-expression)

Ma fonction :

```powershell

# Version à compléter
function LaFormuleMagique {
    param([Int64]$i)

    $expression = ([string]$i).ToCharArray() -join '+'
    $result = Invoke-Expression -Command $expression

    return 
}

```

### Explications

On va y aller étape par étape :

`([string]$i)` : permet de convertir le nombre entier en une chaine de caractères

```powershell

PS C:\> $i = [string]2568

```

`.ToCharArray()` : une fois que l'entier est transformé, on peut utiliser la méthode ToCharArray pour convertir la chaine "2568" en un tableau avec les valeurs 2, 5, 6 et 8

```powershell

PS C:\> $i = $i.ToCharArray()
PS C:\> $i

2
5
6
8

```

`-join '+'` : on réassemble ensuite le tableau en joignant les caractères entre eux avec un "+"

```powershell

PS C:\> $i = $i -join '+'
PS C:\> $i

2+5+6+8

```

Une fois notre chaine de caractère prête, il ne reste plus qu'à l'interprêter comme une ligne de commande. Et pour ça on peut utiliser la commande Invoke-Expression (iex pour les intimes) :

```powershell

PS C:\> Invoke-Expression $i
21

```

---