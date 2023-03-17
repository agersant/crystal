---
parent: crystal.table
grand_parent: API Reference
nav_order: 1
---

# table.copy

Returns a shallow copy of a table.

## Usage

```lua
table.copy(my_table)
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
local original = { 1, 2, 3};
local copy = table.copy(original);
table.push(copy, 4);
print(original[4]); -- Prints "nil"
print(copy[4]); -- Prints "4"
```

```lua
local party = { hero = { hp = 100, mp = 20 } };
local copy = table.copy(party);
copy.hero.hp = 40;
print(copy.hero.hp); -- Prints "40"
print(party.hero.hp); -- Prints "40" ⚠ Shallow copy does not copy nested tables!
```
