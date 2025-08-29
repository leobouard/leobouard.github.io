---
---

### Obtenir un SecureString vide

```powershell
'' | ConvertTo-SecureString -AsPlainText -Force
```

On obtient l'erreur suivante : **Cannot bind argument to parameter 'String' because it is an empty string.**

```powershell
$emptySs = Read-Host -AsSecureString
# ou
$emptySs = [SecureString]::New()
```

Avec la commande `ConvertTo-NTHash` du module DSInternals :

```powershell
$emptySs | ConvertTo-NTHash
```

On obtient alors le hash NTLM qui correspond à un mot de passe vide : `31d6cfe0d16ae931b73c59d7e0c089c0`

### Compte PasswordLess

[GOING PASSWORDLESS WITH DSRM by Narayanan Subramanian](https://medium.com/@nannnu/overview-72d7f737bdc6)

