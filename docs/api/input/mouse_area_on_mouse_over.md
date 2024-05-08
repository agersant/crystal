---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# MouseArea:on_mouse_over

Called when this component becomes the mouse target.

## Usage

```lua
mouse_area.on_mouse_over = function(self, player_index)
  -- your code here
end
```

### Arguments

| Name           | Type     | Description                  |
| :------------- | :------- | :--------------------------- |
| `player_index` | `number` | Number identifying a player. |

## Examples

```lua
local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);
local draw_system = ecs:add_system(crystal.DrawSystem);

local entity = ecs:spawn(crystal.Entity);
local mouse_area = entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));

mouse_area.on_mouse_over = function(self, player_index)
  print("Mouse now inside");
end

mouse_area.on_mouse_out = function(self, player_index)
  print("Mouse now outside");
end
```
