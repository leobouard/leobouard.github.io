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

- **JEA_Requesters_Domain Admins** pour demander à être ajouter dans une sélection de groupes
- **JEA_Approvers_Domain Admins** pour approuver les demandes d'ajout
- **JEA_WaitingApproval_Domain Admins** qui va stocker les demandes en attente d'approbation

Deux profils JEA :

- JEARequesterDA qui va permettre de faire une demande (groupe autorisé : JEA_Requesters_Domain Admins)
- JEAApproverDA qui va permettre d'approuver les demandes (groupe autorisé : JEA_Approvers_Domain Admins)

Même si un utilisateur a accès aux deux profils JEA, il ne pourra pas faire d'auto-approbation (accepter lui-même sa demande).

Comportement :

Les demandeurs sont ajoutés automatiquement dans le groupe JEA_WaitingAttribution_, avec une durée de vie (TTL) de X jours qui va correspondre au nombre d'heures souhaitées pour l'appartenance au groupe demandé. Les groupes JEA_WaitingAttribution_ sont automatiquement purgés tous les jours à minuit pour nettoyer les demandes caduques.

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
        [Parameter(Mandatory)][ValidateRange(1, 24)][int]$Hours,
        [Parameter(Mandatory)][ValidateLength(8, 120)[string]$Reason
    )

    Invoke-Command -ComputerName (Get-ADDomainController).HostName -ConfigurationName JEAApprobation -ArgumentList $Group, $Hours -ScriptBlock {
        New-JEADCRequest -Group $args[0] -Hours $args[1] -Reason $Reason
    }
}

function New-JEADCRequest {
    param(
        [Parameter(Mandatory)][string]$Group,
        [Parameter(Mandatory)][ValidateRange(1, 24)][int]$Hours,
        [Parameter(Mandatory)][ValidateLength(8, 120)][string]$Reason
    )

    # Add member with TTL
    $member = (Get-ADUser [System.Security.Principal.NTAccount]::New($PSSenderInfo.ConnectedUser).Translate([System.Security.Principal.SecurityIdentifier])).SamAccountName
    $splat = @{
        Identity         = Get-ADGroup -Identity "JEA_WaitingApproval_$Group"
        Members          = $member
        MemberTimeToLive = New-TimeSpan -Days ($Hours + 1)
    }
    Add-ADGroupMember @splat

    # Add reason
    $Reason = $Reason -replace ':', '' -replace "`n", ''
    $group = Get-ADGroup $splat.Identity -Properties nTGroupMembers
    $group.nTGroupMembers | ForEach-Object {
        $text = [System.Text.Encoding]::UTF8.GetString($_)
        if ($text -like "$member:*") { Set-ADGroup $group -Remove @{ nTGroupMembers = $_ } }
    }
    Set-ADGroup $group -Add @{ nTGroupMembers = "$member:$Reason" }
}

function Get-JEARequest {
    Get-ADGroup -Filter { Name -like 'JEA_WaitingApproval_*' } -Properties Members, nTGroupMembers -ShowMemberTimeToLive | ForEach-Object {
        $waGroup = $_.Name
        $group = ($waGroup -split '_' | Select-Object -Skip 2) -join '_'
        $reasons = $_.nTGroupMembers | ForEach-Object { 
            $raw = [System.Text.Encoding]::UTF8.GetString($_) -split ':'
            [PSCustomObject]@{
                Requestor = $raw[0]
                Reason    = $raw[1]
            }    
        }

        $_.Members | ForEach-Object {
            if ($_ -match "<TTL=(\d+)>") {
                $sec   = $matches[1]
                $ttl   = New-TimeSpan -Seconds $sec
                $hours = [int]$ttl.TotalDays
                $dn    = ($_ -split ',' | Select-Object -Skip 1) -join ','
                $user = (Get-ADUser $dn).SamAccountName

                [PSCustomObject]@{
                    Group     = $group
                    Requestor = $user
                    Hours     = $hours
                    Timestamp = (Get-Date).AddSeconds($sec).AddDays(-$hours)
                    Reason    = ($reasons | Where-Object { $_.Requestor -eq $user }).Reason
                }
            }
        }
    }
}

function Approve-JEARequest {
    param(
        [Parameter(Mandatory)][string]$Group,
        [Parameter(Mandatory)][string]$Requestor
    )

    Invoke-Command -ComputerName (Get-ADDomainController).HostName -ConfigurationName JEAApprobation -ArgumentList $Group, $Requestor -ScriptBlock {
        Approve-JEADCRequest -Group $args[0] -Requestor $args[1]
    }
}

