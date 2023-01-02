## Trouver la date du Patch Tuesday

## Ma version

```powershell
# Version classique et facile à comprendre
function Get-PatchTuesdayDate_Leo1 {
    param(
        [int]$Month = (Get-Date).Month,
        [int]$Year = (Get-Date).Year,
        [int]$Offset = 1
    )

    $date = Get-Date -Day $Offset -Month $Month -Year $Year -H 0 -Min 0 -Sec 0
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
function Get-PatchTuesdayDate_Leo2 {
    param(
        [int]$Month = (Get-Date).Month,
        [int]$Year = (Get-Date).Year,
        [int]$Offset = 1
    )

    $date = (Get-Date -Day $Offset -Month $Month -Year $Year -H 0 -Min 0 -Sec 0)
    $dayOfWeek = [int]($date.DayOfWeek)
    if ($dayOfWeek -le 2) { $addDays = -$dayOfWeek+2 } else { $addDays = 7+(-$dayOfWeek+2) }
    return ($date.AddDays($addDays+7))
}
```

## Version de ChatGPT

Obtenu avec la question suivante : 

> find the second tuesday of the month in PowerShell

Réponse de ChatGPT :

To find the second Tuesday of the month in PowerShell, you can use the following steps:

Use the Get-Date cmdlet to get the current date.
Use the Get-Date cmdlet to get the first day of the month, using the -Month and -Year parameters to specify the month and year.
Use the AddDays method to add 7 days to the first day of the month.
Use a while loop to check if the day of the week is not Tuesday. If it is not Tuesday, use the AddDays method to add 1 day to the date.
When the day of the week is Tuesday, use the Get-Date cmdlet to format the date as desired and output it.
Here is an example of how this could be done:

```powershell
$currentDate = Get-Date
$firstDayOfMonth = Get-Date -Month $currentDate.Month -Year $currentDate.Year -Day 1
$secondTuesday = $firstDayOfMonth.AddDays(7)

while ($secondTuesday.DayOfWeek -ne "Tuesday") {
  $secondTuesday = $secondTuesday.AddDays(1)
}

$secondTuesdayString = Get-Date -Date $secondTuesday -Format "MM/dd/yyyy"
Write-Output "The second Tuesday of the month is $secondTuesdayString"
```

This will output the second Tuesday of the month in the format "MM/dd/yyyy". You can use a different format string if desired. For example, to output the date in the format "dd-MM-yyyy", you can use -Format "dd-MM-yyyy" instead

### Adaptation de la réponse à notre modèle 

```powershell
function Get-PatchTuesdayDate_ChatGPT {

    param(
        [int]$Month = (Get-Date).Month,
        [int]$Year = (Get-Date).Year,
        [int]$Offset = 1
    )

    $currentDate = Get-Date
    $firstDayOfMonth = Get-Date -Month $Month -Year $Year -Day $Offset -H 0 -Min 0 -Sec 0
    $secondTuesday = $firstDayOfMonth.AddDays(7)

    while ($secondTuesday.DayOfWeek -ne "Tuesday") {
        $secondTuesday = $secondTuesday.AddDays(1)
    }

    return $secondTuesday
}
```

## Combat final

### Comparatif des performances

```powershell
$measure = 1..100 | % {
        Measure-Command {
        foreach ($year in 2000..2022) {
            foreach ($month in 1..12) {
                $null = Get-PatchTuesdayDate_ChatGPT -Year $year -Month $month
            }
        }
    }
}
$measure | Measure-Object -Average -Property TotalMilliseconds
```

Version/Fonction | Léo n°1 | Léo n°2 | ChatGPT
---------------- | ------- | ------- | -------
PowerShell 2.0   | 65ms    | 70ms    | 85ms
PowerShell 5.1   | 49ms    | 49ms    | 70ms
PowerShell 7.3   | 15ms    | 10ms    | 14ms