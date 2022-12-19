## Trouver la date du Patch Tuesday

## Ma version

```powershell
# Version classique et facile à comprendre
function Get-PatchTuesdayDate {
    param(
        [int]$Month = (Get-Date).Month,
        [int]$Year = (Get-Date).Year,
        [int]$Offset = 1
    )

    $date = Get-Date -Day $Offset -Month $Month -Year $Year -H 0 -Min 0
    switch ([int]($date.DayOfWeek)) {
        3 { $addDays = 6 } # Wednesday
        4 { $addDays = 5 } # Thursday
        5 { $addDays = 4 } # Friday
        6 { $addDays = 3 } # Saturday
        0 { $addDays = 2 } # Sunday
        1 { $addDays = 1 } # Monday
        2 { $addDays = 0 } # Tuesday
    }
    return ($date.AddDays($addDays+7))
}

# Version plus complexe avec la formule mathématique
function Get-PatchTuesdayDate2 {
    param(
        [int]$Month = (Get-Date).Month,
        [int]$Year = (Get-Date).Year,
        [int]$Offset = 1
    )

    $date = (Get-Date -Day $Offset -Month $Month -Year $Year -H 0 -Min 0)
    $dayOfWeek = [int]($date.DayOfWeek)
    if ($dayOfWeek -le 2) { $addDays = -$dayOfWeek+2 } else { $addDays = 7+(-$dayOfWeek+2) }
    return ($date.AddDays($addDays+7))
}

Measure-Command {
    foreach ($year in 2000..2022) {
        foreach ($month in 1..12) {
            $null = Get-PatchTuesdayDate -Year $year -Month $month
        }
    }
}
```

Ma version est 1000x plus rapide que celle avec une boucle

## Version de Marc-Antoine

```powershell
Function Get-PatchTuesday {
    [Cmdletbinding()]
    Param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipelineByPropertyName = $true)]
        [int]$Year,
        [Parameter(Mandatory = $true, Position = 1, ValueFromPipelineByPropertyName = $true)]
        [int]$Month
    )
    BEGIN {
        $TuesdayList = [System.Globalization.CultureInfo]::GetCultures([System.Globalization.CultureTypes]::AllCultures).DateTimeFormat |
                            ForEach-Object {$_.DayNames[2]} |
                            Select-Object -Unique
    }
    PROCESS {
        $TuesdayCount = 0
        $Date = Get-date -Year $Year -Month $Month -Day 1 -Hour 0 -Minute 0 -Second 0
        While ($TuesdayCount -lt 2) {
            Write-Verbose -Message "Date : $($Date.ToString('dd/MM/yyyy')) - $($Date.DayOfWeek)"
            $Date = $Date.AddDays(1)
            If ($TuesdayList -contains $Date.DayOfWeek) {
                Write-Verbose -Message "Is Tuesday ($TuesdayCount)"
                $TuesdayCount++
            }
        }
        Write-Verbose -Message "Second Tuesday : $($Date.ToString('dd/MM/yyyy'))"
        $Date
    }
}
```

```powershell
Measure-Command {
    foreach ($year in 2000..2022) {
        foreach ($month in 1..12) {
            $null = Get-PatchTuesday -Year $year -Month $month
        }
    }
}
```