---
title: "Renforcement d'un OS Windows"
description: "Appliquer toutes les recommandations Microsoft en 30 secondes"
tags: windows
listed: true
---

## HardeningKitty

Renforcer un OS serveur en se basant sur les recommandations de Microsoft peut être long et fastidieux. Pour remédier au problème, la communauté a créé [HardeningKitty - GitHub](https://github.com/0x6d69636b/windows_hardening/tree/master) afin de déployer rapidement plus de 300 règles de sécurité sur un OS. La documentation GitHub de HardeningKitty est déjà très complète, facile à suivre et est mise à jour régulièrement. Cependant voici un guide rapide de sécurisation *made in LaBouaBouate*.

### Référentiels

Les référentiels sont tous contenus dans le dossier `lists` et regroupe l'ensemble des règles de sécurité (au format CSV) à respecter. Il existe souvent plusieurs modèle pour chaque type d'OS, suivant votre préférence.

Fichiers | Référentiel
-------- | -----------
`finding_list_0x6d69636b` | Suit les préférences personnelles du créateur de HardeningKitty
`finding_list_bsi` | Suit les recommandations du *Federal Office for Information Security* (l'équivalent de l'ANSSI en Allemagne)
`finding_list_cis` | Suit les recommandations du CIS Benchmark (Center for Internet Security)
`finding_list_dod` | Suit les recommandations du *Department of Defense* des Etats-Unis
`finding_list_msft_security_baseline` | Suit les recommandations de la Microsoft Security Baseline

En l'absence de recommandations de l'ANSSI, il est préférable de se baser sur les **Microsoft Security Baseline**.

## Sécurisation via HardeningKitty

### Téléchargement et import du module

Vous pouvez télécharger le ZIP du projet GitHub ici : [Lien direct](https://github.com/0x6d69636b/windows_hardening/archive/refs/heads/master.zip)

Décompressez le fichier ZIP sur la machine à sécuriser, puis naviguer en PowerShell jusqu'à l'emplacement du dossier et exécuter la commande suivante pour charger le module :

~~~powershell
Import-Module .\HardeningKitty.psm1
~~~

### Audit de l'existant

Une fois le module chargé, vous pouvez lancer un audit de l'existant avec la commande suivante :

~~~powershell
Invoke-HardeningKitty -Mode Audit -Log -Report -FileFindingList .\lists\finding_list_msft_security_baseline_windows_server_2022_21h2_member_machine.csv
~~~

Le paramètre `-FileFindingList` permet de donner le référentiel à utiliser pour la sécurisation du serveur, en l'occurence : Microsoft Security Baseline for Windows Server 2022 21H1 (hors contrôleur de domaine).

L'audit vous donnera un score de 1 (insuffisant) à 6 (excellent) :

Score | P'tit chat | Signification
----- | ---------- | -------------
6 | 😹 | Excellent
5 | 😺 | Bon
4 | 😼 | Suffisant
3 | 😿 | Insuffisant
2 | 🙀 | Insuffisant
1 | 😾 | Insuffisant

Le score par défaut tourne fréquement autour de 3.

### Sauvegarde

Pour pouvoir revenir en arrière en cas de problème, HardeningKitty permet de sauvegarder la configuration actuelle avec la commande suivante :

~~~powershell
Invoke-HardeningKitty -Mode Config -Backup
~~~

### Application d'un modèle

Si vous avez un peu de temps à tuer, vous pouvez vous amuser à revoir chacune des règles de sécurité pour les modifier ou en supprimer quelques unes.

Le plus simple pour faire ça est probablement d'utiliser l'interface web disponible ici : [Hardening Interface](https://phi.cryptonit.fr/policies_hardening_interface/interface/windows)

Sinon, vous pouvez utiliser tel-quel les modèles par défaut qui se basent sur les recommandations de Microsoft, du DOD, du BSI ou du CIS.

~~~powershell
Invoke-HardeningKitty -Mode HailMary -Log -Report -FileFindingList .\lists\votre-fichier-de-regles.csv
~~~

Un redémarrage est souvent requis après l'application des règles.

### Relancer un audit

Une fois le redémarrage terminé, vous pouvez relancer un audit pour vérifier le score :

~~~powershell
Import-Module .\HardeningKitty.psm1
Invoke-HardeningKitty -Mode Audit -Log -Report -FileFindingList .\lists\finding_list_msft_security_baseline_windows_server_2022_21h2_member_machine.csv
~~~

Votre score devrait maintenant se situer entre 5 et 6.

## Règles à personnaliser

### Copie de fichiers via presse-papier

Le modèle `msft_security_baseline` pour Windows Server désactive notamment la possibilité de copier des fichiers vers le serveur via le presse-papier. Il s'agit de la ligne de configuration suivante : *Remote Desktop Session Host: Device and Resource Redirection: Do not allow drive redirection* (ID : 10961).

Vous pouvez donc supprimer ou modifier cette ligne sur le fichier CSV, ou supprimer la clé de registre **fDisableCdm** au chemin *Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows NT\Terminal Services* après avoir renforcé l'OS.

### Verrouillage de session après 15 minutes d'inactivité

Le modèle `msft_security_baseline` pour Windows Server active le verrouillage de la session après 15 minutes d'inactivité. Il s'agit de la ligne de configuration suivante : *Interactive logon: Machine inactivity limit* (ID : 10208).

Vous pouvez donc supprimer ou modifier cette ligne sur le fichier CSV, ou supprimer la clé de registre **InactivityTimeoutSecs** au chemin *Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System* après avoir renforcé l'OS.
