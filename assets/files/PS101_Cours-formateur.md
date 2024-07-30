---
marp: true
---

# PowerShell 101

Devenir opérationnel le plus rapidement possible en PowerShell

---

## La base de la base

PowerShell est un language de scripting développé par Microsoft pour administrer les environnements techniques Microsoft (Windows, Hyper-V, Active Directory, Microsoft 365, Azure, etc.)

---

Il est installé par défaut sur tous les Windows depuis Windows 7 avec deux composants :

- **Windows PowerShell (5.1)** pour l'interface de commande classique
- **Windows PowerShell ISE** pour l'environnement de développement

> PowerShell est un outil incontournable pour gagner en efficacité sur la partie administration système.

---

## Historique rapide

- **2006** : Première version de PowerShell
- **2009** : Déploiement de PowerShell à grande échelle (installé par défaut sur Windows 7 & Windows Server 2008 R2)
- **2016** : Passage en version 5.0 qui marque le début de l'aire "moderne" de PowerShell
- **2019** : Lancement de PowerShell v7

---

## Architecture

PowerShell propose des commandes par défaut, disponibles nativement mais sa force réside dans l'utilisation de modules. C'est les modules qui permettent d'administrer des technologies annexes².

---

On peut voir les modules comme une liste de commandes sur une technologie. Il existe des modules :

- **officiels Microsoft** (Hyper-V, Microsoft 365, Active Directory, Exchange)
- **officiels éditeurs** (Quest, ShareGate, VMWare)
- **de la communauté** (PSWriteHTML, PSWindowsUpdate, DellBIOSProvider)

---

## A vous de jouer !

> Installation de Visual Studio Code et de l'extension PowerShell

⌚ 10 minutes

---

## Syntaxe des commandes

Les commandes PowerShell se décomposent en trois parties distinctes :

1. Le verbe
2. Le préfixe (optionnel)
3. Le nom

Le verbe est séparé du reste par un tiret, ce qui nous donne la structure suivante : `Verbe-PrefixeNom`

---

### Verbe

Voici quelques exemples :

- **Get** : récupérer un truc
- **Set** : modifier un truc
- **New** : créer un truc
- **Add** : ajouter un truc
- **Remove** : supprimer un truc
- **Convert** : convertir un truc

Il existe une liste de verbes approuvés par Microsoft.\
On peut obtenir cette liste avec la commande `Get-Verb`.

---

### Préfixe (optionnel)

Indique la provenance de la commande et permet d'éviter les conflits entre des commandes provenant de différents modules.
Certaines commandes *de base* de PowerShell n'ont pas de préfixe, mais la plupart des modules fournissent des commandes avec préfixes :

- `Mg` pour les commandes Microsoft Graph
- `AD` pour les commandes Active Directory
- `PnP` pour le module SharePoint

---

### Nom

Le nom donne une description brève de la commande.\
Ce nom est **toujours au singulier** et n'a pas de limite de longueur.

---

### En résumé

Type | Description | Exemples
---- | ----------- | --------
Verbe | Indique la méthode | Get, Set, New...
Préfixe | Indique la provenance de la commande | EXO, AD, MG...
Nom | Indique l'utilité de la commande | User, Group, Service

---

Quelques exemples de commandes :

- `Add-LocalGroupMember`
- `Get-Date`
- `New-ADUser`
- `Remove-MgGroup`
- `Start-Service`
- `Write-Host`

---

## Les alias

Certaines commandes possèdent des "alias" qui permette d'utiliser une commande avec un nom alternatif, souvent plus court et/ou issu de la syntaxe UNIX.

Voici quelques exemples :

Alias | Commande | Description
----- | -------- | -----------
`cd` | `Set-Location` | Se déplacer dans un répertoire
`ls` | `Get-ChildItem` | Lister le contenu d'un dossier
`mkdir` | `New-Item` | Créer un dossier
`cls` | `Clear-Host` | Nettoyer l'affichage dans la console

---

Les alias ne doivent pas être utilisé dans un script pour des raisons d'accessibilité. Ceux-ci ne doivent être utilisés que lorsque vous faites des requêtes dans la console.

La liste des alias est disponible avec la commande `Get-Alias` (ou `gal` pour les intimes).

---

## Les paramètres

Certaines commandes peuvent donner un résultat juste en entrant le nom de la commande. C'est le cas de la commande `Get-Date`, que l'on va utiliser en exemple sur les éléments suivants.

