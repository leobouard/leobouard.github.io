Add-Type -AssemblyName PresentationFramework
$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/interface.xaml"
[xml]$Global:xaml = (Invoke-WebRequest -Uri $uri).Content
$Global:interface = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xaml))
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { 
    Set-Variable -Name ($_.Name) -Value $interface.FindName($_.Name) -Scope Global
}

$progressbarCoupsRestants.Value = 0
$labelMin.Content = 1
$labelMax.Content = 1000
$Global:allAnswers = [System.Collections.Generic.List[int]]@()
$Global:stopwatch  = [System.Diagnostics.Stopwatch]::New()
$Global:random     = Get-Random -Minimum $labelMin.Content -Maximum $labelMax.Content

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
        }

        if ($progressbarCoupsRestants.Value -eq $progressbarCoupsRestants.Maximum -and $textboxResponse.Text -ne $random) {
            $stackpanelButtons.Visibility = "Visible"
            $textboxResponse.Text = $random
            $textboxResponse.IsEnabled = $false
            $labelText.Content = "DEFAITE ! Le nombre etait : $random"
            $stopwatch.Stop()
        }
    }
})

$null = $Global:interface.ShowDialog()