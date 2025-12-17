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
$gpo | Where-Object {$_.NTSecurityDescriptor.Access.IdentityReference -notcontains 'NT AUTHORITY\Authenticated Users'}

# Mettre en évidence les GPOs sans paramètres utilisateur actifs
$gpo = Get-GPO -All
$test = $gpo | Where-Object {
    $_.User.DSVersion -eq 0 -and
    $_.User.SysvolVersion -eq 0 -and
    $_.GPOStatus -ne 'UserSettingsDisabled'
}

# Afficher les GPO orpherlines
$gpo = Get-GPO -All
$ous = Get-ADOrganizationalUnit -Filter * -Properties LinkedGroupPolicyObjects
$appliedGPO = $ous.LinkedGroupPolicyObjects | Sort-Object -Unique | ForEach-Object { ($_ -split '{' -split '}')[1] }
$gpo | Where-Object { $_.Id -notin $appliedGPO } | Sort-Object DisplayName | Select-Object DisplayName, Id
```