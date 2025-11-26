---

title: "PS101 #5 - Les opérateurs en bref"
description: "Second élément essentiel du scripting"
tableOfContent: "cours-powershell-from-scratch-introduction#table-des-matières"
nextLink:
  name: "Partie 6"
  id: "cours-powershell-from-scratch-006"
prevLink:
  name: "Partie 4"
  id: "cours-powershell-from-scratch-004"
---

## Opérateurs de comparaison

Les opérateurs de comparaison permettent de comparer deux éléments entre eux en retournant un booléen (vrai ou faux) en fonction du résultat. Il existe plusieurs types d'opérateurs de comparaison mais tous fonctionnent de la même manière. Il est possible de comparer n'importe quel type de donnée (nombres, texte, dates) entre elle.

Par défaut, les opérateurs de comparaison ne sont pas sensible à la casse (dans le cas de comparaison sur du texte), mais une variante sensible à la casse est disponible en ajoutant un "C" avant l'opérateur habituel. Exemple : `-clike` est la version sensible à la casse de `-like`.

### Egalité

Opérateur | Description
--------- | -----------
`-eq`     | Egal à
`-ne`     | N'est pas égal à
`-gt`     | Strictement supérieur à
`-ge`     | Supérieur ou égal à
`-lt`     | Strictement inférieur à
`-le`     | Inférieur ou égal à

### Exercice n°4A

Sans utiliser PowerShell, prédire le résultat de chaque comparaison :

- `"bonjour" -eq "Bonjour"`
- `"bonjour" -ceq "Bonjour"`
- `"bonjour" -gt "123"`
- `10 -ge (5+5)`
- `"bonjour" -lt "azerty"`
- `152 -le -80`

### Correspondance

Opérateur | Description
--------- | -----------
`-like` | Contient une chaine de caractère
`-notlike` | Ne contient pas une chaine de caractère
`-match` | Contient une expression régulière (RegEx)
`-notmatch` | Ne contient pas une expression régulière (RegEx)

Pour les opérateurs `-like` & `-notlike`, l'utilisation d'un astérisque est vitale pour indiquer si la chaine recherchée est au début, n'importe-où ou à la fin de la chaine de caractère.

Comparaison | Résultat | Description
----------- | -------- | -----------
`"Anticonstitutionnel" -like "Anti*"` | TRUE | Est-ce que *Anticonstitutionnel* commence par "Anti" ?
`"Anticonstitutionnel" -like "*constit*"` | TRUE | Est-ce que *Anticonstitutionnel* contient par "constit" ?
`"Anticonstitutionnel" -like "*onnel"` | TRUE | Est-ce que *Anticonstitutionnel* fini par "onnel" ?
`"Anticonstitutionnel" -like "An*el"` | TRUE | Est-ce que *Anticonstitutionnel* commence par "An" et fini par "el" ?

L'ordre à une importance pour cet opérateur et inverser les deux parties ne donnera pas le même résultat.

### Exercice n°4B

```powershell
$days = 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
```

Trouver la bonne utilisation de `like` et `-notlike` pour obtenir les résultats suivants :

1. Les jours du week-end
2. Les jours de la semaine
3. Mardi et Mercredi
4. Mardi, Mercredi et Jeudi

### Appartenance

Les opérateurs de comparaison pour l'appartenance sont très simple et ne s'utilisent que pour requêter des collections d'objets.

Opérateur | Description
--------- | -----------
`-in` | L'objet est dans la collection
`-notin` | L'objet n'est pas dans la collection
`-contains` | La collection contient l'objet
`-notcontains` | La collection ne contient pas l'objet

### Exercice n°4C

```powershell
$months = 'janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre'
```

Sans utiliser PowerShell, prédire le résultat de chaque comparaison :

- `"avril" -in $months`
- `$months -in "avril"`
- `"avril" -contains $months`
- `$months -contains "avril"`

### Manipulation de texte

Certains opérateurs ne font pas de comparaison mais peuvent modifier des chaines de caractères. On peut en retenir trois principaux :

1. `-replace` pour remplacer une chaine de caractères par une autre
1. `-split` pour séparer une chaine de caractères suivant un délimiteur
1. `-join` pour assembler une chaine de caractères avec un délimiteur

### Exercice n°4D

Devinez le contenu de chaque variable :

```powershell
$replace = 'Je serai en avance' -replace 'avance','retard'
$split1 = 'abcdefghijklmnopqrstuvwyz' -split ''
$split2 = '192.168.0.1' -split '.'
$join = 'Robert','Jimmy','John','John Paul' -join '+'
```

## Opérateurs logiques

Les opérateurs logiques permettent de relier des comparaisons entre-elles. Les deux plus utilisés sont `-and` (ET) et `-or` (OU).

### Exercice n°5

Sans utiliser PowerShell, prédire le résultat de chaque comparaison :

- `15 -gt 10 -and "Testing" -like "*ing"`
- `$true -eq $false -or (1,2,3) -contains 3`
- `1 -le 10 -and ('bonjour' -like 'bon' -or 'test' -cne 'TEST')`

### Travaux pratiques n°2

Vous pouvez maintenant réaliser les 5 défis restants sur le "wargame" CENTURY.

Vous pouvez vous rendre sur <https://underthewire.tech/century> et lancer votre connexion SSH avec la commande suivante :

```plaintext
ssh century.underthewire.tech -l century9
```

Le mot de passe du premier compte "Century9" est `696`.

Une fois que vous aurez trouvé le mot de passe du compte "Century10", vous pourrez quitter le SSH (commande `exit`) et lancer la même commande en modifiant le nom du compte.
