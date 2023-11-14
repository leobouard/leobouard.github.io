---
layout: post
title: "Bégaiement"
prevLink:
  name: "Retour au défi"
  id: "/2021/09/28/begaiement"
---

## Version simple

Cette version est simple et efficace, avec un nombre de paramètres limités. Elle ne prend pas en compte les syllabes et répète bêtement les deux premières lettres du mot :

```powershell
function ConvertTo-Stutter {
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Text,
        [int]$Frequency = 50
    )

    $finalText = $Text -split ' ' | ForEach-Object {
        if ($_ -match '^[A-z]{5}' -and ((0..100 | Get-Random) -le $Frequency)) {
            "$($_.Substring(0,2))…"*2 + $_
        } else { $_ }
    }
    return ($finalText -join " ")
}
```

### Choisir le nom de la fonction

Ça peut paraître sans importance, mais si vous comptez réutiliser vos fonctions dans différents environnements ou scripts, il est important de bien les nommer. Pour ça, le plus simple est d'utiliser la convention de nommage de Microsoft : `<ApprovedVerb>-<Prefix><SingularNoun>`.

Partie | Explication
------ | -----------
ApprovedVerb | *Verbe* approuvé par Microsoft (comme Get, Set ou Remove par exemple). Vous pouvez obtenir la liste complète des verbes ainsi que leur catégorie et un descriptif avec la commande `Get-Verb`.
Prefix | Le préfixe est ajouté à l'ensemble des commandes d'un module lorsque celui-ci est importé avec la commande `Import-Module -Prefix 'TEST'`. Ce préfixe permet d'indiquer la provenance d'une commande et surtout d'éviter les conflits de cmdlets identiques entre différents modules.
SingularNoun | Descriptif court sur l'action de la commande. Celui-ci doit être unique au niveau du module.

Dans notre cas, on va prendre un texte pour le transformer. J'ai donc choisi le verbe `ConvertTo` qui indique une transformation unidirectionnelle d'un format A en format B. Pour le nom singulier, on utilise la traduction anglaise de "Bégayer".

