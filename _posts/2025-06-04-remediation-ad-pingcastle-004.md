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

Plus d'information sur le hash LM ici : [LM, NTLM, Net-NTLMv2, oh my!. A Pentester’s Guide to Windows Hashes | by Péter Gombos | Medium](https://medium.com/@petergombos/lm-ntlm-net-ntlmv2-oh-my-a9b235c58ed4)

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
