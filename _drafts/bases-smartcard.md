---
title: "PWDLESS#1 - Les bases des smartcards"
description: "Smartcards ou devrais-je dire carte intelligente ?"
tags: ["windows", "activedirectory", "certificats"]
---

## Contexte

### Ancien format

## Les éléments essentiels d'une YubiKey PIV

> Attention : je ne m'intéresse ici qu'à l'utilisation d'une YubiKey pour l'authentification Active Directory. Toutes les spécificités liées à l'utilisation pour faire du FIDO ou du U2F sont donc ignorées dans cet article.

### Le port USB

### Le capteur capacitif

### PIN, PUK et clé de management

#### Code PIN

> The main purpose of the PIN is to authenticate the user for signing and decrypting, although there are other operations that need it as well. The standard specifies that it is a 6- to 8-byte value, each of the bytes an ASCII number ('0' to '9', which in ASCII is 0x30 to 0x39). The YubiKey allows the PIN to be any ASCII character: numbers, letters (upper- and lower-case), and even non-alphanumeric characters such as !, %, or # (among others).

Source : [The PIV PIN, PUK, and management key](https://docs.yubico.com/yesdk/users-manual/application-piv/pin-puk-mgmt-key.html)

En bref : 

- Signification : Personal Identification Number
- Usage : Assure la partie "ce que je sais" de l'authentification, ne doit jamais être communiquer à qui que se soit
- PIN par défaut sur les YubiKey : `123456`
- Longueur : entre 6 et 8 caractères

Au bout de trois tentatives erronées, la YubiKey ne peut plus être utilisée jusqu'au déblocage par code PUK.

Peut contenir n'importe quel caractère ASCII, donc voici des PIN potentiels :
  - `355779` pour la saveur vanille
  - `Bucheron` si vous êtes un peu joueur
  - `ERwACl3r` si vous êtes un(e) dégênéré(e)

> Les accents ne font pas partie du jeu de caractères ASCII, donc le code PIN `Bûcheron` ne marchera pas.

Vous ne pouvez pas installer un certificat de connexion sur une YubiKey qui a encore son code PIN par défaut.

Pour lister tous les caractères ASCII disponibles en PowerShell : 

```powershell
33..126 -as [char[]] | Get-Random -Count 8
```

Et sinon voici un bout de code pour générer un code PIN composé de six chiffres aléatoires :

```powershell
# Version longue
(1..6 | ForEach-Object { Get-Random -Minimum 0 -Maximum 9 }) -join ''
# Version courte
(1..6|%{random -Mi 0 -Ma 9})-join''
```

Changer le code PIN n'impacte pas les certificats installés sur la YubiKey.

#### Code PUK

#### Clé de management

### Les slots pour certificat

### Le minidriver générique

### Les outils de gestion

#### Yubico Authenticator

#### ykman

#### yubico-piv-tools
