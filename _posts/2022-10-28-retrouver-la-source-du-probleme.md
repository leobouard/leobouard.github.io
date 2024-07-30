---
layout: post
title: "Triangulation AD"
description: "Une requête Active Directory bloquée à cause d'une erreur sur un compte utilisateur ou ordinateur"
tags: active-directory
listed: true
---

## Contexte

Une requête Active Directory classique "Get-ADUser" effectuée sur tout le domaine retourne l'erreur suivante : **Get-ADUser : Not a valid Win32 FileTime.**

~~~
Get-ADUser : Not a valid Win32 FileTime.
Parameter name: fileTime
At line:1 char:1
+ Get-ADUser -Filter * -Properties *
+ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    + CategoryInfo          : InvalidArgument: (:) [Get-ADUser], ArgumentOutOfRangeException
    + FullyQualifiedErrorId : ActiveDirectoryCmdlet:System.ArgumentOutOfRangeException,Microsoft.ActiveDirectory.Management.Commands.GetADUser
~~~

Il s'agit d'une valeur d'attribut qui ne correspond pas au format souhaité. Il faut maintenant trouver quel compte génère cette erreur.

## Localisation du compte défaillant

### 1. Dans quelle unité d'organisation ?

Première étape : trianguler la position du compte dans l'Active Directory :

~~~powershell
$ous = Get-ADOrganizationalUnit -SearchBase (Get-ADDomain).DistinguishedName -Properties CanonicalName -Filter * | Sort-Object -Property CanonicalName
$ous | ForEach-Object {
    $_.CanonicalName
    $null = Get-ADUser -Filter * -Properties * -SearchBase $_.DistinguishedName -SearchScope OneLevel
}
~~~

### 2. Quel compte ?

Une fois que l'on a récupéré l'emplacement, on va tester chaque compte à la racine de cette OU :

~~~powershell
Get-ADUser -Filter * -SearchBase "OU=CONTOSO (14),OU=LBB,DC=corp,DC=lbb,DC=com" -SearchScope OneLevel | ForEach-Object {
    $_.Name
    $null = Get-ADUser -Identity $_.DistinguishedName -Properties *
}
~~~

### 3. Quel attribut ?

Prener un compte "sain" (compteA) en exemple et tester chacune des propriétés sur le compte "infecté" (compteB) :

~~~powershell
$members = Get-ADUser "compteA" -Properties * | Get-Member -MemberType Property
$members.Name | ForEach-Object { $_ ; $null = Get-ADUser "compteB" -Properties $_ }
~~~

## Résolution

Maintenant que vous savez d'où vient le problème, il ne reste plus qu'à le résoudre. Dans mon cas, il s'agissait d'un compte Active Directory qui avait été activé alors qu'il n'avait pas de mot de passe défini (*je ne pensais pas que c'était possible*). Le problème venait donc de la valeur de l'attribut "PasswordLastSet" qui était vide, alors qu'il est censé contenir une date (celle de la dernière modification du mot de passe). 

La résolution : changer le mot de passe du compte. 🙂
