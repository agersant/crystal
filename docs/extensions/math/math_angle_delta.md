---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.angle_delta

Returns the shortest rotation between two angles. The result is in radians, within `-math.pi` and `math.pi`.

## Usage

```lua
math.angle_delta(angle_1, angle_2)
```

### Arguments

| Name      | Type     | Description   |
| :-------- | :------- | :------------ |
| `angle_1` | `number` | First angle.  |
| `angle_2` | `number` | Second angle. |

### Returns

| Name    | Type     | Description                                      |
| :------ | :------- | :----------------------------------------------- |
| `delta` | `number` | Rotation from `angle_1` to `angle_2` in radians. |

## Examples

```lua
local delta = math.angle_delta(math.pi / 4, math.pi / 2);
print(math.deg(delta)); -- Prints "45"
```
