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

### La solution droit au but

*Trouvée par [@Clément Vigier](https://www.linkedin.com/in/cl%C3%A9ment-vigier-3648bb141/).*

Ici pas le temps de niaiser, on va aller directement à la solution sans chercher à utiliser une commande aussi peu efficace que `Invoke-Expression`. On va utiliser une méthode différente pour découper notre nombre (via `-split`) et l'incontournable commande `Measure-Object` pour compter la somme de nos chiffres. Voilà ce que ça donne en code :

```powershell
function LaFormuleMagique {
    param([Int64]$i)
    $result = $i -split '' | Measure-Object -Sum
    return $result.Sum
}
```

### Explications

On commence par découper notre nombre via un `-split ''` qui a un avantage et un inconvénient par rapport à la méthode que j'ai utilisé. D'un côté il n'y a pas besoin de convertir notre nombre en une chaine de caractère, mais de l'autre côté : découper un nombre de quatre chiffres nous donne 6 items en résultat :

> PS C:\> 2568 -split ''\
> \
> 2\
> 5\
> 6\
> 8\
> 

Si vous ne voyez pas les six items, sachez qu'il y a un item vide avant le 2 et un item vide après le 8. Vous pouvez vous en débarrasser avec la méthode `.Trim()` si ça vous dérange, mais dans notre cas ils n'auront aucun impact sur notre calcul puisque 0+2+5+6+8+0 donne le même résultat que 2+5+6+8. Il ne nous reste plus qu'à calculer la somme de tous nos chiffres, et pour ça on utilise la commande `Measure-Object` qui permet de faire bien plus que simplement compter le nombre d'items dans une collection.

En effet, `Measure-Object` permet de :

- Calculer la valeur moyenne
- Donner la valeur maximale et/ou minimale d'une liste
- Calculer l'écart type (depuis PowerShell 7)
- **Calculer la somme**

On va donc utiliser le paramètre `-Sum` pour demander à PowerShell de nous calculer la somme des chiffres présents dans notre liste.
