
## Les bit fields

Les bit fields (ou champs de bits en français) sont des attributs qui stockent plusieurs informations (options, états, permissions…) sous forme de bits individuels dans un seul nombre entier.

Chaque bit (ou combinaison de bits) représente une option ou une propriété différente. Le nombre entier final correspond à l'addition de toutes les options entre-elles.

On parle aussi parfois d’attributs à indicateurs ou d’attributs à valeurs de drapeaux.

On en retrouve quelques exemples dans Active Directory :

- `searchFlags`
- `userAccountControl`
- `systemFlags`

### Cas pratique

Voici un exemple de tableau de valeurs pour un attribut fictif :

| Name | Value |
| --- | ---
| SCRIPT | 1 |
| ACCOUNTDISABLE | 2 |
| HOMEDIR\_REQUIRED | 8 |
| LOCKOUT | 16 |
| PASSWD\_NOTREQD | 32 |
| PASSWD\_CANT\_CHANGE | 64 |
| ENCRYPTED\_TEXT\_PWD\_ALLOWED | 128 |
| TEMP\_DUPLICATE\_ACCOUNT | 256 |
| NORMAL\_ACCOUNT | 512 |
| INTERDOMAIN\_TRUST\_ACCOUNT | 2048 |
| WORKSTATION\_TRUST\_ACCOUNT | 4096 |
| SERVER\_TRUST\_ACCOUNT | 8192 |
| DONT\_EXPIRE\_PASSWORD | 65536 |
| MNS\_LOGON\_ACCOUNT | 131072 |
| SMARTCARD\_REQUIRED | 262144 |
| TRUSTED\_FOR\_DELEGATION | 524288 |
| NOT\_DELEGATED | 1048576 |
| USE\_DES\_KEY\_ONLY | 2097152 |
| DONT\_REQ\_PREAUTH | 4194304 |
| PASSWORD\_EXPIRED | 8388608 |
| TRUSTED\_TO\_AUTH\_FOR\_DELEGATION | 16777216 |
| PARTIAL\_SECRETS\_ACCOUNT | 67108864 |

Comme les valeurs vont par puissance de deux, il est impossible que plusieurs combinaisons d'options donnent le même résultat :

- `1 + 2 = 3` donc pas de collision avec l'option #C
- `1 + 2 + 4 = 7` donc pas de collision avec l'option #D

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