Les paramètres servent à modifier ou affiner le résultat d'une commande, pour obtenir un résultat au plus proche de vos attentes.

---

Le résultat par défaut :

~~~powershell
Get-Date
~~~

Avec l'utilisation du paramètre `-Year`, on indique l'année qui nous intéresse :

~~~powershell
Get-Date -Year 2010
~~~

Il est possible d'utiliser plusieurs paramètres en combinaison, pour obtenir la date au 1 janvier 2010 par exemple :

~~~powershell
Get-Date -Year 2010 -Month 01 -Day 01
~~~

---

Si on veut indiquer une valeur plus complexe que de simple chiffres, il est souvent nécessaire d'utiliser des *double-quotes* pour encadrer la valeur à passer en paramètre, exemple :

~~~powershell
Get-Date -Date "15/12/1997"
~~~

Certains paramètres n'ont pas besoin d'avoir une valeur définie pour être utilisé, c'est ce qu'on appelle un *switch* :

~~~powershell
Get-Date -AsUTC
~~~

---

D'autres paramètres peuvent s'exclure entre-eux car ils ne peuvent pas être utilisé en combinaison, exemple :

~~~powershell
Get-Date -Format "dd/MM/yyyy"
# vs.
Get-Date -UFormat "%d/%m/%Y"
~~~

---

Pour consulter la liste des paramètres disponibles, le plus simple est de tapper votre commande, ajouter un tiret et appuyer sur `Ctrl`+`Espace`.

~~~plainttext
PS C:\> Get-Date -
Date                 Hour                 UFormat              ErrorAction          WarningVariable
UnixTimeSeconds      Minute               Format               WarningAction        InformationVariable
Year                 Second               AsUTC                InformationAction    OutVariable
Month                Millisecond          Verbose              ProgressAction       OutBuffer
Day                  DisplayHint          Debug                ErrorVariable        PipelineVariable
~~~

---

Certains paramètres sont des paramètres "par défaut" que vous retrouverez sur quasiment toutes les commandes PowerShell, c'est le cas des paramètres suivants :

- `-Verbose` : permet d'afficher toutes les actions de la commande dans la console
- `-ErrorAction` : indique le comportement que la commande doit suivre en cas d'erreur
- `-WhatIf` : permet de simuler l'action de la commande sans jamais faire l'action

---

### Astuces de pro

Vous n'avez pas besoin de spécifier le nom complet du paramètre. Dès lors qu'il n'y a plus qu'un choix possible, PowerShell comprendra implicitement le paramètre utilisé.

~~~powershell
Get-Date -H 12 -Min 59 -Sec 00
# vs.
Get-Date -Hour 12 -Minute 59 -Second 00
~~~

Egalement, certains paramètres sont utilisés par défaut si une valeur est spécifiée juste après une commande. Exemple :

~~~powershell
Write-Host 'Hello world!'
~~~

---

## Trouver une commande

Il y a une commande PowerShell qui permet de trouver toutes les autres : `Get-Command`

Pour trouver toutes les commandes qui contiennent le mot "culture" :

~~~powershell
Get-Command -Name "*culture*"
~~~

> Suivant la présence ou la position des `*`, cela permet de modifier la requête pour demander les commandes qui commencent par un texte, finissent par un texte ou simplement contiennent un texte.

---

## Exercice n°1

1. Expérimenter les commandes suivantes et trouver leur utilité :
   - `Get-Process`
   - `Get-Service`
   - `Get-ChildItem`
   - `Get-LocalGroup`
   - `Get-ComputerInfo`
2. Trouver la commande pour générer un nombre aléatoire grâce à `Get-Command`
3. Générer un nombre aléatoire
4. Générer un nombre aléatoire entre 1 et 10

---

## Pipeline

Le pipeline permet d'assembler des commandes entre-elles en envoyant le résultat d'une commande (ou autre chose) vers la suivante.

~~~powershell
Get-Content -Path '.\fichier.json' | ConvertFrom-Json
~~~

---

## Les commandes essentielles

Ces commandes là vont vous suivre dans tous vos scripts et pour toujours ! Il est important de les connaitre par coeur et de bien comprendre leur utilité.

- `Select-Object` : pour selectionner des propriétés
- `Sort-Object` : pour trier des données
- `Measure-Object` : pour mesurer une collection
- `Where-Object` : pour filtrer des données
- `ForEach-Object` : pour boucler sur chaque élément d'une collection

