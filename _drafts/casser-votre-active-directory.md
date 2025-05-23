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

Mieux encore : un objet dynamique dans le schéma est une véritable bombe à retardement qui peut exploser jusqu'à un an après avoir été amorcée. Et une fois la bombe posée, si vous n'avez pas de sauvegarde antérieure à la création de la bombe, il sera impossible de s'en débarasser.

### Création de l'objet

Toute la sécurité liée aux objets dynamique est faite à la création de l'objet. Si vous essayez de le créer directement dans le schéma, vous allez obtenir l'erreur suivante : *"The server is unwilling to process the request"*

```powershell
# Création de l'attribut "timebomb" dans la partition Schéma
$dynamicObject = ([ADSI]("LDAP://CN=Schema,DC=Configuration,DC=contoso,DC=com")).Create('attributeSchema', 'CN=timebomb')
$dynamicObject.PutEx(2, 'objectClass', @('dynamicObject', 'attributeSchema'))
# $dynamicObject.Put('entryTTL', 900)
$dynamicObject.Put('lDAPDisplayName', 'timebomb')
$dynamicObject.Put('adminDescription', 'This attribute will blow up the entire Active Directory forest in 15 minutes')
$dynamicObject.Put('attributeId', (New-Oid))
$dynamicObject.Put('oMSyntax', 1)
$dynamicObject.Put('attributeSyntax', '2.5.5.8')
$dynamicObject.Put('searchflags', 0)
$dynamicObject.Put('systemFlags', 536870912)
$dynamicObject.SetInfo()
```

Et si on essaye de créer un attribut ou une classe en dehors de la partition dédiée, on tombe sur une autre erreur : *"There is a naming violation"*

## Détection de la création d'objet dynamique

```powershell
$filterXPath = "Event[System[EventID=5136]] and *[EventData[Data[@Name='AttributeValue']='1.3.6.1.4.1.1466.101.119.2']]"
Get-WinEvent -ProviderName Microsoft-Windows-Security-Auditing -FilterXPath $filterXPath
```

[AD Object Detection: Detecting the undetectable (dynamicObject) \| Microsoft Learn](https://learn.microsoft.com/en-us/archive/blogs/pfesweplat/ad-object-detection-detecting-the-undetectable-dynamicobject)