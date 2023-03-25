---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.length_squared

Computes the squared length of a 2D vector.

## Usage

```lua
math.length_squared(x, y)
```

### Arguments

| Name | Type     | Description                 |
| :--- | :------- | :-------------------------- |
| `x`  | `number` | X coordinate of the vector. |
| `y`  | `number` | Y coordinate of the vector. |

### Returns

| Name             | Type     | Description            |
| :--------------- | :------- | :--------------------- |
| `length_squared` | `number` | Vector length squared. |

## Examples

```lua
local d = math.length_squared(0, 5);
print(d); -- Prints "25" (5^2)
```
