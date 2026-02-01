---
title: "LM Hash"
description: ""
tags: ["activedirectory", "powershell"]
listed: true
---

Liens utiles :

- [Windows Hashes & Attacks : LM, NT \| by Anis Ouersighni \| Medium](https://medium.com/@AnisO./windows-authentication-attacks-lm-nt-aka-ntlm-794bdcfe3887)
- [Empêcher le stockage de hachages de mot de passe de LAN Manager \| Microsoft Learn](https://learn.microsoft.com/fr-fr/services-hub/unified/health/remediation-steps-ad/prevent-storage-of-lan-manager-password-hashes)
- [SANS Digital Forensics and Incident Response Blog | Protecting Privileged Domain Accounts: LM Hashes #8212; The Good, the Bad, and the Ugly | SANS Institute](https://www.sans.org/blog/protecting-privileged-domain-accounts-lm-hashes-the-good-the-bad-and-the-ugly)

Comme on va vouloir contrôler les hashs de mot de passe enregistrés dans la base NTDS de Active Directory, le module DSInternals est obligatoire :

{% include github-repository.html repository="MichaelGrafnetter/DSInternals" %}

## Fonctionnement du LM Hash

### Utilité de LM Hash

Le LM Hash dans Active Directory est présent pour des raisons de compatibilités avec les versions de Windows antérieures à Windows 2000. 

### Théorique

Voici ce que nous dit [Wikipédia](https://fr.wikipedia.org/wiki/LM_hash) au sujet du fonctionnement de LM Hash :

- Le mot de passe est séparé en deux éléments de 7 caractères
- Si le mot de passe a une longueur inférieure à 14 caractères, il est complété par des caractères nuls
- Le hash de chaque morceau est calculé séparément
- Les deux hashs concaténés forment le LM Hash

Par ailleurs, le format LM ne gère pas la casse.

### En pratique

On peut facilement convertir une chaine de caractère en LM Hash avec la commande `ConvertTo-LMHash` du module DSInternals. On peut créer un LM Hash de la manière suivante :

```powershell
'bonjour' | ConvertTo-SecureString -AsPlainText | ConvertTo-LMHash
```

#### Sensibilité à la casse

En testant un peu, on peut vérifier que celui-ci n'est en effet pas sensible à la casse. Toutes les verionss avec ou sans majuscule d'une même chaine de caractère donneront toujours le même hash :

Mot de passe | LM Hash
------------ | -------
bonjour | 43d119e8b3d8710baad3b435b51404ee
Bonjour | 43d119e8b3d8710baad3b435b51404ee
BONJOUR | 43d119e8b3d8710baad3b435b51404ee

#### Longueur du mot de passe

On remarque également que le découpage en deux blocs est visible, puisque le LM Hash de tous les mots de passe de moins de 7 caractères finissent par **aad3b435b51404ee** :

Mot de passe | LM Hash
------------ | -------
bonjour | 43d119e8b3d8710b**aad3b435b51404ee**
testing | 2d5545077d7b7d2**aaad3b435b51404ee**
sept | c06bd14e029e9e47**aad3b435b51404ee**

Si on essaye de convertir une chaine de plus de 14 caractères, on tombe sur l'erreur **The password must be 0-14 characters long.**

#### Caractères interdits

Si on utilise des caractères spéciaux non pris en charge comme "€", on obtient l'erreur **Il n’y a pas de caractère correspondant au caractère Unicode dans la page de codes multi-octet cible.**

## Notes techniques

### Autorisation du LM Hash

Le paramètre pour autoriser (ou non) l'utilisation de LM Hash dans le stockage des mots de passe sur Active Directory a maintenant un petit historique :

- Par défaut sur Windows Server 2003 : support de LM Hash activé
- Par défaut depuis Windows Server 2008 : support de LM Hash désactivé
- Depuis Windows Server 2025 : impossible d'activer le support de LM Hash

> Pour Windows Server 2025, le paramètre de GPO n'est plus disponible, et même en utilisant la clé de registre DWORD `HKLM:\SYSTEM\CurrentControlSet\Control\lsa\NoLmHash` définie à 0, ça ne marche pas non plus.

Le paramètre pour le support du LM Hash est le suivant : **Computer configuration > Policies > Windows Settings > Security Settings > Local Policies > Security Options > Network security: Do not store LAN Manager hash value on next password change**. Il faut donc définir ce paramètre à "Désactiver" pour que celui-ci prenne effet (au prochain changement de mot de passe).

### Création du compte de test

Pour l'occasion, on va créer le compte de test "lmhash" avec un mot de passe de moins de 14 caractères (indispensable pour que le LM Hash puisse être généré) :

```powershell
New-ADUser -SamAccountName lmhash
Set-ADAccountPassword lmhash -NewPassword ('Password123!' | ConvertTo-SecureString -AsPlainText -Force)
```

On vérifie maintenant la présence du LM Hash dans la base NTDS avec le module DSInternals :

```powershell
Get-ADReplAccount -SamAccountName lmhash -Server (Get-ADDomainController)
```

### Après changement de mot de passe

Comme on le sait, le LM Hash ne permet pas de chiffrer des chaines de plus de 14 caractères. Donc si on change le mot de passe de notre compte de test pour `Password123456!` (15 caractères), le LM Hash disaparait du résultat de la commande `Get-ADReplAccount` :

```plaintext
Secrets
  NTHash: bee98dc086291586556711a645c6bd58
  LMHash:
```

### Conflit avec une DDPP

Depuis Windows Server 2022, nous avons une option pour augmenter la longueur minimum des mots de passe à plus de 14 caractères sur la Default Domain Password Policy. Comme LM Hash ne gère pas ce genre de mot de passe, quel est le comportement du contrôleur de domaine ?

- Vérification de la clé de registre NoLMHash
- Vérification avec une PSO qui permet d'avoir un mot de passe de moins de 14 caractères

### Cohabitation avec un Windows Server 2025

Dans un domaine avec LM Hash autorisé, comment se comporte un Windows Server 2025 ?

### Comportement de retrait

La suppression du paramètre pour autoriser le LM Hash et le redémarrage des contrôleurs de domaine n'est pas suffisant pour "purger" l'existant. Il va falloir réinitialiser le mot de passe des comptes concernés pour supprimer définitivement le LM Hash de la base NTDS de Active Directory.

Pour lister l'ensemble des comptes qui possède encore un LM Hash enregistré dans la base NTDS :

```powershell
(Get-ADReplAccount -All -Server (Get-ADDomainController) | Test-PasswordQuality).LMHash
```
