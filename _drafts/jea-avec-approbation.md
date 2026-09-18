---
title: "Approbation avec PowerShell JEA"
description: "Mise en place d'une preuve de concept pour un système d'approbation qui permet de devenir admin du domaine"
tags: ["activedirectory", "powershell"]
---

On va beaucoup utiliser la fonctionnalité d'appartenance temporaire à des groupes, disponible sur les domaines Active Directory en version 2016+.

Deux serveurs :

- Un serveur d'administration depuis lequel on va lancer les demandes JEA
- Un contrôleur de domaine qui va réceptionner les demandes JEA et les exécuter avec les permissions Domain Admins

Trois groupes :

- **JEA_Requesters** pour demander à être ajouter dans une sélection de groupes
- **JEA_Approvers** pour approuver les demandes d'ajout
- **JEA_WaitingAttribution_Domain Admins** qui va stocker les demandes en attente d'approbation

Deux profils JEA :

- JEARequester qui va permettre de faire une demande (groupe autorisé : JEA_Domain Admins_Requester)
- JEAApprover qui va permettre d'approuver les demandes (groupe autorisé : JEA_Domain Admins_Approver)

Même si un utilisateur a accès aux deux profils JEA, il ne pourra pas faire d'auto-approbation (accepter lui-même sa demande).

Comportement :

Les demandeurs sont ajoutés automatiquement dans le groupe WaitingAttribution, avec une durée de vie (TTL) de X jours qui va correspondre au nombre d'heures souhaitée pour l'appartenance au groupe demandé. Les groupes WaitingAttribution sont automatiquement purgés tous les jours à minuit pour nettoyer les demandes caduques. 

Les informations suivantes sont demandées pour toute requête :

- Groupe cible : va permettre d'ajouter l'utilisateur directement dans le groupe "WaitingApprobation" associé au groupe cible
- Durée demandée : va indiquer la durée d'appartenance au groupe cible et sera stockée dans le TTL du groupe "WaitingApprobation" (format 1 heure demandée = 1 jour + 1)
- Raison invoquée : va permettre de donner plus de détails sur la demande. Sera stockée dans l'attribut `SeeAlso` et préfixée par le nom du demandeur.

L'approbateur et le demandeur peuvent tous les deux consulter les demandes en attentes. Les informations suivantes sont affichées pour chaque demande :

- Demandeur de l'élévation (*exemple : adm-jsmith*)
- Groupe cible (*exemple : Domain Admins*)
- Heure de la demande, qui sera calculé à partir du TTL du membre dans le groupe WaitingAttribution
- Durée demandée (*exemple : 4 heures*)
- Raison invoquée (*exemple : Needs to install a new version of Entra ID Connect*)

L'approbateur peut finalement approuver une demande en indiquant le nom du groupe et le membre autorisé. L'approbation ajoute l'utilisateur dans le groupe cible avec le TTL demandé, et supprime l'appartenance au groupe WaitingAttribution.

```powershell
function New-JEARequest {
    param(
        [Parameter(Mandatory)][string]$Group,
        [Parameter(Mandatory)][ValidateRange(1, 24)][int]$TimeToLive,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Reason
    )

    $User = $env:USERNAME
    $domainController = (Get-ADDomainController -Discover).HostName
    Invoke-Command -ComputerName $domainController -ConfigurationName 'JEARequester' -ScriptBlock {
        param($Group, $TimeToLive, $Reason)
        New-JEADCRequest -Group $Group -TimeToLive $TimeToLive -Reason $Reason
    } -ArgumentList $User, $Group, $TimeToLive, $Reason
}

function New-JEADCRequest {
    param(
        [Parameter(Mandatory)][string]$Group,
        [Parameter(Mandatory)][string]$User,
        [Parameter(Mandatory)][ValidateRange(1, 24)][int]$TimeToLive,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string]$Reason
    )

    $waitingGroup = Get-ADGroup -Identity "JEA_WaitingAttribution_$Group" -ErrorAction Stop
    $requestor = Get-ADUser -Identity $env:USERNAME -ErrorAction Stop
    $entry = "$($requestor.SamAccountName):$TimeToLive`:$Reason"

    Add-ADGroupMember -Identity $waitingGroup -Members $requestor -MemberTimeToLive (New-TimeSpan -Days ($TimeToLive + 1))
    Set-ADGroup -Identity $waitingGroup -Add @{ SeeAlso = $entry }
    "Demande créée pour $($targetGroup.Name)."
}

function Get-JEARequest {
    $domainController = (Get-ADDomainController -Discover).HostName
    Invoke-Command -ComputerName $domainController -ConfigurationName 'JEARequester' -ScriptBlock {
        Get-JEADCRequest
    }
}

