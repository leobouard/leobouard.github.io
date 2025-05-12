
## Les bit fields

Les bit fields (ou champs de bits en français) sont des attributs qui stockent plusieurs informations (options, états, permissions…) sous forme de bits individuels dans un seul nombre entier.

Chaque bit (ou combinaison de bits) représente une option ou une propriété différente. Le nombre entier final correspond à l'addition de toutes les options entre-elles.

> On parle aussi parfois d’attributs à indicateurs ou d’attributs à valeurs de drapeaux.

### Attributs bit fields dans Active Directory

On en retrouve quelques exemples dans Active Directory :

- **userAccountControl** : Contrôle les options et états du compte utilisateur (désactivé, mot de passe expiré, etc.).
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
8 | 0x8 | AES 128
16 | 0x10 | AES 256

Comme les valeurs vont par puissance de deux, il est impossible que plusieurs combinaisons d'options donnent le même résultat :

- DES_CBC_CRC (1) et DES_CBC_MD5 (2) donne 3 comme résultat, donc pas de conflit avec RC4 (4)
- DES_CBC_CRC (1), DES_CBC_MD5 (2) et RC4 (4) donne 7 comme résultat, donc pas de conflit avec AES 128 (8)

On peut donc stocker 

### Utilisation de l'opérateur -band



### Sans utiliser l'opérateur -band

```powershell
$number = 21 # 16+4+1
$table = @'
Name,Value
SCRIPT,1
ACCOUNTDISABLE,2
HOMEDIR_REQUIRED,8
LOCKOUT,16
PASSWD_NOTREQD,32
PASSWD_CANT_CHANGE,64
ENCRYPTED_TEXT_PWD_ALLOWED,128
TEMP_DUPLICATE_ACCOUNT,256
NORMAL_ACCOUNT,512
INTERDOMAIN_TRUST_ACCOUNT,2048
WORKSTATION_TRUST_ACCOUNT,4096
SERVER_TRUST_ACCOUNT,8192
DONT_EXPIRE_PASSWORD,65536
MNS_LOGON_ACCOUNT,131072
SMARTCARD_REQUIRED,262144
TRUSTED_FOR_DELEGATION,524288
NOT_DELEGATED,1048576
USE_DES_KEY_ONLY,2097152
DONT_REQ_PREAUTH,4194304
PASSWORD_EXPIRED,8388608
TRUSTED_TO_AUTH_FOR_DELEGATION,16777216
PARTIAL_SECRETS_ACCOUNT,67108864
'@ | ConvertFrom-Csv

$table | ForEach-Object { $_.value = [int]$_.value }

$number = 1114624
$table | Sort-Object Value -Descending | ForEach-Object {
    $value = $_.Value
    "Testing $($_.Name) with value $value"   
    if ($number -ge $value) {
        Write-Host "  ⌊_ $number is larger or equal to $value : CHECK"
        $sub = $number - $value
        Write-Host "  ⌊_ Number has been updated to $sub"
        if ($number -ne $sub) {
            $number = $sub
            Write-Host "    ⌊_ Option '$($_.Name)' is enabled!" -ForegroundColor Green
        } 
    }
    else {
        Write-Host "  ⌊_ $number is lower than $value : IGNORED" -ForegroundColor DarkGray
    }
}
```

### Différence avec DSHeuristics

Le champ DSHeuristics, même si il contient un nombre entier qui en apparence ne veut pas dire grand-chose, n'est pas un bitfield ! Ici ce n'est pas la 

