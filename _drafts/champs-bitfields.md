
## Les bit fields

Les bit fields (ou champs de bits en français) sont des attributs qui stockent plusieurs informations (options, états, permissions…) sous forme de bits individuels dans un seul nombre entier.

Chaque bit (ou combinaison de bits) représente une option ou une propriété différente. Le nombre entier final correspond à l'addition de toutes les options entre-elles.

> On parle aussi parfois d’attributs à indicateurs ou d’attributs à valeurs de drapeaux.

### Attributs bit fields dans Active Directory

On en retrouve quelques exemples dans Active Directory :

- **userAccountControl** : Le plus connu, i contrôle les options et états du compte utilisateur (désactivé, mot de passe expiré, etc.).
- **searchFlags** : Définit les options de recherche et d’indexation pour un attribut du schéma.
- **systemFlags** : Indique des propriétés système sur les objets du schéma (protégé, répliqué, etc.).
- **groupType** : Définit le type et la portée d’un groupe (global, universel, distribution, sécurité…).
- **msDS-Behavior-Version** : Utilisé pour stocker les niveaux fonctionnels, certains bits peuvent être utilisés pour des options.
- **trustAttributes** : Définit des options sur les relations d’approbation (trusts) entre domaines.
- **instanceType** : Définit le type d’objet et son comportement en réplication.

### Cas pratique

Voici un exemple de tableau de valeurs pour l'attribut `msDS-Supported-Encryption-Type` :

Valeur décimale | Valeur hexadécimale | Supported Encryption Types
--- | --- | ---
1 | 0x1 | DES_CBC_CRC
2 | 0x2 | DES_CBC_MD5
4 | 0x4 | RC4
8 | 0x8 | AES_128
16 | 0x10 | AES_256

Ce tableau va nous permettre de comprendre la signification de n'importe quel nombre entier dans la plage de valeur valide (de 0 à 31). 

Si l'on raisonne en binaire plutôt qu'en valeur décimale ou hexadécimale, on comprend le côté cumulatif des valeurs :

- 1 devient 00001
- 2 devient 00010
- 4 devient 00100
- 8 devient 01000
- 16 devient 10000

Et si on transpose notre valeur binaire dans un tableau, on retrouve 


AES_256 (16) | AES_128 (8) | RC4 (4) | DES_CBC_MD5 (2) | DES_CBC_CRC (1)
------------ | ----------- | ------- | --------------- | -------------

## Lire un bit field

### Classe ENUM

Source : <https://learn-powershell.net/2016/03/07/building-a-enum-that-supports-bit-fields-in-powershell/>

```powershell
Add-Type -TypeDefinition @'
[System.Flags]
public enum supportedEncryptionType {
    DES_CBC_CRC = 1,
    DES_CBC_MD5 = 2,
    RC4 = 4,
    AES_128 = 8,
    AES_256 = 16
}
'@
```

```powershell
1..31 | ForEach-Object {
    $int = $_
    $bits = 0..4 | ForEach-Object {
        $val = [math]::Pow(2, $_)
        if ($int -band $val) { $val }
    }
    [PSCustomObject]@{
        Int = $int
        Calc = $bits -join '+'
        Meaning = [supportedEncryptionType]$int
    }
}
```

Int | Calcul     | Signification
--- | ------     | -------------
  1 | 1          | **DES_CBC_CRC**
  2 | 2          | **DES_CBC_MD5**
  3 | 1+2        | DES_CBC_CRC, DES_CBC_MD5
  4 | 4          | **RC4**
  5 | 1+4        | DES_CBC_CRC, RC4
  6 | 2+4        | DES_CBC_MD5, RC4
  7 | 1+2+4      | DES_CBC_CRC, DES_CBC_MD5, RC4
  8 | 8          | **AES_128**
  9 | 1+8        | DES_CBC_CRC, AES_128
 10 | 2+8        | DES_CBC_MD5, AES_128
 11 | 1+2+8      | DES_CBC_CRC, DES_CBC_MD5, AES_128
 12 | 4+8        | RC4, AES_128
 13 | 1+4+8      | DES_CBC_CRC, RC4, AES_128
 14 | 2+4+8      | DES_CBC_MD5, RC4, AES_128
 15 | 1+2+4+8    | DES_CBC_CRC, DES_CBC_MD5, RC4, AES_128
 16 | 16         | **AES_256**
 17 | 1+16       | DES_CBC_CRC, AES_256
 18 | 2+16       | DES_CBC_MD5, AES_256
 19 | 1+2+16     | DES_CBC_CRC, DES_CBC_MD5, AES_256
 20 | 4+16       | RC4, AES_256
 21 | 1+4+16     | DES_CBC_CRC, RC4, AES_256
 22 | 2+4+16     | DES_CBC_MD5, RC4, AES_256
 23 | 1+2+4+16   | DES_CBC_CRC, DES_CBC_MD5, RC4, AES_256
 24 | 8+16       | AES_128, AES_256
 25 | 1+8+16     | DES_CBC_CRC, AES_128, AES_256
 26 | 2+8+16     | DES_CBC_MD5, AES_128, AES_256
 27 | 1+2+8+16   | DES_CBC_CRC, DES_CBC_MD5, AES_128, AES_256
 28 | 4+8+16     | RC4, AES_128, AES_256
 29 | 1+4+8+16   | DES_CBC_CRC, RC4, AES_128, AES_256
 30 | 2+4+8+16   | DES_CBC_MD5, RC4, AES_128, AES_256
 31 | 1+2+4+8+16 | DES_CBC_CRC, DES_CBC_MD5, RC4, AES_128, AES_256

### Utilisation de l'opérateur -band



### Sans utiliser l'opérateur -band

```powershell
# Préparation de la table de correspondance
$table = @'
Name,Value
DES_CBC_CRC,1
DES_CBC_MD5,2
RC4,4
AES_128,8
AES_256,16
'@ | ConvertFrom-Csv
$table | ForEach-Object { $_.value = [int]$_.value }

###
$number = 21
$table | Sort-Object Value -Descending | ForEach-Object {
    $value = $_.Value
    Write-Host "Testing $($_.Name) with value $value" -ForegroundColor Yellow
    if ($number -ge $value) {
        Write-Host "  $number is larger or equal to $value"
        $sub = $number - $value
        Write-Host "  Number has been updated to $sub"
        if ($number -ne $sub) {
            $number = $sub
            Write-Host "    Option '$($_.Name)' is enabled!" -ForegroundColor Green
        } 
    }
    else {
        Write-Host "  Ignored: $number is lower than $value" -ForegroundColor DarkGray
    }
}
```

### Différence avec DSHeuristics

Le champ DSHeuristics, même si il contient un nombre entier qui en apparence ne veut pas dire grand-chose, n'est pas un bit field ! Ici ce n'est pas la 

