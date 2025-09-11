---
title: "Les bit fields avec PowerShell"
description: "Tout savoir sur les champs de bits et l'opérateur -band (pas de blagues promis)"
tags: powershell
listed: true
---

## Définition

Les bit fields (ou champs de bits en français) sont des attributs qui stockent plusieurs informations (options, états, permissions…) sous forme de bits individuels dans un seul nombre entier. Chaque bit (ou combinaison de bits) représente une option ou une propriété différente. Le nombre entier final correspond à l'addition de toutes les options entre-elles.

> On parle aussi parfois d’attributs à indicateurs ou d’attributs à valeurs de drapeaux.

### Attributs bit fields dans Active Directory

On en retrouve quelques exemples dans Active Directory :

- **userAccountControl** : Le plus connu, il contrôle les options et états du compte utilisateur (désactivé, mot de passe expiré).
- **searchFlags** : Définit les options de recherche et d’indexation pour un attribut du schéma.
- **systemFlags** : Indique des propriétés système sur les objets du schéma (protégé, répliqué).
- **groupType** : Définit le type et la portée d’un groupe (global, universel, distribution, sécurité).
- **msDS-Behavior-Version** : Utilisé pour stocker les niveaux fonctionnels, certains bits peuvent être utilisés pour des options.
- **trustAttributes** : Définit des options sur les relations d’approbation (trusts) entre domaines.
- **instanceType** : Définit le type d’objet et son comportement en réplication.

### Attribut DSHeuristics

Le champ DSHeuristics, même si il contient un nombre entier qui en apparence ne veut pas dire grand-chose, n'est pas un bit field ! Pour cet attribut, c'est la position du caractère qui indique une valeur. Plus d'informations ici : [attribut DS-Heuristics - Win32 apps \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows/win32/adschema/a-dsheuristics#remarks)

## Cas pratique

### Table de valeur

Un bit field ne peut être compris qu'avec une table de correspondance qui indique clairement la signification de chaque bit. Sans elle, on ne peut pas comprendre la valeur 16 par exemple.

Voici le tableau de valeurs pour l'attribut Active Directory `msDS-Supported-Encryption-Type` :

Valeur décimale | Valeur hexadécimale | Supported Encryption Types
--------------- | ------------------- | --------------------------
1 | 0x1 | DES_CRC
2 | 0x2 | DES_MD5
4 | 0x4 | RC4
8 | 0x8 | AES_128
16 | 0x10 | AES_256

> Le nom des méthodes de chiffrement indiquées dans le tableau a été simplifié pour plus de lisibilité.

### Valeurs de base

Si la valeur de l'attribut `msDS-Supported-Encryption-Type` est égale à 16, on sait (grâce à la table) que cela signifie "AES_256". 1, 2, 4, 8 et 16 sont appelées **valeurs de base** car elles n'utilisent qu'un bit. Elles sont donc compréhensibles immédiatement et sans avoir besoin de faire de calcul.

### Combinaison de bits

Comme un bit field peut stocker plusieurs informations en un seul nombre entier, il est rare que la valeur se limite à 1, 2, 4, 8 ou 16. Pour un bit field sur 5 bits, les valeurs possibles peuvent varier de 1 (2⁰) à 31 (2⁵-1). 

Comment comprendre la valeur 24 ou 29 par exemple ? Il y a deux options :

- le calcul en décimal
- le calcul en binaire

#### Calcul en décimal

Le calcul en décimal consiste simplement à additionner les différentes valeurs de base pour obtenir la valeur cible. Ainsi les valeurs suivantes peuvent être trouvées :

- 24 est obtenu avec 16 + 8
- 29 est obtenu avec 16 + 8 + 4 + 1

Comme on connaît la signification des valeurs de base, on comprend alors que 24 signifie "AES_256" (16) et "AES_128" (8).

#### Calcul en binaire

Le calcul binaire permet d'approcher le problème de manière plus programmatique. La première étape est de convertir nos valeurs de base en binaire. Cela permet de rappeler qu'un seul bit est défini à 1 pour l'ensemble de nos valeurs de base :

- 1 devient 00001
- 2 devient 00010
- 4 devient 00100
- 8 devient 01000
- 16 devient 10000

Pour convertir un nombre décimal en binaire avec PowerShell :

```powershell
$i = 29 # nombre à convertir
[Convert]::ToString($i, 2)
```

Une fois le nombre binaire représenté dans un tableau avec une colonne par option, on obtient la signification de 24 et 29 :

Valeur décimale | AES_256 | AES_128 | RC4 | DES_MD5 | DES_CRC
--------------- | ------- | ------- | --- | ------- | -------
1 | 0 | 0 | 0 | 0 | **1**
2 | 0 | 0 | 0 | **1** | 0
4 | 0 | 0 | **1** | 0 | 0
8 | 0 | **1** | 0 | 0 | 0
16 | **1** | 0 | 0 | 0 | 0
24 | **1** | **1** | 0 | 0 | 0
29 | **1** | **1** | **1** | 0 | **1**

