---
title: "Auditer les mots de passe faibles"
description: "Trouver tous les comptes utilisateurs qui utilise un mot de passe faible avec HaveIBeenPwned"
tags: active-directory
listed: true
---

## C'est quoi un mot de passe faible ?

Un mot de passe faible, c'est un mot de passe dont le hash (résumé) est déjà connu. Cela traduit souvent un mot de passe commun, trop court ou prévisible.

Même si votre organisation impose une longueur minimum et de la complexité, cela ne vous protège pas des mots de passe faibles. Par exemple, le mot de passe `Bonjour1234!` respecte les règles suivantes :

- Longueur minimum de 12 caractères
- Contient au moins :
  - une lettre majuscule
  - une lettre minuscule
  - un chiffre
  - un caractère spécial

...mais son hash est déjà connu sur [NTLM.PW](https://ntlm.pw/) :

```powershell
$ntHash = '178c4b4f6a3afc38d6237f16b12af4ee'
$uri = "https://ntlm.pw/api/lookup/nt/$ntHash"
Invoke-RestMethod -Method GET -Uri $uri
```

Résultat de la commande :

```plaintext
178c4b4f6a3afc38d6237f16b12af4ee:Bonjour1234!
```

### Comment auditer des mots de passe Active Directory

Un domaine Active Directory repose sur un seul fichier : le fichier "NTDS.dit". C'est la base de données qui est partagée entre les contrôleurs de domaine et qui contient absolument toutes les informations du domaine, y compris les hashs de mot de passe (au format NTLM).

Avec le chiffrement NTLM, la même chaine de caractère génèrera toujours le même hash. Par exemple, le hash NTLM de `p@ssw0rd` sera toujours `DE26CCE0356891A4A020E7C4957AFC72`.

En sachant cela, il suffit de confronter le hash des mots de passe présents dans le domaine Active Directory avec un référentiel de mots de passe compromis comme celui de [HaveIBeenPwned](https://haveibeenpwned.com/).

> Pour faire l'ensemble des opérations qui suivent, il est nécessaire d'être administrateur du domaine.

### Module PowerShell DSInternals

Qu'importe le type d'audit que vous allez choisir, l'élément central est le module PowerShell [DSInternals](https://github.com/MichaelGrafnetter/DSInternals), développé par Michael Grafnetter.

Celui-ci permet de manipuler facilement une base NTDS ayant été extraite, ou utiliser les données de réplication entre contrôleur de domaine pour récupérer les hashs de mot de passe.

Pour installer le module depuis la PowerShell Gallery :

```powershell
Install-Module DSInternals
```

> Attention : l'utilisation de ce module est souvent identifié comme une tentative d'attaque par des outils d'EDR.

Dans la suite de cet article, nous exploiterons les données de réplication avec la commande `Get-ADReplAccount`, mais il est également possible de faire ce genre d'audit en utilisant une base NTDS extraite et la commande `Get-ADDBAccount`.

### Est-ce qu'on peut auditer la longueur des mots de passe ?

Oui c'est possible, mais pas en utilisant directement le hash. Un hash NTLM fera toujours 32 caractères de long, qu'importe la longueur du mot de passe :

Mot de passe | Hash NTLM
------------ | ---------
abc | `e0fba38268d0ec66ef1cb452d5885e53`
azerty123 | `3c6a6f19a3254e18f31c869afefd6d5d`
very-long-and-complex-password | `c15b375a2b642bb71adffdbcef7b4e8c`

Mais depuis août 2020, il est possible d’obtenir un évènement Windows lorsque la longueur d’un mot de passe est en dessous d’une certaine longueur. Cet évènement est généré au moment du changement de mot de passe, avant que le mot de passe ne soit haché. La longueur du mot de passe n’est jamais donnée explicitement.

Voici le paramètre de GPO : *Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies de comptes > Stratégie de mot de passe > **Audit de la longueur minimale du mot de passe***

Plus d'informations ici : [Minimum Password Length auditing and enforcement on certain versions of Windows - Microsoft Support](https://support.microsoft.com/en-us/topic/minimum-password-length-auditing-and-enforcement-on-certain-versions-of-windows-5ef7fecf-3325-f56b-cc10-4fd565aacc59)

Voici un code PowerShell pour récupérer les évènements liés à l'audit de la longueur minimale du mot de passe :

```powershell
$filterXPath = 'Event[System[(EventID=16978)]]'
Get-WinEvent -ProviderName Directory-Services-SAM -FilterXPath $filterXPath
```

Et voici un exemple de résultat, sur le compte "testminpwd" dont la longueur du mot de passe est entre 8 et 12 caractères.

```plaintext
Le compte suivant a été configuré avec un mot de passe dont la longueur est inférieure à celle du paramètre MinimumPasswordLengthAudit actuel. 
- AccountName : testminpwd 
- MinimumPasswordLength : 8
- MinimumPasswordLengthAudit : 12
Pour plus d’informations, voir https://go.microsoft.com/fwlink/?LinkId=2097191. 
```

### Comment interdire les mots de passe faibles ?

Il est impossible d'interdire purement et simplement les mots de passe faible, mais vous pouvez utiliser certains produits pour ajouter une liste de mots interdits qui ne peuvent pas être utilisé dans un mot de passe :

- [Password protection in Microsoft Entra ID](https://learn.microsoft.com/en-us/entra/identity/authentication/concept-password-ban-bad)
- [Lithnet Password Protection for Active Directory](https://github.com/lithnet/ad-password-protection)
- [OpenPasswordFilter](https://github.com/jephthai/OpenPasswordFilter)

> La plupart de ces solutions se basent sur la DLL de filtre de mot de passe Active Directory. Plus d'informations ici : [Installing and Registering a Password Filter DLL - Win32 apps \| Microsoft Learn](https://learn.microsoft.com/en-us/windows/win32/secmgmt/installing-and-registering-a-password-filter-dll).
>
> Dans le cas de Entra ID Password Protection, il ne s'agit pas d'une interdiction mais plutôt d'une diminution de la valeur des mots *interdits*.

## Audit hors-ligne

Si vous souhaitez réaliser l'audit entièrement hors-ligne, vous pouvez télécharger la base complète de HaveIBeenPwned. Attention : au 10 mars 2025, le fichier TXT téléchargé pèse plus de 43 Go.

### Téléchargement de la base HaveIBeenPwned

Installation de l'outil de téléchargement de la base HaveIBeenPwned :

```powershell
dotnet tool install --global haveibeenpwned-downloader
```

Téléchargement de la base de données des hashs NTLM vers le fichier "pwnedpasswords_ntlm.txt" :

```powershell
haveibeenpwned-downloader.exe -p 64 -n C:\temp\pwnedpasswords_ntlm
```

### Vérification des hashs

Une fois la base téléchargée, vous pouvez auditer les mots de passe faibles avec la commande suivante :

```powershell
$server = (Get-ADDomainController).HostName
$users = Get-ADReplAccount -All -Server $server
$users | Test-PasswordQuality -WeakPasswordHashesSortedFilePath 'C:\temp\pwnedpasswords_ntlm.txt'
```

La partie qui concerne les mots de passe faibles est disponible dans la section suivante :

```plaintext
Passwords of these accounts have been found in the dictionary:
  CONTOSO\jdoe
  CONTOSO\jblack
```

## Audit avec API

Si vous préférez éviter de télécharger la base complète, vous pouvez utiliser [l'API gratuite de HaveIBeenPwned](https://haveibeenpwned.com/API/v3#PwnedPasswords) pour conduire votre audit.

### Questions relatives à la sécurité de l'utilisation de l'API

L'API de HaveIBeenPwned a besoin de connaitre les cinq premiers caractères du hash pour vous répondre. Cela représente 15% de la longueur totale du hash.

Par exemple, si vous voulez tester le hash `DE26CCE0356891A4A020E7C4957AFC72`, il faudra envoyer `DE26C` à l'API. Comme les 27 autres caractères du hash sont inconnus de l'API, cela laisse 16²⁷ possibilités restantes.

### Fonction de vérification

Notre élément principal sera l'utilisation de l'API. Voici une fonction qui permet de l'interroger simplement avec PowerShell :

```powershell
function Get-PwnedNTHashList {
    param([string]$Prefix)

    $pwnedPasswords = Invoke-RestMethod -Method GET -Uri "https://api.pwnedpasswords.com/range/$Prefix`?mode=ntlm"
    $pwnedPasswords -split "`n" | ForEach-Object {
        [PSCustomObject]@{
            NTHash   = [string]($Prefix + ($_ -split ':')[0])
            Exposure = [int](($_ -split ':')[-1])
        }
    }
}
```

### Vérification des hashs

Le code est légèrement plus complexe que la version hors-ligne, car il n'est pas possible d'utiliser la commande `Test-PasswordQuality` dans ce cas.

```powershell
$server = (Get-ADDomainController).HostName
$users = Get-ADReplAccount -All -Server $server
$users | ForEach-Object {
    $ntHash = ($_.NTHash | ConvertTo-Hex -UpperCase) -join ''
    $pwned = Get-PwnedNTHashList -Prefix ($ntHash.Substring(0,5)) | Where-Object {$_.NTHash -eq $nthash}
    if ($pwned) {
        [PSCustomObject]@{
            Name = $_.Name
            SamAccountName = $_.SamAccountName
            Pwned = $true
            Exposure = $pwned.Exposure
        }
    }
}
```

Vous devriez obtenir un tableau similaire, avec tous les comptes utilisateurs ayant un mot de passe faible :

Name | SamAccountName | Pwned | Exposure
---- | -------------- | ----- | --------
John Doe | jdoe | True | 14
Jack Black | jblack | True | 256

> Plus la valeur dans la colonne "Exposure" est élevée, plus le mot de passe est faible.
