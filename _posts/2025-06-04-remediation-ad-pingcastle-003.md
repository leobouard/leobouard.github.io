---
title: "PING CASTLE - Privileged Accounts"
description: "Administrateurs de Active Directory"
tableOfContent: "remediation-ad-pingcastle-introduction#table-des-matières"
nextLink:
  name: "Anomalies"
  id: "remediation-ad-pingcastle-004"
prevLink:
  name: "Trusts"
  id: "remediation-ad-pingcastle-002"
---

## Appropriation de comptes

### P-Delegated

### P-Kerberoasting

Au moins un compte à privilège porte des valeurs dans l'attribut `servicePrincipalName`. Cette configuration peut alors être utilisée par un attaquant pour usurper l'identité du compte avec l'attaque Kerberoasting.

Vous pouvez utiliser le script suivant pour trouver tous les comptes à haut privilèges avec un SPN :

```powershell
Get-ADUser -Filter {adminCount -eq 1} -Properties servicePrincipalName |
    Where-Object {$_.ServicePrincipalName}
```

> Le compte `krbtgt` portent naturellement le SPN `kadmin/changepw` : pas d'inquiétude à avoir là-dessus.

La plupart du temps, il s'agit de SPN qui pointent vers des instances SQL, comme par exemple :

- MSSQLSvc/SRV001.contoso.com:1433
- MSSQLSvc/SRV001.contoso.com
- MSSQLSvc/SRV002.contoso.com:1433
- MSSQLSvc/SRV002.contoso.com

Dans ce cas, la première chose est de vérifier que les serveurs/services indiqués dans le SPN existent toujours. Si ceux-ci n'existent plus, vous pouvez supprimer les valeurs correspondantes. Si les serveurs/services sont toujours utilisés, il vous reste deux choix :

1. Migrer tous les services associés au(x) compte(s) vers un autre compte de service avec moins de privilèges
2. Diminuer les privilèges du compte existant

{% include risk-score.html impact=3 probability=3 comment="Les SPN peuvent rester une épine dans le pied de la sécurité de votre domaine pendant longtemps. La réduction des privilèges du compte est souvent la meilleure méthode pour diminuer les risques." %}

### P-AdminPwdTooOld

Au moins un compte à privilège possède un mot de passe vieux de trois ans ou plus. Voici un script pour les identifier rapidement :

```powershell
Get-ADUser -Filter {(Enabled -eq $true) -and (adminCount -eq 1)} -Properties PasswordLastSet |
    Where-Object {$_.PasswordLastSet -lt (Get-Date).AddYears(-3)}
```

Ici, au moins deux méthodes pour tricher :

