---
permalink: /riskmatrix
title: "Matrice de risque"
description: "Correspondance entre l'impact et la probabilité pour établir un score de risque"
---

## Tableau

<table style="border-collapse: collapse; width: 100%;">
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
      <td style="background: #ffeb3b; color: black;">Moyen<br>5</td>
      <td style="background: #ff9800; color: black;">Élevé<br>10</td>
      <td style="background: #f44336; color: black;">Très élevé<br>15</td>
      <td style="background: #f44336; color: black;">Très élevé<br>20</td>
      <td style="background: #f44336; color: black;">Très élevé<br>25</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Probable<br>4</th>
      <td style="background: #8bc34a; color: black;">Faible<br>4</td>
      <td style="background: #ffeb3b; color: black;">Moyen<br>8</td>
      <td style="background: #ff9800; color: black;">Élevé<br>12</td>
      <td style="background: #f44336; color: black;">Très élevé<br>16</td>
      <td style="background: #f44336; color: black;">Très élevé<br>20</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Modéré<br>3</th>
      <td style="background: #8bc34a; color: black;">Faible<br>3</td>
      <td style="background: #ffeb3b; color: black;">Moyen<br>6</td>
      <td style="background: #ffeb3b; color: black;">Moyen<br>9</td>
      <td style="background: #ff9800; color: black;">Élevé<br>12</td>
      <td style="background: #f44336; color: black;">Très élevé<br>15</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Rare<br>2</th>
      <td style="background: #4caf50; color: black;">Très faible<br>2</td>
      <td style="background: #8bc34a; color: black;">Faible<br>4</td>
      <td style="background: #ffeb3b; color: black;">Moyen<br>6</td>
      <td style="background: #ffeb3b; color: black;">Moyen<br>8</td>
      <td style="background: #ff9800; color: black;">Élevé<br>10</td>
    </tr>
    <tr>
      <th style="font-weight: bold;">Improbable<br>1</th>
      <td style="background: #4caf50; color: black;">Très faible<br>1</td>
      <td style="background: #4caf50; color: black;">Très faible<br>2</td>
      <td style="background: #8bc34a; color: black;">Faible<br>3</td>
      <td style="background: #8bc34a; color: black;">Faible<br>4</td>
      <td style="background: #ffeb3b; color: black;">Moyen<br>5</td>
    </tr>
  </tbody>
</table>

### Gradation

Risque | Range
------ | -----
Très faible | de 0 à 2
Faible | de 3 à 4
Moyen | de 5 à 9
Élevé | de 10 à 14
Très élevé | plus de 15

<script>
document.addEventListener("DOMContentLoaded", () => {
  const items = document.querySelectorAll("li.task-list-item");
  items.forEach(item => {
    item.addEventListener("click", () => {
      const checkbox = item.querySelector('input[type="checkbox"]');
      if (checkbox.checked) {
        item.classList.add("good-answer");
        item.innerHTML += '<i class="fa-solid fa-circle-check"></i>';
      } else {
        item.classList.add("bad-answer");
        item.innerHTLM += '<i class="fa-solid fa-circle-xmark"></i>';
      }
    });
  });
});
</script>

### Test de question

Question n°1

- [ ] Réponse A
- [ ] Réponse B
- [x] La bonne réponse
- [ ] Réponse D
