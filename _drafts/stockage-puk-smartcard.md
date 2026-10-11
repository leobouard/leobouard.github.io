---
title: ""
description: ""
tags: ["", ""]
---

## Contexte

Si vous avez un Active Directory avec un tiering-model de déployé et que vous devez utiliser un mot de passe différent pour chaque compte, les smartcards sont une solution merveilleuse pour vous simplifier la vie tout en garantissant un top niveau de sécurité. Avec un appareil physique (type YubiKey) et un code PIN, vous pouvez vous connecter avec l'ensemble de vos comptes sans avoir à tapper de mot de passe !

Donc pour résumer, une smartcard c'est :

- un appareil physique
- un code PIN personnel de 6 à 10 caractères pour déverrouiller l'appareil
- un code PUK pour débloquer la clé si besoin

...et si le code PIN est personnel (c'est dans le nom), le code PUK est utile à votre administrateur pour éviter d'avoir à refaire tous vos certificats si jamais vous avez oublié votre PIN (ou si vous avez bloqué votre clé après X mauvais PIN).

Viens alors la réflexion du stockage de ces codes PUK, et pour ça plusieurs options possibles :

- **Si vous êtes le seul administrateur** : un bon vieux KeePass pour stocker ça de manière sécurisé, c'est simple et efficace (mais peu relou et daté)
- **Si vous êtes plusieurs** :
  - Soit vous partez sur la facilité au détriment de la sécurité : un petit fichier Excel des familles, stocké sur SharePoint pour permettre la coédition et éviter d'écraser le travail de quelqu'un d'autre. Si vous faites ça, des identifiants critiques pour votre Active Directory seront accessibles depuis Microsoft 365.
  - Soit vous utilisez une solution de coffre-fort partagé, mais là aussi vous allez stocker des mots de passe qui seront accessibles aux administrateurs du coffre-fort

Il reste une troisième option, qui est de mettre tous ses œufs dans le même panier et de stocker l'information des codes PUK directement dans Active Directory.

### Principal problème



## Modification du schéma

### Prérequis

1. Être membre du groupe "Schema Admins"
2. Pouvoir générer un OID (avec la commande PowerShell ci-dessous par exemple)
3. Pouvoir redémarrer le contrôleur de domaine qui porte le rôle SchemaMaster

{% include name="New-Oid.ps1" id="e797c922cef0553924436149199c8ab4" %}

### Définition des attributs

On va avoir besoin de trois nouveaux attributs dans le schéma :

- `corp-puk` pour stocker le code PUK
- `corp-pukHistory` pour stocker les anciens codes PUK (on ne sait jamais)
- `corp-pukLastSet` pour indiquer la date de définition du dernier code PUK

Les attributs sont préfixés par "CORP" pour éviter une éventuelle collision avec des nouveaux attributs qui pourraient être ajoutés dans le schéma par Microsoft ou un éditeur tier.

Voici les spécifications techniques pour chacun :

#### corp-puk

*Ajouter une description pour expliquer les choix de designs*

Attribut | Valeur
-------- | ------
name | corp-puk
objectClass | attributeSchema
adminDescription | Contains the current personal unlocking key (PUK)
attributeSyntax | 2.5.5.10 (Octet String)
isSingleValued | True
omSyntax | 4 (Octet String)
searchFlags | 128 (Confidential)

#### corp-pukHistory

*Ajouter une description pour expliquer les choix de designs*

Attribut | Valeur
-------- | ------
name | corp-puk
objectClass | attributeSchema
adminDescription | Contains all the old PUK values
attributeSyntax | 2.5.5.10 (Octet String)
isSingleValued | False
omSyntax | 4 (Octet String)
searchFlags | 128 (Confidential)

#### corp-pukLastSet

*Ajouter une description pour expliquer les choix de designs*

Attribut | Valeur
-------- | ------
name | corp-puk
objectClass | attributeSchema
adminDescription | Contains the last time the PUK was set
attributeSyntax | 2.5.5.11 (DateTime)
isSingleValued | True
omSyntax | 24 (DateTime)
searchFlags | 0 (Not indexed)

> Vous pouvez retrouver le tableau officiel de Microsoft pour obtenir les valeurs attendues pour `attributeSyntax` et `omSyntax` ici : [LDAP Representations \| Microsoft Learn](https://learn.microsoft.com/en-us/openspecs/windows_protocols/ms-adts/7cda533e-d7a4-4aec-a517-91d02ff4a1aa).

### Création des attributs

Voici la commande pour l'attribut `corp-puk`, que vous pouvez recycler en mettant à jour les différentes valeurs indiquées dans les spécifications :

```powershell
$name = 'corp-puk'
$splat = @{
    Name = $name
    Type = 'attributeSchema'
    OtherAttributes = @{
        AdminDescription = 'Contains the current personal unlocking key (PUK)'
        AdminDisplayName = $name
        AttributeSyntax  = '2.5.5.10'
        IsSingleValued   = $true
        LDAPDisplayName  = $name
        OMSyntax         = 4
        SearchFlags      = 128
        AttributeID      = (New-Oid)
    }
    Path = (Get-ADRootDSE).schemaNamingContext
}
New-ADObject @splat
```

### Définition de la classe

Il faut maintenant passer aux spécifications de la classe qui a héberger nos nouveaux attributs :

Attribut | Valeur
-------- | ------
name | corp-smartCard
objectClass | classSchema

*tableau à mettre à jour*

### Création de la classe

> Ça n'aura pas été aussi facile que prévu puisqu'il n'y a que très peu de documentation sur le sujet, mais les attributs "MayContain" et "MustContain" ne reçoivent que les OID des attributs cibles (si jamais ça peut vous aider).

```powershell
$name = 'corp-smartCard'
$schemaPath = (Get-ADRootDSE).schemaNamingContext
$mustContain = Get-ADObject -Filter { Name -eq 'corp-puk' } -SearchBase $schemaPath -Properties AttributeID
$mayContain = 'serialNumber', 'corp-pukHistory', 'corp-pukLastSet' | ForEach-Object {
    Get-ADObject -Filter { Name -eq $_ } -SearchBase $schemaPath -Properties AttributeID
}
$splat = @{
    Name = $name
    Type = 'classSchema'
    OtherAttributes = @{
        AdminDisplayName       = $name
        AdminDescription       = 'Device that can be used to authenticate'
        DefaultHidingValue     = $true
        GovernsID              = (New-OID)
        LDAPDisplayName        = $name
        MayContain             = $mayContain.AttributeID # serialNumber, corp-pukHistory, corp-pukLastSet
        MustContain            = $mustContain.AttributeID
        ObjectClassCategory    = 1 # Structural
        PossSuperiors          = 'user', 'inetOrgPerson'
        ShowInAdvancedViewOnly = $true
        SystemOnly             = $false
        SubClassOf             = '2.5.6.0' # top
    }
    Path = (Get-ADRootDSE).schemaNamingContext
}
New-ADObject @splat
```

1. Création du groupe "SmartCard PUK Administrators"
2. Chiffrement via DpapiNg du code PUK
3. Création d'une nouvelle smartcard sous l'utilisateur John Smith
4. Déchiffrer via DpapiNg
5. Pour aller plus loin : la délégation pour le flag 128

### Création du module

```powershell
# Fonctions privées

Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class DpapiNg {
    [DllImport("ncrypt.dll")]
    static extern int NCryptCreateProtectionDescriptor(
        [MarshalAs(UnmanagedType.LPWStr)] string rule, uint flags, out IntPtr desc);

    [DllImport("ncrypt.dll")]
    static extern int NCryptProtectSecret(
        IntPtr desc, uint flags, byte[] data, uint cbData,
        IntPtr alloc, IntPtr hwnd, out IntPtr blob, out uint cbBlob);

    [DllImport("ncrypt.dll")]
    static extern int NCryptUnprotectSecret(
        IntPtr desc, uint flags, byte[] blob, uint cbBlob,
        IntPtr alloc, IntPtr hwnd, out IntPtr data, out uint cbData);

    [DllImport("ncrypt.dll")]
    static extern int NCryptCloseProtectionDescriptor(IntPtr desc);

    [DllImport("kernel32.dll")]
    static extern IntPtr LocalFree(IntPtr p);

    public static byte[] Protect(string rule, byte[] data) {
        IntPtr d; int r = NCryptCreateProtectionDescriptor(rule, 0, out d);
        if (r != 0) throw new Exception("Descriptor: 0x" + r.ToString("X"));
        try {
            IntPtr p; uint n;
            r = NCryptProtectSecret(d, 0, data, (uint)data.Length, IntPtr.Zero, IntPtr.Zero, out p, out n);
            if (r != 0) throw new Exception("Protect: 0x" + r.ToString("X"));
            byte[] o = new byte[n]; Marshal.Copy(p, o, 0, (int)n); LocalFree(p); return o;
        } finally { NCryptCloseProtectionDescriptor(d); }
    }

    public static byte[] Unprotect(byte[] blob) {
        IntPtr p; uint n;
        int r = NCryptUnprotectSecret(IntPtr.Zero, 0, blob, (uint)blob.Length, IntPtr.Zero, IntPtr.Zero, out p, out n);
        if (r != 0) throw new Exception("Unprotect: 0x" + r.ToString("X"));
        byte[] o = new byte[n]; Marshal.Copy(p, o, 0, (int)n); LocalFree(p); return o;
    }
}
'@

function ConvertFrom-SecureStringAsPlainText {
    param([Parameter(Mandatory, ValueFromPipeline)][SecureString]$InputObject)

    [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($InputObject))
}

function ConvertTo-DpapiNg {
    param(
        [Parameter(Mandatory, ValueFromPipeline)][SecureString]$InputObject,
        [string]$Owner = 'SmartCard PUK Administrators'
    )

    $string = $InputObject | ConvertFrom-SecureStringAsPlainText
    $descriptor = "SID=$((Get-ADGroup $Owner -Properties objectSid).objectSid.value)"
    [DpapiNg]::Protect($descriptor, [Text.Encoding]::UTF8.GetBytes($string))
}

function ConvertFrom-DpapiNg {
    param([Parameter(Mandatory, ValueFromPipeline)][System.Object[]]$InputObject)

    [Text.Encoding]::UTF8.GetString([DpapiNg]::Unprotect($InputObject))
}

# Fonctions publiques

function New-ADSmartCard {
    param(
        [Parameter(Mandatory)][String]$Name,
        [Parameter(Mandatory, ValueFromPipeline)][Microsoft.ActiveDirectory.Management.ADUser]$User,
        [Parameter(Mandatory)][SecureString]$PUK
    )

    [byte[]]$pukBytes = ConvertTo-DpapiNg $PUK
    $splat = @{
        Name = $Name
        Path = $User.DistinguishedName
        Type = 'corp-smartCard007'
        OtherAttributes = @{
            'corppuk' = $pukBytes
            'corppukLastSet' = Get-Date
        }
    }
    New-ADObject @splat
}

function Get-ADSmartCard {
    param(
        [Parameter(Mandatory, ValueFromPipeline)][Microsoft.ActiveDirectory.Management.ADUser]$User,
        [switch]$AsPlainText
    )

    $smartCards = Get-ADObject -Filter { ObjectClass -eq 'corp-smartCard007' } -Properties * -SearchBase $User.DistinguishedName -SearchScope OneLevel

    $smartCards | Select-Object DistinguishedName, Name, ObjectClass, ObjectGUID, 
        @{ Name = 'PUK' ; Expression = { ConvertFrom-DpapiNg $_.corpPuk } },
        @{ Name = 'PUKHistory' ; Expression = { $_.corpPukHistory | ForEach-Object { ConvertFrom-DpapiNg $_ } } },
        @{ Name = 'PUKLastSet' ; Expression = { $_.corpPukLastSet[0] } }
}

function Set-CORPSmartCard {

}

function Remove-CORPSmartCard {

}
```