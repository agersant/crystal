---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:mouse_moved

Called from [love.mousemoved](https://love2d.org/wiki/love.mousemoved).

## Usage

```lua
scene:mouse_moved(x, y, dx, dy, is_touch)
```

### Arguments

| Name       | Type     | Description                                                                       |
| :--------- | :------- | :-------------------------------------------------------------------------------- |
| `x`        | `number` | The mouse position on the x-axis.                                                 |
| `y`        | `number` | The mouse position on the y-axis.                                                 |
| `dx`       | `number` | The amount moved along the x-axis since the last time love.mousemoved was called. |
| `dy`       | `number` | The amount moved along the y-axis since the last time love.mousemoved was called. |
| `is_touch` | `number` | True if the mouse move originated from a touchscreen touch-press.                 |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.mouse_moved = function(self, x, y, dx, dy, is_touch)
  print(x, y);
end
```
