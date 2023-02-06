---
layout: post
title: "Cours PowerShell #8 - Ajout de l'interface graphique"
description: "On appose maintenant une interface graphique XAML au script PowerShell et on adapte le script existant pour convenir à ce changement"
icon: 🎓
nextLink:
  name: "Partie 9"
  id: "/2022/12/01/cours-pratique-powershell-009"
prevLink:
  name: "Partie 7"
  id: "/2022/12/01/cours-pratique-powershell-007"
---

## Consigne

Nouveau départ ! On va implémenter une interface graphique réalisée avec Windows Presentation Foundation (WPF) et stockée dans un fichier XAML externe au script. Si vous le souhaitez, vous pouvez faire votre propre interface graphique en utilisant Visual Studio Community par exemple. Je vous recommande tout de même d'utiliser le fichier que je propose comme base de travail.

<div class="information">
  <h4>P'tit conseil</h4>
  <p>Pour cette partie, je vous recommande de créer un nouveau script plutôt qu'adapter le script existant. De cette manière, vous pourrez créer la structure liée à l'interface graphique, puis copier-coller les bouts de code pertinents en dessous de chaque bouton.</p>
</div>

### Résultat attendu



### Ressources

Une interface graphique XAML est disponible ci-dessous, vous pouvez l'utiliser si besoin ou faire la vôtre en utilisant Visual Studio Community par exemple.

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
                <TextBox Name="textboxResponse" MaxLength="4" Margin="10" Height="25" HorizontalAlignment="Stretch" VerticalAlignment="Center" HorizontalContentAlignment="Center" VerticalContentAlignment="Center" Grid.Column="2"/>
                <Label Content="&lt;" HorizontalAlignment="Center" VerticalAlignment="Center" Grid.Column="3"/>
                <Label Name="labelMax" Content="1000" HorizontalAlignment="Center" VerticalAlignment="Center" Grid.Column="4"/>
            </Grid>
            <Label Name="labelText" Content="Le nombre est plus..." HorizontalAlignment="Center" VerticalAlignment="Center"/>
            <StackPanel Name="stackpanelButtons" Orientation="Horizontal" HorizontalAlignment="Center" Height="35" Visibility="Hidden">
                <Button Name="buttonRetry" Content="Recommencer" Margin="5" Width="100"/>
                <Button Name="buttonHighScore" Content="Meilleurs scores" Margin="5" Width="100"/>
            </StackPanel>
        </StackPanel>
        <ProgressBar Name="progressbarCoupsRestants" Minimum="0" Maximum="10" Height="10" Foreground="#3590F3" Background="#F2F2F2" Margin="10" HorizontalAlignment="Stretch" VerticalAlignment="Bottom"/>
    </Grid>
</Window>
```

---

## Etape par étape

1. Afficher l'interface graphique
2. Créer des évenements pour chaque action
3. Adapter le code PowerShell

## Correction

```powershell

```
