---
title: ""
description: ""
tags: ["", ""]
---

## Contexte

Si vous avez un Active Directory avec un tiering-model de déployé et que vous devez utiliser un mot de passe différent pour chaque compte, les smart cards sont une solution merveilleuse pour vous simplifier la vie. Grâce à elles, vous pouvez vous connecter avec l'ensemble de vos comptes sans avoir à tapper de mot de passe : un code PIN suffit !

Pour résumer, une smart card c'est :

- un appareil physique (type [Yubikey 5C NFC FIPS](https://www.amazon.fr/Yubico-Y-335-YubiKey-5C-NFC/dp/B08DHL1YDL) par exemple) qui va stocker votre certificat de connexion utilisateur
- un code PIN personnel de 6 à 10 caractères pour déverrouiller l'appareil
- un code PUK pour débloquer la clé si besoin

...et si le code PIN est personnel (*c'est le "P" dans "PIN"*), le code PUK est utile à votre administrateur pour éviter d'avoir à refaire tous vos certificats si jamais vous avez oublié votre PIN (ou que vous avez bloqué votre clé après plusieurs mauvais codes PIN).

Viens alors la réflexion du stockage de ces codes PUK, et pour ça plusieurs options possibles :

- Un fichier KeePass2 au format KBDX pour stocker ça de manière simple et sécurisée
- Un espace partagé sur votre gestionnaire de mot de passe préféré (Bitwarden ❤️)
- Un vieux fichier Excel sur SharePoint si jamais vous n'en avez rien à faire de la sécurité

### Principal problème

Toutes ces options ont un inconvénient majeur : elles ne suivent pas le cycle de vie des utilisateurs Active Directory. Au fil des départs et arrivées, des changements de noms et d'équipe, vous allez finir par vous y perdre. Impossible d'identifier rapidement les utilisateurs qui n'ont pas de code PUK, ou ceux qui ont quitté l'entreprise depuis déjà plusieurs années.

L'idée de cet article est donc de proposer autre chose : une méthode purement expérimentale qui va lier directement l'utilisateur à sa smart card dans Active Directory ; sans pour autant que le code PUK soit accessible à tous.

![There is another](https://i.redd.it/lyd5md4v3q351.jpg)

### Ma solution (expérimentale)

Le principe s'inspire très largement du travail que Microsoft a déjà effectué pour la gestion des clés BitLocker sur les comptes ordinateurs, ainsi que mots de passe LAPS et ceux des comptes gMSA. On va **créer une nouvelle classe d'objet** représentant nos smart cards dans notre schéma Active Directory (vous comprenez maintenant le côté *expérimental*). Ces nouveaux objets "smart cards" viendrait se greffer comme un objet enfant des comptes utilisateurs existant, pour se lier durablement à eux sans être impactés par un déplacement ou un renommage de l'objet parent.

Pour accompagner cette nouvelle classe, on vient également ajouter trois nouveaux attributs :

- Un pour stocker le **code PUK actuel**
- Un pour stocker **l'historique des anciens codes PUK**
- Un dernier pour indiquer **la date de définition du code PUK actuel**

Les codes PUK ne doivent évidemment être accessibles uniquement par le personnel autorisé. Pour ça on part sur ceinture-bretelles avec :

- **des attributs déclarés comme confidentiels** : leur valeur ne peut être consulter que par les utilisateurs ayant un droit d'accès explicite sur l'objet parent ou l'attribut
- **un chiffrement des données via DPAPI-NG** : le mécanisme de chiffrement natif depuis Windows 8 & Windows Server 2012, qui va permettre de déchiffrer le code PUK très simplement pour tous les membres d'un groupe Active Directory

## Modification du schéma

> Petit rappel, mais modifier son schéma sans savoir ce que l'on fait n'est clairement pas une bonne idée. Ne faites évidemment pas ça sur votre production. Chaque changement fait à votre schéma est indélébile et peut impacter la stabilité de votre domaine Active Directory.

### Prérequis

Pour pouvoir modifier le schéma, créer notre classe et nos nouveaux attributs, il va falloir :

1. Être membre du groupe "Schema Admins"
2. Pouvoir générer un OID (avec la commande PowerShell ci-dessous par exemple)
3. Pouvoir redémarrer le contrôleur de domaine qui porte le rôle SchemaMaster si besoin

{% include name="New-Oid.ps1" id="e797c922cef0553924436149199c8ab4" %}

### Définition des attributs

On va avoir besoin de trois nouveaux attributs dans le schéma :

- `corp-puk`
- `corp-pukHistory`
- `corp-pukLastSet`

Les attributs sont préfixés par "CORP" pour éviter une éventuelle collision avec des nouveaux attributs qui pourraient être ajoutés dans le schéma par Microsoft ou un éditeur tier.

Voici les spécifications techniques pour chacun :

#### corp-puk

`corp-puk` va être une chaîne d'octet confidentielle :

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

Tout comme `corp-puk`, `corp-pukHistory` sera une chaîne d'octet confidentielle mais multi-valeur :

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

Ici pas besoin de déclarer l'attribut comme confidentiel, on défini simplement le bon format pour avoir une belle date bien propre (comme l'attribut `accountExpirationDate` par exemple) :

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

> N'oubliez pas, une seule erreur et celle-ci sera visible à jamais dans votre schéma.

### Définition de la classe

Il faut maintenant passer aux spécifications de la classe qui va héberger nos nouveaux attributs :

Attribut | Valeur
-------- | ------
name | corp-smartCard
objectClass | classSchema
adminDescription | Device that can be used to authenticate
defaultHidingValue | True
mayContain | `serialNumber`, `corp-pukHistory`, `corp-pukLastSet`
mustContain | `corp-puk`
objectClassCategory | 1 (STRUCTURAL)
possSuperior | user, inetOrgPerson
showInAdvancedViewOnly | True
systemOnly | False
subClassOf | 2.5.6.0 (top)

### Création de la classe

Voici la dernière étape pour la modification du schéma : la création de notre nouvelle classe d'objet `corp-smartCard` qui va utiliser les attributs créés précédemment.

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
        MayContain             = $mayContain.AttributeID
        MustContain            = $mustContain.AttributeID
        ObjectClassCategory    = 1
        PossSuperiors          = 'user', 'inetOrgPerson'
        ShowInAdvancedViewOnly = $true
        SystemOnly             = $false
        SubClassOf             = '2.5.6.0'
    }
    Path = (Get-ADRootDSE).schemaNamingContext
}
New-ADObject @splat
```

> Ça n'aura pas été aussi facile que prévu puisqu'il n'y a que très peu de documentation sur le sujet, mais sachez que les attributs "MayContain" et "MustContain" ne reçoivent que les OID des attributs cibles (si jamais ça peut vous aider).

## Exploitation de la nouvelle classe et des nouveaux attributs

### Création du groupe d'accès au PUK

Je l'ai caché dans mon module, et celui-ci devrait être plus visible mais les codes PUK ne sont déchiffrables que par les membres du groupe "SmartCard PUK Administrators". Il convient donc de créer ce groupe dans Active Directory :

```powershell
New-ADGroup -Name 'SmartCard PUK Administrators' -GroupScope Global -GroupCategory Security
```

Si vous voulez pouvez déchiffrer les codes PUK, vous aurez besoin d'être membre du groupe.

### Délégation d'accès sur les attributs confidentiels

Vous vous souvenez de l'explication sur les attributs qui ne pouvaient être lu que par les comptes autorisés ? Et bien comme le groupe "Domain Admins" possède déjà ces permissions ; je m'en accommode très bien. Si vous souhaitez mettre en place une délégation, voici ce que [Claude](https://claude.ai/) m'a proposé (je n'ai pas testé) :

```powershell
$path  = "OU=Utilisateurs,DC=corp,DC=contoso,DC="
$group = "CORP\SmartCard PUK Administrators"
$attr  = "corp-puk"

# 1. Lecture de l'attribut
dsacls $path /I:S /G "${group}:RP;$attr;corp-smartCard"

# 2. Control Access (requis pour les attributs confidentiels)
dsacls $path /I:S /G "${group}:CA;;corp-smartCard"
```

> Avant de mettre en place cette délégation, souvenez-vous qu'une seule smart card peut permettre d'utiliser plusieurs comptes, donc n'allez pas faire une délégation qui pourrait ouvrir un nouveau chemin d'attaque vers les membres du groupe "Domain Admins".

### Utilisation du module

Une fois notre schéma ~~cassé~~ modifié, on peut passer à l'exploitation de nos nouveaux jouets ! Pour ça, j'ai créé un module PowerShell assez simple qui permet d'interagir avec nos smart cards :

{% include name="PUKManagement.psm1" id="185f2b6e5cadbb1827b1609138463eb2" %}

Celui-ci est composé de quelques commandes utiles :

- `New-ADSmartCard` pour créer une nouvelle smart card
- `Get-ADSmartCard` pour lister les smart cards et obtenir leur code PUK
- `Set-ADSmartCard` pour modifier une smart card
- `Remove-ADSmartCard` pour supprimer évidemment

### Création d'une nouvelle smart card

Création d'une nouvelle smart card pour l'utilisateur "John Smith", sans jamais saisir le code PUK en clair dans la console :

```powershell
New-ADSmartCard -Name '28293929' -User (Get-ADUser john.smith)
```

Comme le code PUK est obligatoire, il sera automatiquement récupéré via un prompt supplémentaire au format SecureString.

> Ici j'ai indiqué le numéro de série (SerialNumber) de la smart card dans la valeur du paramètre "Name". A mon humble avis, c'est le meilleur choix à faire.

### Récupération des informations d'une ou plusieurs smart cards

Obtenir toutes les smart cards du domaine :

```powershell
Get-ADSmartCard -Filter *
```

Obtenir toutes les smart cards d'un utilisateur :

```powershell
Get-ADUser john.smith | Get-ADSmartCard
```

Obtenir le code PUK en clair de la smart card "28293929" :

```powershell
Get-ADSmartCard 28293929 -AsPlainText
```

### Mise à jour d'un code PUK

```powershell
Get-ADSmartCard 28293929 |
Set-ADSmartCard -PUK (Read-Host -AsSecureString -Prompt 'New PUK')
```

### Suppression d'une smart card

Et pour finir, la commande `Remove-ADSmartCard` :

```powershell
Get-ADSmartCard 28293929 | Remove-ADSmartCard
```
