---
title: "Contourner l'expiration de mot de passe"
description: "Comment prolonger la vie d'un mot de passe Active Directory et (surtout) trouver les tricheurs ?"
tags: active-directory
listed: true
---

## Avant-propos

La durée de vie des mots de passe et leur expiration en 2024, c'est un sujet compliqué.

D'un côté, nous avons les recommandations du NIST ou de l'ANSSI qui ne préconisent plus une expiration fréquente de mot de passe pour les comptes sans privilèges. De l'autre, les assurances qui demandent encore aux entreprises de définir une durée de vie maximum des mots de passe à 90 ou 180 jours. Au milieu de tout ça, il y a les utilisateurs, qui utilisent de nombreux stratagèmes pour contourner cette expiration et se faciliter la vie.

### Rappels sur les politiques de mot de passe

Dans Active Directory, les politiques de mot de passe (qu'elles soient des *fine-grained password policy* ou la politique par défaut) se basent sur les critères suivants pour définir leurs exigences :

- **Historique de mot de passe** : Active Directory va conserver les hashs des 10 derniers mots de passe (par exemple) pour s'assurer que l'utilisateur ne réutilise pas un ancien mot de passe au moment du renouvellement
- **Durée de vie maximale du mot de passe** : c'est le nombre de jours durant lequel le mot de passe sera valide. Une fois cette période passée, le mot de passe "expire" et doit être changer
- **Durée de vie minimale du mot de passe** : c'est le nombre de jours avant lequel un changement de mot de passe par l'utilisateur n'est pas autorisé
- **Respect des exigences de complexité** : le mot de passe doit contenir au moins trois des quatre types de caractères :
  - Lettres minuscules (a, b, c...)
  - Lettres majuscules (A, B, C...)
  - Chiffres (0, 1, 2...)
  - Caractères spéciaux (!, ?, @...)
- **Longueur minimale du mot de passe** : c'est le nombre de caractères minimum à respecter

### Exemple de configuration

Pour la suite de cet article, nous allons nous baser sur la politique de mot de passe suivante :

Paramètre | Valeur
--------- | ------
Historique de mot de passe | 10 mots de passe
Durée de vie maximale du mot de passe | 90 jours
Durée de vie minimale du mot de passe | 0 jour
Respect des exigences de complexité | Oui
Longueur minimale du mot de passe | 10 caractères

## Méthode 1 : Bête et méchant

Sur cette méthode, l'utilisateur respecte toutes les règles définies, mais les exploite à son avantage. Comme la configuration actuelle ne définie pas d'âge minimum avant changement, l'utilisateur va changer dix fois son mot de passe (pour respecter les règles d'historique) dans la même journée pour pouvoir redéfinir le même mot de passe que précedemment.

Pour le mot de passe initial `MotDePasse!` :

Changement | Heure | Mot de passe
---------- | ----- | ------------
N°1        | 8h30  | `Temporaire1`
N°2        | 8h31  | `Temporaire2`
N°3        | 8h33  | `Temporaire3`
N°4        | 8h34  | `Temporaire4`
N°5        | 8h36  | `Temporaire5`
N°6        | 8h38  | `Temporaire6`
N°7        | 8h40  | `Temporaire7`
N°8        | 8h41  | `Temporaire8`
N°9        | 8h43  | `Temporaire9`
N°10       | 8h44  | `Temporaire10`

Après avoir défini dix mots de passe *temporaires* en moins de 15 minutes, l'utilisateur peut maintenant redéfinir son mot de passe à sa valeur intiale `MotDePasse!` et pourra le conserver pendant 90 jours.

### Blocage de la méthode

Pour résoudre ce problème, vous pouvez augmenter l'historique de mot de passe et/ou définir une durée de vie minimum du mot de passe :

- faire 50 changements de mots de passe dans la même journée avant de pouvoir réutiliser l'ancien demande beaucoup plus de détermination de la part de l'utilisateur
- attendre une journée complète avant chaque changer de mot de passe implique d'attendre au moins deux semaines avant de pouvoir réutiliser l'ancien

### Détection

En supposant que vous ayez bien configuré l'intégralité des [Audit Policy Recommendations \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/audit-policy-recommendations) dans votre domaine Active Directory, vous devriez pouvoir accéder aux évenements de changement de mot de passe.

Le script suivant permet de mettre en lumière les utilisateurs qui ont changé leur mot de passe récemment :

```powershell
$dc = (Get-ADDomainController).Hostname
$events = Get-WinEvent -ComputerName $dc -ProviderName 'Microsoft-Windows-Security-Auditing' | Where-Object {$_.Id -eq 4723}
$report = $events | ForEach-Object {
    $message = $_.Message -split [System.Environment]::NewLine
    $accounts = $message | Where-Object {$_ -like '*Account Name:*'} | ForEach-Object { ($_ -split ':' | Select-Object -Last 1).Trim() }
    [PSCustomObject]@{
        TimeCreated   = $_.TimeCreated
        PerformedBy   = $accounts[0]
        TargetAccount = $accounts[1]
    }
}
$report | Format-Table
$report | Group-Object PerformedBy | Sort-Object Count -Descending
```

Voici un exemple de résultat :

```plaintext
TimeCreated         PerformedBy TargetAccount
-----------         ----------- -------------
21/09/2024 07:00:35 leob        leob
21/09/2024 07:00:27 leob        leob
21/09/2024 06:58:57 leob        leob
21/09/2024 06:58:43 leob        leob
21/09/2024 06:58:19 leob        leob
21/09/2024 06:58:03 leob        leob
21/09/2024 06:57:46 leob        leob
```

