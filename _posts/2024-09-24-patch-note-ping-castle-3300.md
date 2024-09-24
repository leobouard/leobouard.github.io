---
title: "Patch note Ping Castle 3.3.0.0"
description: "Quoi de neuf dans la dernière version de Ping Castle ?"
tags: active-directory
listed: true
---

## Patch notes officielle

Comme d'habitude, Ping Castle donne un petit fichier TXT pour donner la liste des changements. Celui-ci reste très court mais permet de constater les améliorations dans la détection de certaines vulnérabilité ou quelques nouveaux indicateurs. Voici le contenu pour cette nouvelle version :

```plaintext
3.3.0.0
* adjusted the rules S-DesEnabled, S-PwdNotRequired, S-PwdNeverExpires, P-Delegated, A-PreWin2000Other, S-PrimaryGroup, P-ServiceDomainAdmin, 
  A-AdminSDHolder to display directly the list of impacted users in the rule if the number is limited (hardcoded to 100) so Pro / Enterprise users can set accounts in exceptions
* handle the case where the property ms-DS-MachineAccountQuota has been removed (you can add as many computers as you want)
* ignore RPC coerce test if the computer used to run PingCastle is the DC (false positive)
* added the rule S-FirewallScript which recommends firewall rules against script engines (suggestion of Steen Poulsen)
* added the rule S-TerminalServicesGPO which recommends session timeout for RDP (suggestion of Steen Poulsen)
```

L'intégralité des règles (à jour) sont également disponible ici : [PingCastle Health Check rules - 2024-09-13](https://pingcastle.com/PingCastleFiles/ad_hc_rules_list.html)

## Décryptage

### Modification de criticité

Il y a eu deux changements de niveau de criticité dans la version 3.3.0.0 :

- **A-AdminSDHolder** : la criticité à été relevée de 3 à 2
  - Relève les comptes avec un adminCount à 1 alors qu'ils ne sont pas membres du groupe "Administrateurs"
- **S-ADRegistration** : la criticité a été abaissée de 3 à 4
  - S'assure que les utilisateurs sans privilèges ne peuvent pas joindre d'ordinateur au domaine avec l'attribut `ms-DS-MachineAccountQuota`

### Nouveaux indicateurs

Indicateur             | Criticité | Points   | Description
----------             | --------- | ------   | -----------
S-PwdLastSet-Cluster   | 2         | 5 points | Changement régulier du mot de passe du compte de cluster
S-AesNotEnabled        | 3         | 0 point (règle informative)  | Utilisation de Kerberos sur des comptes de services qui ne supportent pas AES
P-RODCKrbtgtOrphan     | 3         | 1 point  | Comptes krbtgt orphelins de leur RODC
S-TerminalServicesGPO  | 4         | 0 point (règle informative) | Paramètres de session RDP pour l'inactivité
A-SmartCardPwdRotation | 4         | 0 point (règle informative) | Rotation des mots de passe pour les comptes avec smart card
A-RootDseAnonBinding   | 5         | 0 point (règle informative) | Désactivation de Anonymous Binding sur rootDSE
S-DefenderASR          | 5         | 0 point (règle informative) | Présence de règles ASR pour Microsoft Defender
S-FirewallScript       | 5         | 0 point (règle informative) | Restriction de l'accès à Internet pour les scripts
S-FolderOptions        | 5         | 0 point (règle informative) | Forcer l'ouverture de certains type de fichiers avec notepad.exe par défaut
