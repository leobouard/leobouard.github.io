---
layout: post
title: "Solution - Père Noël aléatoire"
background: "#f78787"
prevLink:
  name: "Retour au défi"
  id: "/2021/11/30/pere-noel-secret"
---

```powershell
function Get-SecretSanta {
    param(
        [array]$People,
        [switch]$Pause
    )

    $i = 0
    $random = 1..$People.Count | Get-Random -Count $People.Count
    $People = $People | ForEach-Object {
        [PSCustomObject]@{
            Name = $_
            ID = $random[$i]
        }
        $i++
    } | Sort-Object -Property ID
    
    $People | ForEach-Object {
        $index = $_.ID+1
        $giftTo   = ($People | Where-Object {$_.ID -eq $index}).Name
        if (!$giftTo) { $giftTo = ($People | Where-Object {$_.ID -eq 1}).Name }

        "#{0} {1} offre son cadeau à {2}" -f $_.ID,$_.Name,$giftTo
        if ($Pause.IsPresent) { $null = Read-Host }
    }
}
```
