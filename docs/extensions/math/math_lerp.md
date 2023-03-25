---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.lerp

Linear interpolation between two numbers.

## Usage

```lua
math.lerp(from, to, parameter)
```

### Arguments

| Name        | Type     | Description                                             |
| :---------- | :------- | :------------------------------------------------------ |
| `from`      | `number` | First bound.                                            |
| `to`        | `number` | Second bound.                                           |
| `parameter` | `number` | Parameter for the interpolation, often between 0 and 1. |

### Returns

## Examples

```lua
local lerped = math.lerp(50, 100, .5);
print(lerped); -- Prints "75"
```

```lua
local lerped = math.lerp(50, 100, 2);
print(lerped); -- Prints "150"
```
