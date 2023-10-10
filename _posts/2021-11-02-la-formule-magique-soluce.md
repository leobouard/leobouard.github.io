---
layout: post
title: "La formule magique"
background: "#fbe888"
prevLink:
  name: "Retour au défi"
  id: "/2021/11/02/la-formule-magique"
---

## Ma solution

Pour ça j'avais envie de vous partager une commande assez spécifique mais qui peut avoir son utilité : [Invoke-Expression](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/invoke-expression)

Ma fonction :

```powershell
function LaFormuleMagique {
    param([Int64]$i)

    $expression = ([string]$i).ToCharArray() -join '+'
    $result = Invoke-Expression -Command $expression

    return $result
}
```

En version courte, le cœur de la fonction peut être résumé à : `iex("$i".ToCharArray()-join'+')`

### Explications

On va y aller étape par étape :

`([string]$i)` : permet de convertir le nombre entier en une chaine de caractères

> PS C:\> $i = [string]2568

`.ToCharArray()` : une fois que l'entier est transformé, on peut utiliser la méthode ToCharArray pour convertir la chaine "2568" en un tableau avec les valeurs 2, 5, 6 et 8

> PS C:\> $i = $i.ToCharArray()\
> PS C:\> $i\
> 2\
> 5\
> 6\
> 8

`-join '+'` : on réassemble ensuite le tableau en joignant les caractères entre eux avec un "+"

> PS C:\> $i = $i -join '+'\
> PS C:\> $i\
> \
> 2+5+6+8

Une fois notre chaine de caractère prête, il ne reste plus qu'à l'interpréter comme une ligne de commande. Et pour ça on peut utiliser la commande `Invoke-Expression` (`iex` pour les intimes) :

> PS C:\> Invoke-Expression $i\
> \
> 21
