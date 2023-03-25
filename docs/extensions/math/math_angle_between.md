---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.angle_between

Returns the shortest rotation between two vectors. The result is in radians, within `-math.pi` and `math.pi`.

## Usage

```lua
math.angle_between(x1, y1, x2, y2)
```

### Arguments

| Name | Type     | Description                        |
| :--- | :------- | :--------------------------------- |
| `x1` | `number` | X coordinate of the first vector.  |
| `y1` | `number` | Y coordinate of the first vector.  |
| `x2` | `number` | X coordinate of the second vector. |
| `y2` | `number` | Y coordinate of the second vector. |

### Returns

| Name    | Type     | Description       |
| :------ | :------- | :---------------- |
| `angle` | `number` | Angle in radians. |

## Examples

```lua
local angle = math.angle_between(0, 1, 2, 0);
print(math.deg(angle)); -- Prints "-90"
```
