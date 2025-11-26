---
title: "SOLUCE #6 - SUTOM"
prevLink:
  name: "Retour au défi"
  id: "sutom"
---

## Ma solution

Le code PowerShell et sa documentation associée est disponible sur GitHub Gist :

{% include github-gist.html name="Find-SutomWord" id="ba40d91bff7105b99a8219114ad2fd15" %}

### Explications

#### Récupération du dictionnaire

La première étape est de récupérer le dictionnaire utilisé par l'application. Comme celle-ci est en open-source, on peut le récupérer facilement sur son dépôt via un `Invoke-RestMethod` ou `Invoke-WebRequest` :

```powershell
$uri = 'https://framagit.org/JonathanMM/sutom/-/raw/main/data/mots.txt?ref_type=heads'
$raw = Invoke-RestMethod -Method GET -Uri $uri
```

Une fois le contenu de la page web récupéré, il va falloir faire comprendre à PowerShell qu'il s'agit d'une liste composée de plusieurs mots et pas une seule chaine de caractères qui contiendrait des retours à la ligne.

Pour ça il y a plein de méthodes, mais la plus simple (et la plus rapide à ma connaissance) est de couper la chaine de caractères actuelle à chaque retour à la ligne. Deux méthodes possibles ici :

```powershell
$wordList = $raw -split "`n"
# vs.
$wordList = $raw.split()
```

Une fois la chaine de caractère séparée, on obtient 451 278 mots dans notre variable `$wordList`. Pour améliorer les performances de recherche, on va donc réduire ce nombre au maximum.

#### Réduction du nombre de résultats

Parmi les 500 000 mots, tous ne nous seront pas utiles. On va donc essayer de réduire ce chiffre pour n'avoir que des résultats pertinents. À partir des informations que l'on a déjà, on va pouvoir exclure les mots qui :

- Ne commencent pas par la lettre que le mot recherché
- N'ont pas le même nombre de caractères que le mot recherché

On peut réaliser ce filtre en PowerShell avec la commande suivante (pour un mot qui commence par "H" et qui contient 8 caractères) :

```powershell
$wordList = $wordList | Where-Object { $_ -like 'H*' -and $_.Length -eq 8 }
```

Ce premier filtre nous permet de descendre de ~500 000 mots à moins de 1000 mots, ce qui va grandement améliorer les performances de nos filtres futurs (car il y aura moins d'objets à parcourir).

#### Création d'une base de donnée temporaire

Une fois le nombre de résultats réduit au minimum, on va créer une base de données pour stocker plus d'information que simplement le mot. J'ai choisi de créer un objet pour chaque mot, qui contiendrait les propriétés suivantes :

- `Word` qui contiendrait le mot en majuscule
- `Letters` qui contiendrait une liste dédupliquée de toutes les lettres du mot, sans accent (sous forme d'une chaine de caractère unique)
- `Score` qui ferait le ratio entre le nombre de lettres uniques et la longueur du mot

On peut réaliser cette petite base de données avec le code suivant :

```powershell
$db = $wordList | ForEach-Object {
    $letters = [Text.Encoding]::ASCII.GetString([Text.Encoding]::GetEncoding("Cyrillic").GetBytes($_))
    $letters = ($letters.ToLower().ToCharArray() | Sort-Object -Unique) -join ''
    [PSCustomObject]@{
        Word    = $_.ToUpper()
        Letters = $letters
        Score   = [math]::Round($letters.Length / $_.Length, 2)
    }
}
```

> La réduction du nombre de mots nous permet de créer nos objets PowerShell beaucoup plus rapidement que si l'on avait gardé le dictionnaire au complet.

On obtient alors le résultat suivant :

Word     | Letters  | Score
----     | -------  | -----
HABANERA | abehnr   |  0,75
HABANÉRA | abehnr   |  0,75
HABILETÉ | abehilt  |  0,88
HABILITA | abhilt   |  0,75
HABILITE | abehilt  |  0,88

#### Utilité des nouvelles propriétés

Deux propriétés ont donc été ajoutées à notre dictionnaire réduit : `Letters` et `Score`.

La première propriété va nous permettre de filtrer en indiquant des lettres qui doivent être présentes ou non dans le mot mystère. En outre, comme la chaine de caractère est sans accent et dédupliquée, sa longueur permet de connaitre le nombre de lettres différentes dans le mot. C'est à ce moment qu'intervient la deuxième propriété qui calcule un "score" entre 0 et 1 pour chaque mot. Plus ce score est élevé, plus le mot permet de tester des lettres différentes :

- Un score de 1 indique qu'il y a autant de lettres uniques que de caractères dans le mot
- Un score de 0.50 indique que pour un mot de 8 caractères de long, il n'y a que 4 lettres uniques

Voici deux exemples :

Word     | Letters  | Score
----     | -------  | -----
HOLDINGS | dghilnos |  1,00
HAÏSSAIS | ahis     |  0,50

#### Utilisation de filtres supplémentaires

Pour le moment, notre code est utile, mais uniquement pour le premier tour, quand on a encore très peu d'informations. L'idée est donc d'ajouter des filtres supplémentaires pour permettre d'affiner encore plus les résultats :

1. Un filtre générique pour permettre par exemple d'indiquer si le mot se termine par une lettre
2. Un filtre pour rendre obligatoire la présence de certaines lettres dans le mot recherché
3. Un filtre pour éliminer tous les mots qui contiennent certaines lettres

Pour le filtre générique, on utilise simplement l'opérateur `-like` qui va nous permettre d'indiquer un paterne pour exprimer le fait que le mot commence par "H" et finit par "S". Exemple de filtre : `H*S`.

```powershell
$db = $db | Where-Object { $_.Word -like 'H*S' }
```

Pour les deux autres filtres, ils sont identiques à l'exception de l'opérateur de comparaison qui passe de `-like` pour les lettres obligatoires à `-notlike` pour les lettres interdites :

```powershell
# Lettres obligatoires
$IncludedLetters = 'O', 'I'
$IncludedLetters | ForEach-Object {
    $letter = "*$_*"
    $db = $db | Where-Object { $_.Letters -like $letter }
}
# Lettres interdites
$ExcludedLetters = 'L', 'D', 'N', 'G'
$ExcludedLetters | ForEach-Object {
    $letter = "*$_*"
    $db = $db | Where-Object { $_.Letters -notlike $letter }
}
```

> Dans mon code initial, ma propriété `Letters` était une liste et non une chaine de caractères, pour que je puisse utiliser l'opérateur de comparaison `-contains` plutôt que `-like` (que je pensais plus performant).
> D'après mes tests, c'est au final l'utilisation d'une chaine de caractères et de `-like` qui est l'option la plus rapide.

#### Affichage des résultats

Après le passage des filtres ci-dessus, la liste s'est réduite de 880 mots potentiels à seulement 10 mots. Il ne nous reste plus qu'à les afficher, en les triant par ordre décroissant de score :

```powershell
$db | Sort-Object Score -D | Select-Object -First 20
```

Résultat final :

Word     | Letters  | Score
----     | -------  | -----
HARICOTS | achiorst |  1,00
HAUTBOIS | abhiostu |  1,00
HICKORYS | chikorsy |  1,00
HOUERAIS | aehiorsu |  1,00
HYPOXIES | ehiopsxy |  1,00
HACHOIRS | achiors  |  0,88
HORAIRES | aehiors  |  0,88
HOSPICES | cehiops  |  0,88
HOUPPAIS | ahiopsu  |  0,88
HOUSSAIS | ahiosu   |  0,75
