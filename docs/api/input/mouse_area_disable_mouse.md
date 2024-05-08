---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# MouseArea:disable_mouse

Prevents this component from being the mouse target or receiving click-related events.

If the component previously executed its `on_mouse_over` callback, it will execute `on_mouse_out` on the next call to [InputSystem:update_mouse_target](input_system_update_mouse_target).

## Usage

```lua
mouse_area:disable_mouse()
```

## Examples

This example creates a `MouseArea` that can only be clicked once.

```lua
local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);
local draw_system = ecs:add_system(crystal.DrawSystem);

local entity = ecs:spawn(crystal.Entity);
local mouse_area = entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));

mouse_area.on_mouse_clicked = function(self, player_index)
  self:disable_mouse();
end
```