- [Abuser de la réinitialisation du mot de passe par un administrateur](https://www.labouabouate.fr/2024/09/15/prolonger-la-vie-mdp#m%C3%A9thode-2--abus-du-passwordreset)
- [Mettre à jour la date de changement de mot de passe](https://www.labouabouate.fr/2024/09/15/prolonger-la-vie-mdp#m%C3%A9thode-3--abus-du-pwdlastset)

> Tricher sur cette métrique fera plaisir à la fois à Ping Castle et à l'attaquant qui utilisera ce compte pour faire tomber votre domaine.

La méthode propre est évidemment de changer le mot de passe et/ou diminuer les permissions des comptes concernés.

{% include risk-score.html impact=3 probability=3 comment="Faire un premier changement de mot de passe sur un compte de service après plusieurs années implique de très bien connaitre son environnement sous peine de casser quelque chose." %}

### P-ProtectedUsers

### P-LogonDenied

C'est la première pierre du tiering model Active Directory. Sur cette métrique, c'est le groupe "Admins du domaine" qui est ciblé et qui devrait être interdit de connexion sur toutes les ressources du Tier 2 (ordinateurs personnels principalement).

Pour résoudre ce point, vous devez d'abord créer de nouveaux comptes à privilège qui ne sont pas administrateurs du domaine pour accéder aux ordinateurs personnels en tant qu'administrateur local.

Ensuite, vous pouvez créer une nouvelle GPO qui s'appliquera au moins sur les ordinateurs personnels de votre domaine, avec la configuration suivante : *Configuration ordinateur > Stratégies > Paramètres Windows > Paramètres de sécurité > Stratégies locales > Attribution des droits utilisateurs*

Stratégie	| Paramètres de stratégie
--------- | -----------------------
Session locale | CONTOSO\Admins du domaine
Session en tant que service | CONTOSO\Admins du domaine
Session en tant que tâche | CONTOSO\Admins du domaine
Session par les services Bureau à distance | CONTOSO\Admins du domaine

À voir si vous préférez faire une exception sur votre compte brise-glace pour qu'il puisse se connecter n'importe où.

> Comme toutes les vérifications GPO de Ping Castle, à partir du moment où la GPO existe dans le domaine : le risque est considéré comme résolu. En réel, le périmètre d'application de la GPO a évidemment une importance majeure et celle-ci devrait être appliquée à toutes les ressources du Tier 2.

{% include risk-score.html impact=1 probability=3 comment="Le changement de compte administrateur est la partie la plus impactante car cela implique une modification des habitudes d'administration et des processus." %}

### P-DisplaySpecifier

## Vérification des ACL

### P-DCOwner

### P-DangerousExtendedRight

### P-DsHeuristicsDoListObject

### P-DNSAdmin

### P-DNSDelegation

### P-DelegationLoginScript

### P-DelegationKeyAdmin

### P-ExchangePrivEsc

### P-ExchangeAdminSDHolder

### P-DelegationFileDeployed

### P-DelegationGPOData

### P-DsHeuristicsAdminSDExMask

### P-LoginDCEveryone

### P-RecoveryModeUnprotected

## Contrôle des comptes administrateurs

### P-Inactive

### P-AdminLogin

Cette vulnérabilité indique que le compte Administrateur par défaut (SID-500) a été utilisé récemment. Pour rappel : le compte Administrateur par défaut ne doit être utilisé qu'en cas de dernier recours, et vous devez utiliser des comptes nominatifs pour les actions quotidiennes sur le Tier 0.

Si l'usage de ce compte sort de ce contexte d'urgence absolue, vous devez :

- trouver la source de l'utilisation du compte avec l'évenement `4624`
- arrêter l'utilisation de ce compte en fournissant une alternative (en suivant le principe du moindre privilège)
- réinitialiser le mot de passe du compte Administrateur

{% include risk-score.html impact=2 probability=2 comment="Le risque dépend fortement de quelle est l'utilisation qui a été faite du compte Administrateur." %}

### P-AdminNum

### P-OperatorsEmpty

## Chemins de contrôle

### P-AdminEmailOn

### P-ControlPathIndirectEveryone

### P-ControlPathIndirectMany

## Vérification des délégations

### P-DelegationEveryone

### P-UnkownDelegation

Des permissions dans Active Directory ne peuvent pas être résolues (SID orphelins), ce qui peut être expliqué par une délégation accordée à un objet d'un autre domaine Active Directory et/ou que le principal qui portait la permission à été supprimé.

Vous pouvez vérifier que la provenance des SID inconnus en les comparant aux DomainSID connus : 

```powershell
$domains = @()
$domains += (Get-ADDomain).DNSRoot
$domains += (Get-ADTrust -Filter *).Name
$domains | ForEach-Object {
    Get-ADDomain $_ | Select-Object DNSRoot, DomainSID
}
```

Et pour rechercher un SID dans la corbeille Active Directory, vous pouvez utiliser la commande suivante :

```powershell
Get-ADObject -Filter {ObjectSID -eq 'S-1-5-21-1519513455-2607746426-4144247390-102133'} -IncludeDeletedObjects -Properties Modified
```

> Pensez également à vérifier dans les SIDHistory lors votre recherche des SID orphelins.

{% include risk-score.html impact=1 probability=2 comment="Il peut y avoir des cas où cela cause un impact, mais si votre audit des permissions orphelines est bien fait il ne devrait pas y avoir de soucis." %}

### P-DelegationDCt2a4d

### P-DelegationDCa2d2

### P-DelegationDCsourcedeleg

### P-UnconstrainedDelegation

## Changement irréversible

### P-SchemaAdmin

### P-UnprotectedOU

Certaines unités d'organisation ne sont pas protégées contre la suppression accidentelle. Vous pouvez résoudre facilement ce point avec le script suivant :

```powershell
Get-ADOrganizationalUnit -Filter * -Properties ProtectedFromAccidentalDeletion |
    Where-Object {$_.ProtectedFromAccidentalDeletion -eq $false} |
    Set-ADOrganizationalUnit -ProtectedFromAccidentalDeletion:$true -Verbose
```

{% include risk-score.html impact=1 probability=1 comment="Aucun impact à prévoir." %}

### P-RecycleBin

## Contrôle des privilèges

### P-ServiceDomainAdmin

### P-TrustedCredManAccessPrivilege

### P-PrivilegeEveryone

## Contrôleurs de domaine en lecture seule (RODC)

### P-RODCRevealOnDemand

### P-RODCAdminRevealed

### P-RODCSYSVOLWrite

### P-RODCNeverReveal

### P-RODCAllowedGroup

### P-RODCDeniedGroup

### P-RODCKrbtgtOrphan
