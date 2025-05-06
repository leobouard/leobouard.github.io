---

title: "Cours PowerShell #5 - Top chrono !"
description: "On ajoute un chronomètre qui va mesurer le temps de résolution total ainsi que le temps moyen par tentative"
tableOfContent: "/2022/12/01/cours-pratique-powershell-introduction#table-des-matières"
nextLink:
  name: "Partie 6"
  id: "/2022/12/01/cours-pratique-powershell-006"
prevLink:
  name: "Partie 4"
  id: "/2022/12/01/cours-pratique-powershell-004"
---

## Consigne

On ajoute un chronomètre qui se lance après que le script ait reçu la première réponse du joueur. Ce chronomètre s'arrêtera juste avant d'afficher les résultats, qui inclurons maintenant le temps total en secondes pour la résolution (arrondi à 0.001 seconde) et le temps moyen par essai (également arrondi à 0.001 seconde).

### Résultat attendu

```plaintext
VICTOIRE ! Vous avez deviné le nombre aléatoire

Nombre aléatoire          : 198
Réponses                  : {500, 250, 125, 200...}
Réponse moyenne           : 216
Tentatives                : 10
Temps de résolution (sec) : 16,036
Temps moyen par tentative : 1,604
```

---

## Étape par étape

1. Créer et lancer un chronomètre
2. Stopper le chronomètre
3. Afficher le temps de résolution
4. Formater du temps de résolution
5. Calculer et afficher le temps par coup

### Créer et lancer un chronomètre

Pour mesure un temps d'exécution, il existe deux méthodes principales en PowerShell :

- le combo des commandes `Get-Date` pour obtenir la date à un instant T et `New-TimeSpan` pour mesurer un écart de temps entre deux dates. Les deux combinés permettent d'obtenir une sorte de chronomètre. On démarre le chronomètre en sauvegardant la date du début dans une variable `$startTime`
- la classe .NET `[System.Diagnostics.Stopwatch]` : "stopwatch" signifie litéralement "chronomètre". On peut démarrer le chronomètre avec la méthode `Start()` et le stocker dans la variable `$stopwatch`

On peut également mentionner la commande `Measure-Command` qui permet de mesurer le temps d'exécution d'un bloc de script, mais celle-ci ne convient pas à notre usage car notre début se situe dans une boucle et la fin se trouve en dehors de cette boucle (le bloc de script n'est donc pas entier).

Avant de lancer le chronomètre, on va juste s'assurer qu'un chronomètre n'est pas déjà en cours d'exécution (puisque le départ se trouve dans la boucle). Pour faire ça, plusieurs méthodes sont possibles :

- pour la technique `Get-Date`, on vérifie simplement que la variable `$startTime` existe
- pour la technique `[System.Diagnostics.Stopwatch]`, il existe la propriété `IsRunning` qui permet de vérifier que le chronomètre est bien démarré

```powershell
# Pour "Get-Date" & "New-TimeSpan"
if (!$startTime) { $startTime = Get-Date }

# Pour "System.Diagnostics.Stopwatch"
$stopwatch = [System.Diagnostics.Stopwatch]::New()
if ($stopwatch.IsRunning -eq $false) { $stopwatch.Start() }
```

### Stopper le chronomètre

Pour arrêter le chronomètre, tout dépend du type de chronomètre que l'on utilise :

- pour la technique avec le combo `Get-Date` & `New-TimeSpan` : on mesure le temps écoulé avec une comparaison via `New-TimeSpan`
- pour la technique `[System.Diagnostics.Stopwatch]`, on utilise la méthode `Stop()`

```powershell
# Pour "Get-Date" & "New-TimeSpan"
$stopwatch = New-TimeSpan -Start $startTime

# Pour "System.Diagnostics.Stopwatch"
$stopwatch.Stop()
```

### Afficher le temps de résolution

Le temps total de résolution en secondes est stocké dans la propriété `TotalSeconds` du chronomètre.

```powershell
# Pour "Get-Date" & "New-TimeSpan"
$stopwatch.TotalSeconds

# Pour "System.Diagnostics.Stopwatch"
$stopwatch.Elapsed.TotalSeconds
```

### Formater du temps de résolution

Pour arrondir le temps total de résolution au millième de seconde (0.001 seconde), on utilise la classe .NET `[System.Math]` qui prend deux paramètres : le premier est la valeur à arrondir et le deuxième est le nombre de décimales que l'on doit conserver (dans notre cas : 3).

```powershell
[System.Math]::Round($stopwatch.Elapsed.TotalSeconds,3)
```

### Calculer et afficher le temps par coup

L'étape la plus simple de cette partie : on divise avec l'opérateur `/` le nombre de secondes du chronomètre par le nombre de coups stockés dans la variable `$i`.

```powershell
$stopwatch.Elapsed.TotalSeconds / $i
```

## Correction

<a class="solution" href="https://github.com/leobouard/leobouard.github.io/blob/main/assets/scripts/cours-pratique-powershell-005.ps1" target="_blank">Voir le script complet</a>