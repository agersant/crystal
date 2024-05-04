---
parent: Table Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# table.append

Adds a list of values at the end of another.

## Usage

```lua
table.append(list, other_list)
```

### Arguments

| Name         | Type    | Description                                                  |
| :----------- | :------ | :----------------------------------------------------------- |
| `list`       | `table` | List to add a value to.                                      |
| `other_list` | `table` | List of values to add. This may be the same table as `list`. |

## Examples

```lua
local list = { 1, 2, 3 };
table.push(list, { 20, 60 });
print(table.concat(list, ", ")); -- Prints "1, 2, 3, 20, 60"
```
