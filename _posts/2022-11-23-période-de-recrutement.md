
# Période de recrutement

## Récupérer la liste des utilisateurs

```powershell

$uri = "https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/files/users.csv"
$users = (Invoke-WebRequest -Uri $uri).Content | ConvertFrom-Csv -Delimiter ';'

```

## Ajouter une date aléatoire à chaque utilisateur

### Première solution

Générer une date aléatoire, ça peut paraitre simple au premier abords, mais ça ne l'est pas nécessairement ! Dans mon cas, ma première piste était de récupérer 3 valeurs aléatoires :

- le jour (donc entre 1 et 31)
- le mois (donc entre 1 et 12)
- l'année (dans mon cas, entre 1990 et 2022)

...pour ensuite générer la fameuse date aléatoire. Problème : le 31 février n'existe pas. On peut contourner le problème en réduisant le nombre de jours possible à 28, mais on s'eloigne alors de la réalité.

```powershell

$days   = 1..28
$months = 1..12
$years  = 1990..2022

$users | ForEach-Object {

    $params = @{
        Day    = $days | Get-Random
        Month  = $months | Get-Random
        Year   = $years | Get-Random
        Hour   = 0
        Minute = 0
        Second = 0
    }
    $value = Get-Date @params
    $_ | Add-Member -MemberType NoteProperty -Name 'hireDate' -Value $value -Force

}

```

### Deuxième solution

Une autre méthode serait d'enlever un nombre de jours aléatoire à la date du jour. On calcule le nombre de jours qui nous séparent de 

```powershell

$max = [int](New-TimeSpan -Start (Get-Date '01/01/1990') -End (Get-Date)).TotalDays
$range = 1..$max

$users | ForEach-Object {
    $random = $range | Get-Random
    $value  = (Get-Date -H 0 -Min 0 -Sec 0).AddDays(-$random)
    $_ | Add-Member -MemberType NoteProperty -Name 'hireDate' -Value $value -Force
}

```

Attention quand-même : cette méthode consomme beaucoup plus de ressources que l'autre ! Si vous utilisez PowerShell 7 ou supérieur, je vous recommande d'utiliser le paramètre '-Parallel' pour la boucle 'ForEach-Object' afin de diviser le temps de traitement. Si vous utilisez ce paramètre, il faudra quand-même un peu adapter votre script pour qu'il soit compatible.

## Calculer le nombre d'arrivées par mois

Pour ça, il existe une commande sur-mesure : `Group-Object` qui permet de regrouper des objets en fonction d'un critère commun. Dans notre cas


```powershell

$users | Select-Object givenName,surname,@{N='month';E={Get-Date -Month $_.hireDate.month -Format 'MMM'}} `
    | Group-Object -Property month `
    | Sort-Object -Property Count

```

## Si vous voulez aller plus loin 

- Calculer le nombre d'arrivée par jour de la semaine (lundi, mardi, etc...) et par année
- Calculer l'ancienneté de chaque employé et faire statistiques avec

Et puis si vous avez la chance d'avoir un environnement Active Directory ou Azure AD sous la main, je ne peux que vous encourager a adapter votre script pour le tester sur votre infrastructure. Cela vous permettra d'avoir des données utiles en plus de satisfaire votre curiosité personnelle.