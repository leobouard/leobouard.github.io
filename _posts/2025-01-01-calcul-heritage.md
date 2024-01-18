
# Calcul impôt sur le revenu

function CalculImpot {

    param([int]$Revenu)

$tranches = @"
[
    {
        "revenu":  10084,
        "imposition": 0.00
    },
    {
        "revenu":  25710,
        "imposition": 0.11
    },
    {
        "revenu":  73516,
        "imposition": 0.30
    },
    {
        "revenu":  158122,
        "imposition": 0.41
    },
    {
        "revenu":  1000000,
        "imposition": 0.45
    }
]
"@ | ConvertFrom-Json
    
    $impots = 0
    $i = 0
    
    do {
    
        $tranche = ($tranches)[$i]
    
        if ($revenu -gt $tranche.Revenu) {
            $impot  = ($tranche.Revenu)*($tranche.Imposition)
            $revenu = $revenu-$tranche.Revenu
        } else {
            $impot  = ($revenu)*($tranche.Imposition)
            $revenu = $revenu-$revenu
        }
    
        "$impot€ d'impôts sur la $($i+1)e tranche | Revenus restants : $revenu€"
    
        $impots = $impots + $impot
        
        $i++
    } until ($revenu -le 0)
    
    "TOTAL IMPÔTS annuel: $impots€"
    "TOTAL IMPÔTS mensuel: $([math]::Round($impots/12,2))€"
    
    return $impots
}

<#

1e tranche
36000€ plus grand que 10084€ --> 10084*0.00 = 0€ d'impots sur la première tranche
    donc 36000-10084 = 25916€

2e tranche
25916€ plus grand que 25710€ --> 25710*0.11 = 2828,1€ d'impots sur la deuxième tranche
    donc 25916-25710 = 206€

3e tranche
206€ plus petit que 73516€ --> 206*0.30 = 61,80€ d'impots sur la troisième tranche
    donc 206-206 = 0

4e tranche
0€ plus petit que 158122€ --> 0*0.41 = 0€ d'impôts sur la quatrième tranche


TOTAL
- 0€ sur la première tranche
- 2828,1€ sur la deuxième tranche
- 84,46€ sur la troisième tranche
- 0€ sur la quatrième tranche
------------------------------
2889,90€ d'impots annuel
240,82€ d'impots mensuel

Reste à vivre : 36000€-2889,90€ = 33110,1€

#>






# Référence : https://www.service-public.fr/simulateur/calcul/droits-succession#main

function CalculHeritage {

    param([double]$Heritage)

    $data = @"
[
    {
        "ID":  "0",
        "Somme":  100000,
        "Taux":  0
    },
    {
        "ID":  "1",
        "Somme":  8072,
        "Taux":  0.05
    },
    {
        "ID":  "2",
        "Somme":  4037,
        "Taux":  0.1
    },
    {
        "ID":  "3",
        "Somme":  3823,
        "Taux":  0.15
    },
    {
        "ID":  "4",
        "Somme":  536392,
        "Taux":  0.2
    },
    {
        "ID":  "5",
        "Somme":  350514,
        "Taux":  0.3
    },
    {
        "ID":  "6",
        "Somme":  902839,
        "Taux":  0.4
    },
    {
        "ID":  "7",
        "Somme":  0,
        "Taux":  0.45
    }
]
"@ | ConvertFrom-Json

    $HeritageInitial = $Heritage
    $Resultats = @()
   
    $data | ForEach-Object {

        if ($Heritage -gt $_.Somme -and $_.ID -ne 7) {
            $DroitsDeSuccession = $_.Somme * $_.Taux
            $Heritage = $Heritage - $_.Somme
        } else {
            $DroitsDeSuccession = $Heritage * $_.Taux
            if ($_.ID -eq 7) { $Tranche7 = $Heritage }
            $Heritage = $Heritage - $Heritage
        }

        $Resultats += [PSCustomObject]@{
            ID      = $_.ID
            Tranche = $_.Somme
            Barème  = [math]::Round($_.Taux * 100,0)
            Succession = [math]::Round($DroitsDeSuccession,2)
        }
    }

    ($Resultats | Where-Object {$_.ID -eq 7}).Tranche = $Tranche7
    $Resultats = $Resultats | Where-Object {$_.Succession -ne 0}

    $Succession = ($Resultats | Measure-Object -Property Succession -Sum).Sum
    Write-Host "Droits de succession estimés : $Succession €"

    $HeritageRestant = $HeritageInitial - $Succession
    $TauxRestant = [math]::Round(($HeritageRestant / $HeritageInitial) * 100,2)
    Write-Host "Héritage restant : $HeritageRestant € ($TauxRestant % restant)"
    
    return $Resultats
}
