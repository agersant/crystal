---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.cross_product

Computes the length of the cross product between two `(x1, y1, 0)` and `(x2, y2, 0)`.

## Usage

```lua
math.cross_product(x1, y1, x2, y2)
```

### Arguments

| Name | Type     | Description                        |
| :--- | :------- | :--------------------------------- |
| `x1` | `number` | X coordinate of the first vector.  |
| `y1` | `number` | Y coordinate of the first vector.  |
| `x2` | `number` | X coordinate of the second vector. |
| `y2` | `number` | Y coordinate of the second vector. |

### Returns

| Name     | Type     | Description                  |
| :------- | :------- | :--------------------------- |
| `result` | `number` | Length of the cross product. |

## Examples

```lua
local cross_product = math.cross_product(0, 1, -2, 0);
print(cross_product); -- Prints "2"
```
