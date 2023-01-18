
Calculer toutes les plaques d'immatriculation possible

de AA-001-AA à ZZ-999-ZZ

```powershell

$letters =  "A","B","C","D","E","F","J","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"
$numbers = 1..999

$firstPart = [System.Collections.Generic.List[string]]@()
foreach ($firstLetter in $letters) {
    foreach ($secondLetter in $letters) { $firstPart.Add("$firstLetter$secondLetter") }
}

$secondPart = [System.Collections.Generic.List[string]]@()
foreach ($nb in $numbers) {
    $nb = switch ("$nb".Length) {
        1       { "00$nb" }
        2       { "0$nb" }
        default { $nb }
    }
    $secondPart.Add([string]$nb)
}

$thirdPart = $firstPart

$fullResults = @()
$firstPart | ForEach-Object {
    $1 = $_
    $secondPart | ForEach-Object {
        $2 = $_
        $thirdPart | ForEach-Object {
            $3 = $_
            $fullResults += "$1-$2-$3"
        }
    }
}

$fullResults = [System.Collections.Generic.List[string]]@()
foreach ($1 in $firstPart) {
    foreach ($2 in $secondPart) {
        foreach ($3 in $thirdPart) {
            $fullResults.Add("$1-$2-$3")
        }
    }
}

```