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

## OS obsolètes

### S-OS-...

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
Get-ADComputer -Filter {Enabled -eq $true} -Properties OperatingSystem | Group-Object OperatingSystem | Sort-Object Count -Descending
```

Pour la résolution, pas de miracles : il faut remplacer ou mettre à jour les ordinateurs concernés. Il s'agit souvent de payer une dette technique qui s'est accumulée sur plusieurs années et qui impacte lourdement l'organisation.

Le remplacement de ces OS est à initier dès le début du projet de remédiation, car il invoque souvent plusieurs contacts techniques différents et a des implications dans certains applicatifs sensibles.

Pour la priorisation des tâches, il a deux choix possibles :

- soit procéder par ordre chronologique (2003 puis 2008 puis 2012 par exemple) pour réduire le score Ping Castle rapidement
- soit procéder par ordre de grandeur (commencer par les OS obsolètes les plus rares et finir par les plus communs) pour obtenir des victoires rapides

### S-DC-...

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

Ce point peut être facilement adressé : il suffit de déployer de nouveaux contrôleurs de domaine avec des OS plus récent et de décommissionner les anciens.

Liens utiles :

- [dcpromo dans Windows Server \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/administration/windows-commands/dcpromo)
- [Transfer or seize Operation Master roles - Windows Server \| Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/windows-server/active-directory/transfer-or-seize-operation-master-roles-in-ad-ds)
- [Comment rétrograder des contrôleurs de domaine et des domaines à l'aide de Server Manager ou de PowerShell \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/deploy/demoting-domain-controllers-and-domains--level-200-)

## Anciens protocoles d'authentification

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

### S-OldNtlm

Le meilleur article sur le sujet du NTLM (v1 et v2) est disponible ici : [NTLM authentication: What it is and why it’s risky](https://blog.quest.com/ntlm-authentication-what-it-is-and-why-you-should-avoid-using-it/)

## Configuration de l’objet

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