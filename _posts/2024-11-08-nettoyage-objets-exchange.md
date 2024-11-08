---
title: "Nettoyer les derniers objets Exchange"
description: "Comment nettoyer son domaine Active Directory après la suppression de votre dernier serveur Exchange ?"
tags: active-directory
listed: true
---

## Contexte

Exchange étant très lié à Active Directory, celui-ci génère beaucoup d'objets et de valeur d'attributs lors de son installation. Si votre dernier serveur Exchange a été supprimé et que vous n'avez pas pour objectif d'en réinstaller un nouveau, voici comment faire le ménage dans les objets Exchange devenus caduques.

Je vous invite à parcourir ma principale source pour cet article : [How to remove Exchange from Active Directory - ALI TAJRAN](https://www.alitajran.com/how-to-remove-exchange-from-active-directory/).

Dans cet article je ne parle pas du nettoyage des enregistrements DNS. Pour cette partie, veuillez consulter l'article d'Ali Tajran.

## Remédiation

### Prérequis

Avant de commencer, vous devez ajouter votre compte aux administrateurs de l'entreprise :

```powershell
$SID = "$((Get-ADDomain).DomainSID)-519"
Get-ADGroup $SID | Add-ADGroupMember -Members $env:USERNAME
```

### Modification ADSI

Lancer `adsiedit.exe` et se connecter à la configuration du schéma. Se déplacer au chemin "CN=Services,CN=Configuration,DC=contoso,DC=com" et supprimer les objets suivants :

- CN=Microsoft Exchange
- CN=Microsoft Exchange Autodiscover

### Suppression des objets Exchange

Les groupes Exchange sont stockés dans l'OU "contoso.com/Microsoft Exchange Security Groups" et portent de nombreuses permissions sur la racine du domaine. Avant de supprimer ces groupes, il convient de vérifier que ceux-ci sont bien vide :

```powershell
Get-ADGroup -Filter * -SearchBase 'OU=Microsoft Exchange Security Groups,DC=contoso,DC=com' | Get-ADGroupMember -Recursive
```

Vous ne devriez obtenir qu'un seul résultat : le compte Administrateur par défaut. Si c'est le cas, vous pouvez procéder à la suppression des OU suivantes (placées à la racine du domaine) :

- Microsoft Exchange Security Groups
- Microsoft Exchange System Objects

Après la suppression des OUs, il ne reste que deux objets encore liés à Exchange :

- le groupe "Exchange Domain Servers"
- le groupe "Exchange Enterprise Servers"

Les deux peuvent également être supprimés.

### Suppression des permissions orphelines

Sur la racine du domaine Active Directory, inspecter les paramètres de sécurité de l'objet et supprimer toutes les permissions accordées à des comptes inconnus. Vérifier aussi le container "contoso.com/System/AdminSDHolder", qui porte les permissions pour vos comptes à privilèges.

### Nettoyage des attributs Exchange

Les attributs Exchange sont maintenant complètement inutiles, et même s'il est impossible de les supprimer, il convient tout de même de vider les valeurs.

Voici un script pour afficher tous les objets portant des valeurs dans un attribut Exchange :

```powershell
$users = Get-ADUser -Filter * -Properties *
$members = $users | Get-Member -Name 'msExch*'
$members | ForEach-Object {
    $attribute = $_.Name
    Write-Host $attribute -ForegroundColor Yellow
    $users | Where-Object {$_.$attribute} |
        Select-Object Name,Enabled,$attribute,CanonicalName |
        Format-Table
}
```

Et voici un script pour nettoyer ces valeurs :

```powershell
$members | ForEach-Object {
    $attribute = $_.Name
    $users | Where-Object {$_.$attribute} | ForEach-Object {
        Set-ADUser $_.SamAccountName -Clear $attribute -Verbose
    }
}
```
