---
layout: post
title: "Partie X"
thumbnailColor: "#007acc"
icon: 🎓
---

## Résumé

## Détails

### Vérification des données à l'entrée

```powershell

do {
    $validAnswer = try {
        [int]$answer = Read-Host "TEST"
        $true
    } catch {
        Write-Host "Answer is bad formating"
        $false
    }
} while ($validAnswer -ne $true)

```

### Définir les bornes supérieures et inférieures

```powershell

$limitLow  = 0
$limitHigh = 1000

# Borne inférieure
$limitLow  = $allAnswers | Where-Object {$_ -lt $random} | Sort-Object -Descending | Select-Object -First 1

# Borne supérieure
$limitHigh = $allAnswers | Where-Object {$_ -gt $random} | Sort-Object | Select-Object -First 1

```

### Modifier les couleurs

### Nettoyer l'affichage après chaque essai

### Sauvegarder les scores dans un CSV

### Sauvegarder dans un JSON

### Récupérer les high-scores avec une requête web

### Calcul de statistique

### Afficher une barre de progression

### Passage en interface graphique avec WPF

```xaml
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Deviner le nombre" MinHeight="230" Height="300" MinWidth="300" Width="350">
    <Grid Margin="15">
        <StackPanel>
            <Label Name="labelTitle" Content="Deviner le nombre aléatoire !" FontSize="18" FontWeight="Bold" FontFamily="Bahnschrift" Foreground="#343434" Margin="10" HorizontalAlignment="Center" VerticalAlignment="Center"/>
            <Separator/>
            <Grid Margin="10">
                <Grid.ColumnDefinitions>
                    <ColumnDefinition Width="50"/>
                    <ColumnDefinition Width="20"/>
                    <ColumnDefinition MinWidth="80"/>
                    <ColumnDefinition Width="20"/>
                    <ColumnDefinition Width="50"/>
                </Grid.ColumnDefinitions>
                <Label Name="labelMin" Content="1" HorizontalAlignment="Center" VerticalAlignment="Center"/>
                <Label Content="&lt;" HorizontalAlignment="Center" VerticalAlignment="Center" Grid.Column="1"/>
                <TextBox Name="textboxResponse" Text="500"  MaxLength="4" Margin="10" Height="25" HorizontalAlignment="Stretch" VerticalAlignment="Center" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" Grid.Column="2"/>
                <Label Content="&lt;" HorizontalAlignment="Center" VerticalAlignment="Center" Grid.Column="3"/>
                <Label Name="labelMax" Content="1000" HorizontalAlignment="Center" VerticalAlignment="Center" Grid.Column="4"/>
            </Grid>
            <Label Name="labelText" Content="Le nombre est plus..." HorizontalAlignment="Center" VerticalAlignment="Center"/>
        </StackPanel>
        <ProgressBar Name="progressbarCoupsRestants" Minimum="0" Maximum="10" Height="10" Foreground="#FAFAFA" Margin="10" HorizontalAlignment="Stretch" VerticalAlignment="Bottom"/>
    </Grid>
    
    <!--
    <Grid Margin="0,0,4,0" Height="266" VerticalAlignment="Top">
        <Label Name="labelMinimum" Content="1" HorizontalContentAlignment="Center" HorizontalAlignment="Left" Height="23" Margin="54,54,0,0" VerticalAlignment="Top" Width="43"/>
        <TextBox Name="textboxReponse" HorizontalAlignment="Left" TextAlignment="Center" Height="23" Margin="117,54,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="120"/>
        <Label Name="labelMaximum" Content="1000" HorizontalContentAlignment="Center" HorizontalAlignment="Left" Height="23" Margin="259,54,0,0" VerticalAlignment="Top" Width="43"/>
        <Label Name="labelTexte" Content="Le nombre est plus..." HorizontalContentAlignment="Center" HorizontalAlignment="Left" Margin="54,82,0,0" VerticalAlignment="Top" Width="248" FontWeight="Bold"/>
        <Button Name="buttonValider" Content="Valider" HorizontalAlignment="Left" Margin="117,139,0,0" VerticalAlignment="Top" Width="120" Height="23"/>
        <Button Name="buttonRecommencer" Content="Recommencer ?" Visibility="Hidden" HorizontalAlignment="Left" Margin="117,139,0,0" VerticalAlignment="Top" Width="120" Height="23"/>
        <ProgressBar Name="progressbarCoupsRestants" HorizontalAlignment="Left" Height="10" Margin="24,222,0,0" VerticalAlignment="Top" Width="308" Minimum="0" Maximum="10" Value="0" Foreground="DarkGray"/>
        <Label Name="labelTemps" Content="" HorizontalContentAlignment="Center" HorizontalAlignment="Left" Margin="54,108,0,0" VerticalAlignment="Top" Width="248" FontWeight="Bold"/>
        <Label Name="labelNom" Content="Ecrivez votre nom pour sauvegarder votre score" Visibility="Hidden" HorizontalContentAlignment="Center" HorizontalAlignment="Left" Margin="24,23,0,0" VerticalAlignment="Top" Width="308"/>
        <Button Name="buttonScore" Content="Meilleurs scores" Visibility="Hidden" HorizontalAlignment="Left" Margin="117,179,0,0" VerticalAlignment="Top" Width="120" Height="23"/>
    </Grid> -->
</Window>
```

### Mode simplifié avec (Get-Random de 0 à 100)*100

### Mise en fonction (mise en bouate)

### 1. Ajouter un chronomètre

Chronométrer le temps qu'il faut à l'utilisateur pour trouver le nombre aléatoire.

- Méthodes possibles :
  - **Classe .NET "System.Diagnostics.Stopwatch"**
  - Commande "Measure-Command"
  - Commande "New-TimeSpan"
- Nom de variable : "stopwatch" 

<details>
  <pre><code>
    $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
    $stopwatch.Stop()

    $stopwatch = Measure-Command { <#[...]#> }

    $startTime = Get-Date
    $stopWatch = New-TimeSpan -Start $startTime -End (Get-Date)
  </code></pre>
</details>

### 2. Formatage du temps de résolution

Arrondir le temps total de résolution en seconde à au millième de seconde (0.001 secondes).

- Classe .NET "System.Math"

<details>
  <pre><code>
    [System.Math]::Round($stopWatch.Elapsed.TotalSeconds,3)
  </code></pre>
</details>

### 3. Affichage du temps de résolution

Dans l'objet affiché à la fin, on ajoute le temps de résolution de la tentative. 

- Objet "PSCustomObject"
- Propriété "totalSeconds"

<details>
  <pre><code>
    [PSCustomObject]@{
        "Random"       = $random
        "Answer"       = $answer
        "Count"        = $i
        "TotalSeconds" = [System.Math]::Round($stopWatch.Elapsed.TotalSeconds,3)
    } | Format-List
  </code></pre>
</details>

