---
parent: crystal.table
grand_parent: API Reference
nav_order: 1
---

# table.map

Creates a new table by running all the values of a reference table through a transformation function.

## Usage

```lua
table.map(my_table, transform)
```

### Arguments

| Name        | Type                        | Description         |
| :---------- | :-------------------------- | :------------------ |
| `my_table`  | `table`                     | Original table.     |
| `transform` | `function(value: any): any` | Transform function. |

### Returns

| Name     | Type    | Description                        |
| :------- | :------ | :--------------------------------- |
| `mapped` | `table` | Table with all values transformed. |

## Examples

```lua
local original = { 10, 20 };
local squared = table.map(original, function(v) return v * v; end);
print(squared[2]); -- Prints "400"
```
