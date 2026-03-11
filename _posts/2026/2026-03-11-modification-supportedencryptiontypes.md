---
title: "Comment empêcher l'attribut msDS-SupportedEncryptionTypes d'être modifié ?"
description: "Chassez le DES, il revient au galop"
tags: ["activedirectory", "powershell"]
listed: true
---

## Remédiation en surface

### Contexte

Alors oui je sais, ça parait paradoxal de faire un article pour savoir comment se débarasser du chiffrement DES sur les tickets Kerberos quand l'actualité en 2026 c'est plutôt la fin de vie du chiffrement RC4 (plus sécurisé que DES).

J'ai encore des clients où certains ordinateurs ont toujours une valeur dans leur attribut `msDS-SupportedEncryptionTypes` qui indique qu'ils supportent DES pour le chiffrement de leurs tickets Kerberos. Et si ils pensent pouvoir s'en débarraser en remplaçant le 31 par un 28 ou un 24 (le mieux) dans l'attribut, l'attribut revient souvent à sa valeur initiale de 31 au bout de quelques jours.

Si vous ne comprennez pas de quoi je parle avec les 31 & 28, je vous invite à lire l'article et regarder la vidéo associée : [Supprimer le chiffrement DES très peu sécurisé des comptes d’utilisateur \| Microsoft Learn](https://learn.microsoft.com/fr-fr/services-hub/unified/health/remediation-steps-ad/remove-the-highly-insecure-des-encryption-from-user-accounts).

Sinon, je pose ce tableau ici pour rappel :

Décimal | Hexa | Chiffrements autorisés
------- | ---- | ----------------------
24 | 0x18 | AES_128, AES_256
28 | 0x1C | RC4, AES_128, AES_256
31 | 0x1F | DES_CRC, DES_MD5, RC4, AES_128, AES_256

### Inventaire des comptes avec DES

Pour faire l'inventaire des objets qui peuvent utiliser le chiffrement DES pour leurs tickets Kerberos, vous pouvez utiliser la commande suivante :

```powershell
$splat = @{
    Filter = {UserAccountControl -band 0x200000 -or msDS-SupportedEncryptionTypes -band 3}
    Properties = 'Name', 'OperatingSystem', 'msDS-SupportedEncryptionTypes'
}
Get-ADObject @splat | Format-Table $splat.Properties
```

### Remédiation en masse

Comme expliqué en introduction, on peut simplement venir remplacer la valeur 31 de l'attribut `msDS-SupportedEncryptionTypes` par 24 (AES128 & AES256 uniquement). Pour faire ça, vous pouvez utiliser la commande suivante :

```powershell
Get-ADObject -Filter {UserAccountControl -band 0x200000 -or msDS-SupportedEncryptionTypes -band 3} |
Set-ADObject -Replace @{'msDS-SupportedEncryptionTypes' = 24} -Verbose
```

Cependant, il y a fort à parier que dans quelques jours, la valeur initiale (31) reviendra.

## Pourquoi la remédiation échoue ?

Mais alors si la maudite valeur de 31 qui bipper PingCastle revient à chaque fois, comment faire ? Et bien c'est simple : vous devez modifier quelque chose sur l'ordinateur/serveur et pas juste sur l'objet Active Directory qui le représente.

> Pour information, c'est à l'ouverture d'une session utilisateur sur l'ordinateur concerné que l'attribut `msDS-SupportedEncryptionTypes` est modifié par l'ordinateur lui-même dans Active Directory.

### Modification par GPO

Sur les OS en Windows Server 2008R2+ ou Windows 7, vous pouvez configurer le support (ou non) des différentes méthodes de chiffrement Kerberos sur les ordinateurs de votre domaine :

- Chemin : Computer configuration > Policies > Windows Settings > Local Policies > Security Options
- Paramètre : **Network security: Configure encryption types allowed for Kerberos.**

Ce paramètre permet d'agir directement sur la configuration des ordinateurs pour interdire ou non le chiffrement DES et empêcher la réécriture de l'attribut `msDS-SupportedEncryptionTypes`.

> Par défaut, le chiffrement DES pour Kerberos a été désactivé à partir de Windows 7 / Windows Server 2008 R2.

Si vous n'avez pas envie de déployer ce genre de GPO sur tout le domaine pour remettre dans le rang quelques ordinateurs, vous pouvez modifier manuellement la `secpol.msc` de chaque ordinateur récalcitrant.

### La clé de registre SkipSupportedEncryptionTypesUpdate

Dans mes recherches pour empêcher ce comportement de réécriture de l'attribut, ChatGPT m'a sorti du chapeau une clé de registre inconnue au bataillon : **SkipSupportedEncryptionTypesUpdate**. Selon ses dires, la clé de registre évite que le Windows Server 2008 remette le support de DES dans son objet Active Directory.

La clé de registre en question :

```powershell
reg add HKLM\System\CurrentControlSet\Control\Lsa\Kerberos\Parameters ^
    /v SkipSupportedEncryptionTypesUpdate ^
    /t REG_DWORD ^
    /d 1 ^
    /f
```

Cette clé serait prise en charge immédiatement par LSASS (donc pas besoin de redémarrer). Le LLM précise cependant que c'est une clé non documentée dans les pages de Microsoft Learn, KB, TechNet, MS-Docs ou autres blogs officiels, qu'elle existe mais que Microsoft ne la reconnaît pas. Il ajout également que c'est typiquement le genre de clé :

- trouvée dans des environnements Microsoft Premier Support
- transmise par des ingénieurs CSS dans des cas très particuliers, mais jamais publiée officiellement

> Ça ressemble beaucoup à une hallucination vous ne trouvez pas ? Surtout avec le petit côté *Source ? TKT.*

J'ai quand-même tenté le coup pour la science et le résultat est sans-appel : **ça ne marche pas**, l'ordinateur continue de modifier la valeur de l'attribut à la connexion d'un utilisateur, comme si de rien n'était.

### Interdiction d'écriture de l'attribut

Pour les serveurs avant Windows Server 2008 R2, la seule solution que j'ai trouvé est d'interdire l'écriture de l'attribut `msDS-SupportedEncryptionTypes` par l'ordinateur lui-même. On peut appliquer l'interdiction avec la commande suivante :

```powershell
dsacls 'CN=server001,OU=Servers,DC=contoso,DC=com' /D 'SELF:WP;msDS-SupportedEncryptionTypes'
```

> **Attention :** ça reste une configuration assez "ghetto" que je ne peux pas recommander. Cependant, c'est la seule solution qui a fonctionné pour empêcher l'ordinateur de venir inscrire la valeur 31 dans l'attribut Active Directory `msDS-SupportedEncryptionTypes`.
