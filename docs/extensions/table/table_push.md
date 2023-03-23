---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.push

Adds an element at the end of a list.

## Usage

```lua
table.push(list, value)
```

### Arguments

| Name   | Type    | Description             |
| :----- | :------ | :---------------------- |
| `list` | `table` | List to add a value to. |

## Examples

```lua
local list = { "fairy", "demon", "elf", "dragon" };
table.push(list, "mimic");
print(list[5]); -- Prints "mimic"
```
