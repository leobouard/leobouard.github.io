---
title: "Comment détruire votre Active Directory"
description: "Votre forêt s'auto-détruira dans 3, 2, 1..."
tags: activedirectory
listed: true
---

## Un objet dynamique dans le schéma

### En quoi est-ce dangereux ?

Le schéma Active Directory défini la structure des classes (les types d'objets) et leurs attributs (name, surname, streetAddress...). Il ne peut être qu'étendu et chaque objet ajouté ne pourra plus jamais être supprimé.

Ajouter un objet dynamique (qui se supprimera automatiquement) dans le schéma Active Directory (où rien ne peut être supprimé) donne donc la recette parfaite pour corrompre un domaine.

Mieux encore : un objet dynamique dans le schéma est une véritable bombe à retardement qui peut exploser jusqu'à un an après avoir été amorcée. Et une fois la bombe posée, si vous n'avez pas de sauvegarde antérieure à la création de la bombe, il sera impossible de s'en débarrasser.

## Pistes de recherches

Avant toute chose : il faut évidemment s'ajouter dans le groupe "Schema Admins".

```powershell
Add-ADGroupMember 'Schema Admins' -Members 'Administrator'
```

### Création directe dans le schéma

Pour créer un objet dans le schéma (un attribut ou une classe), il va falloir générer un OID. Voici une fonction pour en générer un :

```powershell
function New-Oid {
    param([string]$Prefix = '1.2.840.113556.1.8000.2554')

    $guid = [string]([System.Guid]::NewGuid())
    $oid = 0, 4, 9, 14, 19, 24, 30 | ForEach-Object {
        if ($_ -ge 24) { $l = 6 } else { $l = 4 }
        [UInt64]::Parse($guid.SubString($_, $l), 'AllowHexSpecifier')
    }
    $prefix + ($oid -join '.')
}
```

En essayant directement de créer un objet dynamique de type "attribut" dans le schéma, on tombe directement sur l'erreur suivante : *"The server is unwilling to process the request"*.

```powershell
# Création de l'attribut "timebomb" dans la partition Schéma
$dynamicObject = ([ADSI]("LDAP://CN=Schema,CN=Configuration,DC=contoso,DC=com")).Create('attributeSchema', 'CN=timebomb')
$dynamicObject.PutEx(2, 'objectClass', @('dynamicObject', 'attributeSchema'))
$dynamicObject.Put('entryTTL', 900)
$dynamicObject.Put('lDAPDisplayName', 'timebomb')
$dynamicObject.Put('adminDescription', 'This attribute will blow up the entire Active Directory forest in 15 minutes')
$dynamicObject.Put('attributeId', (New-Oid))
$dynamicObject.Put('oMSyntax', 1)
$dynamicObject.Put('attributeSyntax', '2.5.5.8')
$dynamicObject.Put('searchflags', 0)
$dynamicObject.Put('systemFlags', 536870912)
$dynamicObject.SetInfo()
```

Et si on essaye de créer un attribut ou une classe en dehors de la partition dédiée, on tombe sur une autre erreur : *"There is a naming violation"*.

C'est lié au fait que la classe "attributeSchema" que l'on essaye de créer n'a comme parent possible (*possible superior*) que la classe "dMD" qui correspond au schéma Active Directory. Si l'on essaye de modifier ça dans la console "Active Directory Schema", on obtient l'erreur suivante : *The change was rejected by the schema master server*.

### Création puis déplacement dans le schéma

Comme on ne peut pas modifier la classe "attributeSchema", on va plutôt modifier la classe "user" pour ajouter "dMD" (le schéma) comme parent possible. Cette opération n'est pas bloquée et nous permet donc de tester la création d'un utilisateur dynamique dans la partition par défaut (contoso.com/Users) puis essayer le déplacement dans le schéma :

```powershell
# Création de l'utilisateur "timebomb" dans le container par défaut
$dynamicObject = ([ADSI]("LDAP://CN=Users,DC=contoso,DC=com")).Create('user', 'CN=timebomb')
$dynamicObject.PutEx(2, 'objectClass', @('dynamicObject', 'user'))
$dynamicObject.Put('entryTTL', 900)
$dynamicObject.Put('samAccountName', 'timebomb')
$dynamicObject.SetInfo()

# Déplacement dans le schéma
$dn = (Get-ADUser timebomb).DistinguishedName
Move-ADObject $dn -TargetPath 'CN=Schema,CN=Configuration,DC=contoso,DC=com'
```

On tombe alors sur l'erreur suivante : *Illegal modify operation. Some aspect of the modification is not permitted*.

> À noter : sans la modification de la classe `user` dans le schéma, nous aurions obtenu l'erreur *The object cannot be added because the parent is not on the list of possible superiors*.

### Création d'une classe personnalisée



## Détection de la création d'objet dynamique

```powershell
$filterXPath = "Event[System[EventID=5136]] and *[EventData[Data[@Name='AttributeValue']='1.3.6.1.4.1.1466.101.119.2']]"
Get-WinEvent -ProviderName Microsoft-Windows-Security-Auditing -FilterXPath $filterXPath
```

[AD Object Detection: Detecting the undetectable (dynamicObject) \| Microsoft Learn](https://learn.microsoft.com/en-us/archive/blogs/pfesweplat/ad-object-detection-detecting-the-undetectable-dynamicobject)