---
title: "Vous méritez de meilleurs codes PIN !"
description: "Donne moi ta date de naissance et je te donnerai ton code PIN"
tags: ["windows", "smartcard"]
---

## Dictionnaire de mots

Sur ordinateur, l'utilisation d'un mot comme code PIN est beaucoup plus efficace qu'une suite de chiffres. Voici quelques propositions pour vous aider à trouver le vôtre :

{% include pin-generator.html %}

## Les codes PIN sur Windows

On peut retrouver des codes PIN un peu partout sous Windows : avec Windows Hello, pour le chiffrement BitLocker ou encore avec des smart cards comme les YubiKey.

Et la plupart du temps, lorsqu'on nous demande de définir un code PIN, on pense immédiatement à un truc comme ça :

<div style="margin: 1em auto;width: fit-content;font-size: 1.25em;font-family: var(--codefont);display: flex;grid-gap: 0.25em;">
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">2</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">2</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">0</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">5</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">2</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">0</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">2</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">6</span>
</div>

<i style="margin: auto; display: block; width: fit-content;">Est-ce que vous la voyez la belle date de naissance ?</i>

### Pourquoi est-ce que l'on pense à un code PIN avec des chiffres ?

Bon le "N" dans PIN c'est "Number", mais passons.

Pendant longtemps, un code PIN était tapé sur un clavier à 10 touches (comme un téléphone T9 ou un terminal de paiement). Du coup les limites techniques imposaient un code uniquement composés de chiffres.

### Pourquoi est-ce mieux d'utiliser un mot ?

Le truc c'est qu'aujourd'hui et sur un ordinateur, il n'y a pas de raison de se limiter à une sélection 10 caractères pour votre code PIN. Vous avez un clavier complet à votre disposition, et aucune interdiction de mettre autre chose que des chiffres ! Les codes PIN avec des lettres sont supportés sur :

- Windows Hello
- BitLocker
- YubiKey (sauf les accents)

Donc au lieu de penser à une date de naissance, pensez plutôt à un truc comme ça :

<div style="margin: 1em auto;width: fit-content;font-size: 1.25em;font-family: var(--codefont);display: flex;grid-gap: 0.25em;">
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">F</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">e</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">s</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">t</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">i</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">v</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">a</span>
  <span style="border: 1px solid var(--mediumaccent);padding: 0.5em;border-radius: var(--borderradius);">l</span>
</div>

Un code PIN qui prend la forme d'un mot :

- Est souvent **plus rapide à tapper** sur des claviers sans pavé numérique
- Peut être **compatible en AZERTY et QWERTY** si vous excluez quelques lettres (A, Z, Q, W et M)
- Est beaucoup **plus facile à mémoriser** qu'une suite de chiffres aléatoire

### En terme de sécurité

Un code PIN c'est trois essais maximum et ça nécessite un accès physique à l'appareil. A moins que vous mettiez votre prénom (ce qui est du même niveau que mettre votre date de naissance), ça devrait aller.

Si on compare avec un code PIN classique composé de nombres, on retrouve souvent les mêmes paternes : date de naissance, code postal, répétition de chiffres...

Donc on va dire égalité entre les deux options.

## Contraintes techniques

### Windows Hello

> **Lowercase letters in PIN, Uppercase letters in PIN, and Special characters in PIN.**
>
> You can enforce a stronger PIN by requiring the use of uppercase letters, lowercase letters, and special characters in the PIN.
> [...]
> Not allowed (default): Users must not use these character types in their PIN. (This is also the behavior if the setting isn't configured.). Special characters include: `! " # $ % & ' ( ) * + , - . / : ; < = > ? @ [ \ ] ^ _ { | } ~`

Source : [Configure Windows Hello for Business on devices when they enroll with Intune](https://learn.microsoft.com/intune/device-security/identity-protection/configure-tenant-wide-policy)

### BitLocker

> Enhanced startup PINs permit the use of characters including uppercase and lowercase letters, symbols, numbers, and spaces. This policy setting is applied when you turn on BitLocker.

Source : [Allow enhanced PINs for startup](https://learn.microsoft.com/previous-versions/windows/it-pro/windows-7/ee706521(v=ws.10)#allow-enhanced-pins-for-startup)

### YubiKey

> The main purpose of the PIN is to authenticate the user for signing and decrypting, although there are other operations that need it as well. The standard specifies that it is a 6- to 8-byte value, each of the bytes an ASCII number ('0' to '9', which in ASCII is 0x30 to 0x39). The YubiKey allows the PIN to be any ASCII character: numbers, letters (upper- and lower-case), and even non-alphanumeric characters such as !, %, or # (among others).

Source : [The PIV PIN, PUK, and management key](https://docs.yubico.com/yesdk/users-manual/application-piv/pin-puk-mgmt-key.html)

Les accents ne font pas partie du jeu de caractères ASCII, donc le code PIN `Bûcheron` ne marchera pas.

Pour lister tous les caractères ASCII disponibles en PowerShell :

```powershell
(33..126 -as [char[]]) -join ' '
```
