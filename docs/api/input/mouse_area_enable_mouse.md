---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# MouseArea:enable_mouse

Allows this component to be the mouse target and receive click-related events.

## Usage

```lua
mouse_area:enable_mouse()
```

## Examples

This example creates an entity with two mouse areas that can only be clicked in alternance.

```lua
local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);
local draw_system = ecs:add_system(crystal.DrawSystem);

local entity = ecs:spawn(crystal.Entity);
local circle_area = entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));
local rectangle_area = entity:add_component(crystal.MouseArea, love.physics.newRectangleShape(20, 10));

circle_area:set_draw_offset(40, 0);
rectangle_area:set_draw_offset(-40, 0);

circle_area.on_mouse_clicked = function(self, player_index)
  print("Clicked circle");
  rectangle_area:enable_mouse();
  circle_area:disable_mouse();
end

rectangle_area.on_mouse_clicked = function(self, player_index)
  print("Clicked rectangle");
  circle_area:enable_mouse();
  rectangle_area:disable_mouse();
end
```
