Faire un backup des GPO :

```powershell
mkdir C:/temp/GPO_backup
$gpo = Get-Gpo -All
$gpo | Export-Csv -Path 'C:/temp/GPO_backup/referential.csv' -Delimiter ';' -Encoding UTF8 -NoTypeInformation
$gpo | Backup-Gpo -Path 'C:/temp/GPO_backup'
```



```powershell
$dnsRoot = (Get-ADDomain).DNSRoot
$gpo = Get-ChildItem -Path "\\$dnsRoot\SYSVOL\$dnsRoot\Policies" -Filter "{*}"

$gpo | Add-Member -MemberType NoteProperty -Name "GPOName" -Value $null -Force
$gpo | Add-Member -MemberType NoteProperty -Name "NTSecurityDescriptor" -Value $null -Force

$gpo | ForEach-Object {
    $_.GPOName = (Get-GPO -Guid $_.PSChildName).DisplayName
    $_.NTSecurityDescriptor = Get-Acl -Path $_.FullName
}

# Filter GPOs where 'Authenticated Users' do not have access
$gpo | Where-Object {$_.NTSecurityDescriptor.Access.IdentityReference -notcontains 'NT AUTHORITY\Authenticated Users'} |
    Select-Object GPOName, Name |
    Sort-Object GPOName

# Mettre en évidence les GPOs sans paramètres utilisateur actifs
$gpo = Get-GPO -All
$gpo | Where-Object {
    $_.User.DSVersion -eq 0 -and
    $_.User.SysvolVersion -eq 0 -and
    $_.GPOStatus -ne 'UserSettingsDisabled'
}

# Mettre en évidence les GPOs sans paramètres ordinateurs actifs
$gpo = Get-GPO -All
$gpo | Where-Object {
    $_.Computer.DSVersion -eq 0 -and
    $_.Computer.SysvolVersion -eq 0 -and
    $_.GPOStatus -ne 'ComputerSettingsDisabled'
}

# Afficher les GPO orphelines
$gpo = Get-GPO -All
$ous = Get-ADOrganizationalUnit -Filter * -Properties LinkedGroupPolicyObjects
$appliedGPO = $ous.LinkedGroupPolicyObjects | Sort-Object -Unique | ForEach-Object { ($_ -split '{' -split '}')[1] }
$gpo | Where-Object { $_.Id -notin $appliedGPO } | Sort-Object DisplayName | Select-Object DisplayName, Id
```

