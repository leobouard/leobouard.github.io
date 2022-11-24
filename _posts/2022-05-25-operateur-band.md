---
layout: post
title: "-band en PowerShell"
description: "Oui. Je viens de faire ce jeu de mot."
tags: AD
thumbnailColor: "#452057"
icon: 🍆
listed: false
---

En faisant quelques recherches sur le fameux attribut "UserAccountControl" sur les comptes utilisateurs Active Directory, je suis tombé sur un très bon article d'IT-Connect sur le sujet. L'article parle de l'attribut et donne un bout de script PowerShell pour déchiffrer sa valeur.

Cool n'est-ce pas ? Sauf qu'en voyant le bout de code, je bloque sur un opérateur de comparaison qui ne m'est que très vaguement familier : l'opérateur -BAND. Quelques recherches DuckDuckGo plus tard, je tombe sur la documentation Microsoft : [about_Arithmetic_Operators](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_arithmetic_operators) mais ça ne m'aide pas beaucoup. Il est question de "Bitwise AND" et d'opérateur "arithmétique".

![math lady meme](https://media4.giphy.com/media/WRQBXSCnEFJIuxktnw/giphy.gif?cid=ecf05e47ni6059isv8xffm6xqrw4x9bg85868n8b0g4ozpgg&rid=giphy.gif&ct=g)

Comme il est 18h passé et qu'il ne me reste plus beaucoup de neurones actives, je décide de comprendre par moi-même comment peut bien fonctionner cet opérateur "arithmétique".

## Cas pratique : userAccountControl dans l'Active Directory

Je vous invite à lire l'article d'IT-Connect : [Active Directory et l'attribut UserAccountControl](https://www.it-connect.fr/active-directory-et-lattribut-useraccountcontrol/) dont je parlais précédemment pour mieux comprendre le cas pratique.

Indicateur de propriété | Valeur hexadécimale | Valeur en décimal
----------------------- | ------------------- | -----------------
SCRIPT | 0x0001 | 1
ACCOUNTDISABLE | 0x0002 | 2
HOMEDIR_REQUIRED | 0x0008 | 8
LOCKOUT | 0x0010 | 16
PASSWD_NOTREQD | 0x0020 | 32
PASSWD_CANT_CHANGE | 0x0040 | 64
ENCRYPTED_TEXT_PWD_ALLOWED | 0x0080 | 128
TEMP_DUPLICATE_ACCOUNT | 0x0100 | 256
NORMAL_ACCOUNT | 0x0200 | 512
INTERDOMAIN_TRUST_ACCOUNT | 0x0800 | 2048
WORKSTATION_TRUST_ACCOUNT | 0x1000 | 4096
SERVER_TRUST_ACCOUNT | 0x2000 | 8192
DONT_EXPIRE_PASSWORD | 0x10000 | 65536
MNS_LOGON_ACCOUNT | 0x20000 | 131072
SMARTCARD_REQUIRED | 0x40000 | 262144
TRUSTED_FOR_DELEGATION | 0x80000 | 524288
NOT_DELEGATED | 0x100000 | 1048576
USE_DES_KEY_ONLY | 0x200000 | 2097152
DONT_REQ_PREAUTH | 0x400000 | 4194304
PASSWORD_EXPIRED | 0x800000 | 8388608
TRUSTED_TO_AUTH_FOR_DELEGATION | 0x1000000 | 16777216
PARTIAL_SECRETS_ACCOUNT | 0x04000000 | 67108864