function Get-JEADCRequest {
    Get-ADGroup -Filter "Name -like 'JEA_WaitingAttribution_*'" -Properties Members, SeeAlso -ShowMemberTimeToLive |
        ForEach-Object {
            $waitingGroup = $_
            $targetName = $waitingGroup.Name.Substring(4, $waitingGroup.Name.Length - 23)

            foreach ($member in $waitingGroup.Members) {
                if ($member -notmatch '^<TTL=(\d+)>,(.+)$') { continue }

                $ttl = [int64]$Matches[1]
                $requestor = Get-ADUser -Identity $Matches[2] -Properties SamAccountName
                $entry = $waitingGroup.SeeAlso | Where-Object { $_ -like "$($requestor.SamAccountName):*" } | Select-Object -First 1
                $parts = $entry -split ':', 3
                $requestedHours = [int]$parts[1]

                [PSCustomObject]@{
                    Requestor = $requestor.SamAccountName
                    Group = $targetName
                    Timestamp = (Get-Date).AddSeconds($ttl).AddDays(-($requestedHours + 1))
                    TimeToLive = $requestedHours
                    Reason = $parts[2]
                }
            }
        }
}

function Approve-JEARequest {
    param(
        [Parameter(Mandatory)][string]$Group,
        [Parameter(Mandatory)][string]$Member
    )

    $domainController = (Get-ADDomainController -Discover).HostName
    Invoke-Command -ComputerName $domainController -ConfigurationName 'JEAApprover' -ScriptBlock {
        param($Group, $Member)
        Approve-JEADCRequest -Group $Group -Member $Member
    } -ArgumentList $Group, $Member
}

function Approve-JEADCRequest {
    param(
        [Parameter(Mandatory)][string]$Group,
        [Parameter(Mandatory)][string]$Member
    )

    $waitingGroup = Get-ADGroup -Identity "JEA_WaitingAttribution_$Group" -Properties Members, SeeAlso -ShowMemberTimeToLive -ErrorAction Stop
    $requestor = Get-ADUser -Identity $Member -Properties SamAccountName -ErrorAction Stop

    if ($requestor.SamAccountName -eq $env:USERNAME) {
        throw 'Un approbateur ne peut pas approuver sa propre demande.'
    }

    $memberEntry = $waitingGroup.Members | Where-Object { $_ -like "*,$($requestor.DistinguishedName)" -or $_ -eq $requestor.DistinguishedName } | Select-Object -First 1
    if ($memberEntry -notmatch '^<TTL=(\d+)>,') {
        throw "Aucune demande en attente pour $($requestor.SamAccountName) dans $($targetGroup.Name)."
    }

    $entry = $waitingGroup.SeeAlso | Where-Object { $_ -like "$($requestor.SamAccountName):*" } | Select-Object -First 1
    $requestedHours = [int](($entry -split ':', 3)[1])
    Add-ADGroupMember -Identity $targetGroup -Members $requestor -MemberTimeToLive (New-TimeSpan -Hours $requestedHours)
    Remove-ADGroupMember -Identity $waitingGroup -Members $requestor -Confirm:$false
    Set-ADGroup -Identity $waitingGroup -Remove @{ SeeAlso = $entry }
    "Demande approuvée pour $($requestor.SamAccountName)."
}

function Remove-JEAExpiredRequest {
    Get-ADGroup -Filter "Name -like 'JEA_WaitingAttribution_*'" -Properties Members, SeeAlso -ShowMemberTimeToLive |
        ForEach-Object {
            $waitingGroup = $_
            $activeRequestors = $waitingGroup.Members | ForEach-Object {
                if ($_ -match '^<TTL=\d+>,(.+)$') {
                    (Get-ADUser -Identity $Matches[1]).SamAccountName
                }
            }

            $waitingGroup.SeeAlso | Where-Object {
                $requestor = ($_ -split ':', 2)[0]
                $requestor -notin $activeRequestors
            } | ForEach-Object {
                Set-ADGroup -Identity $waitingGroup -Remove @{ SeeAlso = $_ }
            }
        }
}
```

Les fonctions `New-JEARequest`, `Get-JEARequest` et `Approve-JEARequest` sont les fonctions exposées aux utilisateurs. Les fonctions dont le nom se termine par `DC` sont celles exposées par les endpoints JEA sur le contrôleur de domaine.

Le groupe `JEA_WaitingAttribution_<groupe cible>` doit être crée pour chaque groupe administrable. La fonction `Remove-JEAExpiredRequest` peut être exécutée par une tache planifiée chaque nuit ; l'expiration TTL supprime deja les membres, et cette fonction nettoie les entrees correspondantes dans `SeeAlso`.

### Création des groupes

Création des trois groupes :

```powershell
$path = 'OU=Groups,OU=TIER0,DC=corp,DC=contoso,DC=com'
New-ADGroup -Name 'JEA_WaitingApprobation_Domain Admins' -Description 'Request the access to the Domain Admins group' -Path $path
New-ADGroup -Name 'JEA_Approvers' -Description 'Can approve membership for privileged groups' -Path $path
New-ADGroup -Name 'JEA_Requesters' -Description 'Can request membership to privileged groups' -Path $path
```

### Création de la configuration du JEA

```powershell
$path = 'C:\Program Files\WindowsPowerShell\Modules\JEADC'
New-Item -Type Directory -Path $path
```

### Fichier de configuration de session (PSSC)

PowerShell Session Configuration, avec la commande `New-PSSessionConfigurationFile`.

### Fichier de configuration du rôle (PSRC)

PowerShell Role Configuration, avec la commande `New-PSRoleCapabilityFile`.