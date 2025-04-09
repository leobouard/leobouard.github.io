
Calculer toutes les plaques d'immatriculation possibles

de AA-001-AA à ZZ-999-ZZ

<https://immatriculation.ants.gouv.fr/tout-savoir/numero-logo-et-plaque>

```powershell
$letters = 'ABCDEFGHJKLMNPQRSTVWXYZ'.ToCharArray()
$numbers = 1..999

$AA  = $letters | ForEach-Object {
    $A = $_
    $letters | ForEach-Object { 
        "$A$_"
    }
}
$AA = $AA | Where-Object {$_ -ne 'SS'}

$001 = $numbers | ForEach-Object {
    $i = "$_"
    switch ($i.Length) {
        1       { "00$i" }
        2       { "0$i" }
        default { $i }
    }
}

# Façon brutale
$results = $AA | ForEach-Object -Parallel {
    $1 = $_
    $using:001 | ForEach-Object {
        $2 = $_
        $using:AA | ForEach-Object {
            $3 = $_
            "$1-$2-$3"
        }
    }
}

# Temps de traitement théorique : ~60 min pour générer 280 millions de plaques
```