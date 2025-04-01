---
title: "Automatiser le changement du mot de passe DSRM"
description: "Cet objet s'auto-détruira dans 3, 2, 1..."
tags: active-directory
listed: true
---

## Contexte

### Qu'est-ce que le compte DSRM ?

Le compte DSRM est l'équivalent d'un compte administrateur local pour un contrôleur de domaine, à utiliser en cas de problème avec votre service Active Directory. Pour plus d'informations, vous pouvez consulter cet article : [Le compte DSRM sur un contrôleur de domaine \| LaBouaBouate](/2025/02/24/compte-de-recuperation-rodc).

Celui-ci est important pour le PRA de votre Active Directory et doit impérativement être renouvelé périodiquement et être unique pour chaque contrôleur de domaine.

### Pourquoi changer régulièrement le mot de passe DSRM ?

Même si l'expiration de mot de passe n'est plus recommandée pour les utilisateurs standards ; les comptes à privilèges, de service ou de récupération doivent toujours être soumis à un renouvellement de mot de passe régulier. Dans le cas du compte DSRM, comme celui-ci est le compte administrateur local pour la récupération du serveur le plus critique de Active Directory, il convient de suivre cette règle d'hygiène.

Pour la fréquence de renouvellement, il est conseillé de changer les mots de passe au moins une fois par an (comme les comptes KRBTGT).

### Pourquoi ne pas partager le même mot de passe sur tous les contrôleurs de domaine ?

Même si il s'agit d'une règle d'hygiène simple en sécurité informatique, il est bon de rappeler les bases. L'intérêt d'utiliser un mot de passe différent est d'éviter le déplacement d'un attaquant vers d'autres ressources, qui n'ont pas toujours le même niveau de criticité.

Ainsi si le mot de passe est identique entre des RODCs et les contrôleurs de domaines en lecture/écriture, un attaquant peut entrer sur un RODC (qui contient un nombre limité de hash) et se déplacer sur un DC qui contiendrait tous les hashs du domaine.

### Contraintes liées au compte DSRM

Voici quelques contraintes importantes pour les comptes DSRM :

