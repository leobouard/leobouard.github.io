---
permalink: /test
title: "Test"
description: "Page de test"
---

## Matrice de risque

### Risque très faible

{% include
    risk-matrix.html
    impact=1
    probability=1
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque faible

{% include
    risk-matrix.html
    impact=3
    probability=1
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque moyen

{% include
    risk-matrix.html
    impact=5
    probability=1
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque élevé

{% include
    risk-matrix.html
    impact=3
    probability=3
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}

### Risque très élevé

{% include
    risk-matrix.html
    impact=5
    probability=5
    comment="Lorem ipsum dolor sit amet. Ab ipsum quam eum dicta atque in aspernatur voluptate. A ipsa magnam sit praesentium consequatur eos quam consequuntur qui repellat veniam qui repellat autem et minima iste?"
%}