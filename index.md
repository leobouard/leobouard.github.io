# Titre principal

Un petit sous texte qui permet de mettre en contexte le site peut-être. Après je ne suis pas un professionnel du développement web donc bon on fait avec les moyens du bord et surtout selon nos capacités (limités).

## Ceci est un plus petit titre

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

<div class="hero">
    <div width="20%" style="padding: 1em;">
        <img src="/assets/images/logo_white.svg" style="transform: rotate(-8deg);">
    </div>
    <div width="80%" style="display: table-cell; vertical-align: middle;">
        <span style="font-size: large;">C'est quoi au juste "La Boua Bouate" ?</span>
        <p>Ce site web sert globalement de boîte à idée avec :</p>
        <ul>
            <li>des défis PowerShell</li>
            <li>des trucs & astuces</li>
            <li>des petites trouvailles</li>
        </ul>
        <p>...et un peu tout ce qui me passe par la tête ! 😀</p>
        <br>
        <a href="/challenges">Voir les défis</a>
    </div>
</div>

## Un autre petit titre

**C'est un titre H2 au dessus**

Colonne A | Colonne B
--------- | ---------
Valeur 1A | Valeur 1B
Valeur 2A | Valeur 2B
Valeur 3A | Valeur 3B
Valeur 4A | Valeur 4B

Et si on mettait un petit lien hypertexte pour la route ? [Ça c'est du lien](https://duckduckgo.com)

### Un plus petit titre encore

> C'est du H3 cette fois-ci

Une petite liste non-ordonnée, ça vous tente ?

- Elément A
- Elément B, mais tellement plus complexe parce qu'il faut bien un peu de variété
- Elément C un peu plus court cette fois-ci

Une liste ordonnée maintenant ?

1. Premier élément
2. Deuxième élément
3. On s'est pas foulé sur celle-ci

#### Tout petit titre (H4)

![image](https://i.redd.it/if3ldk2w2j841.jpg)

On se met un séparateur et un autre texte et on devrait être pas trop mal !

---

## Un titre H2

Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.

Un peu de code pour la variété :

```powershell

$params = @{
    Path = ".\export.csv"
    Encoding = "UTF8"
    Delimiter = ";"
    NoTypeInformation = $true
}

$users = Get-ADUser -Filter * -Properties CanonicalName
$users | Foreach-Object {
    $_ | Add-Member -MemberType NoteProperty -Name "OU" -Value (($_.CanonicalName -split '/')[2])
}

$user | Export-Csv @params

``` 

Et c'est tout pour moi !
