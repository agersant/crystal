---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.distance

Computes the distance between two 2D points.

## Usage

```lua
math.distance(x1, y1, x2, y2)
```

### Arguments

| Name | Type     | Description                        |
| :--- | :------- | :--------------------------------- |
| `x1` | `number` | X coordinate of the first vector.  |
| `y1` | `number` | Y coordinate of the first vector.  |
| `x2` | `number` | X coordinate of the second vector. |
| `y2` | `number` | Y coordinate of the second vector. |

### Returns

| Name     | Type     | Description                      |
| :------- | :------- | :------------------------------- |
| `result` | `number` | Distance between the two points. |

## Examples

```lua
local d = math.distance(1, 0, 11, 0);
print(d); -- Prints "10"
```
