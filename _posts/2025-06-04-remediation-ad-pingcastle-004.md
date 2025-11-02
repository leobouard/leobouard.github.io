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

Modification de la GPO *Default Domain Controller Policy* pour générer les événements recommandés. La liste des événements requis est disponible ici (sur le paramètre le plus fort) : [System Audit Policy recommendations \| Microsoft Learn](https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/plan/security-best-practices/audit-policy-recommendations?tabs=winclient)

{% include risk-score.html impact=1 probability=1 comment="L'activation d’audit augmente le volume de logs mais n’introduit pas de vrai risque pour votre domaine." %}

## Sauvegarde

### A-BackupMetadata

### A-NotEnoughDC

Votre domaine ne tient que sur "une patte". Vous devez monter un nouveau contrôleur de domaine au plus vite pour suivre les bonnes pratiques. Et malheureusement cette vulnérabilité n'est pas réservée qu'aux labs.

{% include risk-score.html impact=1 probability=1 comment="Aucun impact à prévoir sur le fait d'ajouter un contrôleur de domaine, si ce n'est une licence Windows Server et un peu de ressources sur votre hyperviseur." %}

## Golden Ticket

### A-Krbtgt

Le mot de passe du compte krbtgt utilisé par les contrôleurs de domaine n'a pas été changé depuis plus d'un an. Pour faire plaisir à Ping Castle, vous n'avez qu'à le changer une seule fois, mais la bonne pratique est de le faire deux fois, avec 10 heures d'écart entre les deux changements. Ce délai correspond à la durée de vie maximum des tickets Kerberos dans votre domaine.

> Attention : 10 heures c'est la configuration par défaut, mais celle de votre domaine est peut-être différente. Vous pouvez vérifier votre configuration dans la Default Domain Policy.

