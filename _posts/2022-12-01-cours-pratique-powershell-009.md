---
layout: post
title: "Cours PowerShell #9 - Réparation"
description: "Description"
icon: 🎓
nextLink:
  name: "Partie 10"
  id: "/2022/12/01/cours-pratique-powershell-010"
prevLink:
  name: "Partie 8"
  id: "/2022/12/01/cours-pratique-powershell-008"
---

## Consigne

### Résultat attendu

---

## Etape par étape

## Correction

```powershell
Add-Type -AssemblyName PresentationFramework
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/interface.xaml"
[xml]$Global:xaml = (Invoke-WebRequest -Uri $uri).Content
$Global:interface = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
    Set-Variable -Name ($_.Name) -Value $interface.FindName($_.Name) -Scope Global
}

$textboxResponse.Add_KeyDown({
    if ($_.Key -eq "Return") {
        $answer = [int]($textboxResponse.Text)
        Write-Host $answer
        $textboxResponse.Text = $null
    }
})

$null = $Global:interface.ShowDialog()
```
