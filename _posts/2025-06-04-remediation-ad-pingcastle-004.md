---
title: "PING CASTLE - Anomalies"
description: "Configurations anormales et/ou dangereuses de Active Directory"
tableOfContent: "remediation-ad-pingcastle-introduction#table-des-matières"
prevLink:
  name: "Privileged Accounts"
  id: "remediation-ad-pingcastle-003"
---

## Audit

### A-AuditPowershell

Création d'une nouvelle GPO ordinateurs "Audit PowerShell" à la racine du domaine avec la configuration suivante : *Configuration ordinateur > Stratégies > Modèles d'administration > Composants Windows > Windows PowerShell*

- Activer l'enregistrement des modules : Activé
  - Noms des modules : `*`
- Activer la journalisation de bloc de scripts PowerShell : Activé
  - Consigner les événements de début/de fin des appels de blocs de script : Activé

{% include risk-score.html impact=2 probability=1 comment="L'activation de ce paramètre va générer plus de données dans les journaux d'événements des ordinateurs du domaine." %}

### A-AuditDC

---

## Sauvegarde

### A-BackupMetadata

### A-NotEnoughDC

---

## Golden Ticket

### A-Krbtgt

---

## Vulnérabilités liées aux groupes restreints

### A-MembershipEveryone

---

## Reniflage du réseau

### A-LMHashAuthorized

Ce paramètre a probablement été activé pour des raisons de compatibilité avec des vieilles versions de Windows Server (avant 2003). Si votre domaine ne contient plus de Windows Server 2000 ou antérieur, vous devriez pouvoir désactiver ce paramètre sans risque.

Plus d'information sur le hash LM ici : [LM, NTLM, Net-NTLMv2, oh my!. A Pentester’s Guide to Windows Hashes \| by Péter Gombos \| Medium](https://medium.com/@petergombos/lm-ntlm-net-ntlmv2-oh-my-a9b235c58ed4)

{% include risk-score.html impact=1 probability=1 comment="Si vous n'avez plus aucun Windows Server 2000 et antérieur dans votre domaine, ce changement ne devrait pas avoir d'impact sur les autres ressources." %}

### A-DnsZoneAUCreateChild

### A-DnsZoneUpdate2

### A-DnsZoneUpdate1

### A-NoGPOLLMNR

### A-NTFRSOnSysvol

### A-DCLdapSign

### A-DCLdapsChannelBinding

### A-SMB2SignatureNotEnabled

### A-SMB2SignatureNotRequired

### A-LDAPSigningDisabled

### A-HardenedPaths

Suite à une CVE de 2015, il est nécessaire de renforcer les partages SYSVOL & NETLOGON d'attaques par spoofing (usurpation). Une GPO est attendue par Ping Castle pour résoudre la vulnérabilité.

La meilleure pratique est de créer une nouvelle GPO nommée "Chemins d'accès UNC renforcés" (par exemple), appliquée sur les contrôleurs de domaine avec la configuration suivante : *Configuration ordinateur > Stratégies > Modèle d'administration > Réseau > Fournisseur réseau*.

Vous pouvez activer le paramètre **Chemin d'accès UNC renforcés** et définir les valeurs suivantes :

Nom de la valeur | Valeur
---------------- | ------
\\*\NETLOGON | RequireMutualAuthentication=1, RequireIntegrity=1
\\*\SYSVOL | RequireMutualAuthentication=1, RequireIntegrity=1

> Il existe du troisième paramètre `RequirePrivacy=1` qui impose l'utilisation du chiffrement SMB, disponible seulement à partir de Windows 8 & Windows Server 2012. Si votre parc contient des OS plus anciens, n'ajoutez pas l'option.

Pour plus d'informations : [Active Directory - Découverte des chemins UNC durcis](https://www.it-connect.fr/active-directory-securite-du-partage-sysvol-avec-les-chemins-unc-durcis/)

{% include risk-score.html impact=1 probability=1 comment="Je n'ai jamais eu d'impact sur le déploiement de ce paramètre, même avec la présence d'OS très vieux comme des Windows XP ou Windows Server 2003." %}

---

## Pass-the-credential

### A-SmartCardPwdRotation

### A-SmartCardRequired

### A-ProtectedUsers

### A-LAPS-Joined-Computers

### A-LAPS-Not-Installed

### A-DCRefuseComputerPwdChange

### A-DC-Spooler

### A-DC-WebClient

### A-DC-Coerce

---

## Récupération de mot de passe

### A-ReversiblePwd

### A-UnixPwd

### A-PwdGPO

---

## Reconnaissance

### A-DsHeuristicsAllowAnonNSPI

### A-DsHeuristicsAnonymous

### A-AnonymousAuthorizedGPO

### A-PreWin2000Anonymous

### A-DnsZoneTransfert

### A-NoNetSessionHardening

### A-DsHeuristicsLDAPSecurity

### A-DsHeuristicsDoNotVerifyUniqueness

### A-PreWin2000AuthenticatedUsers

### A-PreWin2000Other

### A-RootDseAnonBinding

### A-NullSession

---

## Administrateurs temporaires

### A-AdminSDHolder

---

## Mots de passe faibles

### A-LimitBlankPasswordUse

### A-MinPwdLen

### A-Guest

### A-NoServicePolicy
