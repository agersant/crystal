---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.dot_product

Computes the dot product between 2D vectors.

## Usage

```lua
math.dot_product(x1, y1, x2, y2)
```

### Arguments

| Name | Type     | Description                        |
| :--- | :------- | :--------------------------------- |
| `x1` | `number` | X coordinate of the first vector.  |
| `y1` | `number` | Y coordinate of the first vector.  |
| `x2` | `number` | X coordinate of the second vector. |
| `y2` | `number` | Y coordinate of the second vector. |

### Returns

| Name     | Type     | Description         |
| :------- | :------- | :------------------ |
| `result` | `number` | Dot product result. |

## Examples

```lua
local dp = math.dot_product(1, 0, 0, 1);
print(dp); -- Prints "0"
```

```lua
local dp = math.dot_product(1, 0, 2, 0);
print(dp); -- Prints "2"
```