Pour aller plus loin sur le nommage : [Dénomination - Fonctions - PowerShell \| Microsoft Learn](https://learn.microsoft.com/fr-fr/powershell/scripting/learn/ps101/09-functions?view=powershell-7.3#naming)

### Création des paramètres

Dans notre bloc `param()`, on va déclarer notre paramètre principal pour récupérer le texte à convertir. Pour suivre la consigne, on sait que l'on doit accepter que la valeur soit issue d'un pipeline. Pour ça, on ajoute simplement l'attribut `ValueFromPipeline` : `[Parameter(Mandatory,ValueFromPipeline)][string]$Text`.

Ainsi, on s'assure que la fonction peut-être utilisée de deux manières différentes :

> C:> ConvertTo-Stutter -Text "Vous savez, moi je ne crois pas qu’il y ait de bonne ou de mauvaise situation"\
> C:> "Vous savez, moi je ne crois pas qu’il y ait de bonne ou de mauvaise situation" | ConvertTo-Stutter

Pour tout comprendre sur le support du pipeline dans les fonctions : [Entrée de pipeline - Fonctions - PowerShell \| Microsoft Learn](https://learn.microsoft.com/fr-fr/powershell/scripting/learn/ps101/09-functions?view=powershell-7.3#pipeline-input)

Pour le deuxième paramètre `-Frequency` : on ajoute un paramètre de type "entier" avec une valeur par défaut à 50. Ce paramètre agit sur la probabilité qu'un mot soit soumis au traitement.

### Transformation du texte

`$Text -split ' '` : on va découper le texte en un tableau qui contient autant d'éléments qu'il y a de mots (on coupe à chaque espace). On effectue cette action pour ensuite appliquer un traitement indépendant à chaque mot dans la boucle `ForEach-Object` qui suit.

### Condition de traitement

On ne veut pas apporter un traitement à tous les mots de notre phrase : il faut que ceux-ci correspondent à certains critères :

- `$_ -match '^[A-z]{5}'` : on vérifie via une expression régulière (RegEx) que le mot commence par 5 lettres consécutives. Cette méthode est meilleure que la mesure de la longueur d'une chaine de caractère (avec `.Length`) puisqu'elle permet en plus d'éliminer les mots qui contiennent une apostrophe ou un tiret (comme *rez-de-chaussée* ou *j'adore*).
- `((0..100 | Get-Random) -le $Frequency)` : ici on va tirer au sort pour savoir si le mot doit être soumis au traitement. Plus la valeur du paramètre `-Frequency` est élevée, plus il y a de chances que le mot soit soumis au traitement.

Si le mot ne correspond pas au critère, alors il ne sera pas soumis à modification.

### Création de la nouvelle chaine de caractère

Le traitement est le suivant : `"$($_.Substring(0,2))…"*2 + $_` qui est composé de trois parties :

1. `$_.Substring(0,2)` : on récupère les deux premiers caractères du mot. Les paramètres de la méthode indiquent que l'on commence au caractère 0 pour s'arrêter au bout de deux lettres.
2. `"…"*2` : on va répéter deux fois la chaine de caractère entre guillemets
3. `+ $_` : on ajoute notre mot complet à la fin

Ce qui nous permet de convertir le mot "bonjour" en "bo…bo…bonjour".

---

## Version complexe

Place à la version plus "aboutie" qui va essayer (j'insiste sur le fait d'essayer uniquement) de délimiter les syllabes du mot.

```powershell
function ConvertTo-Stutter {
    param(
        [Parameter(Mandatory,ValueFromPipeline)][string]$Text,
        [int]$Frequency = 50,
        [switch]$OutLoud
    )

    $vowels = 'a','e','i','o','u','y','h'

    $finalText = $Text -split ' ' | ForEach-Object {
        if ($_ -match '^[A-z]{5}' -and ((0..100 | Get-Random) -le $Frequency)) {
            $cutWord = $_[0]
            $cutWord += for ($i = 1 ; $_[$i] -in $vowels ; $i++) { $_[$i] }
            "$($cutWord -replace ' ','')…"*2 + $_
        } else { $_ }
    }

    $finalText = $finalText -join ' '

    if ($OutLoud.IsPresent) {
        Add-Type -AssemblyName System.Speech
        $speak = New-Object System.Speech.Synthesis.SpeechSynthesizer
        $speak.Speak($finalText)
    }

    return $finalText
}
```

Si l'on reprend les exemples donnés dans la consigne (avancer → a…a…avancer, mauvaise → mau…mau…mauvaise, beaucoup → beau…beau…beaucoup), on remarque que le bégaiement s'arrête dès que l'on rencontre une consonne.

### Modification du traitement

On va modifier la boucle de traitement pour que celle-ci arrête de couper à deux caractères de manière systématique et qu'elle applique le nouveau traitement qui est de couper à la première consonne.

```powershell
$vowels = 'a','e','i','o','u','y','h'

$cutWord = $_[0]
$cutWord += for ($i = 1 ; $_[$i] -in $vowels ; $i++) { $_[$i] }
"$($cutWord -replace ' ','')…"*2 + $_
```

On commence par récupérer le premier caractère du mot avec `$_[0]`. On poursuit avec une boucle `for()` qui va continuer à construire le mot "coupé" jusqu'à ce que le caractère en cours ne fasse pas partie de la liste de voyelle que l'on a défini précédemment. On termine alors le traitement en créant le mot final.

### Ajout d'un nouveau paramètre

Vous avez peut-être déjà remarqué, mais un nouveau paramètre a fait son apparition : `-OutLoud`. Celui-ci permet de lire le texte à voix haute via `System.Speech`. Rien de très complexe là-dedans, c'est surtout pour partager le fait qu'il est possible de lire un texte avec PowerShell.
