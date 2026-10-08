---
title: ""
description: ""
tags: ["", ""]
---

## Contexte

Si vous avez un Active Directory avec un tiering-model de déployé et que vous devez utiliser un mot de passe différent pour chaque compte, les smartcards sont une solution merveilleuse pour vous simplifier la vie tout en garantissant un top niveau de sécurité.

Une smartcard c'est :

- un appareil physique (type YubiKey)
- un code PIN personnel de 6 à 10 caractères pour déverrouiller l'appareil
- un code PUK pour débloquer la clé si besoin

...et si le code PIN est personnel (c'est dans le nom), le code PUK est utile à votre administrateur pour éviter d'avoir à refaire tous vos certificats si jamais vous avez oublié votre PIN (ou si vous avez bloqué votre clé après X mauvais PIN).

Viens alors la réflexion du stockage de ces codes PUK, et pour ça plusieurs options possibles :

- **Si vous êtes le seul administrateur** : un bon vieux KeePass pour stocker ça de manière sécurisé, c'est simple et efficace (mais peu relou et daté)
- **Si vous êtes plusieurs** : 
  - Soit vous partez sur la facilité au détriment de la sécurité : un petit fichier Excel des familles, stocké sur SharePoint pour permettre la coédition et éviter d'écraser le travail de quelqu'un d'autre
  - Soit vous utilisez une solution de coffre-fort partagé, mais là aussi vous

## Mise en place

### Création des attributs

On va créer trois attributs :

- `corp-puk` pour stocker le code PUK
- `corp-pukHistory` pour stocker les anciens codes PUK (on sait jamais)
- `corp-pukLastSet` pour indiquer la date de définition du dernier code PUK

Les attributs sont préfixés par "CORP" pour éviter une éventuelle collision avec des nouveaux attributs qui pourraient être ajoutés dans le schéma par Microsoft ou un éditeur tier.

Voici les spécifications pour chaque attribut :

Attribut | `corp-puk` | `corp-pukHistory` | `corp-pukLastSet`
-------- | ---------- | ----------------- | ----------------
type | Octet String | Octet String | DateTime
multiple-value | No | Yes | No
searchFlags | 128 | 128 | 0

### Création de la classe

On va créer la classe d'objet `corp-SmartCard` avec les propriétés suivantes :

```powershell
$splat = @{
    adminDescription       = 'SmartCard attached to a user'
    adminDisplayName       = 'corp-SmartCard'
    defaultHidingValue     = $true
    governsID              = (New-OID)
    lDAPDisplayName        = 'corpSmartCard'
    mayContain             = 'corp-pukHistory', 'corp-pukLastSet', 'serialNumber'
    mustContain            = 'corp-puk'
    possSuperiors          = 'user', 'inetOrgPerson'
    showInAdvancedViewOnly = $true
    subClassOf             = 'top'
    path                   = (Get-ADRootDSE).schemaNamingContext
    type                   = 'classSchema'
}
New-ADObject @splat
```

