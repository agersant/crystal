---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.angle_to_cardinal

Converts an angle into the closest cardinal directions (including intercardinals).

## Usage

```lua
math.angle_to_cardinal(angle)
```

### Arguments

| Name    | Type     | Description       |
| :------ | :------- | :---------------- |
| `angle` | `number` | Angle in radians. |

### Returns

| Name | Type     | Description                                                       |
| :--- | :------- | :---------------------------------------------------------------- |
| `x`  | `number` | X component of the closest cardinal direction: `-1`, `0`, or `1`. |
| `y`  | `number` | Y component of the closest cardinal direction: `-1`, `0`, or `1`. |

## Examples

```lua
local x, y = math.angle_to_cardinal(math.pi / 4);
print(x, y); -- Prints "1, -1"
```

```lua
local x, y = math.angle_to_cardinal(math.pi);
print(x, y); -- Prints "-1, 0"
```
