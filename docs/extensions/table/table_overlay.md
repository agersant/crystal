---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.overlay

Writes all the `(key, value)` pairs from a table into an existing table.

## Usage

```lua
table.overlay(destination, source)
```

### Arguments

| Name          | Type    | Description                               |
| :------------ | :------ | :---------------------------------------- |
| `destination` | `table` | Table receiving new `(key, value)` pairs. |
| `source`      | `table` | Table providing `(key, value)` pairs.     |

## Examples

```lua
local summon_levels = { elf = 6, jellyfish = 2, wolves = 2 };
table.overlay(summon_levels, { wolves = 3, warhawk = 1 });
print(summon_levels.jellyfish); -- Prints "2"
print(summon_levels.wolves); -- Prints "3"
print(summon_levels.warhawk); -- Prints "1"
```
