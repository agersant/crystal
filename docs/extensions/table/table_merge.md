---
parent: crystal.table
grand_parent: Lua Extensions
nav_order: 1
---

# table.merge

Creates a new table containing all `(key, value)` pairs from two tables. If two source tables have shared keys, the values associated with these keys in the merged table will be from the second table argument (referred to as `table_b` below).

## Usage

```lua
table.merge(table_a, table_b)
```

### Arguments

| Name      | Type    | Description            |
| :-------- | :------ | :--------------------- |
| `table_a` | `table` | First table to merge.  |
| `table_b` | `table` | Second table to merge. |

### Returns

| Name     | Type    | Description   |
| :------- | :------ | :------------ |
| `merged` | `table` | Merged table. |

## Examples

```lua
local backpack = { rock = 10, flint = 2, herb = 63 };
local chest = { flint = 5, potion = 1 };
local merged = table.merge(backpack, chest);
print(merged.rock); -- Prints "10"
print(merged.flint); -- Prints "5"
print(merged.potion); -- Prints "1"
```
