---
title: "KCLAD #2 - Epuisement des SID"
description: "Casser tous vos profils utilisateurs pour juste trier une liste déroulante ?"
tags: ["activedirectory", "powershell"]
listed: true
---

> **Disclaimer**
>
> KCLAD (*à lire "Casser l'AD"*) est une série d'articles techniques sur des trucs idiots à faire dans un domaine Active Directory. L'idée est de torturer un peu une maquette et essayer de mieux comprendre comment fonctionne Active Directory.
> Ces articles sont en deux parties : la partie "safe" et la partie "dangereuse". La partie dangereuse **n'est pas à reproduire sur la production, évidemment !**

Quasiment 

- [Limite Active Directory : nombre de SID \| Philippe BARTH](https://pbarth.fr/node/257)
- [Limites et scalabilité maximales des services de domaine Active Directory \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/plan/active-directory-domain-services-maximum-limits)

## La partie sans danger

### Principe du SID

Tous les objets créés dans un domaine Active Directory sont pourvus d'un SID (*Security Identifier* ou identifiant de sécurité en français). Celui-ci va servir de plaque d'immatriculation de votre objet :

- Il est unique à votre domaine (et unique au monde normalement)
- Il n'est pas impacté par le déplacement ou le changement de nom de votre objet
- Même après la suppression de l'objet, le SID ne sera jamais réutilisé pour un nouvel objet

C'est ce SID qui va permettre d'identifier l'objet 

### Constitution du SID

Les SID sont constitués de trois parties :

1. Le préfixe : `S-1-5-21-`
2. Le SID du domaine : ``
3. Le RID (relative ID) : ``, compris entre 3 600 et 1 073 741 823

Il y a ??? RID disponibles par domaine

```powershell
Dcdiag.exe /TEST:RidManager /v | find /i "Available RID Pool for the Domain"
```

Certains RID sont connus et réservés : [Active Directory Security Groups | Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups)

### Distribution du SID

Définir le rôle FSMO du RID Master et parler des pools de RID distribués à chaque contrôleur

+ taille des pools de RID

https://technet.microsoft.com/library/jj574229.aspx

on peut invalider un pool rid qui a été distribué 

est-ce que 

