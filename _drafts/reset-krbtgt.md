


[🔐 Changer le mot de passe du compte KRBTGT](https://unmotdepassepourri.substack.com/p/changer-le-mot-de-passe-du-compte)

```powershell
# Rewrite from https://github.com/zjorz/Public-AD-Scripts/blob/master/Reset-KrbTgt-Password-For-RWDCs-And-RODCs.ps1 because +8000 lines is just too much

# Requires -Version 5.1
# Requires -Modules ActiveDirectory
# Requires -RunAsAdministrator

# 1. Audit
# --------

# Affichage des informations de la forêt et du domaine
$forest = Get-ADForest
$domain = Get-ADDomain

if ([int]$domain.DomainMode -lt 3) {
    Write-Host "Domain functional level is lower than Windows 2003. This script is not supported."
    exit
}

[PSCustomObject]@{
    Forest      = $forest.Name
    ForestMode  = $forest.ForestMode
    Domain      = $domain.Name
    DomainMode  = $domain.DomainMode
    PDCEmulator = $domain.PDCEmulator
} | Format-List

# Affichage et récupération des informations sur la durée de vie des tickets Kerberos
$null = Get-GPResultantSetOfPolicy -ReportType Xml -Path "C:\temp\gprsop.xml"
$rsopXml = [xml](Get-Content -Path "C:\temp\gprsop.xml" -Raw)
$kerberosSettings = $rsopXml.rsop.ComputerResults.ExtensionData.Extension.Account | Where-Object { $_.Type -eq 'Kerberos' }
if ($kerberosSettings) {
    $maxTicketAge = ($kerberosSettings | Where-Object { $_.Name -eq 'MaxTicketAge' }).SettingNumber
    Write-Host "Kerberos ticket maximum age: $maxTicketAge hour(s)"
}

# Récupération des contrôleurs de domaine et des comptes KRBTGT associés
$dcs = Get-ADDomainController -Filter *
$dcs | Add-Member -MemberType NoteProperty -Name 'krbtgtAccount' -Value $null -Force

# Pour les RODC
$dcs | Where-Object { $_.IsReadOnly -eq $true } | ForEach-Object {
    $krbtgtDn = (Get-ADComputer $_.ComputerObjectDN -Properties 'msDS-KrbTgtLink').'msDS-KrbTgtLink'
    $_.krbtgtAccount = Get-ADUser -Filter { DistinguishedName -eq $krbtgtDn } -Properties passwordLastSet
}

# Pour les RWDC
$krbtgtSID = $domain.DomainSID.Value + '-502'
$krbtgt = Get-ADUser $krbtgtSID -Properties passwordLastSet, 'msDS-KeyVersionNumber'
$dcs | Where-Object { $_.IsReadOnly -eq $false } | ForEach-Object {
    $_.krbtgtAccount = $krbtgt
}

# Affichage des résultats
$dcs | Select-Object Name, Site, IsReadOnly, isGlobalCatalog, 
@{N = 'Account'; E = { $_.krbtgtAccount.SamAccountName } },
@{N = 'PwdLastSet'; E = { $_.krbtgtAccount.passwordLastSet } },
@{N = 'PwdAgeDays'; E = { [int](New-TimeSpan -Start $_.krbtgtAccount.passwordLastSet).TotalDays } },
@{N = 'PwdResetCount'; E = { if ($_.krbtgtAccount.SamAccountName -eq 'krbtgt') { $_.krbtgtAccount.'msDS-KeyVersionNumber' - 2 } else { [int]($_.krbtgtAccount.'msDS-KeyVersionNumber') } } } |
Sort-Object PasswordLastSet -Descending |
Format-Table

# 2. Simulation
# -------------

# Test de la connectivité LDAP et SSL
$dcs | Add-Member -MemberType NoteProperty -Name 'LdapConnectivity' -Value $null -Force
$dcs | Add-Member -MemberType NoteProperty -Name 'SslConnectivity' -Value $null -Force
$dcs | ForEach-Object {
    $_.LdapConnectivity = (Test-NetConnection -ComputerName $_.Name -Port $_.LdapPort).TcpTestSucceeded
    $_.SslConnectivity = (Test-NetConnection -ComputerName $_.Name -Port $_.SslPort).TcpTestSucceeded
}

# Affichage des résultats
$dcs | Select-Object Name, Site, IsReadOnly, LdapConnectivity, SslConnectivity |
Format-Table -AutoSize

# Filtrage des contrôleurs de domaine RWDC et RODC
$krbtgtToReset = ($dcs | Where-Object {
        $_.krbtgtAccount.PasswordLastSet -lt (Get-Date).AddHours(-10) -and
        $_.LdapConnectivity -eq $true -and
        $_.SslConnectivity -eq $true
    }).KrbTgtAccount | Sort-Object -Unique

# Vérification qu'aucun DC offline n'utilise un compte KRBTGT qui va être réinitialisé
$dcs | Where-Object {
    $_.krbtgtAccount -in $krbtgtToReset -and
    ($_.LdapConnectivity -eq $false -or $_.SslConnectivity -eq $false)
}

# 3. Réinitialisation
# -------------------

# Réinitialisation du mot de passe des comptes KRBTGT
$krbtgtToReset | ForEach-Object {
    $dn = $_.DistinguishedName
    $sam = $_.SamAccountName

    # Réinitialisation du mot de passe
    $password = New-Password -Length 127 -AsSecureString
    Set-ADAccountPassword -Identity $sam -NewPassword $password -Server $domain.PDCEmulator

    # Réplication du changement sur les contrôleurs de domaine concernés
    $dcs | Where-Object { $_.krbtgtAccount.SamAccountName -eq $sam } | ForEach-Object {
        Sync-ADObject -Identity $dn -Source $domain.PDCEmulator -Destination $_.HostName
    }   
}
```