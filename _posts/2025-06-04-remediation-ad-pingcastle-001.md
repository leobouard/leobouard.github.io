---
title: "PING CASTLE - Stale Object"
description: "Dette technique liées aux comptes ordinateurs"
tableOfContent: "remediation-ad-pingcastle-introduction#table-des-matières"
nextLink:
  name: "Trusts"
  id: "remediation-ad-pingcastle-002"
prevLink:
  name: "Introduction"
  id: "remediation-ad-pingcastle-introduction"
---

## Utilisateurs ou ordinateurs inactifs

### S-PwdLastSet-Cluster

### S-PwdLastSet-45

### S-PwdLastSet-90

### S-DC-Inactive

### S-PwdLastSet-DC

### S-Inactive

### S-C-Inactive

---

## Topographie du réseau

### S-DC-SubnetMissing

### S-FirewallScript

---

## Configuration des objets

### S-C-PrimaryGroup

### S-PrimaryGroup

### S-Reversible

### S-C-Reversible

### S-NoPreAuth

### S-NoPreAuthAdmin

### S-DefaultOUChanged

### S-PwdNotRequired

### S-PwdNeverExpires

Selon Ping Castle, il ne devrait avoir qu'un seul compte par domaine avec la case "Password never expires" cochée : le compte Administrateur par défaut (SID 500).

Pour résoudre cette vulnérabilité, il faut :

1. retravailler sa stratégie de mot de passe par défaut
2. déployer de nouvelles [stratégies de mot de passe à grain fin](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/get-started/adac/fine-grained-password-policies?tabs=adac) si besoin
3. identifier tous les comptes avec un mot de passe qui n'expire jamais
4. assigner les comptes à une politique de mot de passe (par défaut ou ciblée)
5. définir des lots d'activation de l'expiration de mot de passe
6. communiquer aux utilisateurs et aux gestionnaires des comptes de services / comptes génériques sur :
   - les bonnes pratiques de sécurité
   - la procédure de changement de mot de passe
   - la nouvelle stratégie de sécurité
7. préparer la première vague de renouvellement de mot de passe avec le support informatique

Il est recommandé de lisser la charge au mieux (pas plus de 100 utilisateurs par semaine par exemple) pour éviter les pics d'appels au support informatique.

