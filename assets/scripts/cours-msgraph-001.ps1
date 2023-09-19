# Combien y'a-t'il de communes dans le département 75 ?
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/departements/75/communes'

# Combien y'a-t'il d'habitants à Louvemont-Côte-du-Poivre ?
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/communes/55307'

# Récupérer la liste des départements de votre région de naissance
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/regions'
Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/regions/52/departements'

# BONUS : Lister les cinq plus grandes villes de votre département de naissance
$result = Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/departements/85/communes'
$result | Sort-Object population -Descending | Select-Object nom,code,population -First 5

# BONUS : Quelle est la région la moins peuplée ?
$regions = Invoke-RestMethod -Method GET -Uri 'https://geo.api.gouv.fr/regions'
$regions | ForEach-Object { 
    $dpts = Invoke-RestMethod -Method GET -Uri "https://geo.api.gouv.fr/regions/$($_.code)/departements"
    $villes = $dpts | ForEach-Object {
        Invoke-RestMethod -Method GET -Uri "https://geo.api.gouv.fr/departements/$($_.code)/communes"
    }
    $pop = $villes.population | Measure-Object -Sum
    $_ | Add-Member -MemberType NoteProperty -Name 'population' -Value $pop.Sum
}
$regions | Sort-Object population | Select-Object nom,code,population