---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.clamp

Clamps a number between a minimum and maximum value. This function will error if `min` > `max`.

## Usage

```lua
math.clamp(value, min, max)
```

### Arguments

| Name    | Type     | Description           |
| :------ | :------- | :-------------------- |
| `value` | `number` | Number to clamp.      |
| `min`   | `number` | Clamping lower bound. |
| `max`   | `number` | Clamping upper bound. |

### Returns

| Name      | Type     | Description    |
| :-------- | :------- | :------------- |
| `clamped` | `number` | Clamped value. |

## Examples

```lua
local clamped = math.clamp(896, 100, 200);
print(clamped); -- Prints "200"
```

```lua
local clamped = math.clamp(-50, 100, 200);
print(clamped); -- Prints "100"
```

```lua
local clamped = math.clamp(125, 100, 200);
print(clamped); -- Prints "125"
```
