
Calculer toutes les plaques d'immatriculation possibles

de AA-001-AA à ZZ-999-ZZ

<https://immatriculation.ants.gouv.fr/tout-savoir/numero-logo-et-plaque>

```powershell
$letters =  "A","B","C","D","E","F","J","H","J","K","L","M","N","P","Q","R","S","T","V","W","X","Y","Z"
$numbers = 1..999

$i = 1
$AA  = $letters | ForEach-Object { $A = $_ ; $letters | ForEach-Object { "$A$_" } }
$AA = $AA | Where-Object {$_ -ne 'SS'}
$AA = $AA | ForEach-Object {
    [PSCustomObject]@{
        Letters = $_
        Index   = $i
    }
    $i++
}

$001 = $numbers | ForEach-Object {
    $i = "$_"
    switch ($i.Length) {
        1       { "00$i" }
        2       { "0$i" }
        default { $i }
    }
}


function TEST {

    $test = Read-Host "Donnez votre plaque d'immatriculation"
    $test2 = $test -split '-'

    $a = ($AA | ? {$_.Letters -eq $test2[0]}).Index
    $b = $test2[1]
    $c = ($AA | ? {$_.Letters -eq $test2[2]}).Index

    $total = 528*999*528
    $id = $a*$b*$c

    "Votre plaque est la n° {0:N0}" -f $id

}




$total = 528*999*528

# Façon brutale

$i = 0
$results = $AA | ForEach-Object {
    $1 = $_
    $001 | ForEach-Object {
        $2 = $_
        $AA | ForEach-Object {
            $3 = $_
            "$1-$2-$3"
            Write-Progress -Activity "$1-$2-$3" -PercentComplete (($i/$total)*100)
            $i++
        }
    }
}

<# 
528 combinaisons de lettres
999 combinaisons de chiffres
528 combinaisons de lettres




#>


```