Il ne reste plus qu'à lire le tableau : si la valeur d'une colonne est définie à 1, alors l'option est active. Voici donc la signification des nombres suivants :

- 24 indique "AES_256" et "AES_128"
- 29 indique "AES_256", "AES_128", "RC4" et "DES_CRC"

## Lecture avec PowerShell

Il existe plusieurs méthodes pour déchiffrer un bit field. Dans tous les cas, la première étape consiste à construire ou au moins connaître la table de correspondance pour le bit field.

### Énumération .NET

La première méthode utilise l'énumération .NET (C#) avec l'attribut `[System.Flags]`, spécialement conçu pour les bit fields. On va commencer par créer l'énumération en indiquant la table de valeur :

```powershell
Add-Type -TypeDefinition @'
[System.Flags]
public enum SupportedEncryptionType {
    DES_CRC = 1,
    DES_MD5 = 2,
    RC4 = 4,
    AES_128 = 8,
    AES_256 = 16
}
'@
```

> Les noms des membres de la table (exemple : AES_256) ne peuvent pas contenir d'espace. C'est la raison de l'utilisation des underscores (`_`).

Pour utiliser cette méthode, il faut simplement invoquer notre énumération nouvellement créée et indiquer le nombre entier à déchiffrer :

```powershell
[SupportedEncryptionType]29
```

On obtient alors la signification du nombre 29 : `DES_CRC, RC4, AES_128, AES_256`. Cette méthode est idéale pour obtenir toutes les options pour un nombre entier donné.

Source : <https://learn-powershell.net/2016/03/07/building-a-enum-that-supports-bit-fields-in-powershell/>

### Opérateur Bitwise AND (-band)

#### Fonctionnement théorique

L'opérateur "Bitwise AND" (que l'on pourrait traduire par *opérateur ET bit à bit*) permet de savoir simplement si un bit est actif sur un nombre entier en retournant le ou les bits en commun entre les deux nombres. Une comparaison ET bit à bit revient à passer les nombres décimaux en binaire est appliquer l'opération suivante sur chaque bit :

- 1 et 1 donnent 1
- 1 et 0 donnent 0
- 0 et 0 donnent 0

Si le résultat final en décimal est 0, alors il n'y a aucun bit en commun entre les deux nombres. Sinon, il y a au moins un bit en commun entre les deux nombres. Dans le cas d'un bit field, si un bit partagé cela signifie que l'option est active.

Voici un exemple de la comparaison "Bitwise AND" entre 24 et 16 :

```plaintext
11000 = 24
10000 = 16
-----
10000 = 16
```

Voici un autre exemple entre 24 et 4 :

```plaintext
11000 = 24
00100 = 4
-----
00000 = 0
```

#### Fonctionnement pratique

Pour faire cette comparaison rapidement avec PowerShell, il existe l'opérateur `-band` :

Comparaison   | Résultat
-----------   | --------
`24 -band 16` | 16
`24 -band 4`  | 0

Cet opérateur peut être utilisé dans le cadre d'un filtre avec `Where-Object` pour détecter facilement si un bit est présent sur un attribut. Ici par exemple, on affiche tous les nombres entre 0 et 31 qui ont le bit n°2 actif ("DES_MD5" dans le cas de `msDS-Supported-Encryption-Type`) :

```powershell
1..31 | Where-Object { $_ -band 2 }
```

> Pour toutes les valeurs possibles d'un bit field (31 dans ce cas), on retrouve le bit n°2 dans 50% des cas (16 valeurs sur 31). Cette règle est valable pour toutes les valeurs de base comme 1, 4, 8 ou 16.

Même si cette méthode est moins efficace que l'énumération .NET, il est possible de lister toutes les options d'un bit field avec l'opérateur `-band`. Comme toujours, la première étape est de créer la table de valeur :

```powershell
$table = @'
Name,Value
DES_CRC,1
DES_MD5,2
RC4,4
AES_128,8
AES_256,16
'@ | ConvertFrom-Csv
$table | ForEach-Object { $_.value = [int]$_.value }
```

> Ici une conversion en entier de la colonne "Value" est faite puisque le format CSV traite toutes les informations comme des chaines de caractères par défaut. Cette conversion permet de faire des opérations mathématique sur la colonne de manière sécurisée.

Il ne reste plus qu'à exploiter la table de valeur pour lister toutes les options :

```powershell
$i = 24
($table | Where-Object {($_.Value -band $i) -ne 0}).Name
```

### Sans utiliser l'opérateur -band

Cette méthode illustre la décomposition d’un nombre en puissances de deux, comme on le ferait à la main. Ici on récupère la variable `$table` créée précédemment pour faire le calcul en décimal.

Le principe est simple :

- Chaque option de la table de valeur est parcourue, de la plus grande à la plus petite
- Si `$i` est supérieur ou égal à la valeur de l’option, il soustrait cette valeur à `$i` et indique que l’option est activée
- Sinon, il ignore l’option et passe à la suivante

