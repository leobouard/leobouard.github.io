# War games - CENTURY

<https://underthewire.tech/century>

Le but du jeu et de trouver le mot de passe du prochain compte SSH

## Connexion au SSH

```ssh
ssh century.underthewire.tech -l centuryX
```

## Century1

Le mot de passe est disponible sur Slack : `century1`

## Century2

Le mot de passe correspond à la BuildVersion

```powershell
[string]$psversiontable.BuildVersion
```

Le mot de passe est `10.0.14393.5582`

## Century3

Commande qui a pour alias "WGET" en PowerShell + Nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = (Get-Alias -Name wget).Definition
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `invoke-webrequest443`

## Century4

Nombre de fichiers sur le bureau

```powershell
(Get-ChildItem | Measure-Object).count
```

Le mot de passe est `123`

## Century5

Nom du fichier dans le dossier du bureau qui contient des espaces dans son nom

```powershell
$folder = Get-ChildItem -Directory | Where-Object {$_.Name -like '* *'}
(Get-ChildItem -Path $folder.FullName).Name
```

Le mot de passe est `34182`

## Century6

Nom NETBIOS du domaine + Nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$1 = $env:USERDOMAIN
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `underthewire3347`

## Century7

Le nombre de dossiers sur le bureau

```powershell
(Get-ChildItem -Directory | Measure-Object).Count
```

Le mot de passe est `197`

## Century8

Le mot de passe est le contenu du fichier "README" sur le profil utilisateur

```powershell
cd ..
$file = Get-ChildItem -Recurse | Where-Object {$_.BaseName -eq 'README'}
(Get-Content -Path $file.FullName).ToLower()
```

Le mot de passe est `7points`

## Century9

Le nombre d'entrées dans le fichier unique.txt sur le bureau

```powershell
(Get-Content 'unique.txt' | Measure-Object).Count
```

Le mot de passe est `696`

## Century10

La 161e entrée dans le fichier Word_File.txt sur le bureau

```powershell
((Get-Content 'Word_File.txt') -split ' ')[160]
```

Le mot de passe est `pierid`

## Century11

1. 10e mot de la description du service Windows Update
2. 8e mot de la description du service Windows Update
3. Nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$serv = (Get-WmiObject Win32_Service -Filter "DisplayName = 'Windows Update'").Description -split ' '
$1 = $serv[9,7]
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `windowsupdates110`

## Century12

Nom du fichier caché dans le dossier Download

Le mot de passe est forcément en minuscule

```powershell
$file = Get-ChildItem -Recurse -Hidden | Where-Object {$_.Name -ne 'desktop.ini'}
($file.Name).ToLower()
```

Le mot de passe est `secret_sauce`

## Century13

1. Description du contrôleur de domaine
2. Nom du fichier sur le bureau

Le mot de passe est forcément en minuscule

```powershell
$dc = (Get-ADDomainController).ComputerObjectDN
$1 = (Get-ADComputer $dc -Properties Description).Description
$2 = (Get-ChildItem).Name
"$1$2".ToLower()
```

Le mot de passe est `i_authenticate_things`

## Century14

Nombre de mots dans le fichier du bureau

```powershell
((Get-Content 'countmywords') -split ' ' | Measure-Object).Count
```

Le mot de passe est `755`

## Century15

Nombre de fois où le mot "polo" apparait dans le fichier sur le bureau

```powershell
$text = (Get-Content 'countpolos') -split ' '
($text | Where-Object {$_ -eq 'polo'} | Measure-Object).Count
```

Le mot de passe est `153`
