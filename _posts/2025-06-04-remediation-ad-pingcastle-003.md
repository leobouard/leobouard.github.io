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

Au moins un compte à privilège porte des valeurs dans l'attribut `servicePrincipalName`. Cette configuration peut alors être utilisée par un attaquant pour usurper l'identité du compte avec l'attaque [Kerberoasting](https://beta.hackndo.com/kerberoasting/).

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

### P-ProtectedUsers

### P-LogonDenied

C'est la première pierre du tiering model Active Directory. Sur cette métrique, c'est le groupe "Domain Admins" qui est ciblé et qui devrait être interdit de connexion sur toutes les ressources du Tier 2.

A voir si vous préférez faire une exception sur votre compte brise-glace pour qu'il puisse se connecter n'importe où.

Plus d'informations ici : [Limiter les connexions à des ressources par GPO](https://www.labouabouate.fr/2024/11/01/tiering-model-005#d%C3%A9finition-des-param%C3%A8tres)

> Comme toutes les vérifications GPO de Ping Castle, à partir du moment où la GPO existe dans le domaine : le risque est considéré comme résolu. En réel, le périmètre d'application de la GPO a évidemment une importance majeure et celle-ci devrait être appliquer à toutes les ressources du Tier 2.

### P-DisplaySpecifier

---

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

---

## Contrôle des comptes administrateurs

### P-Inactive

### P-AdminLogin

### P-AdminNum

### P-OperatorsEmpty

---

## Chemins de contrôle

### P-AdminEmailOn

### P-ControlPathIndirectEveryone

### P-ControlPathIndirectMany

---

## Vérification des délégations

### P-DelegationEveryone

### P-UnkownDelegation

### P-DelegationDCt2a4d

### P-DelegationDCa2d2

### P-DelegationDCsourcedeleg

### P-UnconstrainedDelegation

---

## Changement irréversible

### P-SchemaAdmin

### P-UnprotectedOU

### P-RecycleBin

---

## Contrôle des privilèges

### P-ServiceDomainAdmin

### P-TrustedCredManAccessPrivilege

### P-PrivilegeEveryone

---

## Contrôleurs de domaine en lecture seule (RODC)

### P-RODCRevealOnDemand

### P-RODCAdminRevealed

### P-RODCSYSVOLWrite

### P-RODCNeverReveal

### P-RODCAllowedGroup

### P-RODCDeniedGroup

### P-RODCKrbtgtOrphan
