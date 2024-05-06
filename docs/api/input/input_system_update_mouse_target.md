---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# InputSystem:update_mouse_target

Execute hover-related callbacks on [mouse areas](mouse_area) according to current cursor position.

When using an [InputSystem](input_system) in a scene that makes use of [MouseArea](mouse_area) components, you should be calling this function on mouse move and, optionally, during scene update.

## Usage

```lua
input_system:update_mouse_target()
```

## Examples

```lua
local MyScene = Class("MyScene", crystal.Scene);

MyScene.init = function(self)
  self.ecs = crystal.ECS:new();
  self.input_system = self.ecs:add_system(crystal.InputSystem);
end

MyScene.update = function(self, dt)
  self.input_system:update_mouse_target(); -- Triggers mouse over events when the mouse isn't moving but possible targets are
end

MyScene.mouse_moved = function(self, x, y, dx, dy, is_touch)
  self.input_system:update_mouse_target();
end
```
