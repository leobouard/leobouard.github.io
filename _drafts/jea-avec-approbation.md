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

- **JEA_Domain Admins_Requester** pour demander à être ajouter dans le groupe Domain Admins
- **JEA_Domain Admins_Approver** pour approuver les demandes d'ajout dans le groupe Domain Admins
- **JEA_Domain Admins_WaitingAttribution** qui va stocker les demandes en attente d'approbation

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
function New-JEARequestDC {
    param(
        [string]$Group,  # mandatory + validate set
        [int]$TimeToLive, # mandatory + validate range
        [string]$Reason # mandatory
    )

    $splat = @{
        Identity = (Get-ADGroup $Group).DistinguishedName
        Members = (Get-ADUser $env:username).DistinguishedName
        MemberTimeToLive = (New-TimeSpan -Days $TimeToLive+1)
    }
    $seeAlso = "$($env:username): $Reason"

    Enter-PSSession -ComputerName $domainController -ConfigurationName JEARequester -ScriptBlock {
        Add-ADGroupMember @splat
        Set-ADGroup $splat.Identity -Add @{ seeAlso = $seeAlso }
    }
}

function Get-JEARequest {
    $groups = Get-ADGroup -Filter { Name -like 'JEA_*_WaitingApprobation' } -Properties Members, SeeAlso -ShowMemberTimeToLive
    $groups | ForEach-Object {
        $name = ($_.Name -split '_' | Select-Object -Skip 1 -SkipLast 1) -join '_'
        $reasons = $_.SeeAlso
        $_.Members | ForEach-Object {
            [PSCustomObject]@{
                Requestor = $null
                Group = $name
                Timestamp = $null
                TimeToLive = $null
                Reason = $null
            }
        }
    }
}

function Approve-JEARequestDC {
    param(
        [string]Group,
        [string]$Member
    )

    $caller = $env:username
    if ($Member -eq $caller) { Write-Error "" }
    else {
        Add-ADGroupMember  -TimeToLive $ttl
        Set-ADGrou
        Remove-ADGroupMember
    }

}
```
