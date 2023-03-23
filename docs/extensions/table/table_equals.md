---
parent: crystal.table
grand_parent: Lua Extensions
nav_order: 1
---

# table.equals

Returns whether two tables contain the same `(key, value)` pairs. This is a shallow comparison, using the `==` operator on all keys and values.

## Usage

```lua
table.equals(table_a, table_b)
```

### Arguments

| Name      | Type    | Description              |
| :-------- | :------ | :----------------------- |
| `table_a` | `table` | First table to compare.  |
| `table_b` | `table` | Second table to compare. |

### Returns

| Name    | Type      | Description                                                                 |
| :------ | :-------- | :-------------------------------------------------------------------------- |
| `equal` | `boolean` | True if the two tables have the same `(key, value)` pairs, false otherwise. |

## Examples

```lua
local hp_values = { dragon = 200, human = 50, bat = 10 };
local also_hp_values = { human = 50, dragon = 200, bat = 10 };
local different = { human = 780, dragon = -90, bat = 0 };
print(table.equals(hp_values, also_hp_values)); -- Prints "true"
print(table.equals(hp_values, different)); -- Prints "false"
```
