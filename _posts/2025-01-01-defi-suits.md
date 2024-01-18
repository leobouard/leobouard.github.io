# SUITS S01E08 | 35min

# Preparation des données
$data = @()
1..25 | ForEach-Object {
    $random = Get-Random -Min 0.0 -Max 100.0 -SetSeed $_
    $data += [PSCustomObject]@{
        Account = $_
        Balance = [math]::Round($random,2)
    }
    Remove-Variable random
}

# Récupération du chiffre cible
$targetList = $data | Get-Random -Count 7
$target = ($targetList.Balance | Measure-Object -Sum).Sum

Write-Host "$target M€ ont été volés et repartis sur 7 différents comptes"
Write-Host "A vous de jouer pour retrouver les comptes sur lesquels l'argent a été dissimulé"













# --- METHODE 1 ----

# Recherche de la combinaison en aléatoire
$i = 0
$time = Measure-Command {
    do {
        $list = $data.Account | Get-Random -Count 7
        $sum = $data | Where-Object {$_.Account -in $list} | Measure-Object -Property Balance -Sum
        $i++
    } until ($sum.Sum -eq $target)
}

# Affichage du résultat
"Target found in {0} attempts and {1} sec" -f $i,$time.TotalSeconds
$data | Where-Object {$_.Account -in $list}





# --- METHODE 2 ---

# Lister toutes les combinaisons
function Get-NextItem {

    param(
        [System.Object]$Item,
        [Int]$Limit
    )

    if (!$Limit) { $Limit = 10 }

    $i = ($Item | Measure-Object).Count - 1
    $limits = ($Limit - $i)..$Limit

    if (($limits -join ',') -eq ($item -join ',')) { return $null}

    do {
        if ($Item[$i] -lt $limits[$i]) { 
            $item[$i]++
            $i = -1
        } elseif ($Item[$i] -eq $limits[$i] -and $Item[$i-1] -lt $limits[$i-1]) {
            
        } else {
            $i--
        }

    } until ($i -eq -1)

    return $Item
}


# ---

# Methode 2bis

<# 

Résultat attendu 

1,2,3       +1
1,2,4       +1
1,2,5       +9
1,3,4       +1
1,3,5       +9
1,4,5       +10
2,3,4       +99
2,4,5       +11
3,4,5       +100

#>


function gni {

    param([System.Object]$Item,[Int]$Limit)

    if (!$Limit) { $Limit = 5 }

    $i      = ($Item | Measure-Object).Count - 1
    $limits = ($Limit - $i)..$Limit
    $i      = 0
    $sum    = 0

    $itemNb = [Int64]($item -join '')

    $item | Sort-Object -Descending | ForEach-Object {

        switch ($_) {
            ($_ -lt $limits[$i]) { $sum = $sum + 1 }
            ($_ -eq $limits[$i]) { $sum = $sum + 9 }
        }

        $i++
    }






}




$test = 1,2,3
1..10 | % {

    $test -join ','
    $test = Get-NextItem -Item $test -Limit 5

}
