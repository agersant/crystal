---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputSystem:mouse_pressed

Routes a mouse press event to the relevant [mouse areas](mouse_area).

When using an [InputSystem](input_system) in a scene that makes use of [MouseArea](mouse_area) components, you should be calling this function from [Scene:mouse_pressed](/crystal/api/scene/scene_mouse_pressed).

## Usage

```lua
input_system:mouse_pressed(x, y, button, is_touch, presses)
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

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.input_system = self.ecs:add_system(crystal.InputSystem);
end

MyScene.mouse_pressed = function(self, x, y, button, is_touch, presses)
  self.input_system:mouse_pressed(x, y, button, is_touch, presses);
end

MyScene.mouse_released = function(self, x, y, button, is_touch, presses)
  self.input_system:mouse_released(x, y, button, is_touch, presses);
end
```
