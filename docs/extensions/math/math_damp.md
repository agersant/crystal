---
parent: Math Extensions
grand_parent: Lua Extensions
nav_order: 1
---

# math.damp

Exponential decay interpolation. This function allows you to interpolate a number towards a target value, with exponential decay. The target value may be different between frames.

A smooting parameter of 0 will instantly jump to the target value. A smoothing parameter of 1 will never leave the current value.

[Reference Article](https://www.rorydriscoll.com/2016/03/07/frame-rate-independent-damping-using-lerp/)

## Usage

```lua
math.damp(current, target, smoothing, dt)
```

### Arguments

| Name        | Type     | Description                                |
| :---------- | :------- | :----------------------------------------- |
| `current`   | `number` | Current value to adjust.                   |
| `target`    | `number` | Target value.                              |
| `smoothing` | `number` | Smoothing amount anywhere between 0 and 1. |
| `dt`        | `number` | Frame duration in seconds.                 |

### Returns

| Name     | Type     | Description         |
| :------- | :------- | :------------------ |
| `result` | `number` | Interpolated value. |

## Examples

```lua
local current = 0;
local target = 100;
MyScene.update = function(dt)
  current = math.damp(current, target, 0.5, dt);
  print(current); -- Prints value getting closer to 100 over time,
end
```
