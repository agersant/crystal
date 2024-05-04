---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.deep_copy

Returns a deep copy of a table. Unlike [table.copy](table_copy), this function will create an independent copy of all tables nested within the original.

## Usage

```lua
table.deep_copy(my_table)
```

### Arguments

| Name       | Type    | Description    |
| :--------- | :------ | :------------- |
| `my_table` | `table` | Table to copy. |

### Returns

| Name     | Type    | Description        |
| :------- | :------ | :----------------- |
| `copied` | `table` | Copy of the table. |

## Examples

```lua
local party = { hero = { hp = 100, mp = 20 } };
local copy = table.deep_copy(party);
copy.hero.hp = 40;
print(copy.hero.hp); -- Prints "40"
print(party.hero.hp); -- Prints "100"
```