> Rappel : dans ses [recommandations relatives à l'authentification multifacteur et aux mots de passe](https://cyber.gouv.fr/publications/recommandations-relatives-lauthentification-multifacteur-et-aux-mots-de-passe), l'ANSSI ne recommande plus d'expiration régulière des mots de passe pour les comptes non sensibles (partie 4.4).

Voici un script pour lister l'intégralité des comptes avec un mot de passe qui n'expire jamais, en ajoutant une colonne "PasswordAge" qui affiche l'âge du mot de passe en jours :

```powershell
$users = Get-ADUser -Filter {(PasswordNeverExpires -eq $true) -and (Enabled -eq $true)} -Properties PasswordLastSet, PasswordNeverExpires
$users |
    Select-Object Name, UserPrincipalName, PasswordLastSet,
        @{N='PasswordAge';E={[int](New-Timespan $_.PasswordLastSet).TotalDays}} |
    Sort-Object PasswordAge -Descending
```

Voici un exemple de résultat du script :

Name| PasswordLastSet | PasswordAge
---- | --------------- | -----------
Isatech | 18/12/2007 14:18:11 | 6391
svc_tech_srt | 29/01/2013 15:20:52 | 4522
AAD_548e59c43da0 | 09/10/2018 14:59:15 | 2443
POSGRE Micheline | 13/03/2019 22:15:06 | 2288
Surveillance GIR | 08/08/2019 12:23:47 | 2140

> Il est tout à fait possible de "mettre la poussière sous le tapis" en basculant les comptes utilisateurs vers une PSO qui n'impose pas d'expiration de mot de passe. De cette manière, vous pourrez décocher la case sans avoir aucun impact à prévoir. En revanche, la sécurité du domaine **ne sera pas améliorée**.

{% include risk-score.html impact=3 probability=2 comment="L'impact varie selon les comptes qui seront concernés par le changement, et la probabilité d'un effet de bord non-anticipé et faible, puisque l'on peut avoir une très bonne vision des choses avec les informations Active Directory." %}

### S-KerberosArmoring

### S-KerberosArmoringDC

### S-JavaSchema

### S-SIDHistory

### S-TerminalServicesGPO

### S-DefenderASR

### S-FolderOptions

---

## OS obsolètes

### S-FunctionalLevel1 / S-FunctionalLevel3 / S-FunctionalLevel4

Ce point est similaire à toutes les DFL & FFL obsolètes, il regroupe donc les vulnérabilités suivantes :

Vulnérabilité | Système d'exploitation
------------- | ----------------------
S-FunctionalLevel1 | Windows 2000
S-FunctionalLevel3 | Windows Server 2008
S-FunctionalLevel4 | Windows Server 2008R2

Pour ça pas de miracles, il faut :

1. Monter de nouveaux contrôleurs de domaine
2. Basculer les rôles FSMO
3. Décommissionner les anciens contrôleurs de domaine
4. Faire la [montée de version du domaine et de la forêt](https://www.labouabouate.fr/2025/01/23/montee-de-version-ad)

{% include risk-score.html impact=4 probability=3 comment="Les montées de version ne posent en général pas de problèmes, c'est plutôt le changement de contrôleur de domaine qui peut causer des soucis surtout si vous avez des applications qui utilise un contrôleur de domaine en spécifique." %}

### S-DC-2000 / S-DC-2003 / S-DC-2008 / S-DC-2012

Ce point est similaire à tous les contrôleurs de domaine avec un OS obsolète, il regroupe donc les vulnérabilités suivantes :

Vulnérabilité | Système d'exploitation
------------- | ----------------------
S-DC-2000 | Windows 2000
S-DC-2003 | Windows Server 2003
S-DC-2008 | Windows Server 2008
S-DC-2012 | Windows Server 2012

Voici une commande pour lister tous les contrôleurs de domaine et leur système d'exploitation :

```powershell
Get-ADDomainController -Filter * |
  Sort-Object OperatingSystem |
  Format-Table Name, OperatingSystem
```

Ce point est souvent lié aux vulnérabilités S-FunctionalLevel1 / S-FunctionalLevel3 / S-FunctionalLevel4.

Liens utiles :

- [dcpromo dans Windows Server \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/administration/windows-commands/dcpromo)
- [Transfer or seize Operation Master roles - Windows Server \| Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/transfer-or-seize-operation-master-roles-in-ad-ds)
- [Comment rétrograder des contrôleurs de domaine et des domaines à l'aide de Server Manager ou de PowerShell \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/deploy/demoting-domain-controllers-and-domains--level-200-)

{% include risk-score.html impact=4 probability=3 comment="Les "inplace upgrades" fonctionnent bien mais ne sont pas recommandés et le remplacement des contrôleurs de domaine peut poser problème, comme vu précédemment sur S-FunctionalLevel." %}

### S-OS-W10 / S-OS-2000 / S-OS-Win7 / S-OS-Win8 / S-OS-NT / S-OS-2003 / S-OS-2008 / S-OS-2012 / S-OS-Vista / S-OS-XP

Ce point est similaire à tous les OS obsolètes, il regroupe donc les vulnérabilités suivantes :

Vulnérabilité | Système d'exploitation | Documentation
------------- | ---------------------- | ------------
S-OS-W10 | Windows 10 et Windows 11 | [Windows 10 Famille et Pro - Microsoft Lifecycle ](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-10-home-and-pro)<br>[Windows 11 Famille et Professionnel - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-11-home-and-pro)
S-OS-2000 | Windows 2000 |
S-OS-Win7 | Windows 7 | [Windows 7 - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-7)
S-OS-Win8 | Windows 8 | [Windows 8 - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-8)
S-OS-NT | Windows NT |
S-OS-2003 | Windows Server 2003 | [Windows Server 2003 - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-server-2003-)
S-OS-2008 | Windows Server 2008 | [Windows Server 2008 - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-server-2008)
S-OS-2012 | Windows Server 2012 | [Windows Server 2012 - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-server-2012)
S-OS-Vista | Windows Vista | [Windows Vista - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-vista)
S-OS-XP | Windows XP | [Windows XP - Microsoft Lifecycle](https://learn.microsoft.com/fr-fr/lifecycle/products/windows-xp)

Voici une commande PowerShell pour faire l'inventaire par OS des comptes ordinateurs actifs :

```powershell
Get-ADComputer -Filter {Enabled -eq $true} -Properties OperatingSystem |
    Group-Object OperatingSystem |
    Sort-Object Count -Descending
```

Pour la résolution, pas de miracles : il faut remplacer ou mettre à jour les ordinateurs concernés. Il s'agit souvent de payer une dette technique qui s'est accumulée sur plusieurs années et qui impacte lourdement l'organisation.

Le remplacement de ces OS est à initier dès le début du projet de remédiation, car il invoque plusieurs contacts techniques différents et a des implications dans certains applicatifs sensibles.

Pour la priorisation des tâches, il a deux choix possibles :

- soit procéder par ordre chronologique (2003 puis 2008 puis 2012 par exemple) pour réduire le score Ping Castle rapidement
- soit procéder par ordre de grandeur (commencer par les OS obsolètes les plus rares et finir par les plus communs) pour obtenir des victoires rapides

Voici un exemple de script pour lister l'ensemble des OS obsolètes. Le script est à adapter suivant votre contexte client :

```powershell
Get-ADComputer -Filter {Enabled -eq $true} -Properties OperatingSystem, OperatingSystemVersion, LastLogonDate |
    Where-Object {
        $_.OperatingSystem -like 'Windows Server 2012*' -or
        $_.OperatingSystem -like 'Windows Server 2008*' -or
        $_.OperatingSystem -like 'Windows 7*' -or 
        $_.OperatingSystemVersion -in ('10.0 (17134)', '10.0 (18362)', '10.0 (18363)', '10.0 (19041)', '10.0 (19042)', '10.0 (19044)')} |
    Select-Object Name, Enabled, LastLogonDate, OperatingSystem, OperatingSystemVersion |
    Sort-Object OperatingSystem |
    Format-Table -AutoSize
```

{% include risk-score.html impact=3 probability=3 comment="L'impact et la probabilité dépendent évidemment du serveur / poste de travail qui doit être mis à jour." %}

---

## Anciens protocoles d'authentification

### S-AesNotEnabled

### S-DesEnabled

Le chiffrement DES pour Kerberos est considéré comme très peu sécurisé. En 2016, on pouvait casser le chiffrement en une quinzaine de jours avec une carte graphique à environ 1000$.

De nos jours, on peut partir du principe qu'une trame chiffrée avec DES peut être cassée par n'importe quel attaquant en peu de temps.

Voici une commande pour lister les objets qui utilisent DES comme méthode de chiffrement pour Kerberos :

```powershell
Get-ADObject -Filter {UserAccountControl -band 0x200000 -or msDs-supportedEncryptionTypes -band 3}
```

Pour résoudre ce point, il faut dresser la liste de tous les objets qui utilisent DES (fréquemment des comptes ordinateurs) et investiguer pour chaque objet. La plupart du temps, il s'agit d'une configuration pour la compatibilité avec une application.

La configuration de l'application doit être modifiée (si possible) et la case "Use Kerberos DES encryption types for this account" doit être décochée sur l'objet Active Directory.

> Si vous ne faites que décocher la case sans modifier la configuration côté applicatif, le compte Active Directory pourra venir "recocher" la case.

Pour décocher la case en masse, voici la commande :

```powershell
Get-ADObject -Filter {UserAccountControl -band 0x200000} | ForEach-Object {
    Set-ADAccountControl $_ -UseDESKeyOnly $false
}
```

Voici la documentation de Microsoft sur le sujet : [Supprimer le chiffrement DES très peu sécurisé des comptes d’utilisateur \| Microsoft Learn](https://learn.microsoft.com/fr-fr/services-hub/unified/health/remediation-steps-ad/remove-the-highly-insecure-des-encryption-from-user-accounts)

{% include risk-score.html impact=1 probability=4 comment="A moins d'interdire le DES au niveau du domaine, faire l'action progressivement et en communiquant au préalable avec les équipes concernées permet de faire baisser drastiquement la probabilité du risque." %}

### S-SMB-v1

### S-OldNtlm

Le meilleur article sur le sujet du NTLM (v1 et v2) est disponible ici : [NTLM authentication: What it is and why it’s risky](https://blog.quest.com/ntlm-authentication-what-it-is-and-why-you-should-avoid-using-it/)

{% include risk-score.html impact=3 probability=4 comment="Sans mener d'audit sur les ressources qui utilisent encore NTLM v1, vous êtes quasiment sûr de casser au moins une authentification dans votre domaine. Plus votre parc informatique est récent, plus la probabilité que le risque se produise diminue." %}

---

## Provisionnement

### S-DCRegistration

### S-ADRegistration

### S-ADRegistrationSchema

---

## Replication

### S-Duplicate

---

## Gestion de vulnérabilité

### S-Vuln-MS14-068

### S-Vuln-MS17_010

### S-DC-NotUpdated

### S-WSUS-UserProxy

### S-WSUS-HTTP

### S-WSUS-NoPinning