Le script référence pour faire ça est celui de Jorge de Almeida Pinto disponible ici : [Public-AD-Scripts/Reset-KrbTgt-Password-For-RWDCs-And-RODCs.ps1 at master · zjorz/Public-AD-Scripts · GitHub](https://github.com/zjorz/Public-AD-Scripts/blob/master/Reset-KrbTgt-Password-For-RWDCs-And-RODCs.ps1)

{% include risk-score.html impact=5 probability=2 comment="Un mauvais changement de mot de passe krbtgt peut bloquer les authentifications sur votre domaine, donc veillez à ne pas avoir de problèmes de réplication avant de jouer avec ça." %}

## Vulnérabilités liées aux groupes restreints

### A-MembershipEveryone

Un groupe comme "Authenticated Users", "Domain Users" ou "Everyone" est ajouté dans un groupe restreint par GPO (du type "Utilisateurs du bureau à distance" ou "Administrateurs"). Pour suivre le principe du privilège le moins élevé, vous devez réduire l'étendue de ces groupes au minimum requis.

Par exemple : remplacer "Domain Users" par "Employés de CONTOSO" qui ne contiendrait que les utilisateurs ayant besoin d'être membre du groupe "Utilisateurs du bureau à distance" de certains serveurs.

{% include risk-score.html impact=2 probability=3 comment="Ce changement concerne tous les comptes du domaine, donc une mauvaise configuration peut bloquer l'accès à une ressource de manière temporaire." %}

## Reniflage du réseau

### A-LMHashAuthorized

Ce paramètre a probablement été activé pour des raisons de compatibilité avec des vieilles versions de Windows Server (avant 2003). Si votre domaine ne contient plus de Windows Server 2000 ou antérieur, vous devriez pouvoir désactiver ce paramètre sans risque.

Plus d'information sur le hash LM ici : [LM, NTLM, Net-NTLMv2, oh my!. A Pentester’s Guide to Windows Hashes \| by Péter Gombos \| Medium](https://medium.com/@petergombos/lm-ntlm-net-ntlmv2-oh-my-a9b235c58ed4)

{% include risk-score.html impact=1 probability=1 comment="Si vous n'avez plus aucun Windows Server 2000 et antérieur dans votre domaine, ce changement ne devrait pas avoir d'impact sur les autres ressources." %}

### A-DnsZoneAUCreateChild

Par défaut, le fait de créer un enregistrement DNS est autorisé pour tous les utilisateurs et ordinateurs du domaine (*Authenticated Users*). Une façon rapide de réduire le risque lié à cette vulnérabilité est de remplacer cette permission accordée à *Authenticated Users* par une permission ciblée sur *Domain Computers*. Pour certaines zones DNS, on peut même envisager de supprimer cette permission (à voir au cas par cas).

Le code proposé remplace les permissions données à *Authenticated Users* pour *Domain Computers* sur toutes les zones DNS. Il est inspiré ce celui de [WS IT-Solutions](https://www.ws-its.de/gegenmassnahme-zum-angriff-dns-wildcard/) (article en allemand).

```powershell
# Get 'Domain Computers' group
$domainSID = (Get-ADDomain).DomainSID.Value
$domainComputers = [System.Security.Principal.NTAccount]::New((Get-ADGroup "$domainSID-515").SamAccountName)

# Get all dnsZones
$domainDn = (Get-ADDomain).DistinguishedName
$dnsZones = "CN=MicrosoftDNS,DC=DomainDnsZones,$DomainDn", "CN=MicrosoftDNS,DC=ForestDnsZones,$DomainDn" | ForEach-Object {
    Get-ADObject -Filter { objectClass -eq 'dnsZone' } -SearchBase $_ -Properties NTSecurityDescriptor
}

# Variables for permissions
$createChild = [System.DirectoryServices.ActiveDirectoryRights]::CreateChild
$allow = [System.Security.AccessControl.AccessControlType]::Allow

# Replace permissions for 'Authenticated Users' by 'Domain Computers'
$dnsZones | ForEach-Object {
    Write-Host $_.Name -ForegroundColor Yellow
    $acl = $_.NTSecurityDescriptor

    $acl.Access | Where-Object {
        $_.IdentityReference -eq 'NT AUTHORITY\Authenticated Users' -and
        $_.IsInherited -eq $false -and
        $_.ActiveDirectoryRights -eq $createChild -and
        $_.AccessControlType -eq $allow
    } | ForEach-Object {

        # Remove permission for 'Authenticated Users'
        $acl.RemoveAccessRuleSpecific($_)

        # Create and add permission for 'Domain Computers'
        $acl.AddAccessRule([System.DirectoryServices.ActiveDirectoryAccessRule]::New($domainComputers, $createChild, $allow))

        $updateAcl = $true
    }

    # Apply new ACL
    if ($updateAcl) {
        Write-Host "Modification have been made to the dnsZone!"
        Set-Acl -Path "AD:\$($_.DistinguishedName)" -AclObject $acl -Confirm:$false
    }

    $updateAcl = $false
}
```

{% include risk-score.html impact=2 probability=2 comment="Je n'ai jamais eu de soucis en faisant cette manipulation, mais il se peut qu'un processus puisse être impacté. Le retour arrière est très simple et vous pouvez avancer zone par zone pour réduire l'impact." %}

### A-DnsZoneUpdate2

### A-DnsZoneUpdate1

### A-NoGPOLLMNR

Ajout du paramètre suivant par GPO : *Configuration ordinateur > Modèles d'administration > Réseau > Client DNS* et activer le paramètre suivant **Désactiver la résolution de noms multidiffusion**.

Plus d'informations sur le LLMNR ici : [Comment et pourquoi désactiver LLMNR et NetBIOS ? - IT-Connect](https://www.it-connect.fr/active-directory-comment-et-pourquoi-desactiver-les-llmnr-et-netbios/)

{% include risk-score.html impact=1 probability=1 comment="Je n'ai jamais eu de soucis en faisant cette manipulation. Vous pouvez déployer la GPO de manière progressive en passant par un groupe de ciblage ou en liant la GPO au fur et à mesure si vous voulez être très prudent." %}

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
\\\\*\NETLOGON | RequireMutualAuthentication=1, RequireIntegrity=1
\\\\*\SYSVOL | RequireMutualAuthentication=1, RequireIntegrity=1

> Il existe un troisième paramètre `RequirePrivacy=1` qui impose l'utilisation du chiffrement SMB, disponible seulement à partir de Windows 8 & Windows Server 2012. Si votre parc contient des OS plus anciens, n'ajoutez pas l'option.

Pour plus d'informations : [Active Directory - Découverte des chemins UNC durcis](https://www.it-connect.fr/active-directory-securite-du-partage-sysvol-avec-les-chemins-unc-durcis/)

{% include risk-score.html impact=1 probability=1 comment="Je n'ai jamais eu d'impact sur le déploiement de ce paramètre, même avec la présence d'OS très vieux comme des Windows XP ou Windows Server 2003." %}

## Pass-the-credential

### A-SmartCardPwdRotation

Vous pouvez lister l'intégralité des objets qui requièrent l'utilisation d'une smart card avec la commande suivante :

```powershell
Get-ADObject -Filter {UserAccountControl -band 262144}
```

En fonction des résultats obtenus, vous pouvez activer la fonctionnalité de rotation du hash de mot de passe automatique pour les comptes avec smart card sur votre domaine :

```powershell
Set-ADObject (Get-ADDomain) -Replace @{ 'msDS-ExpirePasswordsOnSmartCardOnlyAccounts' = $true }
```

{% include risk-score.html impact=2 probability=3 comment="L'impact et la probabilité dépendent fortement du nombre d'objets concernés et de leur criticité." %}

### A-SmartCardRequired

### A-ProtectedUsers

Vérifie la présence du groupe "Protected Users", qui est créé automatiquement lorsque le rôle FSMO "PDC" est transféré vers un Windows Server 2012 ou ultérieur. Le groupe "Protected Users" possède le RID "-525".

Recherche du groupe dans le domaine :

```powershell
$domainSid = (Get-ADDomain).DomainSID
Get-ADGroup "$domainSid-525"
```

{% include risk-score.html impact=1 probability=1 comment="Ce point n'est pas risqué, c'est le transfert du rôle PDC qui constitue le risque." %}

### A-LAPS-Joined-Computers

Certains ordinateurs ont comme propriétaire le compte utilisateur qui les a joint au domaine. Le propriétaire de l'objet ordinateur peut alors lire l'attribut `ms-mcs-AdmPwd` qui contient le mot de passe du compte administrateur local géré par LAPS Legacy. Vous pouvez lister les propriétaires des ordinateurs avec la ligne de commande suivante :

```powershell
Get-ADComputer -Filter * -Properties NTSecurityDescriptor |
    Select-Object *, @{N='Owner' ; E={$_.NTSecurityDescriptor.Owner}} |
    Group-Object Owner -NoElement |
    Sort-Object Count -Descending |
    Format-Table -AutoSize
```

La résolution consiste simplement à remettre le propriétaire par défaut (*Domain Admins* la plupart du temps) et réinitialiser les ACLs de l'objet. Vous pouvez faire cette opération en PowerShell avec la commande suivante :

{% include github-gist.html name="Reset-ADPermission" id="e610f4d49dd58c66c3ed023256b33384" %}

> Il est impossible de nettoyer l'attribut `ms-ds-CreatorSid` car celui-ci est géré par le système.

{% include risk-score.html impact=2 probability=2 comment="Je n'ai jamais eu de soucis sur la réinitialisation des permissions et du propriétaire des objets ordinateurs." %}

### A-LAPS-Not-Installed

Ping Castle va regarder si le schéma Active Directory a été étendu pour Microsoft LAPS (l'ancien) et/ou Windows LAPS (le nouveau). Pour des environnements sans OS obsolètes (et donc compatible avec Windows LAPS), ne vous embêtez pas à mettre en place Microsoft LAPS.

- Pour Microsoft LAPS : [Qu'est ce que Microsoft LAPS et comment le mettre en place ?](https://help.stoik.io/quest-ce-que-microsoft-laps-et-comment-le-mettre-en-place)
- Pour Windows LAPS : [Bien démarrer avec Windows LAPS et Windows Server Active Directory \| Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/identity/laps/laps-scenarios-windows-server-active-directory)

{% include risk-score.html impact=1 probability=1 comment="La modification du schéma peut faire peur, mais pas de soucis à se faire si votre environement Active Directory est sain." }

### A-DCRefuseComputerPwdChange

### A-DC-Spooler

Le service d'impression (*print spooler*) d'au moins un contrôleur de domaine est actif. Celui-ci ouvre beaucoup de failles sur un serveur qui n'a aucun intérêt à avoir ce service d'impression actif (du moins normalement).

Le plus efficace est de désactiver le service par GPO avec la documentation suivante : [Permanently disable print spooler service on domain controller - Microsoft Q&A](https://learn.microsoft.com/en-us/answers/questions/2190588/permanently-disable-print-spooler-service-on-domai)

{% include risk-score.html impact=1 probability=2 comment="Si un contrôleur de domaine utilise réellement le service d'impression, revoyez les bonnes pratiques de base." }

### A-DC-WebClient

### A-DC-Coerce

## Récupération de mot de passe

### A-ReversiblePwd

### A-UnixPwd

### A-PwdGPO

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

Ce point évalue la présence de membres autres que "Authenticated Users" dans le groupe "Pre-Windows 2000 Compatible Access". La plupart du temps, dans les configurations par défaut, on retrouve les serveurs liés à l'autorité de certification (PKI) dans ce groupe.

La présence du ou des serveurs PKI dans ce groupe est liée à l'option "Restrict certificate managers". Si celle-ci n'est pas activée, vous pouvez supprimer les serveurs PKI du groupe "Pre-Windows 2000 Compatible Access".

> Le groupe "Pre-Windows 2000 Compatible Access" est souvent utilisé pour autoriser ses membres à lire toutes les propriétés des utilisateurs et des groupes du domaine (dont la propriété MemberOf).

La source plus complète : [Why Active Directory integrated certificate authorities are members of the "Pre-Windows 2000 Compatible Access" security group - Uwe Gradenegger](https://www.gradenegger.eu/en/why-active-directory-integrated-certification-authorities-are-members-of-pre-windows-2000-compatible-access/)

{% include risk-score.html impact=3 probability=3 comment="S'il s'agit de serveurs PKI, les impacts sont connus. Sinon, vous pouvez vous réferez au point A-PreWin2000AuthenticatedUsers." %}

### A-RootDseAnonBinding

### A-NullSession

## Administrateurs temporaires

### A-AdminSDHolder

Un ou plusieurs comptes n'ayant plus de privilèges ont encore la valeur 1 définie dans l'attribut `adminCount`. Cette valeur indique qu'un compte a fait partie d'un groupe à haut privilège (comme *Domain Admins* par exemple). Rien de grave à cela, il s'agit juste de vérifier que les comptes indiqués ont bien reçu leurs privilèges passés de manière légitime.

Voici une commande PowerShell pour nettoyer l'attribut sur les comptes illégitimes :

```powershell
Get-ADUser -Filter {adminCount -eq 1} -Properties adminCount, NTSecurityDescriptor |
    Where-Object {$_.NTSecurityDescriptor.Access.IsInherited -eq $true} |
    Set-ADUser -Clear adminCount -Verbose
```

Et j'ai fait un article pour obtenir la date d'ajout/suppression d'un membre dans un groupe, ce qui peut être utile sur cette vulnérabilité : [Trouver la date d’ajout d’un membre dans un groupe \| LaBouaBouate](https://www.labouabouate.fr/2025/07/16/date-ajout-membre-groupe).

{% include risk-score.html impact=1 probability=1 comment="La manipulation est sans risque." %}

## Mots de passe faibles

### A-LimitBlankPasswordUse

### A-MinPwdLen

Une stratégie de mot de passe imposant moins de 8 caractères de long est présente dans le domaine. Le standard actuel dans les organisations est plutôt aux alentours de 12 caractères de long, et 8 caractères est considéré comme la limite basse. Pour résoudre cette vulnérabilité, vous n'avez qu'à augmenter le nombre de caractères minimum requis sur votre politique de mot de passe 
(*Default Domain Password Policy* ou *Fine-grained Password Policy*).

Modifier ce paramètre n'impacte pas les mots de passe qui ont déjà été définis, mais impactera tous les changements de mots de passe après modification de la politique. Il y a donc beaucoup de communication à faire en amont de ce changement pour éviter les impacts.

Pour modifier la *Default Domain Password Policy* à 12 caractères minimum :

```powershell
Set-ADDefaultDomainPasswordPolicy -MinPasswordLength 12
```

Pour modifier la *Fine-grained Password Policy* nommée "Employees" à 12 caractères minimum :

```powershell
Set-ADDefaultDomainPasswordPolicy -Identity 'Employees' -MinPasswordLength 12
```

{% include risk-score.html impact=4 probability=3 comment="Sans communication préalable auprès du support et des utilisateurs, c'est le désastre assuré lors du prochain changement de mot de passe pour 90% des utilisateurs du domaine. Ce point n'est pas technique mais purement organisationnel." %}

### A-Guest

Le compte "Invité" (Guest en anglais) est activé, ce qui permet à n'importe qui de se connecter à Active Directory. A moins d'une configuration spécifique, vous devez désactiver le compte au plus vite :

```powershell
$domainSID = (Get-ADDomain).DomainSID
Set-ADUser -Identity "$domainSID-501" -Enabled:$false
```

{% include risk-score.html impact=3 probability=3 comment="L'impact varie en fonction de l'utilisation qui est faite du compte 'Invité'. Je n'ai jamais été confronté au problème donc je n'ai pas plus d'information à partager sur le sujet." %}

### A-NoServicePolicy

Aucune politique de mot de passe imposant une longueur minimum de 20 caractères n'a été trouvé (idéal pour les comptes de service). Si vous n'exécutez pas Ping Castle avec des privilèges d'administrateur du domaine, il est possible qu'il s'agisse d'un faux positif (la PSO existe mais vous ne la voyez pas). Vous pouvez lister les objets autorisés à lire les PSO avec la ligne de commande suivante :

```powershell
$dn = "CN=Password Settings Container,CN=System,$((Get-ADDomain).DistinguishedName)"
(Get-ADObject $dn -Properties NTSecurityDescriptor).NTSecurityDescriptor.Access |
    Where-Object {$_.ActiveDirectoryRights -match 'ListChildren|GenericRead'} |
    Group-Object IdentityReference -NoElement |
    Format-Table -AutoSize
```

Et si vous n'avez pas de PSO pour les comptes de service, vous pouvez en créer une facilement avec la commande suivante :

```powershell
$splat = @{
    # General settings
    Name = 'PSO - Service accounts'
    Description = 'Very strong passwords with longer lifetime'
    Precedence = 100
    ProtectedFromAccidentalDeletion = $true 
    # Password settings
    MaxPasswordAge = (New-TimeSpan -Days 370)
    MinPasswordAge = (New-TimeSpan -Days 1)
    MinPasswordLength = 20
    ComplexityEnabled = $true
    PasswordHistoryCount = 24
    ReversibleEncryptionEnabled = $false
    # Lockout settings
    LockoutDuration = (New-TimeSpan -Days 1)
    LockoutObservationWindow = (New-TimeSpan -Days 1)
    LockoutThreshold = 10
}
New-ADFineGrainedPasswordPolicy @splat
```

{% include risk-score.html impact=1 probability=1 comment="Aucun impact à prévoir sur la création d'une PSO, mais attention sur le paramètre 'MaxPasswordAge' si vous comptez l'appliquer à des comptes : vous pourriez risquer de faire expirer le mot de passe immédiatement." %}
