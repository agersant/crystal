---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.pop

Removes the last element of a list.

## Usage

```lua
table.pop(list)
```

### Arguments

| Name   | Type    | Description                  |
| :----- | :------ | :--------------------------- |
| `list` | `table` | List to remove a value from. |

### Returns

| Name     | Type    | Description             |
| :------- | :------ | :---------------------- |
| `popped` | `table` | Value that was removed. |

## Examples

```lua
local list = { "fairy", "demon", "elf", "dragon" };
local popped = table.pop();
print(popped); -- Prints "dragon"
print(#list); -- Prints 3
```
