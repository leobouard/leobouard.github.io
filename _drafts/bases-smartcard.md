---
title: "Vos codes PIN puent la m**** !"
description: "Donne moi ta date de naissance et je te donnerai ton code PIN"
tags: ["windows", "smartcard"]
---

## Les codes PIN sur Windows

On peut retrouver des codes PIN un peu partout sous Windows : avec Windows Hello, pour le chiffrement BitLocker ou encore avec des smart cards comme les YubiKey.

Et la plupart du temps, lorsqu'on nous demande de définir un code PIN, on pense immédiatement à un truc comme ça :

22052026

*C'est la date de naissance de mon fils si vous vous demandez*

Pourtant, ce code PIN : il pue la m*****.

### Pourquoi on pense à un code PIN avec des chiffres

Pendant longtemps, un code PIN allait être tapé sur un clavier à 10 touches, comme un téléphone ou terminal de paiement. Du coup les limites techniques imposaient logiquement un code uniquement composés de chiffres.

### Pourquoi c'est mieux d'utiliser un mot

Le truc c'est qu'en 2026 et sur un ordinateur, il n'y a pas de raison de se limiter à 10 caractères pour votre code PIN. Et comme on a pas besoin du 

- Permet d'utiliser la majorité des touches de votre clavier
- Garde une cohérence sur votre mémoire musculaire entre tous les claviers (pas de différence entre un clavier de téléphone ou un clavier pleine-taille avec pavé numérique)
- Aussi (si ce n'est plus) rapide à tapper
- Beaucoup plus facile à retenir qu'une suite de chiffres aléatoire
- Si vous vous débrouillez bien, un mot peut être compatible en AZERTY et QWERTY

### 

Et qu'est-ce qui fait 6 ou 8 chiffres et qui est facilement mémorisable ? Dans le lot on va retrouver :

- votre date de naissance
- votre code postal avec un numéro bonus à la fin
- votre code de carte bancaire
- un motif de pavé numérique
- une suite de chiffre logiques (11223344 par exemple)

Et toutes ces propositions ont un niveau de sécurité relatif.

## Générateur de code PIN

## Contraintes techniques

### Windows Hello

### BitLocker

### YubiKey

> The main purpose of the PIN is to authenticate the user for signing and decrypting, although there are other operations that need it as well. The standard specifies that it is a 6- to 8-byte value, each of the bytes an ASCII number ('0' to '9', which in ASCII is 0x30 to 0x39). The YubiKey allows the PIN to be any ASCII character: numbers, letters (upper- and lower-case), and even non-alphanumeric characters such as !, %, or # (among others).

Source : [The PIV PIN, PUK, and management key](https://docs.yubico.com/yesdk/users-manual/application-piv/pin-puk-mgmt-key.html)

> Les accents ne font pas partie du jeu de caractères ASCII, donc le code PIN `Bûcheron` ne marchera pas.

Pour lister tous les caractères ASCII disponibles en PowerShell :

```powershell
33..126 -as [char[]] | Get-Random -Count 8
```
