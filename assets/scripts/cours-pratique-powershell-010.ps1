param(
    [switch]$CalcBot,
    [switch]$EasyMode,
    [System.IO.FileInfo]$HighScorePath = "$PSScriptRoot\highscore.json"
)

Add-Type -AssemblyName PresentationFramework
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/interface.xaml"
[xml]$Global:xaml = (Invoke-WebRequest -Uri $uri).Content
$Global:interface = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
    Set-Variable -Name ($_.Name) -Value $interface.FindName($_.Name) -Scope Global
}

function Reset-UI {
    $progressbarCoupsRestants.Value = 0
    $labelMin.Content = 1
    $labelMax.Content = 1000
    $stackpanelButtons.Visibility = "Hidden"
    $textboxResponse.IsEnabled = $true
    $textboxResponse.Text = $null
    $labelText.Content = "Le nombre est plus..."
    $Global:allAnswers = [System.Collections.Generic.List[int]]@()
    $Global:stopwatch  = [System.Diagnostics.Stopwatch]::New()
    $Global:random     = Get-Random -Minimum $labelMin.Content -Maximum $labelMax.Content
    if ($EasyMode.IsPresent) {
        while ($random % 5 -ne 0) {
            $Global:random = Get-Random -Minimum $labelMin.Content -Maximum $labelMax.Content
        }
    }
}

if (Test-Path -Path $HighScorePath) { 
    $results = [System.Collections.Generic.List[PSCustomObject]](Get-Content $HighScorePath | ConvertFrom-Json)
} else {
    $results = [System.Collections.Generic.List[PSCustomObject]]@()
}

Reset-UI

$textboxResponse.Add_KeyDown({
    if ($_.Key -eq "Return") {
        $answer = [int]($textboxResponse.Text)
        $textboxResponse.Text = $null
        
        $progressbarCoupsRestants.Value++
        if ($stopwatch.IsRunning -eq $false) { $stopwatch.Start() }
        $allAnswers.Add($answer)
        if ($random -gt $answer) { 
            $labelText.Content = "Le nombre aléatoire est plus grand que $answer"
            $labelMin.Content = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object | Select-Object -Last 1
        } elseif ($random -lt $answer) {
            $labelText.Content = "Le nombre aléatoire est plus petit que $answer"
            $labelMax.Content = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1
        } else {
            $labelText.Content = "VICTOIRE ! Vous avez deviné le nombre aléatoire"
            $stackpanelButtons.Visibility = "Visible"
            $textboxResponse.Text = $random
            $textboxResponse.IsEnabled = $false
            $stopwatch.Stop()

            $results.Add([PSCustomObject]@{
                "Joueur"                    = $env:USERNAME
                "Date"                      = Get-Date -Format 'yyyy-MM-ddTHH:mm:ssZ'
                "Nombre aléatoire"          = $random
                "Réponses"                  = $allAnswers -join ','
                "Réponse moyenne"           = [int]($allAnswers | Measure-Object -Average).Average
                "Tentatives"                = [int]($progressbarCoupsRestants.Value)
                "Temps de résolution (sec)" = [System.Math]::Round($stopwatch.Elapsed.TotalSeconds,3)
                "Temps moyen par tentative" = [System.Math]::Round(($stopwatch.Elapsed.TotalSeconds / $progressbarCoupsRestants.Value),3)
                "Mode facile"               = $EasyMode.IsPresent
                "Tricheur"                  = $CalcBot.IsPresent
            })
            if ($HighScorePath) { $results | ConvertTo-Json | Set-Content -Path $HighScorePath -Encoding UTF8 }
        }

        if ($progressbarCoupsRestants.Value -eq $progressbarCoupsRestants.Maximum -and $textboxResponse.Text -ne $random) {
            $stackpanelButtons.Visibility = "Visible"
            $textboxResponse.Text = $random
            $textboxResponse.IsEnabled = $false
            $labelText.Content = "DEFAITE ! Le nombre etait : $random"
            $stopwatch.Stop()
        }

        if ($CalcBot.IsPresent) {
            $textboxResponse.Text = [math]::Round((($labelMax.Content+$labelMin.Content)/2),0)
        }
    }
})

$buttonRetry.Add_Click({ Reset-UI })

$buttonHighScore.Add_Click({ $results | Where-Object {$_.Tricheur -eq $false} | Sort-Object -Property 'Temps de résolution (sec)' | Out-GridView })

$null = $Global:interface.ShowDialog()