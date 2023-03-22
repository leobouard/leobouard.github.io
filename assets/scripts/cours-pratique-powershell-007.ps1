param(
    [switch]$EasyMode,
    [IO.FileInfo]$FilePath = "$PSScriptRoot\highscore.csv"
)

$i          = 0
$min        = 1
$max        = 1000
$allAnswers = [System.Collections.Generic.List[int]]@()
$stopwatch  = [System.Diagnostics.Stopwatch]::New()
$random     = Get-Random -Minimum $min -Maximum $max

if ($EasyMode.IsPresent) {
    while ($random % 5 -ne 0) { $random = Get-Random -Min $min -Max $max }
}

do {
    $i++
    $answer = Read-Host "Deviner le nombre ($min < ??? < $max)"
    if ($stopwatch.IsRunning -eq $false) { $stopwatch.Start() }
    $allAnswers.Add($answer)
    if ($random -gt $answer) { 
        Write-Host "??? est plus grand que $answer"
        $min = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object | Select-Object -Last 1
    } elseif ($random -lt $answer) {
        Write-Host "??? est plus petit que $answer"
        $max = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1
    } else {
        Write-Host "VICTOIRE ! Vous avez deviné le nombre aléatoire"
    }
} until ($answer -eq $random -or $i -ge 10)

$stopwatch.Stop()

$stats = [PSCustomObject]@{
    "Joueur"                    = $env:USERNAME
    "Date"                      = Get-Date -Format G
    "Nombre aléatoire"          = $random
    "Réponses"                  = $allAnswers -join ','
    "Réponse moyenne"           = [int]($allAnswers | Measure-Object -Average).Average
    "Tentatives"                = $i
    "Temps de résolution (sec)" = [System.Math]::Round($stopwatch.Elapsed.TotalSeconds,3)
    "Temps moyen par tentative" = [System.Math]::Round(($stopwatch.Elapsed.TotalSeconds / $i),3)
    "Mode facile"               = $EasyMode.IsPresent
}
$stats | Write-Output

if ($answer -ne $random) { 
    Write-Host "DEFAITE. Vous n'avez pas réussi à trouver le nombre aléatoire"
} else {
    $stats | Export-Csv -Path $FilePath -Encoding UTF8 -Delimiter ';' -NoTypeInformation -Append -Force
}

$question = 'Voulez-vous voir les meilleurs scores?'
$choices  = '&Oui', '&Non'
$decision = $Host.UI.PromptForChoice($null, $question, $choices, 1)

if ($decision -eq 0) {
    Import-Csv -Path $FilePath -Delimiter ';' -Encoding UTF8 | Out-GridView -Title "Meilleurs scores"
}