# Nettoyage des permissions appliquées sur des GPO

Nettoyage des permissions accordées à un SID orphelins dans les GPO (partie GPT & GPC) :

```powershell
$gpo = Get-ADObject -Filter * -SearchBase "CN=Policies,CN=System,$((Get-ADDomain).DistinguishedName)" -SearchScope OneLevel -Properties NTSecurityDescriptor, gPCFileSysPath
$sid = 'S-1-5-21-XXXXXXXXXX-XXXXXXXXXX-XXXXXXXXX-XXXXX'

$gpo | Where-Object { $_.NTSecurityDescriptor.Access.IdentityReference -contains $sid } | ForEach-Object {
    # Show GPO name
    $gpoName = (Get-GPO -Guid $_.Name).DisplayName
    Write-Host $gpoName -ForegroundColor Yellow

    # Remove the ACE on GPC
    $gpcAcl = $_.NTSecurityDescriptor
    $gpcAcl.Access | Where-Object { $_.IdentityReference -eq $sid } | ForEach-Object {
        $gpcAcl.RemoveAccessRule($_)
    }
    $path = "AD:/$($_.DistinguishedName)"
    Set-Acl -Path $path -AclObject $gpcAcl

    # Remove the ACE on GPT
    $gptPath = $_.gPCFileSysPath
    $gptAcl = Get-Acl -Path $gptPath -EA Stop
    $gptAcl.Access | Where-Object { $_.IdentityReference -eq $sid } | ForEach-Object {
        $gptAcl.RemoveAccessRule($_)
    }
    Set-Acl -Path $gptPath -AclObject $gptAcl
}
```

Recherches des objets dans le SYSVOL avec des permissions anormales, basé sur le script de Mehdi Dakhama : https://github.com/dakhama-mehdi/Check_Sysvol_ACL/tree/main

```powershell
# Gather information about the domain and well-known SIDs
$dnsDomain = $env:USERDNSDOMAIN
$baseSID = ([System.Security.Principal.WindowsIdentity]::GetCurrent()).User.Value -replace '-\d+$', ''
$sids = @(
    'S-1-5-32-544', # Administrators
    'S-1-5-18',     # SYSTEM
    'S-1-3-0',      # CREATOR
    'S-1-5-32-549', # Server Operator
    "$baseSID-512", # Domain Admins
    "$baseSID-519", # Entreprise Admins
    "$baseSID-520", # Creator GPO
    'S-1-5-9'       # Enterprise DCs
)

# List of allowed permissions without warning
$noWarningPermissions = @(
    '-1610612736'
    'ReadAndExecute',
    'Read',
    'Synchronize',
    'Read, Synchronize',
    'ReadAndExecute, Synchronize',
    'ReadAttributes, ReadExtendedAttributes, ReadPermissions, Synchronize'
)

# Convert SIDs to NTAccount names
$groups = $sids | ForEach-Object {
    $sid = [System.Security.Principal.SecurityIdentifier]::New($_)
    try { $sid.Translate([System.Security.Principal.NTAccount]).Value }
    catch { $sid.value }
}

# Gather files from SYSVOL folder & their ACLs
$sysvolPath = "\\$dnsDomain\SYSVOL\$dnsDomain"
$files = Get-ChildItem -Path $sysvolPath -Recurse -Force -ErrorAction SilentlyContinue
$files | Add-Member -MemberType NoteProperty -Name 'Access' -Value $null -Force
$files | ForEach-Object { 
    $_.Access = (Get-Acl -Path $_.FullName).Access | Where-Object {
        $_.IsInherited -eq $false -and
        $groups -notcontains $_.IdentityReference.Value -and
        $_.FileSystemRights -notin $noWarningPermissions
    }
}

# Show report
$files | Where-Object {$_.Access} |
    Select-Object Name, CreationTime, LastWriteTime,
        @{Name = 'GPOName' ; Expression = { (Get-GPO -Id $_.Name).DisplayName } },
        @{Name = 'IdentityReference' ; Expression = { $_.Access.IdentityReference } },
        @{Name = 'FileSystemRights' ; Expression = { $_.Access.FileSystemRights } },
        FullName


```

Analyse des GPC sur les permissions :

```powershell
$searchBase = "CN=Policies,CN=System,$((Get-ADDomain).DistinguishedName)"
$objects = Get-ADObject -Filter * -Properties NTSecurityDescriptor, CanonicalName -SearchBase $searchBase

$objects | Where-Object { $_.NTSecurityDescriptor.Access.IdentityReference -like '*S-1-5-21-*'} |
    Select-Object Name, ObjectClass, @{N="Owner";E={$_.NTSecurityDescriptor.Owner}}, CanonicalName
```
