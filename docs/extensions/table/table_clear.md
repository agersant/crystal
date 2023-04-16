---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.clear

Removes all values in a table. This operation has `O(n)` complexity, where `n` is the number of entries in the table.

## Usage

```lua
table.clear(my_table)
```

### Arguments

| Name       | Type    | Description     |
| :--------- | :------ | :-------------- |
| `my_table` | `table` | Table to clear. |

## Examples

```lua
local list = { "fairy", "demon", "elf", "dragon" };
print(#list); -- Prints "4"
table.clear(list);
print(#list); -- Prints "0"
```