```powershell
$i = 21
$table | Sort-Object Value -Descending | ForEach-Object {
    $value = $_.Value
    Write-Host "Testing $($_.Name) with value $value" -ForegroundColor Yellow
    if ($i -ge $value) {
        Write-Host "  $i is larger or equal to $value"
        $sub = $i - $value
        Write-Host "  New value is $sub because $i - $value = $sub"
        if ($i -ne $sub) {
            $i = $sub
            Write-Host "    Option '$($_.Name)' is enabled!" -ForegroundColor Green
        } 
    }
    else {
        Write-Host "  Ignored: $i is lower than $value" -ForegroundColor DarkGray
    }
}
```

Tout le détail est affiché dans la console, ce qui donne ce résultat pour la valeur 21 :

```plaintext
Testing AES_256 with value 16
  21 is larger or equal to 16
  New value is 5 because 21 - 16 = 5
    Option 'AES_256' is enabled!
Testing AES_128 with value 8
  Ignored: 5 is lower than 8
Testing RC4 with value 4
  5 is larger or equal to 4
  New value is 1 because 5 - 4 = 1
    Option 'RC4' is enabled!
Testing DES_CBC_MD5 with value 2
  Ignored: 1 is lower than 2
Testing DES_CBC_CRC with value 1
  1 is larger or equal to 1
  New value is 0 because 1 - 1 = 0
    Option 'DES_CBC_CRC' is enabled!
```

## Calcul du tableau complet

Dans certaines documentations Microsoft (comme celle sur [l'attribut msDS-SupportedEncryptionTypes](https://techcommunity.microsoft.com/blog/coreinfrastructureandsecurityblog/decrypting-the-selection-of-supported-kerberos-encryption-types/1628797)), on y retrouve parfois un tableau qui liste l'intégralité des valeurs possibles du bit field.

Il est possible de générer ce tableau de manière programmatique avec le code suivant :

```powershell
Add-Type -TypeDefinition @'
[System.Flags]
public enum SupportedEncryptionType {
    DES_CRC = 1,
    DES_MD5 = 2,
    RC4 = 4,
    AES_128 = 8,
    AES_256 = 16
}
'@

1..31 | ForEach-Object {
    $int = $_
    $hex = '0x' + ([Convert]::ToString($int, 16)).ToUpper()
    $bits = 0..4 | ForEach-Object {
        $val = [math]::Pow(2, $_)
        if ($int -band $val) { $val }
    }
    [PSCustomObject]@{
        Int     = $int
        Hex     = $hex
        Calc    = $bits -join '+'
        Meaning = [supportedEncryptionType]$int
    }
}
```

Et voici le résultat pour l'attribut `msDS-Supported-Encryption-Type` :

Int | Hex  | Calc       | Meaning
--- | ---  | ----       | -------
  1 | 0x1  | 1          | DES_CRC
  2 | 0x2  | 2          | DES_MD5
  3 | 0x3  | 1+2        | DES_CRC, DES_MD5
  4 | 0x4  | 4          | RC4
  5 | 0x5  | 1+4        | DES_CRC, RC4
  6 | 0x6  | 2+4        | DES_MD5, RC4
  7 | 0x7  | 1+2+4      | DES_CRC, DES_MD5, RC4
  8 | 0x8  | 8          | AES_128
  9 | 0x9  | 1+8        | DES_CRC, AES_128
 10 | 0xA  | 2+8        | DES_MD5, AES_128
 11 | 0xB  | 1+2+8      | DES_CRC, DES_MD5, AES_128
 12 | 0xC  | 4+8        | RC4, AES_128
 13 | 0xD  | 1+4+8      | DES_CRC, RC4, AES_128
 14 | 0xE  | 2+4+8      | DES_MD5, RC4, AES_128
 15 | 0xF  | 1+2+4+8    | DES_CRC, DES_MD5, RC4, AES_128
 16 | 0x10 | 16         | AES_256
 17 | 0x11 | 1+16       | DES_CRC, AES_256
 18 | 0x12 | 2+16       | DES_MD5, AES_256
 19 | 0x13 | 1+2+16     | DES_CRC, DES_MD5, AES_256
 20 | 0x14 | 4+16       | RC4, AES_256
 21 | 0x15 | 1+4+16     | DES_CRC, RC4, AES_256
 22 | 0x16 | 2+4+16     | DES_MD5, RC4, AES_256
 23 | 0x17 | 1+2+4+16   | DES_CRC, DES_MD5, RC4, AES_256
 24 | 0x18 | 8+16       | AES_128, AES_256
 25 | 0x19 | 1+8+16     | DES_CRC, AES_128, AES_256
 26 | 0x1A | 2+8+16     | DES_MD5, AES_128, AES_256
 27 | 0x1B | 1+2+8+16   | DES_CRC, DES_MD5, AES_128, AES_256
 28 | 0x1C | 4+8+16     | RC4, AES_128, AES_256
 29 | 0x1D | 1+4+8+16   | DES_CRC, RC4, AES_128, AES_256
 30 | 0x1E | 2+4+8+16   | DES_MD5, RC4, AES_128, AES_256
 31 | 0x1F | 1+2+4+8+16 | DES_CRC, DES_MD5, RC4, AES_128, AES_256
