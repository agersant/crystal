---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.index_to_xy

Converts an integer into coordinates into a 2D array.

{: .warning}
This function works with 0-based indices, not 1-based!

## Usage

```lua
math.index_to_xy(index, width)
```

### Arguments

| Name    | Type     | Description            |
| :------ | :------- | :--------------------- |
| `index` | `number` | Index to convert.      |
| `width` | `number` | Width of the 2D array. |

### Returns

| Name | Type     | Description                     |
| :--- | :------- | :------------------------------ |
| `x`  | `number` | X coordinate into the 2D array. |
| `y`  | `number` | Y coordinate into the 2D array. |

## Examples

```lua
local x, y = math.index_to_xy(14, 10);
print(x, y); -- Prints "4 1"
```
