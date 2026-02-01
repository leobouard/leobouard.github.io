---
title: "LMHash"
description: ""
tags: ["activedirectory", "powershell"]
listed: true
---

Liens utiles :

- [Windows Hashes & Attacks : LM, NT \| by Anis Ouersighni \| Medium](https://medium.com/@AnisO./windows-authentication-attacks-lm-nt-aka-ntlm-794bdcfe3887)
- [Empêcher le stockage de hachages de mot de passe de LAN Manager \| Microsoft Learn](https://learn.microsoft.com/fr-fr/services-hub/unified/health/remediation-steps-ad/prevent-storage-of-lan-manager-password-hashes)

Module utile :

{% include github-repository.html repository="MichaelGrafnetter/DSInternals" %}

## Fonctionnement du LM hash

### Théorique

Voici ce que nous dit Wikipédia au sujet du fonctionnement de LM Hash :

- Le mot de passe est séparé en deux éléments de 7 caractères
- Si le mot de passe a une longueur inférieure à 14 caractères il est complété par des caractères nuls
- Le hash de chaque morceau est calculé séparément
- Les deux hashs concaténés forment le hash LM

Par ailleurs, le format LM ne gère pas la casse.

### En pratique

On peut facilement convertir une chaine de caractère en LM Hash avec la commande `ConvertTo-LMHash` du module DSInternals. On peut donc vérifier le fonctionnement de l



On va prendre 

```powershell
'bonjour' | ConvertTo-SecureString -AsPlainText | ConvertTo-LMHash
```

```powershell
'testing' | ConvertTo-SecureString -AsPlainText | ConvertTo-LMHash
```




Mot de passe | Hash LM
------------ | -------
bonjour | `43d119e8b3d8710baad3b435b51404ee`
Bonjour | `43d119e8b3d8710baad3b435b51404ee`
BONJOUR | `43d119e8b3d8710baad3b435b51404ee`



