# War games - GROOT

<https://underthewire.tech/groot>

Le but du jeu et de trouver le mot de passe du prochain compte SSH

## Connexion au SSH

```ssh
ssh groot.underthewire.tech -l grootX
```

## Groot1

Le mot de passe est disponible sur Slack : `groot1`

## Groot2

The password for groot2 is the last five alphanumeric characters of the MD5 hash of this system’s hosts file.

```powershell
$hash = (Get-Item 'C:\Windows\System32\Drivers\etc\hosts' | Get-FileHash -Algorithm MD5).Hash
($hash[-5..-1] -join '').ToLower()
```

Le mot de passe est `464c3`

## Groot3

The password for groot3 is the word that is made up from the letters in the range of 1,481,110 to 1,481,117 within the file on the desktop.

```powershell
$text = Get-Content 'elements.txt'
($text[1481110..1481117] -join '').Trim()
```

Le mot de passe est `hiding`

## Groot4

The password for groot4 is the number of times the word “beetle” is listed in the file on the desktop.

```powershell
$text = (Get-Content 'words.txt') -split ' '
($text | Where-Object {$_ -eq 'beetle'} | Measure-Object).Count
```

Password is `5`

## Groot5

The password for groot5 is the name of the Drax subkey within the HKEY_CURRENT_USER (HKCU) registry hive

```powershell
Get-ChildItem -Path hkcu:\ -Recurse | Select-String drax
```

Le mot de passe est `destroyer`

## Groot6

The password for groot6 is the name of the workstation that the user with a username of “baby.groot” can log into as depicted in Active Directory PLUS the name of the file on the desktop

```powershell
$1 = (Get-ADUser baby.groot -Properties LogonWorkstations).LogonWorkstations
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `wk11_enterprise`

## Groot7

The password for groot7 is the name of the program that is set to start when this user logs in PLUS the name of the file on the desktop

```powershell
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
$1 = ((Get-ItemProperty $path | Get-Member).Name | Select-Object -Last 1).ToLower()
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Password is `star-lord_rules`

## Groot8

The password for groot8 is the name of the dll, as depicted in the registry, associated with the “applockerfltr” service PLUS the name of the file on the desktop

```powershell
Get-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Services\applockerfltr'
(Get-ChildItem).Name
```

Password is `srpapi_home`

## Groot9

The password for groot9 is the description of the firewall rule blocking MySQL PLUS the name of the file on the desktop

```powershell
$1 = (Get-NetFirewallRule -DisplayName 'MySQL').Description
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Password is `call_me_starlord`

## Groot10

The password for groot10 is the name of the OU that doesn’t have accidental deletion protection enabled PLUS the name of the file on the desktop

```powershell
$1 = (Get-ADOrganizationalUnit -Filter * -Properties * | Where-Object {$_.ProtectedFromAccidentalDeletion -eq $false}).Name
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Password is `t-25_tester`

# Groot11

The password for groot11 is the one word that makes the two files on the desktop different.

```powershell
$ref = Get-Content 'old.txt'
$dif = Get-Content 'new.txt'
(Compare-Object $ref $dif).InputObject
```

Password is `taserface`

## Groot12

The password for groot12 is within an alternate data stream (ADS) somewhere on the desktop

```powershell
Get-ChildItem | % { Get-Item $_.FullName -Stream * }
Get-Content .\TPS_Reports04.pdf -Stream secret
```

Password is `spaceships`

## Groot13

The password for groot13 is the owner of the Nine Realms folder on the desktop.

```powershell
(Get-Acl 'Nine Realms').Owner
```

Password is `airwolf`

## Groot14

The password for groot14 is the name of the Registered Owner of this system as depicted in the Registry PLUS the name of the file on the desktop.

```powershell
$1 = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion').RegisteredOwner
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Password is `utw_team_ned`

## Groot15

The password for groot15 is the description of the share whose name contains “task” in it PLUS the name of the file on the desktop

```powershell
$1 = (Get-WmiObject Win32_Share -Filter "Name='tasker'").Description
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Password is `scheduled_things_8`
