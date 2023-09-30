---
parent: crystal.scene
grand_parent: API Reference
nav_exclude: true
---

# Scene:mouse_released

Called from [love.mousereleased](https://love2d.org/wiki/love.mousereleased).

## Usage

```lua
scene:mouse_released(x, y, button, is_touch, presses)
```

### Arguments

| Name       | Type     | Description                                                                                                                                                         |
| :--------- | :------- | :------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `x`        | `number` | Mouse x position, in pixels.                                                                                                                                        |
| `y`        | `number` | Mouse y position, in pixels.                                                                                                                                        |
| `button`   | `number` | The button index that was released. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent. |
| `is_touch` | `number` | True if the mouse button release originated from a touchscreen touch-release.                                                                                       |
| `presses`  | `number` | The number of presses in a short time frame and small area, used to simulate double, triple clicks.                                                                 |

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.mouse_released = function(self, x, y, button, is_touch, presses)
  print(x, y);
end
```
