---
parent: crystal.table
grand_parent: Lua Extensions
nav_order: 1
---

# table.map

Creates a new table by applying a transformation to all values in a table.

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
