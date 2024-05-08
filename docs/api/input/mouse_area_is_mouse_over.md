---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# MouseArea:is_mouse_over

Returns whether this component currently is the mouse target.

## Usage

```lua
mouse_area:is_mouse_over()
```

### Returns

| Name      | Type      | Description                                                        |
| :-------- | :-------- | :----------------------------------------------------------------- |
| `is_over` | `boolean` | True if this element is the current mouse target, false otherwise. |

## Examples

```lua
local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);
local draw_system = ecs:add_system(crystal.DrawSystem);

local entity = ecs:spawn(crystal.Entity);
local mouse_area = entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));

mouse_area.on_mouse_over = function(self, player_index)
  print(self:is_mouse_over()); -- Prints "true"
end

mouse_area.on_mouse_out = function(self, player_index)
  print(self:is_mouse_over()); -- Prints "false"
end
```
