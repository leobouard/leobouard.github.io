---
layout: post
title: "✅ Le nom le plus long"
---

```powershell

$users | ForEach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name nameLength -Value ($_.displayName).Length
}
$users | Sort-Object -Property nameLength -Descending | Format-Table displayName,nameLength

```