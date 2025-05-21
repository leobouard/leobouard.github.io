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

<table style="border-collapse: collapse; width: 100%;">
  <caption style="font-weight: bold; font-size: 1.3em; margin-bottom: 0.5em;">
    Exemple de matrice des risques 5x5
  </caption>
  <thead>
    <tr>
      <td colspan="2"></td>
      <td colspan="5">
        <div style="text-align: center;">
          <span style="font-weight: bold;">Impact</span><br>
          <small>Quelle serait la gravité des conséquences si le risque se produisait ?</small>
        </div>
      </td>
    </tr>
    <tr style="text-align: center;">
      <td colspan="2"></td>
      <th>Insignifiant<br>1</th>
      <th>Mineur<br>2</th>
      <th>Significatif<br>3</th>
      <th>Majeur<br>4</th>
      <th>Sévère<br>5</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td rowspan="5">
        <div style="writing-mode: vertical-rl; transform: rotate(180deg); text-align: center; margin: auto;">
          <span style="font-weight: bold;">Probabilité</span><br>
          <small>Quelle est la probabilité que le risque se produise ?</small>
        </div>
      </td>
      <th style="font-weight: bold;">Presque certain<br>5</th>
      <td style="background: #fced57;">Moyen<br>5</td>
      <td style="background: #fc9c2e;">Élevé<br>10</td>
      <td style="background: #f24d3e;">Très élevé<br>15</td>
      <td style="background: #f24d3e;">Très élevé<br>20</td>
      <td style="background: #f24d3e;">Très élevé<br>25</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Probable<br>4</th>
      <td style="background: #88c357;">Faible<br>4</td>
      <td style="background: #fced57;">Moyen<br>8</td>
      <td style="background: #fc9c2e;">Élevé<br>12</td>
      <td style="background: #f24d3e;">Très élevé<br>16</td>
      <td style="background: #f24d3e;">Très élevé<br>20</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Modéré<br>3</th>
      <td style="background: #88c357;">Faible<br>3</td>
      <td style="background: #fced57;">Moyen<br>6</td>
      <td style="background: #fced57;">Moyen<br>9</td>
      <td style="background: #fc9c2e;">Élevé<br>12</td>
      <td style="background: #f24d3e;">Très élevé<br>15</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Rare<br>2</th>
      <td style="background: #49ae58;">Très faible<br>2</td>
      <td style="background: #88c357;">Faible<br>4</td>
      <td style="background: #fced57;">Moyen<br>6</td>
      <td style="background: #fced57;">Moyen<br>8</td>
      <td style="background: #fc9c2e;">Élevé<br>10</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Improbable<br>1</th>
      <td style="background: #49ae58;">Très faible<br>1</td>
      <td style="background: #49ae58;">Très faible<br>2</td>
      <td style="background: #88c357;">Faible<br>3</td>
      <td style="background: #88c357;">Faible<br>4</td>
      <td style="background: #fced57;">Moyen<br>5</td>
    </tr>
  </tbody>
</table>

### Risque très faible

{% include risk-score.html
    impact=1
    probability=1
    comment="Lorem ipsum dolor sit amet.<br>Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit <b>praesentium consequatur</b> eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque faible

{% include risk-score.html
    impact=3
    probability=1
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque moyen

{% include risk-score.html
    impact=5
    probability=1
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque élevé

{% include risk-score.html
    impact=5
    probability=2
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque très élevé

{% include risk-score.html
    impact=5
    probability=3
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}