---

### Select-Object

`Select-Object` permet de manipuler une collection. La plupart du temps, on se servira de cette commande pour limiter la vue à ce qui nous intéresse.

~~~powershell
Get-ComputerInfo | Select-Object BiosSerialNumber, CsManufacturer, CsModel, CsProcessors
~~~

En utilisant un astérisque, on peut également afficher toutes les propriétés :

~~~powershell
Get-Service | Select-Object *
~~~

On peut également sélectionner uniquement les X premiers ou X derniers éléments d'une collection :

~~~powershell
Get-Service | Select-Object -First 10
# vs.
Get-Service | Select-Object -Last 10
~~~

---

### Exercice n°2A

A l'aide des commandes `Select-Object` et `Get-Service`, afficher les 25 premiers services avec les informations suivantes :

- Nom du service
- Type de démarrage
- Si le service peut être arrêté
- Si le service peut être éteint

---

### Sort-Object

`Sort-Object` pour trier des données, selon un ordre ascendant ou descendant

~~~powershell
Get-Process | Sort-Object -Property CPU
# vs.
Get-Process | Sort-Object -Property CPU -Descending
~~~

Il est également possible de dédupliquer une liste :

~~~powershell
Get-Process | Sort-Object -Property ProcessName -Unique
~~~

---

### Measure-Object

`Measure-Object` permet de mesurer une collection, en comptant le nombre d'élément, calculant la somme ou faisant une moyenne des valeurs numérique.

Pour compter le nombre d'objets :

~~~powershell
Get-ChildItem -Path 'C:\Windows' | Measure-Object
~~~

Pour calculer une somme et une moyenne :

~~~powershell
Get-ChildItem -Path 'C:\Windows' | Measure-Object -Property Length -Sum -Average
~~~

On observe que `Measure-Object` compte moins de résultats cette fois-ci, car il ne prend en compte que les éléments avec une propriété "Length".

---

### Exercice n°2B

A l'aide des commandes `Get-Process`, `Sort-Object` et `Measure-Object`, compter le nombre de processus unique sur votre ordinateur.

---

### Where-Object

`Where-Object` permet de filtrer pour ne garder que la donnée qui nous intéresse.

> `-eq` est un opérateur de comparaison pour savoir si un élément est égal à un autre

~~~powershell
Get-Service | Where-Object {$_.Status -eq 'Running'}
~~~

---

> `-like` est un opérateur qui permet de rechercher une chaine de caractère. En fonction de la position de l'astérisque, cela permet de trouver des résultats qui commencent par un mot, contiennent un mot ou finissent par un mot en particulier :

~~~powershell
Get-Service | Where-Object {$_.Name -like 'win*'}
# vs.
Get-Service | Where-Object {$_.Description -like '*xbox*'}
# vs.
Get-Service | Where-Object {$_.Name -like '*svc'}
~~~

---

### ForEach-Object

`ForEach-Object` permet d'appliquer un traitement *pour chaque* objet de la collection. C'est le type de boucle le plus répandu en PowerShell.

`$_` est ce qu'on appelle la "variable courante" : elle contient l'objet en cours de traitement.

~~~powershell
Get-LocalGroup | ForEach-Object {
    Write-Host $_.Name -ForegroundColor Yellow
    Get-LocalGroupMember -Group $_ | Format-List
}
~~~

Dans l'exemple ci-dessus, la variable courante va contenir le groupe "Administrateurs", puis "Administrateur Hyper-V", puis "Duplicateurs", etc.

---

### Exercice n°2C

A l'aide des commandes et des connaissances que vous avez vu précédemment, réaliser votre premier script en suivant le pseudo-code indiqué :

1. Récupérer les fichiers à la racine de C:\Windows
2. Filtrer pour n'obtenir que les fichiers .EXE
3. Obtenir les ACLs de chaque fichier (commande : `Get-Acl`)

Le script n'utilise que des commandes simples, avec des pipeline entre chaque.

---

## Travaux pratiques n°1

Dans ces premiers travaux pratiques nous allons jouer à un "wargame". L'idée est simple : vous avez une connexion SSH avec un compte 1, et l'idée est de progresser en trouvant le mot de passe du compte 2 en résolvant une énigme.

---

Vous pouvez vous rendre sur <https://underthewire.tech/century> et lancer votre première connexion SSH avec la commande suivante :

