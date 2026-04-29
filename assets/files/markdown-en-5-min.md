---
marp: true
theme: metsys
class: default
---

<style>

  @import url('https://fonts.googleapis.com/css2?family=Be+Vietnam+Pro:ital,wght@0,100;0,200;0,300;0,400;0,500;0,600;0,700;0,800;0,900;1,100;1,200;1,300;1,400;1,500;1,600;1,700;1,800;1,900&display=swap');

  /* Variables */
  :root {
    --primary: #783cbc;
    --secondary: #b89d23;
  }
  
  section {
      border-bottom: 0.5em solid  var(--primary);
      color: #3d3834;
      background-image: url('https://www.metsys.fr/wp-content/themes/metsys/images/svg/metsys-logo.svg');
      background-repeat: no-repeat;
      background-position: top 1em right 1em;
      background-size: 6em auto;
      font-family: Arial;
  }

  h1, h2, h3, h4, h5 {
    font-family: "Be Vietnam Pro",sans-serif;
  }

  h1 {
    text-align: center;
    font-size: 3em;
    padding: 1em;
    color: var(--primary);
  }

  img {
    margin: auto;
    max-width: 100%;
    text-align: center;
  }
</style>

# Markdown en 5 min

![width:400px](https://kirkstrobeck.github.io/whatismarkdown.com/img/markdown.png)

---

## C'est quoi Markdown ?

Lui c'est John 👉

<!-- Créé en 2004 par John Gruber dans le but de fournir une alternative simple au HTML pour la mise en forme de contenu. -->

![bg right:40%](https://upload.wikimedia.org/wikipedia/commons/6/64/John_Gruber%2C_2009_%28cropped%29.jpg)

---

## Ça permet de faire quoi ?

Des beaux documents techniques !

---

![bg left:50%](https://www.kindpng.com/picc/m/134-1346891_transparent-will-smith-png-will-smith-meme-png.png)
![height:650px](https://raw.githubusercontent.com/leobouard/leobouard.github.io/main/assets/images/exemple-documentation.png)
_

---

## Les avantages de Markdown

- Syntaxe simple
- Exportable en plusieurs formats
- Ne nécessite aucun logiciel

<!-- ce qui fait du Markdown un langage de choix pour la rédaction de **documentations techniques**. -->

---

Vous avez déjà vu\
Markdown sur :

- GitHub
- Reddit
- Discord
- Notion
- Teams

![bg left:60%](https://bigmedia.bpifrance.fr/sites/default/files/styles/article_main_image/public/2022-11/5%20bonnes%20nouvelles%20pour%20le%20secteur%20du%20New%20Space.jpeg?itok=YVjKUl0d)

---

## La syntaxe

Au lieu d'utiliser des balises comme en HTML, on utilise des caractères spéciaux pour formater le texte.

<!-- On peut y faire des titres, du formatage, des tableaux, des liens et même intégrer des images -->

---

### La syntaxe de base

- `# heading`
- `*italic*`
- `**bold**`
- `- item` et `1. itemA`

---

## Titre 2

Voici un texte *en italique* et **en gras** suivi d'une liste :

- Elément A
- Elément B

Puis d'une liste numérotée :

1. Elément 1
2. Elément 2

---

```markdown
## Titre 2

Voici un texte *en italique* et **en gras** suivi d'une liste :

- Elément A
- Elément B

Puis d'une liste numérotée :

1. Elément 1
2. Elément 2
```

---

### Un peu plus de syntaxe

- `> blockquote`
- `[Link](https://)`
- `![Image](C:/users)`

---

![height:300px](https://imgs.smoothradio.com/images/191589?crop=16_9&width=660&relax=1&signature=Rz93ikqcAz7BcX6SKiEC94zJnqo=)

[Rick Astley - Never Gonna Give You Up](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

> We're no strangers to love
> You know the rules and so do I
> A full commitment's what I'm thinking of
> You wouldn't get this from any other guy

---

```markdown
![thumbnail rick astley](https://imgs.smoothradio.com/images/191589)

[Rick Astley - Never Gonna Give You Up](https://www.youtube.com/watch?v=dQw4w9WgXcQ)

> We're no strangers to love
> You know the rules and so do I
> A full commitment's what I'm thinking of
> You wouldn't get this from any other guy
```

---

### Encore un peu de syntaxe

```
Header A | Header B
-------- | --------
Value 1A | Value 1B
Value 2A | Value 2B
```

```
` ``powershell
Get-ADUser -Filter {Enabled -eq $true} -Properties *
``
```

---

## Ressources

Si vous êtes très pressé : [apprendre la base en 60 secondes](https://commonmark.org/help/)

Si vous avez plus de temps : [tutoriel pour tout savoir en 10 minutes](https://commonmark.org/help/tutorial/)

---

## Commencer avec Markdown

N'importe quel éditeur de texte ou un éditeur en ligne

<!-- N'importe quel éditeur de texte fonctionne : vous n'avez qu'à sauvegarder le fichier avec l'extension `.MD`. -->

<!-- Le plus simple est de débuter avec un éditeur de texte en ligne qui vous montre le résultat en temps réel et permet d'exporter en HTML ou en PDF. -->

Mon choix : <https://dillinger.io/>

---

## Pour aller plus loin

![bg left:30% height:200px](https://user-images.githubusercontent.com/674621/71187801-14e60a80-2280-11ea-94c9-e56576f76baf.png)

Visual Studio Code propose en plus  :

- vérification syntaxique
- sommaires automatiques
- personnalisation du CSS
- utilisation de framework

---

## Lecture des fichiers

![bg right:30% height:200px](https://techlab-handicap.org/wp-content/uploads/2022/07/logo_powertoys-600x600.png)

Recommandation : "File Explorer add-ons utility" dans PowerToys 

<!-- pour lire les fichiers directement depuis l'explorateur de fichiers -->

---

![height:600px](https://www.ghacks.net/wp-content/uploads/2020/04/markdown-viewer.webp)

---

## Quid de PowerShell

`ConvertFrom-Markdown` en PowerShell v7 

<!-- pour convertir un fichier Markdown en HTML. -->

![bg left:24% height:200px](https://se.ewi.tudelft.nl/desosa2019/chapters/powershell/images/powershell/PowerShellLogo.png)

---

### Exemple d'utilisation

Meilleure gestion de l'envoi de mail (découpage en couches) :

- le texte en Markdown
- le modèle en HTML & CSS

<!-- PowerShell fait ensuite l'assemblage des différents fichiers. Ce setup est idéal dans les contextes multilingues. -->

---

```
📁 content
  📄 EN-us.md
  📄 ES-es.md
  📄 FR-fr.md
  📄 PT-br.md
🌐 layout.html
```

```powershell
switch ($country) {
    "BR"    { $path = Get-Item -Path '.\content\PT-br.md' }
    "ES"    { $path = Get-Item -Path '.\content\ES-es.md' }
    "FR"    { $path = Get-Item -Path '.\content\FR-fr.md' }
    default { $path = Get-Item -Path '.\content\EN-us.md' }
}

$content = Get-Content -Path $path -Encoding UTF8bom | ConvertFrom-Markdown
$body = Get-Content -Path '.\layout.html' -Encoding UTF8bom
$body = $body -replace '{{ CONTENT }}',$content

Send-MailMessage ...
```

---

## Autres usages

- Monter un wiki facilement avec [MkDocs](https://www.mkdocs.org/)
- Faire des présentations comme celle-ci avec [Marp](https://www.youtube.com/watch?v=EzQ-p41wNEE&t=7s)
- Faire un blog gratuit avec [GitHub Pages](https://pages.github.com/)

---

## Et voilà !

Vous connaissez \
maintenant le Markdown !

![bg opacity](https://purepng.com/public/uploads/large/purepng.com-happy-menmanpeoplepersonsmalehappy-1121525115957xszkl.png)