1. Ne pas partager de mot de passe entre les différents comptes DSRM
2. Garder une traçabilité des changements de mot de passe (pour le calcul d'âge notamment)
3. Conserver une sauvegarde des mots de passe de ces comptes ailleurs qu'à l'intérieur de votre domaine Active Directory
4. S'assurer que le mot de passe que l'on a sauvegardé est toujours celui du compte DSRM

### Réflexion supplémentaire sur les comptes DSRM

Dans la plupart des cas, l'utilisation des comptes DSRM n'est pas réellement utile. Si vous rencontrez un problème avec un contrôleur de domaine, après investigation le plus simple devrait être d'en monter un nouveau et de supprimer l'ancien.

## NTDSUTIL

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

Ce script passe d'un contrôleur de domaine à l'autre, et vous n'avez qu'à entrer le mot de passe du compte (qui est automatiquement copié dans votre presse-papier). A l'issue du script, vous devriez avoir un tableau récapitulatif des mots de passe de chaque compte DSRM.

Contrainte | État | Commentaire
---------- | ---- | -----------
Mot de passe unique | ✅ | Un mot de passe par contrôleur de domaine
Traçabilité du changement | ⚠️ | Date de changement sauvegardée uniquement au changement via le script
Sauvegarde en dehors du domaine | ✅ | Le script fourni un rapport exportable en CSV
Validité du mot de passe | ⚠️ | La vérification n'est faite qu'au changement du mot de passe

## Windows LAPS

Windows LAPS est le nouveau mécanisme de gestion des mots de passe des comptes administrateurs locaux introduit par Microsoft en remplacement du "vieux" LAPS (*LAPS Microsoft* ou *Legacy LAPS*).

En bref, c'est une solution qui permet de faire une rotation automatique du mot de passe des comptes administrateurs locaux, en inscrivant le mot de passe directement dans un attribut de l'objet ordinateur dans Active Directory.

Contrairement à son prédécesseur, Windows LAPS peut prendre en charge les comptes DSRM des contrôleurs de domaine.

> **Spoiler alert :** Windows LAPS est de très loin la meilleure solution pour gérer la rotation des mots de passe DSRM. Si vous y avez accès, c'est le meilleur choix à faire.

Si vous souhaitez en savoir plus ou déployer Windows LAPS dans votre environnement, je vous recommande la documentation officielle de Microsoft : [Windows LAPS overview \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/laps/laps-overview)

### Prérequis

Windows LAPS est disponible nativement sur les versions suivantes (si celles-ci sont bien à jour) :

- Windows Server 2019 et supérieur
- Windows 11 à partir de la version 21H2
- Windows 10 à partir de la version 20H2

Note : Il n'est pas possible "d'installer" Windows LAPS sur une version non-compatible de Windows / Windows Server.

### Paramétrage de la GPO

Dans une nouvelle GPO dédiée à la configuration de LAPS, vous pouvez activer la gestion des comptes DSRM avec ce paramètre :

*Computer configuration > Policies > Administrative Templates > System > LAPS > Enable password backup for DSRM accounts*

Vous pouvez également en profiter pour configurer d'autres paramètres (longueur du mot de passe, fréquence de renouvellement, sauvegarde du mot de passe sur Microsoft Entra ID...).

### Récupération du mot de passe DSRM

On peut récupérer facilement le mot de passe du compte DSRM avec la commande PowerShell suivante :

```powershell
Get-LapsADPassword DC01.contoso.com -AsPlainText
```

Ce qui va donner ce résultat :

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

### Modification du mot de passe

Une fois que le mot de passe DSRM est géré par Windows LAPS, **il n'est plus possible de le changer** avec l'utilitaire NTDSUTIL.

Si vous essayez, vous obtiendrez l'erreur suivante : `WIN32 Error Code: 0x21ce. Error Message: The account is controlled by external policy and cannot be modified.`

A la place, il faut exécuter cette ligne de commande sur le contrôleur de domaine :

```powershell
Reset-LapsPassword
```

Contrainte | État | Commentaire
---------- | ---- | -----------
Mot de passe unique | ✅ | Un mot de passe par contrôleur de domaine
Traçabilité du changement | ✅ | Date de changement indiquée dans l'attribut
Sauvegarde en dehors du domaine | ✅ | Possibilité de sauvegarde sur Microsoft Entra ID
Validité du mot de passe | ✅ | Le mot de passe est mis à jour automatiquement par Windows LAPS et ne peux pas être modifié autrement

## Tâche planifiée (ancienne version)

En 2009, Microsoft a publié un guide pour s'occuper du changement de mot de passe des comptes DSRM en passant par une tâche planifiée poussée par GPO : [DS Restore Mode Password Maintenance \| Microsoft Community Hub](https://techcommunity.microsoft.com/blog/askds/ds-restore-mode-password-maintenance/396102). Cette tâche planifiée s'exécute tous les jours pour synchroniser le mot de passe du compte DSRM avec celui d'un compte cible du domaine.

Les captures d'écrans n'étant plus disponibles sur l'article original, vous pouvez consulter cet article pour avoir un aperçu de la méthode : [Gérer le mot de passe du compte DSRM \| METSYS Blog](https://blog.metsys.fr/gerer-le-mot-de-passe-du-compte-administrateur-de-restauration-des-services-active-directory-dsrm/)

Cette méthode **n'est plus recommandée par Microsoft depuis 2018**, car elle pousse le même mot de passe sur tous les contrôleurs de domaine.

Contrainte | État | Commentaire
---------- | ---- | -----------
Mot de passe unique | ❌ | Le mot de passe est identique entre tous les contrôleurs de domaine
Traçabilité du changement | ⚠️ | On peut consulter l'âge du mot de passe du compte cible, mais cela ne garanti pas l'âge du mot de passe DSRM sur le DC
Sauvegarde en dehors du domaine | ⚠️ | La sauvegarde des mots de passe sur un autre support est à votre charge
Validité du mot de passe | ⚠️ | A vous de surveiller le résultat des tâches planifiées sur chaque contrôleur de domaine

## Tâche planifiée (nouvelle version)

Cette proposition est un simple exercice technique pour moderniser la version proposée par Microsoft en 2009. Je ne recommande pas cette méthode pour de la production.

### Création des comptes du domaine cibles

Dans un premier temps, il va falloir créer un compte du domaine "cible" pour chaque contrôleur de domaine. C'est le mot de passe de ce compte qui sera utilisé pour définir celui du compte DSRM.

> **Attention :** le code suivant utilise une fonction personnalisée disponible ici : [New-Password](https://gist.github.com/leobouard/11f2b10e6f1fad14e0b150956f1f8eb6).

```powershell
Get-ADDomainController -Filter * | ForEach-Object {
    $password = New-Password -Length 25
    New-ADUser -Name "dsrm-$($_.Name)"
    Set-ADAccountPassword "dsrm-$($_.Name)" -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $password -Force)
    [PSCustomObject]@{
        SamAccountName = "dsrm-$($_.Name)"
        Password = $password
    }
}
```

Si vous avez deux contrôleurs de domaine DC01 et DC02, vous devriez avoir deux comptes créés : dsrm-DC01 et dsrm-DC02.

### Cas particulier des RODC

Afin que votre RODC puisse récupérer le hash du mot de passe du compte cible, vous devez impérativement ajouter le compte dans la Password Replication Policy du RODC.

Plus d'informations ici : [Synchronisation du compte DSRM depuis un RODC - Le compte DSRM sur un contrôleur de domaine \| LaBouaBouate](https://www.labouabouate.fr/2025/02/24/compte-de-recuperation-rodc#synchronisation-du-compte-dsrm-depuis-un-rodc)

### Création de la tâche planifiée

Comme l'ancienne méthode de Microsoft, on va pousser une tâche planifiée par GPO sur tous nos contrôleurs de domaine :

*Computer configuration > Preferences > Control Panel Settings > Scheduled Tasks*

![Configuration de la tâche planifiée par GPO](/assets/images/scheduled-task-dsrm.png)

Voici les arguments utilisés pour NTDSUTIL (pour pouvoir copier-coller facilement) :

```plaintext
"set dsrm password" "sync from domain account dsrm-%COMPUTERNAME%" quit quit
```

> `%COMPUTERNAME%` sera automatiquement remplacé par le nom du contrôleur de domaine, ce qui nous permet d'avoir un mot de passe différent par serveur.

### Rotation du mot de passe

Pour la rotation des mots de passe DSRM, vous n'avez plus qu'à modifier les mots de passe des comptes cibles dans le domaine Active Directory. Le changement se propagera sous 24 heures sur les comptes DSRM des contrôleurs de domaine, avec la tâche planifiée.

### Vérification

A vous de vérifier la bonne exécution de la tâche planifiée, et la modification du mot de passe du compte DSRM.

Plus d'informations ici : [Surveillance du compte DSRM - Le compte DSRM sur un contrôleur de domaine \| LaBouaBouate](https://www.labouabouate.fr/2025/02/24/compte-de-recuperation-rodc#surveillance-du-compte-dsrm)

Contrainte | État | Commentaire
---------- | ---- | -----------
Mot de passe unique | ✅ | Un mot de passe par contrôleur de domaine
Traçabilité du changement | ⚠️ | On peut consulter l'âge du mot de passe du compte cible, mais cela ne garanti pas l'âge du mot de passe DSRM sur le DC
Sauvegarde en dehors du domaine | ⚠️ | La sauvegarde des mots de passe sur un autre support est à votre charge
Validité du mot de passe | ⚠️ | A vous de surveiller le résultat des tâches planifiées sur chaque contrôleur de domaine

## Conclusion

Voici un classement personnel sur les différentes méthodes pour gérer la rotation de vos mots de passe DSRM :

1. **Windows LAPS** si votre environnement est compatible, c'est de loin la meilleur solution disponible actuellement.
2. **NTDSUTIL** si votre environnement n'est pas compatible avec Windows LAPS, c'est l'option la plus simple.
3. **Tâche planifiée :** techniquement faisable, mais trop complexe à maintenir pour gérer un processus aussi sensible.

### Résumé des méthodes

Contrainte | NTDSUTIL | Windows LAPS | Tâche planifiée
---------- | --------- | ------------ | --------------
Mot de passe unique             | ✅ | ✅ | ✅
Traçabilité du changement       | ⚠️ | ✅ | ⚠️
Sauvegarde en dehors du domaine | ✅ | ✅ | ⚠️
Validité du mot de passe        | ⚠️ | ✅ | ⚠️
