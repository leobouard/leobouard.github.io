---

title: "PS101 #4 - Les variables en bref"
description: "Premier élément essentiel du scripting"
tableOfContent: "/2024/04/07/cours-powershell-from-scratch-introduction#table-des-matières"
nextLink:
  name: "Partie 5"
  id: "/2024/04/07/cours-powershell-from-scratch-005"
prevLink:
  name: "Partie 3"
  id: "/2024/04/07/cours-powershell-from-scratch-003"
---

## Variables

Les variables sont un composant majeur de n'importe quel language de programmation/scripting. Dans le cas de PowerShell, les variables sont très flexibles et simple à utiliser. On les déclare à n'importe quel moment avec un `$` et on peut y stocker n'importe quoi en utilisant `=` (résultat de commande, texte, collection, nombre...)

```powershell
$users = Get-LocalUser
$text = 'Voici un texte court'
$number = 1032
```

### Interagir avec le contenu

Pour consulter le contenu d'une variable, il suffit simplement de tapper le nom de la variable dans la console :

```powershell
$text
Voici un texte court

$number
1032
```

### Index

Pour les variables qui contiennent des collections d'objets, il est possible d'indiquer quel élément nous intéresse dans la liste en utilisant l'index. La syntaxe de l'index est plutôt simple puisqu'il suffit d'ajouter `[X]` (où *X* est le numéro d'index) directement après votre variable

```powershell
$array = 'Alpha','Bravo','Charlie','Delta'
$array[1]
```

Index | Valeur(s) d'exemple | Description
----- | ------------------- | -----------
[0] | Alpha | Premier élément de la collection
[1] | Bravo | Deuxième élément de la collection
[1..3] | Bravo, Charlie, Delta | Deuxième au quatrième élément de la collection
[0,2] | Alpha,Charlie | Premier et troisième élément de la collection
[-2] | Charlie | Avant-dernier élément de la collection
[-1] | Delta | Dernier élément de la collection

> L'index peut être remplacé par la commande `Select-Object` avec les paramètres `-First`, `-Skip`, `-Last` et `-SkipLast` (vu précédemment).

### Sous-propriétés

Lorsqu'une variable contient un ou plusieurs objets complexes avec plusieurs propriétés, il est possible d'obtenir uniquement l'information qui nous intéresse en selectionnant directement la propriété. Pour ça, il suffit d'ajouter `.Property` (où *Property* est le nom de la propriété) directement après votre variable.

```powershell
$users = Get-LocalUser
$users.Name
```

Il est possible de mixer les index et les sous-propriétés, par exemple :

```powershell
$users[0].Name
```

> Les sous-propriétés peuvent être remplacé par la commande `Select-Object` avec le paramètre `-ExpandProperty`.

### Conseils sur le nommage

Vous pouvez utiliser n'importe quel nom pour votre variable (lettres, chiffres et tirets & underscore), mais voici quelques conseils :

- Garder des noms simples et explicites sur leur contenu
- Utiliser des majuscules régulières : `$disabledUsers` par exemple
- Privilégier l'anglais

### Variables par défaut

Certaines variables sont utilisés par PowerShell pour stocker des informations importantes et nécessaires à son bon fonctionnement. Evitez de marcher sur les plate-bandes de PowerShell en utilisant ces variables pour stocker vos informations.

Pour obtenir la liste de toutes la variables existantes, vous pouvez utiliser la commande `Get-Variable`.

## Affichage dans du texte

Pour afficher le contenu d'une variable dans un texte, le cas général est plutôt simple :

- Si la chaine de caractère est entre des *simple-quotes*, alors la variable ne sera pas interprêtée
- Si la chaine de caractères est entre des *double-quotes*, alors la variable sera interprêtée.

Exemples :

```powershell
$test = 'PowerShell'
Write-Host "$test est plutôt cool"
# vs.
Write-Host '$test est plutôt cool'
```

### Cas particuliers

Si votre variable est plus complexe (vous ne voulez afficher que une sous-propriété ou/et un index), il faudra modifier un peu la syntaxe.

```powershell
$users = Get-LocalUser
Write-Host "Le premier utilisateur de l'ordinateur est $($users[0].Name)"
```
