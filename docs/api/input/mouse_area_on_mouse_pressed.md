---
parent: crystal.input
grand_parent: API Reference
nav_exclude: true
---

# MouseArea:on_mouse_pressed

Called when a mouse button is pressed within this component.

## Usage

```lua
mouse_area.on_mouse_pressed = function(self, player_index, button)
  -- your code here
end
```

### Arguments

| Name           | Type     | Description                                                                                                                                                        |
| :------------- | :------- | :----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `player_index` | `number` | Number identifying a player.                                                                                                                                       |
| `button`       | `number` | The button index that was pressed. 1 is the primary mouse button, 2 is the secondary mouse button and 3 is the middle button. Further buttons are mouse dependent. |

## Examples

```lua
local ecs = crystal.ECS:new();
local input_system = ecs:add_system(crystal.InputSystem);
local draw_system = ecs:add_system(crystal.DrawSystem);

local entity = ecs:spawn(crystal.Entity);
local mouse_area = entity:add_component(crystal.MouseArea, love.physics.newCircleShape(10));

mouse_area.on_mouse_pressed = function(self, player_index, button)
  print("Button " .. button .. " pressed");
end

mouse_area.on_mouse_released = function(self, player_index, button)
  print("Button " .. button .. " released");
end
```