~~~plainttext
ssh century.underthewire.tech -l century1
~~~

Le mot de passe du premier compte "Century1" est `century1`.

Une fois que vous aurez trouvé le mot de passe du compte "Century2", vous pourrez quitter le SSH (commande `exit`) et lancer la même commande en modifiant le nom du compte.

---

### Conseils et informations

L'objectif pour cette session est d'arriver jusqu'au **niveau 10**. Avant de commencer, voici quelques conseils :

- Les mots de passe seront toujours en minuscule et sans espace
- Les connexions SSH se sont pas toujours stable, donc noter au moins le mot de passe de chaque compte pour éviter de retomber au niveau 1
- Il n'y a pas besoin de faire de scripts complexes pour le moment, donc restez sur des choses simples
- Google/Copilot est votre ami ! Savoir trouver de l'information est aussi important que savoir s'en servir

---

### Liste des commandes utiles

Commande | Description
-------- | -----------
$PSVersionTable | Obtenir la version de PowerShell
Get-ADDomain | Donne les informations du domaine Active Directory
Get-Alias | Trouve l'alias d'une commande et inversement
Get-ChildItem | Liste les éléments d'un dossier
Get-Content | Récupère le contenu d'un fichier

---

## Variables

Les variables sont un composant majeur de n'importe quel language de programmation/scripting. Dans le cas de PowerShell, les variables sont très flexibles et simple à utiliser. On les déclare à n'importe quel moment avec un `$` et on peut y stocker n'importe quoi en utilisant `=` (résultat de commande, texte, collection, nombre...)

~~~powershell
$users = Get-LocalUser
$text = 'Voici un texte court'
$number = 1032
~~~

---

### Interagir avec le contenu

Pour consulter le contenu d'une variable, il suffit simplement de tapper le nom de la variable dans la console :

~~~powershell
$text
Voici un texte court

$number
1032
~~~

---

### Index

