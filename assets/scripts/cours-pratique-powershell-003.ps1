$i = 0
$allAnswers = [System.Collections.Generic.List[int]]@()
$random = Get-Random -Minimum 1 -Maximum 1000
do {
    $i++
    $answer = Read-Host "Deviner le nombre"
    $allAnswers.Add($answer)
    if ($random -gt $answer) { 
        Write-Host "??? est plus grand que $answer"
    } elseif ($random -lt $answer) {
        Write-Host "??? est plus petit que $answer"
    } else {
        Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
    }
} until ($answer -eq $random -or $i -ge 10)

if ($answer -ne $random) { 
    Write-Host "DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire"
}

[PSCustomObject]@{
    "Nombre aléatoire" = $random
    "Réponses"         = $allAnswers
    "Réponse moyenne"  = [int]($allAnswers | Measure-Object -Average).Average
    "Tentatives"       = $i
} | Format-List