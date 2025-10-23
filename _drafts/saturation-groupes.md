Sources :

- https://pentera.io/fr/resources/research/dos-attack-active-directory-sid-exploitation/
- https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/kerberos-authentication-problems-if-user-belongs-to-groups

## Principe

Le nombre maximum de groupes qu’un utilisateur Active Directory peut avoir avant de rencontrer des problèmes de connexion (« too many security IDs ») dépend de la taille maximale du ticket Kerberos (le « token de sécurité »).

Limite classique :

Par défaut, la taille maximale du token Kerberos est de 12 000 octets (peut être augmentée jusqu’à 48 000).
En pratique, cela correspond à environ 1 015 groupes (groupes globaux, universels et locaux confondus) pour un utilisateur.
- Au-delà de cette limite, l’utilisateur ne pourra plus se connecter à certains services (notamment via Kerberos) et recevra des erreurs du type :
- The user's security ID is too large ou too many security IDs.

Résumé :

- Environ 1 015 groupes maximum par utilisateur avant d’avoir des problèmes de connexion liés à la taille du token Kerberos.
- Cette limite peut varier selon la configuration de la taille du token sur les DC et les clients.

La limite concerne tous les groupes dont l’utilisateur est membre, y compris :

Les groupes où il est membre direct et
Les groupes où il est membre de façon indirecte (par récursivité)
Autrement dit, tous les groupes imbriqués sont pris en compte dans le calcul de la taille du token Kerberos.
C’est la somme totale des appartenances, directes et indirectes, qui compte.

## Calcul du nombre

1200 + (40 x appartenance à des groupes d'autres domaines + SIDHistory) + (8 x appartenance à un groupe du domaine)

(48000-1200) / 8 = 5850 groupes

## Méthode pour tout casser

Créer X groupes locaux, ajouter ces groupes en tant que membre de Domain Users

## Méthode de contournement

Pour augmenter cette limite, il faut augmenter la taille maximale du token Kerberos sur les contrôleurs de domaine et les clients Windows.

Procédure :

1. Modifier la clé de registre suivante sur les DC et les clients :
1. Créer ou modifier la valeur DWORD :
  - Nom : MaxTokenSize
  - Valeur : jusqu’à 48000 (décimal) maximum
1. Redémarrer les machines concernées pour que la modification soit prise en compte.

Exemple PowerShell :

```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters" `
  -Name "MaxTokenSize" -PropertyType DWord -Value 48000 -Force
```

Attention :

Même en augmentant cette valeur, il existe toujours une limite physique (taille du ticket, MTU réseau, etc.).
Il est préférable de revoir la gestion des groupes si vous approchez cette limite, plutôt que de l’augmenter indéfiniment.
