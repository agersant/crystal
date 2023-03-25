---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.length

Computes the length of a 2D vector.

## Usage

```lua
math.length(x, y)
```

### Arguments

| Name | Type     | Description                 |
| :--- | :------- | :-------------------------- |
| `x`  | `number` | X coordinate of the vector. |
| `y`  | `number` | Y coordinate of the vector. |

### Returns

| Name     | Type     | Description    |
| :------- | :------- | :------------- |
| `length` | `number` | Vector length. |

## Examples

```lua
local d = math.length(0, 5);
print(d); -- Prints "5"
```
