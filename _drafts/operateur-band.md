
## Les bit fields

Les bit fields (ou champs de bits en français) sont des attributs qui stockent plusieurs informations (options, états, permissions…) sous forme de bits individuels dans un seul nombre entier.

Chaque bit (ou combinaison de bits) représente une option ou une propriété différente. Le nombre entier final correspond à l'addition de toutes les options entre-elles.

On parle aussi parfois d’attributs à indicateurs ou d’attributs à valeurs de drapeaux.

On en retrouve quelques exemples dans Active Directory :

- `searchFlags`
- `userAccountControl`
- `systemFlags`

### Cas pratique

Voici un exemple de tableau de valeurs pour un attribut fictif :

| Value | Description |
| --- | --- |
| 1 (0x00000001) | When applied to an attribute, the attribute will not be replicated.When applied to a Cross-Ref object, the naming context is in NTDS. |
| 2 (0x00000002) | When applied to an attribute, the attribute will be replicated to the global catalog.When applied to a Cross-Ref object, the naming context is a domain. |
| 4 (0x00000004) | When applied to an attribute, the attribute is constructed. |
| 16 (0x00000010) | When set, indicates the object is a category 1 object. A category 1 object is a class or attribute that is included in the base schema included with the system. |
| 33554432 (0x02000000) | The object is not moved to the Deleted Objects container when it is deleted. It will be deleted immediately. |
| 67108864 (0x04000000) | The object cannot be moved. |
| 134217728 (0x08000000) | The object cannot be renamed. |
| 268435456 (0x10000000) | For objects in the configuration partition, if this flag is set, the object can be moved with restrictions; otherwise, the object cannot be moved. By default, this flag is not set on new objects created under the configuration partition. This flag can only be set during object creation. |
| 536870912 (0x20000000) | For objects in the configuration partition, if this flag is set, the object can be moved; otherwise, the object cannot be moved. By default, this flag is not set on new objects created under the configuration partition. This flag can only be set during object creation. |
| 1073741824 (0x40000000) | For objects in the configuration partition, if this flag is set, the object can be renamed; otherwise, the object cannot be renamed. By default, this flag is not set on new objects created under the configuration partition. This flag can only be set during object creation. |
| 2147483648 (0x80000000) | The object cannot be deleted. |

Comme les valeurs vont par puissance de deux, il est impossible que plusieurs combinaisons d'options donnent le même résultat :

- `1 + 2 = 3` donc pas de collision avec l'option #C
- `1 + 2 + 4 = 7` donc pas de collision avec l'option #D

On peut donc stocker 

### Utilisation de l'opérateur -band

### Sans utiliser l'opérateur -band

### Différence avec DSHeuristics

Le champ DSHeuristics, même si il contient un nombre entier qui en apparence ne veut pas dire grand-chose, n'est pas un bitfield ! Ici ce n'est pas la 