Pour les variables qui contiennent des collections d'objets, il est possible d'indiquer quel élément nous intéresse dans la liste en utilisant l'index. La syntaxe de l'index est plutôt simple puisqu'il suffit d'ajouter `[X]` (où *X* est le numéro d'index) directement après votre variable

~~~powershell
$array = 'Alpha','Bravo','Charlie','Delta'
$array[1]
~~~

---

Index | Valeur(s) d'exemple | Description
----- | ------------------- | -----------
[0] | Alpha | Premier élément de la collection
[1] | Bravo | Deuxième élément de la collection
[1..3] | Bravo, Charlie, Delta | Deuxième au quatrième élément de la collection
[0,2] | Alpha,Charlie | Premier et troisième élément de la collection
[-2] | Charlie | Avant-dernier élément de la collection
[-1] | Delta | Dernier élément de la collection

> L'index peut être remplacé par la commande `Select-Object` avec les paramètres `-First`, `-Skip`, `-Last` et `-SkipLast` (vu précédemment).

---

### Sous-propriétés

Lorsqu'une variable contient un ou plusieurs objets complexes avec plusieurs propriétés, il est possible d'obtenir uniquement l'information qui nous intéresse en selectionnant directement la propriété. Pour ça, il suffit d'ajouter `.Property` (où *Property* est le nom de la propriété) directement après votre variable.

~~~powershell
$users = Get-LocalUser
$users.Name
~~~

Il est possible de mixer les index et les sous-propriétés, par exemple :

~~~powershell
$users[0].Name
~~~

> Les sous-propriétés peuvent être remplacé par la commande `Select-Object` avec le paramètre `-ExpandProperty`.

---

### Conseils sur le nommage

Vous pouvez utiliser n'importe quel nom pour votre variable (lettres, chiffres et tirets & underscore), mais voici quelques conseils :

- Garder des noms simples et explicites sur leur contenu
- Utiliser des majuscules régulières : `$disabledUsers` par exemple
- Privilégier l'anglais

---

### Variables par défaut

Certaines variables sont utilisés par PowerShell pour stocker des informations importantes et nécessaires à son bon fonctionnement. Evitez de marcher sur les plate-bandes de PowerShell en utilisant ces variables pour stocker vos informations.

Pour obtenir la liste de toutes la variables existantes, vous pouvez utiliser la commande `Get-Variable`.

---

## Affichage dans du texte

Pour afficher le contenu d'une variable dans un texte, le cas général est plutôt simple :

- Si la chaine de caractère est entre des *simple-quotes*, alors la variable ne sera pas interprêtée
- Si la chaine de caractères est entre des *double-quotes*, alors la variable sera interprêtée.

Exemples :

~~~powershell
$test = 'PowerShell'
Write-Host "$test est plutôt cool"
# vs.
Write-Host '$test est plutôt cool'
~~~

---

### Cas particuliers

Si votre variable est plus complexe (vous ne voulez afficher que une sous-propriété ou/et un index), il faudra modifier un peu la syntaxe.

~~~powershell
$users = Get-LocalUser
Write-Host "Le premier utilisateur de l'ordinateur est $($users[0].Name)"
~~~

---

## Opérateurs de comparaison

Les opérateurs de comparaison permettent de comparer deux éléments entre eux en retournant un booléen (vrai ou faux) en fonction du résultat. Il existe plusieurs types d'opérateurs de comparaison mais tous fonctionnent de la même manière. Il est possible de comparer n'importe quel type de donnée (nombres, texte, dates) entre elle.

Par défaut, les opérateurs de comparaison ne sont pas sensible à la casse (dans le cas de comparaison sur du texte), mais une variante sensible à la casse est disponible en ajoutant un "C" avant l'opérateur habituel. Exemple : `-clike` est la version sensible à la casse de `-like`.

---

### Egalité

Opérateur | Description
--------- | -----------
`-eq`     | Egal à
`-ne`     | N'est pas égal à
`-gt`     | Strictement supérieur à
`-ge`     | Supérieur ou égal à
`-lt`     | Strictement inférieur à
`-le`     | Inférieur ou égal à

---

### Exercice n°4A

Sans utiliser PowerShell, prédire le résultat de chaque comparaison :

- `"bonjour" -eq "Bonjour"`
- `"bonjour" -ceq "Bonjour"`
- `"bonjour" -gt "123"`
- `10 -ge (5+5)`
- `"bonjour" -lt "azerty"`
- `152 -le -80`

---

### Correspondance

Opérateur | Description
--------- | -----------
`-like` | Contient une chaine de caractère
`-notlike` | Ne contient pas une chaine de caractère
`-match` | Contient une expression régulière (RegEx)
`-notmatch` | Ne contient pas une expression régulière (RegEx)

Pour les opérateurs `-like` & `-notlike`, l'utilisation d'un astérisque est vitale pour indiquer si la chaine recherchée est au début, n'importe-où ou à la fin de la chaine de caractère.

---

Comparaison | Résultat | Description
----------- | -------- | -----------
`"Anticonstitutionnel" -like "Anti*"` | TRUE | Est-ce que *Anticonstitutionnel* commence par "Anti" ?
`"Anticonstitutionnel" -like "*constit*"` | TRUE | Est-ce que *Anticonstitutionnel* contient par "constit" ?
`"Anticonstitutionnel" -like "*onnel"` | TRUE | Est-ce que *Anticonstitutionnel* fini par "onnel" ?
`"Anticonstitutionnel" -like "An*el"` | TRUE | Est-ce que *Anticonstitutionnel* commence par "An" et fini par "el" ?

L'ordre à une importance pour cet opérateur et inverser les deux parties ne donnera pas le même résultat.

---

### Exercice n°4B

~~~powershell
$days = 'Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'
~~~

Trouver la bonne utilisation de `like` et `-notlike` pour obtenir les résultats suivants :

1. Les jours du week-end
2. Les jours de la semaine
3. Mardi et Mercredi
4. Mardi, Mercredi et Jeudi

---

### Appartenance

Les opérateurs de comparaison pour l'appartenance sont très simple et ne s'utilisent que pour requêter des collections d'objets.

Opérateur | Description
--------- | -----------
`-in` | L'objet est dans la collection
`-notin` | L'objet n'est pas dans la collection
`-contains` | La collection contient l'objet
`-notcontains` | La collection ne contient pas l'objet

---

### Exercice n°4C

~~~powershell
$months = 'janvier','février','mars','avril','mai','juin','juillet','août','septembre','octobre','novembre','décembre'
~~~

Sans utiliser PowerShell, prédire le résultat de chaque comparaison :

- `"avril" -in $months`
- `$months -in "avril"`
- `"avril" -contains $months`
- `$months -contains "avril"`

---

### Manipulation de texte

Certains opérateurs ne font pas de comparaison mais peuvent modifier des chaines de caractères. On peut en retenir trois principaux :

1. `-replace` pour remplacer une chaine de caractères par une autre
1. `-split` pour séparer une chaine de caractères suivant un délimiteur
1. `-join` pour assembler une chaine de caractères avec un délimiteur

---

### Exercice n°4D

Devinez le contenu de chaque variable :

~~~powershell
$replace = 'Je serai en avance' -replace 'avance','retard'
$split1 = 'abcdefghijklmnopqrstuvwyz' -split ''
$split2 = '192.168.0.1' -split '.'
$join = 'Robert','Jimmy','John','John Paul' -join '+'
~~~

---

## Opérateurs logiques

Les opérateurs logiques permettent de relier des comparaisons entre-elles. Les deux plus utilisés sont `-and` (ET) et `-or` (OU).

---

### Exercice n°5

Sans utiliser PowerShell, prédire le résultat de chaque comparaison :

- `15 -gt 10 -and "Testing" -like "*ing"`
- `$true -eq $false -or (1,2,3) -contains 3`
- `1 -le 10 -and ('bonjour' -like 'bon' -or 'test' -cne 'TEST')`

---

### Travaux pratiques n°2

Vous pouvez maintenant réaliser les 5 défis restants sur le "wargame" CENTURY.

Vous pouvez vous rendre sur <https://underthewire.tech/century> et lancer votre connexion SSH avec la commande suivante :

~~~plainttext
ssh century.underthewire.tech -l century9
~~~

Le mot de passe du premier compte "Century9" est `696`.

Une fois que vous aurez trouvé le mot de passe du compte "Century10", vous pourrez quitter le SSH (commande `exit`) et lancer la même commande en modifiant le nom du compte.

---

## Conditions

En PowerShell, les conditions sont représentées par trois structures :

- IF/ELSEIF/ELSE
- SWITCH
- TERNAIRE (à partir de PowerShell 7+), ne sera pas abordé ici

---

### IF/ELSEIF/ELSE

La structure du IF/ELSEIF/ELSE est la plus courante en PowerShell et permet de traiter des conditions simples rapidement. Cette structure est très modulable et se décline le plus souvent de trois manières :

1. **IF** : pour faire un traitement si la condition est remplie
2. **IF/ELSE** : pour faire un traitement si la condition est remplie et un autre si elle n'est pas remplie
3. **IF/ELSEIF/ELSE** : pour faire un traitement suivant la condition qui sera remplie et un autre pour le reste

---

~~~powershell
if (condition) {
    # Traitement si la condition est remplie
}
elseif (condition) {
    # Traitement si la condition secondaire est remplie
}
else {
    # Traitement si aucune condition n'a été remplie
}
~~~

---

### Exercice n°6A

Avec les commandes `Read-Host`, `Write-Host` et des conditions, réaliser un script qui donne une appréciation selon l'âge de la personne :

- Moins de 18 ans : "Rien à faire ici !
- Entre 18 et 25 ans : "Le bel âge !"
- Entre 25 et 45 ans : "Salut les d'jeuns"
- Entre entre 45 et 65 : "J'adore Nostalgie !"
- Entre 65 et 80 ans : "Il serait temps de partir en retraite"
- Plus de 80 ans : "Ça sent le sapin"

---

### SWITCH

Le SWITCH permet de traiter un grand nombre de comparaison différentes dans une syntaxe très compacte.

~~~powershell
switch ($num) {
    22 { Write-Host 'Finistère' }
    31 { Write-Host 'Haute-Garonne' }
    33 { Write-Host 'Gironde' }
    35 { Write-Host 'Ille-et-Vilaine' }
    44 { Write-Host 'Loire-Altantique' }
    default { Write-Host "Numéro incorrect" -ForegroundColor Red }
}
~~~

---

### Exercice n°6B

Ecrivez un script PowerShell qui permet de transformer une phrase en alphabet militaire.

Vous aurez besoin d'utiliser des variables, une condition, une boucle, un opérateur de manipulation de texte et les commandes `Write-Host` et `Read-Host`.

---

Le résultat attendu est le suivant :

~~~plainttext
Entrer la phrase à convertir: HELLO WORLD

H - Hotel
E - Echo
L - Lima
L - Lima
O - Oscar

W - Whiskey
O - Oscar
R - Romeo
L - Lima
D - Delta
~~~
