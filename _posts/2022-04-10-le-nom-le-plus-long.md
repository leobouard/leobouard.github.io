---
layout: post
title: "Qui a le nom le plus long ?"
description: "Et non ce n'est pas Bernard de la Villardière"
tags: challenges
thumbnailColor: "#334195"
icon: 🆔
---

```powershell

$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'

```

