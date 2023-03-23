---
parent: crystal.table
grand_parent: Lua Extensions
nav_order: 1
---

# table.count

Returns the number of `(key, value)` pairs in a table.

## Usage

```lua
table.count(my_table)
```

### Arguments

| Name       | Type    | Description                 |
| :--------- | :------ | :-------------------------- |
| `my_table` | `table` | Table to count values from. |

### Returns

| Name    | Type     | Description                                  |
| :------ | :------- | :------------------------------------------- |
| `count` | `number` | Number of `(key, value)` pairs in the table. |

## Examples

```lua
local creatures = { "fairy", "mole", "wolf" };
print(table.count(creatures)); -- Prints "3"
```

```lua
local weaknesses = { fairy = "dark", mole = "water" };
print(table.count(weaknesses)); -- Prints "2"
```
