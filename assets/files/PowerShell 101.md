# PowerShell 101

## Table des matières

- [PowerShell 101](#powershell-101)
  - [Table des matières](#table-des-matières)
  - [Commandes et paramètres](#commandes-et-paramètres)
    - [Exercice n°1](#exercice-n1)
  - [Assembler les commandes entre-elles](#assembler-les-commandes-entre-elles)
    - [Exercice n°2A](#exercice-n2a)
    - [Exercice n°2B](#exercice-n2b)
    - [Exercice n°2C](#exercice-n2c)
    - [Travaux pratiques n°1](#travaux-pratiques-n1)
  - [Variables, opérateurs et conditions](#variables-opérateurs-et-conditions)

## Commandes et paramètres

### Exercice n°1

Expérimenter les commandes suivantes et trouver leur utilité

Commande         | Description
---------------- | -----------
Get-Process      | 
Get-Service      | 
Get-ChildItem    | 
Get-LocalGroup   | 
Get-ComputerInfo | 

Trouver la commande pour générer un nombre aléatoire

```powershell
Get-Command
```

Générer un nombre aléatoire entre 1 et 10

```powershell

```

## Assembler les commandes entre-elles

### Exercice n°2A

A l’aide des commandes `Select-Object` et `Get-Service`, afficher les 25 premiers services avec les informations suivantes :

1. Nom du service
2. Type de démarrage
3. Si le service peut être arrêté
4. Si le service peut être éteint

```powershell

```

### Exercice n°2B

A l’aide des commandes `Get-Process`, `Sort-Object` et `Measure-Object`, compter le nombre de processus unique sur votre ordinateur.

```powershell

```

### Exercice n°2C

A l’aide des commandes et des connaissances que vous avez vu précédemment, réaliser votre premier script en suivant le pseudo-code indiqué :

1. Récupérer les fichiers à la racine de C:\Windows
2. Filtrer pour n’obtenir que les fichiers .EXE
3. Obtenir les ACLs de chaque fichier (commande : Get-Acl)

Le script n’utilise que des commandes simples, avec des pipeline entre chaque.

```powershell

```

### Travaux pratiques n°1

Les consignes sont disponibles sur <https://underthewire.tech/century>, et l'objectif est d'atteindre le **niveau 10**.

Lancer une connexion SSH avec : `ssh century.underthewire.tech -l century1` et modifier le nom du compte en fonction de votre niveau.

Compte    | Mot de passe
--------- | ------------
century1  | `century1`
century2  | ``
century3  | ``
century4  | ``
century5  | ``
century6  | ``
century7  | ``
century8  | ``
century9  | ``
century10 | ``
century11 | ``
century12 | ``
century13 | ``
century14 | ``
century15 | ``

## Variables, opérateurs et conditions
