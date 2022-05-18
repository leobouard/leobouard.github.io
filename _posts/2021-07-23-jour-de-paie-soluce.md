---
layout: post
title: "[SOLUTION] Le jour de paie"
---

## Version Do/Until 👑

```powershell
$i = 25
do {
    $d = Get-Date -Day $i
    $i--
} until ($d.DayOfWeek -notlike "S*")
$d
```

En version compressée on obtient :

```powershell
# 63 caractères de long
$i=25;do{$d=date -Day $i;$i--}until($d.DayOfWeek-notlike"S*")$d
```

## Version Foreach-Object

```powershell
$d = @()
1..25 | ForEach-Object { 
    $d += Get-Date -Day $_ | Where-Object {$_.DayOfWeek -notlike "S*"} 
}
$d | Select-Object -Last 1
```

## Version For

```powershell
for ($i = 25; $null -eq $d ; $i--) {
    $d = Get-Date -Day $i | Where-Object {$_.DayOfWeek -notlike "S*"}
}
$d
```

## Version While

```powershell
$d = Get-Date -Day 25
while ($d.DayOfWeek -like "S*") {
    $d = $d.AddDays(-1)
}
$d
```