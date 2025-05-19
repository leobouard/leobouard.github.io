---
permalink: /test
title: "Test"
description: "Page de test"
---

## Matrice de risque

### Gradation

Risque | Range
------ | -----
Très faible | de 0 à 2
Faible | de 3 à 4
Moyen | de 5 à 9
Élevé | de 10 à 14
Très élevé | plus de 15

### Tableau

<table style="border-collapse: collapse; text-align: center; font-family: sans-serif;">
  <caption style="font-weight: bold; font-size: 1.3em; margin-bottom: 0.5em;">
    Exemple de matrice des risques 5x5
  </caption>
  <thead>
    <tr>
      <td colspan="2"></td>
      <td colspan="5">
        <div style="text-align: center;">
          <span style="font-weight: bold;">Impact</span><br>
          <small">Quelle serait la gravité des conséquences si le risque se produisait ?</small>
        </div>
      </td>
    </tr>
    <tr style="text-align: center;">
      <th colspan="2"></th>
      <th>Insignifiante<br>1</th>
      <th>Mineure<br>2</th>
      <th>Significative<br>3</th>
      <th>Majeure<br>4</th>
      <th>Sévère<br>5</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="5">
        <div style="writing-mode: vertical-rl; transform: rotate(180deg); text-align: center;">
          <span style="font-weight: bold;">Probabilité</span><br>
          <small">Quelle est la probabilité que le risque se produise ?</small>
        </div>
      </td>
      <th style="font-weight: bold;">5<br>Presque certain</th>
      <td style="background: #ffeb3b;">Moyen<br>5</td>
      <td style="background: #ff9800;">Élevé 10</td>
      <td style="background: #f44336;">Très élevé 15</td>
      <td style="background: #d32f2f;">Extrême 20</td>
      <td style="background: #d32f2f;">Extrême 25</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">4<br>Probable</th>
      <td style="background: #ffeb3b;">Moyen 4</td>
      <td style="background: #ffeb3b;">Moyen 8</td>
      <td style="background: #ff9800;">Élevé 12</td>
      <td style="background: #f44336;">Très élevé 16</td>
      <td style="background: #d32f2f;">Extrême 20</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">3<br>Modéré</th>
      <td style="background: #8bc34a;">Faible 3</td>
      <td style="background: #ffeb3b;">Moyen 6</td>
      <td style="background: #ffeb3b;">Moyen 9</td>
      <td style="background: #ff9800;">Élevé 12</td>
      <td style="background: #f44336;">Très élevé 15</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">2<br>Improbable</th>
      <td style="background: #4caf50; color: #fff;">Très faible 2</td>
      <td style="background: #8bc34a;">Faible 4</td>
      <td style="background: #ffeb3b;">Moyen 6</td>
      <td style="background: #ffeb3b;">Moyen 8</td>
      <td style="background: #ff9800;">Élevé 10</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">1<br>Rare</th>
      <td style="background: #4caf50;">Très faible 1</td>
      <td style="background: #4caf50;">Très faible 2</td>
      <td style="background: #8bc34a;">Faible 3</td>
      <td style="background: #ffeb3b;">Moyen 4</td>
      <td style="background: #ffeb3b;">Moyen 5</td>
    </tr>
  </tbody>
</table>

### Risque très faible

{% include risk-matrix.html
    impact=1
    probability=1
    comment="Lorem ipsum dolor sit amet.<br>Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit <b>praesentium consequatur</b> eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque faible

{% include risk-matrix.html
    impact=3
    probability=1
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque moyen

{% include risk-matrix.html
    impact=5
    probability=1
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque élevé

{% include risk-matrix.html
    impact=5
    probability=2
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque très élevé

{% include risk-matrix.html
    impact=5
    probability=3
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

## Disclaimer

{% include disclaimer.html
    content="KCLAD (<i>à lire Casser l'AD</i>) est une série d'articles techniques sur des trucs idiots à faire dans un domaine Active Directory. L'idée est de torturer un peu une maquette et essayer de mieux comprendre comment fonctionne Active Directory.<br>
    <b>A ne pas reproduire sur la production, évidemment !</b>"
%}