## Méthode 2 : Abus du "PasswordReset"

Lorsqu'un administrateur réinitialise le mot de passe d'un compte, la mécanique de vérification d'historique des hashs est ignorée (et c'est un comportement normal de Active Directory).

Sauf que certains peuvent abuser de cette exception pour conserver le même mot de passe indéfiniment, en contournant l'expiration. Cela peut provenir d'un administrateur qui a des droits sur son compte, ou d'un utilisateur qui abuse de la gentillesse du support.

### Détection

Évidemment cette méthode laisse des traces derrière elle. Comme Active Directory conserve les hashs de vos anciens mots de passe (pour justement qu'on évite d'utiliser plusieurs fois le même), un simple audit de la base NTDS dévoile alors la supercherie : on retrouve plusieurs fois le même hash à la suite dans l'historique !

Pour Christie Cline, on retrouve plusieurs fois de suite le hash `d96b085ea5c0d101101bb0a4d846d0df`, ce qui indique un potentiel abus de cette mécanique :

```plaintext
DisplayName       : Christie Cline
SamAccountName    : christiec
NTHash            : d96b085ea5c0d101101bb0a4d846d0df
NTHashHistory     : {d96b085ea5c0d101101bb0a4d846d0df, d96b085ea5c0d101101bb0a4d846d0df, 5a17c70656c8056acfc3ce0591774529...}
Prefix            : d96b0
IsAdministrator   : False
DistinguishedName : CN=Christie Cline,OU=Users,OU=CONTOSO,DC=contoso,DC=com
```

> #### Attention
>
> Attention cependant, retrouver plusieurs fois le même hash à la suite dans l'historique n'indique pas forcément une action malicieuse. Il est possible que le mot de passe ai été réinitalisé coup-sur-coup durant la même journée (et donc sans vouloir prolonger la vie du mot de passe).

Vous pouvez faire ce genre d'audit avec le module PowerShell [DSInternals](https://github.com/MichaelGrafnetter/DSInternals) de Michael Grafnetter par exemple.

## Méthode 3 : Abus du PasswordLastSet (ou PwdLastSet)

Un mot de passe expire lorsqu'on arrive 90 jours après la date indiquée dans l'attribut `PasswordLastSet`, qui correspond à la date de définition du mot de passe.

L'idée de cet abus n'est donc pas modifier le mot de passe, mais plutôt d'agir sur la date de définition de celui-ci. Et pour faire cela, il y a plusieurs méthodes.

### Avec la case à cocher

Cette méthode est facile à réaliser car elle peut être faite depuis la console *Active Directory Users and Computers* (ou `dsa` pour les intimes).

Il suffit de cliquer sur le profil de l'utilisateur, naviguer dans l'onglet "Account" puis de :

1. Cocher la case "User must change password at next logon"
2. Cliquer sur "Apply"
3. Décocher la case "User must change password at next logon"

...et voilà ! La durée de vie de votre mot de passe actuel a été prolongé de 90 jours.

![La case à cocher en question](/assets/images/must-change-password-at-next-logon.jpg)

Pour expliquer rapidement ce fonctionnement : 

1. Cocher la case "User must change password at next logon" fait expirer instantanement le mot de passe du compte, pour forcer l'utilisateur a le changer lors de la prochaine connexion.
2. Décocher la case supprime l'expiration du mot de passe, et comme Active Directory n'a pas gardé en mémoire l'ancienne valeur de `PasswordLastSet`, il défini la date de définition du mot de passe à aujourd'hui.

### Via PowerShell

Ici on fait appel à un paramètre peu connu de la commande `Set-ADUser` pour modifier directement la date de définition du mot de passe sans passer par quatre chemins :

```powershell
$user = Get-ADUser christiec -Properties PwdLastSet
$user.PwdLastSet = -1
Set-ADUser -Instance $user
```

La valeur -1 permet de définir la date à aujourd'hui.

### Détection

Ces deux méthodes ne sont pas indétectables. Ce genre d'opération génère une différence sur les données de réplication entre les contrôleurs de domaine. Comme le mot de passe (attribut `unicodePwd`) ne change pas, pas besoin de le répliquer. En revanche, la nouvelle valeur de l'attribut `PasswordLastSet` est partagée sur tous les contrôleurs de domaine.

Il suffit alors de trouver les comptes avec une différence de date de réplication entre les attributs `unicodePwd` et `PasswordLastSet`.

> #### Information
>
> Vous pouvez consulter les données de réplication d'un utilisateur avec l'attribut `msds-replattributemetadata`.

Pour trouver les fraudeurs, vous pouvez lancer [Purple Knight de Semperis](https://www.semperis.com/purple-knight/) qui a un indicateur pour cela, ou alors utiliser mon script PowerShell : [Get-ADAbnormalPasswordRefresh.ps1 \| GitHub Gist](https://gist.github.com/leobouard/f6066b14db8199a864ff00620c08909d).

Exemple de résultat :

```plaintext
Name                    : Christie Cline
Enabled                 : True
SamAccountName          : christiec
PasswordLastSet         : 28/08/2024 00:00:00
RealPasswordLastSet     : 22/06/2024 00:00:00
TimeSpanBetweenPassword : 67
CanonicalName           : contoso.com/CONTOSO/Users/Christie Cline
```

## En résumé

Méthode | Détection | Blocage
------- | --------- | --------
Bête et méchant | Event 4723 | Modifier la politique de mot de passe par défaut
PasswordReset | Audit de la base NTDS | Impossible
PasswordLastSet | Attribut `msds-replattributemetadata` | Impossible