function Approve-JEADCRequest {
    param(
        [Parameter(Mandatory)][string]$Group,
        [Parameter(Mandatory)][string]$Requestor
    )

    $waGroup     = Get-ADGroup -Identity "JEA_WaitingApproval_$Group" -Properties Members, nTGroupMembers -ShowMemberTimeToLive
    $approverSid = [System.Security.Principal.NTAccount]::New($PSSenderInfo.ConnectedUser).Translate([System.Security.Principal.SecurityIdentifier]).Value
    $member      = Get-ADUser $Requestor -Properties ObjectSid
    $memberSid   = $member.objectSid.Value

    if ($approverSid -eq $memberSid) { throw "You can't approve your own request" }

    $memberWithTTL = $waGroup.Members -like "<TTL=*>,$($member.DistinguishedName)"
    if ($memberWithTTL) {
        $ttl = ($memberWithTTL -split ',')[0]
        $ttl = $ttl -replace '<TTL=', '' -replace '>', ''
        $hours = [int](New-TimeSpan -Seconds $ttl).TotalDays

        Add-ADGroupMember $Group -Members $member -MemberTimeToLive (New-TimeSpan -Hours $hours)
        Remove-ADGroupMember $waGroup -Members $member -Confirm:$false
        
        $waGroup.nTGroupMembers | ForEach-Object {
            $text = [System.Text.Encoding]::UTF8.GetString($_)
            if ($text -like "$($member.SamAccountName):*") { Set-ADGroup $group -Remove @{ nTGroupMembers = $_ } }
        }
    }
    else {
        throw "No request has been found for $Requestor on $Group"
    }
}

function Clear-JEARequest {
    param([string]$Group = '*')

    $filter = "JEA_WaitingApproval_$Group"
    Get-ADGroup -Filter { Name -like $filter } -Properties members | ForEach-Object {
        Remove-ADGroupMember $_ -Members $_.members -Confirm:$false
        Set-ADGroup $_ -Clear nTGroupMembers
    }
}
```

Les fonctions `New-JEARequest`, `Get-JEARequest` et `Approve-JEARequest` sont les fonctions exposées aux utilisateurs. Les fonctions dont le nom se termine par `DC` sont celles exposées par les endpoints JEA sur le contrôleur de domaine.

Le groupe `JEA_WaitingApproval_<groupe cible>` doit être crée pour chaque groupe administrable.

### Création des groupes

Création des trois groupes :

```powershell
$path = 'OU=Groups,OU=TIER0,DC=corp,DC=contoso,DC=com'
'Domain Admins', 'Schema Admins', 'Enterprise Admins' | ForEach-Object {
    New-ADGroup -Name "JEA_WaitingApprobation_$_" -Description "Has requested an access to '$_' group" -Path $path
    New-ADGroup -Name "JEA_Approvers_$_" -Description "Can approve membership for privileged '$_' group" -Path $path
    New-ADGroup -Name "JEA_Requesters_$_" -Description "Can request membership to privileged '$_' group" -Path $path
}
```

### Création de la configuration du JEA

```powershell
New-Item -Type Directory -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAApprobation'
New-Item -Type Directory -Path 'C:\ProgramData\JEAApprobation\Transcripts'
```

### Fichier de configuration de session (PSSC)

PowerShell Session Configuration, avec la commande `New-PSSessionConfigurationFile`.

On va créer le fichier `SessionConfiguration.pssc` dans le dossier du module.

```powershell
@{
    SchemaVersion       = '2.0.0.0'
    GUID                = 'f8072fe2-2f5b-4790-9546-45df9fd3a312'
    Author              = 'Léo Bouard'
    Description         = 'Endpoint JEA pour les demandes JEADC'
    SessionType         = 'RestrictedRemoteServer'
    TranscriptDirectory = 'C:\ProgramData\JEADC\Transcripts'
    RunAsVirtualAccount = $true
    ModulesToImport     = 'JEAApprobation', 'ActiveDirectory'
    RoleDefinitions     = @{
        'CORP\JEA_Approvers_Domain Admins'  = @{ RoleCapabilities = 'ApproverDA' }
        'CORP\JEA_Requesters_Domain Admins' = @{ RoleCapabilities = 'RequesterDA' }
    }
}
```

### Fichier de configuration du rôle (PSRC)

PowerShell Role Configuration, avec la commande `New-PSRoleCapabilityFile`.

Pour le rôle "RequesterDA" :

```powershell
@{
    GUID = '21155f4e-ec27-41fd-b63a-ce7e011bdd19'
    VisibleFunctions = @(
        @{
            Name = 'New-JEADCRequest'
            Parameters = @{ Name = 'Group' ; ValidateSet = 'Domain Admins' }, @{ Name = 'Hours' }, @{ Name = 'Reason' }
        }
    )
}
```

Pour le role "ApproverDA" :

```powershell
@{
    GUID = 'd0611c28-162d-431a-b031-81635d31ceda'
    VisibleFunctions = @(
        @{
            Name = 'Approve-JEADCRequest'
            Parameters = @{ Name = 'Group'; ValidateSet = 'Domain Admins' }, @{ Name = 'Requestor' }
        }
    )
}
```

### Activation sur le contrôleur de domaine

Puis on l'enregistre depuis le contrôleur de domaine avec la commande :

```powershell
Register-PSSessionConfiguration -Name JEAApprobation -Path 'C:\Program Files\WindowsPowerShell\Modules\JEAApprobation\SessionConfiguration.pssc'
```

> Si jamais vous devez modifier le fichier, vous allez devoir "rafraîchir" la configuration en la supprimant avec la commande `Unregister-PSSessionConfiguration -Name JEAApprobation` puis en ré-exécutant la commande d'enregistrement précédente et en redémarrant le service WinRM avec `Restart-Service WinRM`.
