$random = Get-Random -Minimum 1 -Maximum 1000
$answer = Read-Host "Deviner le nombre"

if ($random -gt $answer) { 
    Write-Host "??? est plus grand que $answer"
} elseif ($random -lt $answer) {
    Write-Host "??? est plus petit que $answer"
} else {
    Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
}

[PSCustomObject]@{
    "Nombre aléatoire" = $random
    "Dernière réponse" = $answer
} | Format-List