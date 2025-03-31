---
title: "Automatiser le changement du mot de passe DSRM"
description: "Cet objet s'auto-détruira dans 3, 2, 1..."
tags: active-directory
listed: true
---

## Contexte

### Qu'est-ce que le compte DSRM ?

Le compte DSRM est l'équivalent d'un compte administrateur local pour un contrôleur de domaine, à utiliser en cas de problème avec votre service Active Directory. Pour plus d'information, vous pouvez consulter cet article : [Le compte DSRM sur un contrôleur de domaine \| LaBouaBouate](/2025/02/24/compte-de-recuperation-rodc).

Celui-ci est important pour le PRA de votre Active Directory et doit impérativement être renouvellé périodiquement et être unique pour chaque contrôleur de domaine.

### Pourquoi changer régulièrement le mot de passe DSRM ?

Même si l'expiration de mot de passe n'est plus recommandée pour les utilisateurs standards ; les comptes à privilèges, de service ou de récupération doivent toujours être soumis à un renouvellement de mot de passe régulier. Dans le cas du compte DSRM, comme celui-ci est le compte administrateur local pour la récupération du serveur le plus critique de Active Directory, il convient de suivre cette règle d'hygiène.

Pour la fréquence de renouvellement, il est conseillé de changer les mots de passe au moins une fois par an (comme les comptes KRBTGT).

### Pourquoi ne pas partager le même mot de passe sur tous les contrôleurs de domaine ?

Même si il s'agit d'une règle d'hygiène simple en sécurité informatique, il est bon de rappeler les bases. L'intérêt d'utiliser un mot de passe différent est d'éviter le déplacement d'un attaquant vers d'autres ressources, qui n'ont pas toujours le même niveau de criticité.

Ainsi si le mot de passe est identique entre des RODCs et les contrôleurs de domaines en lecture/écriture, un attaquant peut entrer sur un RODC (qui contient un nombre limité de hash) et se déplacer sur un DC qui contiendrait tous les hashs du domaine.

### Contraintes liées au compte DSRM

Voici quelques contraintes importantes pour les comptes DSRM :

1. Ne pas partager de mot de passe entre les différents comptes DSRM
2. Garder une tracabilité des changements de mot de passe (pour le calcul d'âge notamment)
3. Conserver une sauvegarde des mots de passe de ces comptes ailleurs qu'à l'intérieur de votre domaine Active Directory
4. S'assurer que le mot de passe que l'on a sauvegardé est toujours celui du compte DSRM

### Réflexion supplémentaire sur les comptes DSRM

Dans la plupart des cas, l'utilisation des comptes DSRM n'est pas réellement utile. Comme un contrôleur de domaine ne devrait pas servir à autre chose que d'être un controleur de domaine, vous devriez pouvoir supprimer un DC et en promouvoir un nouveau en peu temps.

## Rotation avec NTDSUTIL (semi-automatique)

La première méthode est la plus simple : passer sur chaque contrôleur de domaine pour définir le mot de passe DSRM avec la commande NTDSUTIL. L'opération se fait de manière semi-automatique, puisqu'à ma connaissance il n'est pas possible de renseigner le mot de passe du compte sans saisie manuelle.

> **Attention :** le code suivant utilise une fonction personnalisée disponible ici : [New-Password](https://gist.github.com/leobouard/11f2b10e6f1fad14e0b150956f1f8eb6).

Depuis un contrôleur de domaine :

```powershell
$report = Get-ADDomainController -Filter * | ForEach-Object {
    Write-Host "Updating DSRM password on $($_.Name)"
    $password = New-Password -Length 25
    $password | Set-Clipboard
    ntdsutil.exe 'set dsrm password' "reset password on server $($_.DNSHostName)" quit quit
    [PSCustomObject]@{
        Server = $_.DNSHostName
        Password = $password
        Date = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }
}
$report | Format-Table -AutoSize
```

Ce script devrait donc passer d'un contrôleur de domaine à l'autre, et vous n'aurez 

Contrainte | Etat | Commentaire
---------- | ---- | -----------
Mot de passe unique | ✅ | Un mot de passe par contrôleur de domaine
Tracabilité du changement | ⚠️ | Date de changement sauvegardée uniquement au changement via le script
Sauvegarde en dehors du domaine | ✅ | Le script fourni un rapport exportable en CSV
Validité du mot de passe | ❌ | La vérification doit se faire manuellement

## Avec Windows LAPS

Pré-requis pour Windows LAPS et indication de l'option 

Computer configuration > Policies > Administrative Templates > System > LAPS > Enable password backup for DSRM accounts

```powershell
Get-LapsADPassword DC01.contoso.com -AsPlainText
```

```plaintext
ComputerName        : DC01
DistinguishedName   : CN=DC01,OU=Domain Controllers,DC=contoso,DC=com
Account             : Administrator
Password            : DailyScoldOwlValueAffixCloud
PasswordUpdateTime  : 27/03/2025 04:16:14
ExpirationTimestamp : 26/04/2025 04:16:14
Source              : EncryptedDSRMPassword
DecryptionStatus    : Success
AuthorizedDecryptor : CONTOSO\Domain Admins
```

> Cette solution n'est pas magique pour autant, puisque vous devez vous assurer d'avoir une copie offline des mots de passe DSRM de tous les controleurs de domaine. En effet, en cas d'incident majeur sur votre domaine, vous n'avez pas envie que les mots de passe DSRM soit inaccessibles.

Contrainte | Etat | Commentaire
---------- | ---- | -----------
Mot de passe unique | ✅ | Un mot de passe par contrôleur de domaine
Tracabilité du changement | ✅ | Date de changement indiquée dans l'attribut
Sauvegarde en dehors du domaine | ❌ | La sauvegarde des mots de passe sur un autre support est à votre charge
Validité du mot de passe | ✅ | Le mot de passe est mis à jour automatiquement par Windows LAPS

## Avec une synchronisation avec un compte du domaine

### Tâche planifiée (ancienne version)

[Gérer le mot de passe du compte DSRM \| METSYS Blog](https://blog.metsys.fr/gerer-le-mot-de-passe-du-compte-administrateur-de-restauration-des-services-active-directory-dsrm/)


### Tâche planifiée (nouvelle version)



## Conclusion

### Résumé des méthodes

Contrainte | NTDSUTILS | Windows LAPS | Tâche planifiée (old) | Tâche planifiée (new)
---------- | --------- | ------------ | --------------------- | ---------------------
Mot de passe unique             | ✅ | ✅ | ❌ | ✅
Tracabilité du changement       | ⚠️ | ✅ | ⚠️ | ⚠️
Sauvegarde en dehors du domaine | ✅ | ❌ | ✅ | ✅
Validité du mot de passe        | ⚠️ | ✅ | ⚠️ | ⚠️

Aucune méthode n'est parfaite pour gérer la rotation des mots de passe DSRM.

