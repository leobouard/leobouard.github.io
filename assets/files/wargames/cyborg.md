# War games - CYBORG

<https://underthewire.tech/cyborg>

Le but du jeu et de trouver le mot de passe du prochain compte SSH

## Connexion au SSH

```ssh
ssh cyborg.underthewire.tech -l cyborgX
```

## Cyborg1

Le mot de passe est disponible sur Slack : `cyborg1`

## Cyborg2

La localisation du compte de "Chris Rogers" dans Active Directory

```powershell
(Get-ADUser -Filter {ANR -eq 'Chris Rogers'} -Properties State).State.ToLower()
```

Le mot de passe est `kansas`

## Cyborg3

1. L'adresse IP de CYBORG718W100N
2. Le nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = ((nslookup CYBORG718W100N | Select-String 'Address' | Select-Object -Last 1) -replace 'Address:','').Trim()
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `172.31.45.167_ipv4`

## Cyborg4

1. Le nombre d'utilisateurs dans le groupe "cyborg"
2. Le nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = (Get-ADGroupMember 'cyborg' | Measure-Object).Count
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `88_objects`

## Cyborg5

1. Le nom du module PowerShell installé en version 8.9.8.9
2. Le nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = (Get-Command | Where-Object {$_.Version -eq '8.9.8.9'}).Module.Name
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `bacon_eggs`

## Cyborg6

1. Le nom de famille de l'utilisateur Active Directory avec le LogonHours configuré
2. Le nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = (Get-ADUser -LDAPFilter '(&(objectClass=User)(logonHours=*)(sn=*))').Surname
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `rowray_timer`

## Cyborg7

Mot de passe chiffré dans le fichier du bureau

```powershell
$base64 = Get-Content 'cypher.txt'
$bytes = [System.Convert]::FromBase64String($base64)
$string = [System.Text.Encoding]::UTF8.GetString($bytes)
$char = $string[1]
$string -replace $char,''
```

Le mot de passe est `cybergeddon`

## Cyborg8

Le nom de l'executable qui se lance automatiquement lorsque cyborg7 se connecte

```powershell
$path = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run'
((Get-ItemProperty $path | Get-Member).Name | Select-Object -Last 1).ToLower()
```

Le mot de passe est `skynet`

## Cyborg9

L'ID de la zone internet d'où est issu l'image du bureau

```powershell
$stream = Get-Content '1_qs5nwlcl7f_-SwNlQvOrAw.png' -Stream Zone.Identifier
($stream | Select-String 'ZoneId=') -replace 'Z
oneId=',''
```

Le mot de passe est `4`

## Cyborg10

1. Prénom de l'utilisateur Active Directory le numéro de téléphone "876-5309"
2. Le nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = (Get-ADUser -Filter {telephoneNumber -eq '876-5309'}).GivenName
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `onita99`

## Cyborg11

1. Description de la politique d'AppLocker sur l'executable "ill_be_back.exe"
2. Le nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = (Get-AppLockerPolicy -Effective).RuleCollections.Description
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `terminated!99`

## Cyborg12

Stocké dans les logs ISS (n'est pas Mozilla ou Opera)

```powershell
Get-ChildItem -Path 'C:\inetpub\logs\logfiles\w3svc1' | Get-Content | Select-String 'password'
```

Le mot de passe est `spaceballs`

## Cyborg13

The password for cyborg13 is the first four characters of the base64 encoded full path to the file that started the i_heart_robots service PLUS the name of the file on the desktop.

```powershell
$svc = Get-WmiObject Win32_Service -Filter "DisplayName='i_heart_robots'"
$bytes = [System.Text.Encoding]::Unicode.GetBytes($svc.PathName)
$base64 = [System.Convert]::ToBase64String($bytes)
$1 = $base64.SubString(0,4)
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `ywa6_heart`

## Cyborg14

The password cyborg14 is the number of days the refresh interval is set to for DNS aging for the underthewire.tech zone PLUS the name of the file on the desktop.

```powershell
$1 = (Get-DnsServerZoneAging -Name underthewire.tech).RefreshInterval.Days
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `22_days`

## Cyborg15

The password for cyborg15 is the caption for the DCOM application setting for application ID {59B8AFA0-229E-46D9-B980-DDA2C817EC7E} PLUS the name of the file on the desktop.

```powershell
$1 = (Get-WmiObject Win32_DCOMApplicationSetting -Filter "AppID = '{59B8AFA0-229E-46D9-B980-DDA2C817EC7E}'").Caption
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `propshts_objects`
