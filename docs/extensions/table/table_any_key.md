---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.append

Returns a single unspecified key from the table.

## Usage

```lua
table.any_key(my_table)
```

### Arguments

| Name         | Type    | Description                                                  |
| :----------- | :------ | :----------------------------------------------------------- |
| `my_table`   | `table` | The table to get a key from.                                 |

## Examples

```lua
local my_table = { a = 0, b = 1 };
print(table.any_key(my_table)); -- Prints "a" or "b"

local my_table = { "a", "a", "a" };
print(table.any_key(my_table)); -- Prints 1, 2 or 3
```
