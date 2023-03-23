---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.contains

Returns whether a table contains a specific value.

## Usage

```lua
table.contains(my_table, value)
```

### Arguments

| Name       | Type    | Description                                   |
| :--------- | :------ | :-------------------------------------------- |
| `my_table` | `table` | Table which may or may not contain the value. |
| `value`    | `any`   | Value to look for in the table.               |

### Returns

| Name       | Type      | Description                                             |
| :--------- | :-------- | :------------------------------------------------------ |
| `contains` | `boolean` | True if the value exists in the table, false otherwise. |

## Examples

```lua
local buffs = { "regen", "poison", "blind" };
print(table.contains(buffs, "blind")); -- Prints "true"
print(table.contains(buffs, "stun")); -- Prints "false"
```

```lua
local monster_hp = { dragon = 1800, bandit = 100, bat = 8 };
print(table.contains(monster_hp, 1800)); -- Prints "true"
print(table.contains(monster_hp, 500)); -- Prints "false"
```
