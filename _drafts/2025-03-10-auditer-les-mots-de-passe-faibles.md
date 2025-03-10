---
title: "Auditer les mots de passe faibles"
description: "Trouver tous les comptes utilisateurs qui utilise un mot de passe faible avec HaveIBeenPwned"
tags: active-directory
listed: true
---

## C'est quoi un mot de passe faible ?

### Module PowerShell DSInternals

Installation du module `DSInternals` :

```powershell
Install-Module DSInternals
```

### Téléchargement de la base HaveIBeenPwned

Installation de l'outil de téléchargement de la base HaveIBeenPwned :

```powershell
dotnet tool install --global haveibeenpwned-downloader
```

Téléchargement de la base de données des hashs NTLM vers le fichier "pwnedpasswords_ntlm.txt" :

```powershell
haveibeenpwned-downloader.exe -p 64 -n C:\temp\pwnedpasswords_ntlm.txt
```

En mars 2025, le fichier TXT pèse plus de 
